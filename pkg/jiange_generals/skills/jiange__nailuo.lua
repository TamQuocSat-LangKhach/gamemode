local jiange__nailuo = fk.CreateSkill {
  name = "jiange__nailuo"
}

Fk:loadTranslationTable{
  ['jiange__nailuo'] = '奈落',
  ['#jiange__nailuo-invoke'] = '奈落：是否翻面，令所有敌方角色弃置装备区内所有牌？',
  [':jiange__nailuo'] = '结束阶段，你可以翻面，令所有敌方角色依次弃置其装备区内所有牌。',
}

jiange__nailuo:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiange__nailuo.name) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = jiange__nailuo.name,
      prompt = "#jiange__nailuo-invoke"
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, table.map(U.GetEnemies(room, player), Util.IdMapper))
    player:turnOver()
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if table.contains(U.GetEnemies(room, player), p) and not p.dead then
        p:throwAllCards("e")
      end
    end
  end,
})

return jiange__nailuo
