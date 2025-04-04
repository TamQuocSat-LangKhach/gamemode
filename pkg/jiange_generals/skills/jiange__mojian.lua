local jiange__mojian = fk.CreateSkill{
  name = "jiange__mojian"
}

Fk:loadTranslationTable{
  ['jiange__mojian'] = '魔箭',
  [':jiange__mojian'] = '锁定技，出牌阶段开始时，你视为对所有敌方角色使用一张【万箭齐发】。',
}

jiange__mojian:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and player.phase == Player.Play and
      table.find(U.GetEnemies(player.room, player), function(p)
        return not player:isProhibited(p, Fk:cloneCard("archery_attack"))
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = {}
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      if table.contains(U.GetEnemies(room, player), p) and not player:isProhibited(p, Fk:cloneCard("archery_attack")) then
        table.insert(tos, p)
      end
    end
    room:useVirtualCard("archery_attack", nil, player, tos, skill.name)
  end,
})

return jiange__mojian
