local jiuzhu = fk.CreateSkill {
  name = "jiuzhu"
}

Fk:loadTranslationTable{
  ['jiuzhu'] = '救主',
  ['#jiuzhu-invoke'] = '救主：你可以弃一张牌并失去1点体力，令 %dest 回复1点体力',
  [':jiuzhu'] = '当己方一名其他角色处于濒死状态时，若你的体力值大于1，你可以弃置一张牌并失去1点体力，令该角色回复1点体力。',
}

jiuzhu:addEffect(fk.AskForPeaches, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiuzhu.name) and
      table.contains(U.GetFriends(player.room, player, false), player.room:getPlayerById(data.who)) and
      player.hp > 1 and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = jiuzhu.name,
      cancelable = true,
      prompt = "#jiuzhu-invoke::" .. data.who,
    })
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = player.room:getPlayerById(data.who)
    room:doIndicate(player.id, {data.who})
    room:throwCard(event:getCostData(self).cards, jiuzhu.name, player, player)
    if not player.dead then
      room:loseHp(player, 1, jiuzhu.name)
    end
    if not to.dead and to:isWounded() then
      room:recover({
        who = to,
        num = 1,
        recoverBy = player,
        skillName = jiuzhu.name,
      })
    end
  end,
})

return jiuzhu
