local v11__changjun = fk.CreateSkill {
  name = "v11__changjun"
}

Fk:loadTranslationTable{
  ['v11__changjun'] = '畅军',
  ['#v11__changjun'] = '畅军：你可以将与“畅军”牌花色相同的牌当【杀】或【闪】使用或打出',
  ['#v11__changjun_trigger'] = '畅军',
  ['#v11__changjun-card'] = '畅军：你可以将至多 %arg 张牌置于武将牌上，你可将与“畅军”牌花色相同的牌当【杀】或【闪】使用或打出。',
  [':v11__changjun'] = '出牌阶段开始时，你可以将至多X张牌置于你的武将牌上（X为你的登场角色序数），若如此做，直到你下回合开始，你可以将与“畅军”牌花色相同的牌当【杀】或【闪】使用或打出；准备阶段，你获得所有“畅军”牌。',
}

v11__changjun:addEffect('viewas', {
  pattern = "slash,jink",
  prompt = "#v11__changjun",
  interaction = function()
    local names = {}
    for _, name in ipairs({"slash","jink"}) do
      local card = Fk:cloneCard(name)
      if (Fk.currentResponsePattern == nil and Self:canUse(card)) or
        (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card)) then
        table.insertIfNeed(names, card.name)
      end
    end
    if #names == 0 then return end
    return UI.ComboBox {choices = names}
  end,
  card_num = 1,
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and table.find(player:getPile(v11__changjun.name), function (id)
      return Fk:getCardById(id).suit == Fk:getCardById(to_select).suit
    end)
  end,
  view_as = function(self, player, cards)
    if not self.interaction.data or #cards ~= 1 then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = v11__changjun.name
    return card
  end,
  enabled_at_play = function(self, player)
    return #player:getPile(v11__changjun.name) > 0
  end,
  enabled_at_response = function(self, player)
    return #player:getPile(v11__changjun.name) > 0
  end,
})

v11__changjun:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if player.phase == Player.Play then
        return player:hasSkill(v11__changjun) and not player:isNude()
      elseif player.phase == Player.Start then
        return #player:getPile("v11__changjun") > 0
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    if player.phase ~= Player.Play then return true end
    local room = player.room
    local x = 1 + tonumber(room:getBanner(player.role == "lord" and "@firstFallen" or "@secondFallen")[1])
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = x,
      pattern = ".",
      prompt = "#v11__changjun-card:::"..x,
      skill_name = v11__changjun.name
    })
    if #cards > 0 then
      event:setCostData(self, cards)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player.phase == Player.Play then
      player:addToPile("v11__changjun", event:getCostData(self), true, "v11__changjun")
    else
      room:obtainCard(player, player:getPile("v11__changjun"), true, fk.ReasonJustMove, player.id, v11__changjun.name)
    end
  end,
})

return v11__changjun
