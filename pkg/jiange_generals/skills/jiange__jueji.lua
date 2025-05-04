local jiange__jueji = fk.CreateSkill {
  name = "jiange__jueji",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["jiange__jueji"] = "绝汲",
  [":jiange__jueji"] = "锁定技，敌方角色摸牌阶段，若其已受伤，你令其少摸一张牌。",
}

jiange__jueji:addEffect(fk.DrawNCards, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(jiange__jueji.name) and table.contains(U.GetEnemies(player.room, player), target) and target:isWounded() and data.n > 0
  end,
  on_use = function (self, event, target, player, data)
    player.room:doIndicate(player.id, {target.id})
    data.n = data.n - 1
  end,
})

return jiange__jueji
