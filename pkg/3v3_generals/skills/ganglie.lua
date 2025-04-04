local ganglie = fk.CreateSkill {
  name = "v33__ganglie"
}

Fk:loadTranslationTable{
  ['v33__ganglie'] = '刚烈',
  ['#v33__ganglie-choose'] = '刚烈：选择一名对方角色，你进行判定，若不为<font color=>♥</font>，其弃置两张手牌或受到1点伤害',
  ['#v33__ganglie-discard'] = '刚烈：弃置两张手牌，否则 %src 对你造成1点伤害',
  [':v33__ganglie'] = '当你受到伤害后，你可以选择一名对方角色，然后判定，若结果不为<font color=>♥</font>，其选择一项：1.弃置两张手牌；2.你对其造成1点伤害。',
  ['$v33__ganglie1'] = '鼠辈，竟敢伤我！',
  ['$v33__ganglie2'] = '以彼之道，还施彼身！',
}

ganglie:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(ganglie.name) and #U.GetEnemies(player.room, player) > 0
  end,
  on_cost = function(self, event, target, player)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = table.map(U.GetEnemies(room, player), Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#v33__ganglie-choose",
      skill_name = ganglie.name,
      cancelable = true
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local cost_data = event:getCostData(self)
    local to = room:getPlayerById(cost_data.tos[1])
    room:doIndicate(player.id, {to.id})
    local judge = {
      who = player,
      reason = ganglie.name,
      pattern = ".|.|^heart",
    }
    room:judge(judge)
    if judge.card.suit ~= Card.Heart and not to.dead then
      local discards = room:askToDiscard(to, {
        min_num = 2,
        max_num = 2,
        include_equip = false,
        skill_name = ganglie.name,
        cancelable = true,
        prompt = "#v33__ganglie-discard:" .. player.id
      })
      if #discards < 2 then
        room:damage{
          from = player,
          to = to,
          damage = 1,
          skillName = ganglie.name,
        }
      end
    end
  end,
})

return ganglie
