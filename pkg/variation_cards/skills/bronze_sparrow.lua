local skill = fk.CreateSkill {
  name = "#bronze_sparrow_skill",
  tags = { Skill.Compulsory },
  attached_equip = "bronze_sparrow",
}

Fk:loadTranslationTable{
  ["#bronze_sparrow_skill"] = "铜雀",
}

skill:addEffect(fk.PreCardUse, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name)
  end,
  on_refresh = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.variation_type = {"@fujia", "@kongchao", "@canqu", "@zhuzhan"}
  end,
})

return skill
