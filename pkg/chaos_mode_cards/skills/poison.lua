local skill = fk.CreateSkill {
  name = "poison_skill",
}

skill:addEffect("cardskill", {
  prompt = "#poison_skill",
  mod_target_filter = function (self, player, to_select, selected, card, extra_data)
    return to_select.hp > 0
  end,
  can_use = function(self, player, card, extra_data)
    return Util.CanUseToSelf(self, player, card, extra_data) and player.hp > 0
  end,
  on_effect = function(self, room, effect)
    if effect.to.dead then return end
    room:loseHp(effect.to, 1, skill.name)
  end,
})

skill:addEffect(fk.BeforeCardsMove, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.from == player then
        return true
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.from == player and move.skillName ~= "scrape_poison_skill" and move.moveReason ~= fk.ReasonUse then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand and
            (move.moveVisible or table.contains({Card.PlayerEquip, Card.Processing, Card.DiscardPile}, move.toArea)) then
            if Fk:getCardById(info.cardId, false).name == "poison" then
              move.extra_data = move.extra_data or {}
              local dat = move.extra_data.poison or {}
              table.insert(dat, player.id)
              move.extra_data.poison = dat
            end
          end
        end
      end
    end
  end,
})

skill:addEffect(fk.AfterCardsMove, {
  global = true,
  priority = 0.001,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.extra_data and move.extra_data.poison then
        if table.contains(move.extra_data.poison, player.id) and not player.dead then
          return true
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local n = 0
    for _, move in ipairs(data) do
      if move.extra_data and move.extra_data.poison then
        n = n + #table.filter(move.extra_data.poison, function(id)
          return id == player.id
        end)
      end
    end
    for _ = 1, n, 1 do
      if not player.dead then
        player.room:loseHp(player, 1, "poison")
      end
    end
  end,
})

skill:addAI({
  on_use = function(self, logic, effect)
    self.skill:onUse(logic, effect)
  end,
  on_effect = function(self, logic, effect)
    local target = effect.to
    logic:loseHp(target, 1, skill.name)
  end,
}, "__card_skill")

skill:addTest(function(room, me)
  local poison = room:printCard("poison")
  -- 服务端on_effect测试：能正常摸牌
  FkTest.runInRoom(function()
    room:useCard{
      from = me,
      tos = { me },
      card = poison,
    }
  end)
  lu.assertEquals(#me.hp, 3)
end)

return skill
