local jiange__qinzhen = fk.CreateSkill {
  name = "jiange__qinzhen",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["jiange__qinzhen"] = "亲阵",
  [":jiange__qinzhen"] = "锁定技，友方角色出牌阶段使用【杀】次数上限+1。",
}

jiange__qinzhen:addEffect("targetmod", {
  residue_func = function(self, player, skill_effect, scope)
    if skill_effect.trueName == "slash_skill" and scope == Player.HistoryPhase then
      return #table.filter(Fk:currentRoom().alive_players, function (p)
        return p:hasSkill(skill.name) and table.contains(U.GetFriends(Fk:currentRoom(), p), player)
      end)
    end
  end,
})

return jiange__qinzhen
