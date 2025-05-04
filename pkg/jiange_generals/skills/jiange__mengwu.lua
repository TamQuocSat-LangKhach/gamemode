local jiange__mengwu = fk.CreateSkill {
  name = "jiange__mengwu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ['jiange__mengwu'] = '猛武',
  [':jiange__mengwu'] = '锁定技，你使用【杀】无距离次数限制，当你使用【杀】被抵消后，你摸两张牌。',
}

-- 添加触发效果
jiange__mengwu:addEffect(fk.CardEffectCancelledOut, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiange__mengwu) and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, jiange__mengwu.name)
  end,
})

-- 添加目标修正效果
jiange__mengwu:addEffect('targetmod', {
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill(jiange__mengwu) and skill.trueName == "slash_skill"
  end,
  bypass_distances = function(self, player, skill, card, to)
    return player:hasSkill(jiange__mengwu) and skill.trueName == "slash_skill"
  end,
})

return jiange__mengwu
