local jiange__didong = fk.CreateSkill {
  name = "jiange__didong"
}

Fk:loadTranslationTable{
  ['jiange__didong'] = '地动',
  ['#jiange__didong-invoke'] = '地动：是否令随机一名敌方角色翻面？',
  [':jiange__didong'] = '结束阶段，你可以令随机一名敌方角色翻面。',
}

jiange__didong:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiange__didong.name) and player.phase == Player.Finish and
      #U.GetEnemies(player.room, player) > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = jiange__didong.name,
      prompt = "#jiange__didong-invoke"
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = table.random(U.GetEnemies(room, player))
    room:doIndicate(player.id, {to.id})
    to:turnOver()
  end,
})

return jiange__didong
