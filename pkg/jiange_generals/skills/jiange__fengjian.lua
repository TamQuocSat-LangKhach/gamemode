local jiange__fengjian = fk.CreateSkill {
  name = "jiange__fengjian"
}

Fk:loadTranslationTable{
  ['jiange__fengjian'] = '封缄',
  ['@@jiange__fengjian'] = '封缄',
  [':jiange__fengjian'] = '锁定技，当你对一名角色造成伤害后，其使用牌不能指定你为目标，直到其下回合结束。',
}

jiange__fengjian:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return target and target == player and player:hasSkill(jiange__fengjian.name) and not data.to.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {data.to.id})
    local mark = data.to:getTableMark("@@jiange__fengjian")
    table.insertIfNeed(mark, player.id)
    room:setPlayerMark(data.to, "@@jiange__fengjian", mark)
  end,
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@jiange__fengjian") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@jiange__fengjian", 0)
  end,
})

jiange__fengjian:addEffect('prohibit', {
  is_prohibited = function (skill, from, to, card)
    if from:getMark("@@jiange__fengjian") ~= 0 and card then
      return table.contains(from:getTableMark("@@jiange__fengjian"), to.id)
    end
  end,
})

return jiange__fengjian
