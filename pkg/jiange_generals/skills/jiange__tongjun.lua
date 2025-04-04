local jiange__tongjun = fk.CreateSkill {
  name = "jiange__tongjun"
}

Fk:loadTranslationTable{
  ['jiange__tongjun'] = '统军',
  [':jiange__tongjun'] = '锁定技，友方攻城器械攻击范围+1。',
}

jiange__tongjun:addEffect('atkrange', {
  frequency = Skill.Compulsory,
  correct_func = function (skill, from)
    return #table.filter(Fk:currentRoom().alive_players, function (p)
      return p:hasSkill(skill.name) and Fk.generals[from.general].jiange_machine and
        table.contains(U.GetFriends(Fk:currentRoom(), p), from)
    end)
  end,
})

return jiange__tongjun
