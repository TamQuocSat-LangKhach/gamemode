local ganran = fk.CreateSkill {
  name = "zombie_ganran"
}

Fk:loadTranslationTable{
  ['zombie_ganran'] = '感染',
  [':zombie_ganran'] = '锁定技，你手牌中的装备牌视为【铁锁连环】。',
}

ganran:addEffect('filter', {
  card_filter = function(self, player, to_select)
    return player:hasSkill(skill.name) and to_select.type == Card.TypeEquip and
      table.contains(player.player_cards[Player.Hand], to_select.id)
  end,
  view_as = function(self, player, to_select)
    local card = Fk:cloneCard("iron_chain", to_select.suit, to_select.number)
    card.skillName = ganran.name
    return card
  end,
})

return ganran
