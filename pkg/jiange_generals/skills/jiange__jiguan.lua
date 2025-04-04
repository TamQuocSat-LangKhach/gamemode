local jiange__jiguan = fk.CreateSkill {
  name = "jiange__jiguan"
}

Fk:loadTranslationTable{
  ['jiange__jiguan'] = '机关',
  [':jiange__jiguan'] = '锁定技，你不能成为【乐不思蜀】的目标。',
}

jiange__jiguan:addEffect('prohibit', {
  frequency = Skill.Compulsory,
  is_prohibited = function(self, player, from, to, card)
    return to:hasSkill(jiange__jiguan.name) and card and card.name == "indulgence"
  end,
})

return jiange__jiguan
