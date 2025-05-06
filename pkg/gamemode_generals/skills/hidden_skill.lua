local hidden_skill = fk.CreateSkill {
  name = "hidden_skill&"
}

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["hidden_skill&"] = "隐匿",
  [":hidden_skill&"] = "若你为隐匿将，防止你改变体力上限。当你扣减体力后，或你回合开始时，你解除隐匿状态。",
}

hidden_skill:addEffect(fk.HpChanged, {
  priority = 0.001,
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead and
      (player:getMark("__hidden_general") ~= 0 or player:getMark("__hidden_deputy") ~= 0) and
      data.num < 0
  end,
  on_trigger = function (self, event, target, player, data)
    U.GeneralAppear(player, "HpChanged")
  end,
})

hidden_skill:addEffect(fk.TurnStart, {
  priority = 0.001,
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead and
      (player:getMark("__hidden_general") ~= 0 or player:getMark("__hidden_deputy") ~= 0)
  end,
  on_trigger = function (self, event, target, player, data)
    U.GeneralAppear(player, "TurnStart")
  end,
})

hidden_skill:addEffect(fk.BeforeMaxHpChanged, {
  priority = 0.001,
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead and
      (player:getMark("__hidden_general") ~= 0 or player:getMark("__hidden_deputy") ~= 0)
  end,
  on_trigger = function (self, event, target, player, data)
    data.prevented = true
  end,
})

return hidden_skill
