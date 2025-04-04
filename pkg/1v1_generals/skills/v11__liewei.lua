local v11__liewei = fk.CreateSkill {
  name = "v11__liewe"
}

Fk:loadTranslationTable{
  ['v11__liewei'] = '裂围',
  [':v11__liewei'] = '当你杀死对手的角色后，你可以摸三张牌。',
  ['$v11__liewei1'] = '敌阵已乱，速速突围！',
  ['$v11__liewei2'] = '杀你，如同捻死一只蚂蚁！',
}

v11__liewei:addEffect(fk.Death, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(v11__liewei.name) and data.damage and data.damage.from and data.damage.from == player and player ~= target
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(3, v11__liewei.name)
  end,
})

return v11__liewei
