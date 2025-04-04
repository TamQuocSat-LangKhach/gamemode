local nos__wanyi = fk.CreateSkill {
  name = "nos__wanyi"
}

Fk:loadTranslationTable{
  ['nos__wanyi'] = '婉嫕',
  ['#nos__wanyi'] = '婉嫕：你可以将一张带有应变效果的牌当一种应变篇锦囊使用',
  [':nos__wanyi'] = '出牌阶段每种牌名限一次，你可以将一张带有应变效果的牌当【逐近弃远】、【出其不意】、【水淹七军】或【洞烛先机】使用。',
  ['$nos__wanyi1'] = '婉嫕而淑慎，位居正室。',
  ['$nos__wanyi2'] = '为后需备贞静之德、婉嫕之操。',
}

nos__wanyi:addEffect('viewas', {
  prompt = "#nos__wanyi",
  interaction = function()
    local all_names = {"chasing_near", "unexpectation", "drowning", "foresight"}
    local names = table.simpleClone(all_names)
    for _, name in ipairs(all_names) do
      if table.contains(Self:getTableMark("nos__wanyi-turn"), name) then
        table.removeOne(names, name)
      end
    end
    if #names == 0 then return end
    return UI.ComboBox {choices = names, all_choices = all_names}
  end,
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and table.find({"@fujia", "@kongchao", "@canqu", "@zhuzhan"}, function(mark)
      return Fk:getCardById(to_select):getMark(mark) ~= 0 end)
  end,
  before_use = function (self, player, use)
    local mark = player:getTableMark("nos__wanyi-turn")
    table.insert(mark, use.card.name)
    player.room:setPlayerMark(player, "nos__wanyi-turn", mark)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = nos__wanyi.name
    return card
  end,
})

return nos__wanyi
