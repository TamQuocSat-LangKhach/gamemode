local v11__aibing = fk.CreateSkill {
  name = "v11__aibing"
}

Fk:loadTranslationTable{
  ['v11__aibing'] = '哀兵',
  [':v11__aibing'] = '当你死亡时，你可以令你下一名武将登场时视为使用一张【杀】。',
}

v11__aibing:addEffect(fk.Death, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name, false, true)
  end,
  on_cost = function (skill, event, target, player)
    return player.room:askToSkillInvoke(player, { skill_name = skill.name })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player.tag["v11__aibing"] = true
  end,
})

v11__aibing:addEffect("fk.Debut", {
  can_trigger = function(self, event, target, player, data)
    return target == player and player.tag["v11__aibing"]
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player.tag["v11__aibing"] = false
    room:useVirtualCard("slash", nil, player, player.next, skill.name, true)
  end,
})

return v11__aibing
