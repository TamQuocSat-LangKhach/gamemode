local biantian = fk.CreateSkill {
  name = "jiange__biantian",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["jiange__biantian"] = "变天",
  [":jiange__biantian"] = "锁定技，准备阶段，你进行一次判定，若结果为：<br>红色，所有敌方进入狂风状态（若天侯孔明在场，受到火焰伤害+1），"..
  "直到你下回合开始；<br>♠，所有友方进入大雾状态（若天侯孔明在场，受到非雷电伤害时，防止此伤害），直到你下回合开始。",
}

biantian:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(biantian.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = biantian.name,
      pattern = ".|.|^club",
    }
    room:judge(judge)
    if player.dead then return end
    local mark = {}
    if judge.card.color == Card.Red then
      for _, p in ipairs(player:getEnemies()) do
        room:doIndicate(player, {p})
        room:addPlayerMark(p, "@@kuangfeng", 1)
        table.insert(mark, p.id)
      end
      room:setPlayerMark(player, "_kuangfeng", mark)
    elseif judge.card.suit == Card.Spade then
      for _, p in ipairs(player:getFriends()) do
        room:doIndicate(player, {p})
        room:addPlayerMark(p, "@@dawu", 1)
        table.insert(mark, p.id)
      end
      room:setPlayerMark(player, "_dawu", mark)
    end
  end,
})

biantian:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and (player:getMark("_kuangfeng") ~= 0 or player:getMark("_dawu") ~= 0)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if player:getMark("_kuangfeng") ~= 0 then
      for _, id in ipairs(player:getTableMark("_kuangfeng")) do
        local p = room:getPlayerById(id)
        room:removePlayerMark(p, "@@kuangfeng", 1)
      end
      room:setPlayerMark(player, "_kuangfeng", 0)
    end
    if player:getMark("_dawu") ~= 0 then
      for _, id in ipairs(player:getTableMark("_dawu")) do
        local p = room:getPlayerById(id)
        room:removePlayerMark(p, "@@dawu", 1)
      end
      room:setPlayerMark(player, "_dawu", 0)
    end
  end,
})

biantian:addEffect(fk.DamageInflicted, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return (target:getMark("@@kuangfeng") > 0 and data.damageType == fk.FireDamage and player:getMark("_kuangfeng") ~= 0) or
      (target:getMark("@@dawu") > 0 and data.damageType ~= fk.ThunderDamage and player:getMark("_dawu") ~= 0)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if target:getMark("@@kuangfeng") > 0 and data.damageType == fk.FireDamage and player:getMark("_kuangfeng") ~= 0 then
      room:notifySkillInvoked(player, "kuangfeng", "offensive")
      player:broadcastSkillInvoke("kuangfeng")
      data:changeDamage(1)
    end
    if target:getMark("@@dawu") > 0 and data.damageType ~= fk.ThunderDamage and player:getMark("_dawu") ~= 0 then
      room:notifySkillInvoked(player, "dawu", "defensive")
      player:broadcastSkillInvoke("dawu")
      data:preventDamage()
    end
  end,
})

return biantian
