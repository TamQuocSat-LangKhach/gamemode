local jiange__jingmiao = fk.CreateSkill {
  name = "jiange__jingmiao"
}

Fk:loadTranslationTable{
  ['jiange__jingmiao'] = '精妙',
  [':jiange__jingmiao'] = '锁定技，当敌方角色使用【无懈可击】结算后，其失去1点体力。',
}

jiange__jingmiao:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jiange__jingmiao.name) and data.card.trueName == "nullification" and
      table.contains(U.GetEnemies(player.room, player), target) and not target.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    room:loseHp(target, 1, jiange__jingmiao.name)
  end,
})

return jiange__jingmiao
