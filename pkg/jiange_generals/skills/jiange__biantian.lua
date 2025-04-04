local jiange__biantian = fk.CreateSkill {
  name = "jiange__biantian"
}

Fk:loadTranslationTable{
  ['jiange__biantian'] = '变天',
  ['#jiange__biantian_delay'] = '变天',
  [':jiange__biantian'] = '锁定技，准备阶段，你进行一次判定，若结果为：<br>红色，所有敌方进入狂风状态（若天侯孔明在场，受到火焰伤害+1），直到你下回合开始；<br>♠，所有友方进入大雾状态（若天侯孔明在场，受到非雷电伤害时，防止此伤害），直到你下回合开始。',
}

jiange__biantian:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiange__biantian) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = jiange__biantian.name,
      pattern = ".|.|^club",
    }
    room:judge(judge)
    local mark = {}
    if judge.card.color == Card.Red then
      for _, p in ipairs(U.GetEnemies(room, player)) do
        room:doIndicate(player.id, {p.id})
        room:addPlayerMark(p, "@@kuangfeng", 1)
        table.insert(mark, p.id)
      end
      room:setPlayerMark(player, "_kuangfeng", mark)
    elseif judge.card.suit == Card.Spade then
      for _, p in ipairs(U.GetFriends(room, player)) do
        room:doIndicate(player.id, {p.id})
        room:addPlayerMark(p, "@@dawu", 1)
        table.insert(mark, p.id)
      end
      room:setPlayerMark(player, "_dawu", mark)
    end
  end,
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

jiange__biantian:addEffect(fk.DamageInflicted, {
  name = "#jiange__biantian_delay",
  mute = true,
  can_trigger = function (skill, event, target, player, data)
    return (target:getMark("@@kuangfeng") > 0 and data.damageType == fk.FireDamage and player:getMark("_kuangfeng") ~= 0) or
      (target:getMark("@@dawu") > 0 and data.damageType ~= fk.ThunderDamage and player:getMark("_dawu") ~= 0)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (skill, event, target, player, data)
    local room = player.room
    if target:getMark("@@kuangfeng") > 0 and data.damageType == fk.FireDamage and player:getMark("_kuangfeng") ~= 0 then
      room:notifySkillInvoked(player, "kuangfeng", "offensive")
      player:broadcastSkillInvoke("kuangfeng")
      data.damage = data.damage + 1
    end
    if target:getMark("@@dawu") > 0 and data.damageType ~= fk.ThunderDamage and player:getMark("_dawu") ~= 0 then
      room:notifySkillInvoked(player, "dawu", "defensive")
      player:broadcastSkillInvoke("dawu")
      return true
    end
  end,
})

return jiange__biantian
