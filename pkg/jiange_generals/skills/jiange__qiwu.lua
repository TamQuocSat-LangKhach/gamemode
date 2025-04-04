local jiange__qiwu = fk.CreateSkill {
  name = "jiange__qiwu"
}

Fk:loadTranslationTable{
  ['jiange__qiwu'] = '栖梧',
  ['#jiange__qiwu-choose'] = '栖梧：你可以令一名友方角色回复1点体力',
  [':jiange__qiwu'] = '当你使用♣牌时，你可以令一名友方角色回复1点体力。',
}

jiange__qiwu:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiange__qiwu.name) and data.card.suit == Card.Club and
      table.find(U.GetFriends(player.room, player), function (p)
        return p:isWounded()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(U.GetFriends(room, player), function (p)
      return p:isWounded()
    end)
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#jiange__qiwu-choose",
      skill_name = jiange__qiwu.name,
      cancelable = true
    })
    if #to > 0 then
      event:setCostData(self, to[1])
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(event:getCostData(self))
    room:recover({
      who = to,
      num = 1,
      recoverBy = player,
      skillName = jiange__qiwu.name,
    })
  end,
})

return jiange__qiwu
