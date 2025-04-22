local rule = fk.CreateSkill {
  name = "#m_2v2_rule&",
}

--第一个回合的角色摸牌阶段少摸一张牌
rule:addEffect(fk.DrawNCards, {
  priority = 0.001,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark(self.name) == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local turnevents = room.logic.event_recorder[GameEvent.Turn] or Util.DummyTable
    if #turnevents == 1 and player:getMark(rule.name) == 0 then
      room:setPlayerMark(player, rule.name, 1)
      data.n = data.n - 1
    end
  end,
})

--四号位多摸一张初始手牌
rule:addEffect(fk.DrawInitialCards, {
  priority = 0.001,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player.seat == 4
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.num = data.num + 1
  end,
})

return rule
