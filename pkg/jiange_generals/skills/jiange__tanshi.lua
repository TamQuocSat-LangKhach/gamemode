local jiange__tanshi = fk.CreateSkill {
  name = "jiange__tanshi"
}

Fk:loadTranslationTable{
  ['jiange__tanshi'] = '贪食',
  [':jiange__tanshi'] = '锁定技，结束阶段，你弃置一张手牌。',
}

jiange__tanshi:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and player.phase == Player.Finish and not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    player.room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = skill.name,
      cancelable = false
    })
  end,
})

return jiange__tanshi
