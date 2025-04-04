local jiange__tianjiang = fk.CreateSkill {
  name = "jiange__tianjiang"
}

Fk:loadTranslationTable{
  ['jiange__tianjiang'] = '天将',
  [':jiange__tianjiang'] = '锁定技，当友方角色每回合首次使用【杀】造成伤害后，其摸一张牌。',
}

jiange__tianjiang:addEffect(fk.Damage, {
  anim_type = "support",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if target and player:hasSkill(jiange__tianjiang.name) and data.card and data.card.trueName == "slash" and
      table.contains(U.GetFriends(player.room, player), target) then
      local room = player.room
      local turn_event = room.logic:getCurrentEvent():findParent(GameEvent.Turn)
      if not turn_event then return end
      local damage_event = room.logic:getCurrentEvent()
      if not damage_event then return end
      local events = room.logic:getActualDamageEvents(1, function(e)
        local damage = e.data[1]
        return damage.from and damage.from == player and damage.card and damage.card.trueName == "slash"
      end, Player.HistoryTurn)
      if #events > 0 and damage_event.id == events[1].id then
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:doIndicate(player.id, {target.id})
    target:drawCards(1, jiange__tianjiang.name)
  end,
})

return jiange__tianjiang
