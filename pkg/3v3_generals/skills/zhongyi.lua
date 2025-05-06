local zhongyi = fk.CreateSkill {
  name = "zhongyi",
}

Fk:loadTranslationTable{
  ["zhongyi"] = "忠义",
  [":zhongyi"] = "出牌阶段，若你没有“义”，你可以将任意张红色牌置为“义”。当己方角色使用【杀】对对方角色造成伤害时，你移去一张“义”，令此伤害+1。",

  ["#zhongyi"] = "忠义：将任意张红色牌置于武将牌上，友方使用【杀】造成伤害时移去一张，此伤害+1",
}

local U = require "packages/utility/utility"

zhongyi:addEffect("active", {
  anim_type = "offensive",
  prompt = "#zhongyi",
  target_num = 0,
  min_card_num = 1,
  derived_piles = zhongyi.name,
  can_use = function(self, player)
    return #player:getPile(zhongyi.name) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return Fk:getCardById(to_select).color == Card.Red
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    player:addToPile(zhongyi.name, effect.cards, true, zhongyi.name, player)
  end,
})

zhongyi:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target and #player:getPile(zhongyi.name) > 0 and
      data.card and data.card.trueName == "slash" and
      table.contains(U.GetFriends(player.room, player), target) and
      table.contains(U.GetEnemies(player.room, player, true), data.to)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:moveCardTo(table.random(player:getPile(zhongyi.name)), Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, zhongyi.name)
    data:changeDamage(1)
  end,
})

return zhongyi
