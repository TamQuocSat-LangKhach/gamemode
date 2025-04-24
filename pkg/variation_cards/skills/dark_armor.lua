local skill = fk.CreateSkill {
  name = "#dark_armor_skill",
  tags = { Skill.Compulsory },
  attached_equip = "dark_armor",
}

Fk:loadTranslationTable{
  ["#dark_armor_skill"] = "黑光铠",
}

skill:addEffect(fk.TargetConfirmed, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and
      #data.use.tos > 1 and
      (data.card.is_damage_card or (data.card.color == Card.Black and data.card.type == Card.TypeTrick))
  end,
  on_use = function(self, event, target, player, data)
    data.use.nullifiedTargets = data.use.nullifiedTargets or {}
    table.insertIfNeed(data.use.nullifiedTargets, player)
  end,
})

return skill
