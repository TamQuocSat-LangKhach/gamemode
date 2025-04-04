local jiange__xiaorui = fk.CreateSkill {
  name = "jiange__xiaorui"
}

Fk:loadTranslationTable{
  ['jiange__xiaorui'] = '骁锐',
  [':jiange__xiaorui'] = '锁定技，当友方角色于其回合内使用【杀】造成伤害后，你令其本回合出牌阶段使用【杀】次数上限+1。',
}

jiange__xiaorui:addEffect(fk.Damage, {
  anim_type = "support",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if target and player:hasSkill(jiange__xiaorui.name) and data.card and data.card.trueName == "slash" and
      table.contains(U.GetFriends(player.room, player), target) then
      local turn_event = player.room.logic:getCurrentEvent():findParent(GameEvent.Turn)
      if turn_event then
        return target == turn_event.data[1]
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    room:addPlayerMark(target, MarkEnum.SlashResidue.."-turn", 1)
  end,
})

return jiange__xiaorui
