local jiange__jingfan = fk.CreateSkill {
  name = "jiange__jingfan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["jiange__jingfan"] = "惊帆",
  [":jiange__jingfan"] = "锁定技，其他友方角色计算与敌方角色距离-1。",
}

jiange__jingfan:addEffect("distance", {
  correct_func = function(self, player, from, to)
    return -#table.filter(Fk:currentRoom().alive_players, function (p)
      return p:hasSkill(jiange__jingfan.name) and
        table.contains(U.GetFriends(Fk:currentRoom(), p, false), from) and table.contains(U.GetEnemies(Fk:currentRoom(), p), to)
    end)
  end,
})

return jiange__jingfan
