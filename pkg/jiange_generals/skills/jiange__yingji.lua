local jiange__yingji = fk.CreateSkill {
  name = "jiange__yingji"
}

Fk:loadTranslationTable{
  ['jiange__yingji'] = '影戟',
  ['#jiange__yingji'] = '影戟：你可以展示所有手牌，视为使用一张【杀】，此【杀】伤害值改为展示牌类别数',
  ['#jiange__yingji_delay'] = '影戟',
  [':jiange__yingji'] = '出牌阶段限一次，你可以展示所有手牌，视为使用一张【杀】，此【杀】造成伤害时，将伤害值改为X（X为你展示牌的类别数）。',
}

-- 主动技能效果
jiange__yingji:addEffect('active', {
  anim_type = "offensive",
  prompt = "#jiange__yingji",
  card_num = 0,
  min_target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(jiange__yingji.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to_select, selected, _, _, extra_data)
    local card = Fk:cloneCard("slash")
    card.skillName = jiange__yingji.name
    return card.skill:targetFilter(to_select, selected, {}, card, {bypass_times = true}, player)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local cards = player:getCardIds("h")
    local types = {}
    for _, id in ipairs(cards) do
      table.insertIfNeed(types, Fk:getCardById(id).type)
    end
    player:showCards(cards)
    local card = Fk:cloneCard("slash")
    card.skillName = jiange__yingji.name
    local use = {
      from = player.id,
      tos = table.map(effect.tos, function(id) return {id} end),
      card = card,
      extra_data = {jiange__yingji = #types},
      extraUse = true,
    }
    room:useCard(use)
  end,
})

-- 触发技能效果
jiange__yingji:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target and target == player and data.card and table.contains(data.card.skillNames, jiange__yingji.name) then
      local room = player.room
      local use_event = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if use_event then
        local use = use_event.data[1]
        if use.extra_data and use.extra_data.jiange__yingji then
          event:setCostData(self, use.extra_data.jiange__yingji)
          return true
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = event:getCostData(self)
  end,
})

return jiange__yingji
