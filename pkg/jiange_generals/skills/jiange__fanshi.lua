local jiange__fanshi = fk.CreateSkill {
  name = "jiange__fanshi"
}

Fk:loadTranslationTable{
  ['jiange__fanshi'] = '反噬',
  [':jiange__fanshi'] = '锁定技，结束阶段，你失去1点体力。',
}

jiange__fanshi:addEffect(fk.EventPhaseStart, {
  anim_type = "negative",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(skill.name) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player)
    player.room:loseHp(player, 1, skill.name)
  end,
})

return jiange__fanshi
