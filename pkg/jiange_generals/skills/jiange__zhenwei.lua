local jiange__zhenwei = fk.CreateSkill {
  name = "jiange__zhenwei",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["jiange__zhenwei"] = "镇卫",
  [":jiange__zhenwei"] = "锁定技，敌方角色计算与其他友方角色距离+1。",
}

jiange__zhenwei:addEffect("distance", {
  correct_func = function(self, player, from, to)
    return #table.filter(Fk:currentRoom().alive_players, function (p)
      return p:hasSkill(skill.name) and
        table.contains(U.GetEnemies(Fk:currentRoom(), p), from) and table.contains(U.GetFriends(Fk:currentRoom(), p, false), to)
    end)
  end,
})

return jiange__zhenwei
