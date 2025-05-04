local ganran = fk.CreateSkill {
  name = "zombie_ganran",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["zombie_ganran"] = "感染",
  [":zombie_ganran"] = "锁定技，你手牌中的装备牌视为【铁索连环】。",
}

ganran:addEffect("filter", {
  anim_type = "drawcard",
  card_filter = function(self, to_select, player)
    return player:hasSkill(ganran.name) and to_select.type == Card.TypeEquip and
    table.contains(player:getCardIds("h"), to_select.id)
  end,
  view_as = function(self, player, to_select)
    return Fk:cloneCard("iron_chain", to_select.suit, to_select.number)
  end,
})

return ganran
