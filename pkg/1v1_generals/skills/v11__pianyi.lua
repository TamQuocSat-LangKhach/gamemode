local v11__pianyi = fk.CreateSkill {
  name = "v11__pianyi"
}

Fk:loadTranslationTable{
  ['v11__pianyi'] = '翩仪',
  [':v11__pianyi'] = '锁定技，当你登场时，若此时是对手的回合，对手结束此回合。',
  ['$v11__pianyi1'] = '呵呵~不能动了吧。',
  ['$v11__pianyi2'] = '将军看呆了吗？',
}

v11__pianyi:addEffect("fk.Debut", {
  anim_type = "control",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(v11__pianyi) and player.room.current ~= player
  end,
  on_use = function(self, event, target, player, data)
    player.room:endTurn()
  end,
})

return v11__pianyi
