local jiange__tunshi = fk.CreateSkill {
  name = "jiange__tunshi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["jiange__tunshi"] = "吞噬",
  [":jiange__tunshi"] = "锁定技，准备阶段，你对所有手牌数大于你的敌方角色各造成1点伤害。",
}

jiange__tunshi:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and player.phase == Player.Start and
      table.find(U.GetEnemies(player.room, player), function (p)
        return p:getHandcardNum() > player:getHandcardNum()
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(U.GetEnemies(room, player), function (p)
      return p:getHandcardNum() > player:getHandcardNum()
    end)
    room:doIndicate(player.id, table.map(targets, Util.IdMapper))
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if table.contains(targets, p) and not p.dead then
        room:damage({
          from = player,
          to = p,
          damage = 1,
          skill_name = jiange__tunshi.name,
        })
      end
    end
  end,
})

return jiange__tunshi
