local jiange__huchen = fk.CreateSkill {
  name = "jiange__huchen",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["jiange__huchen"] = "虎臣",
  [":jiange__huchen"] = "锁定技，摸牌阶段，你额外摸X张牌（X为你杀死的敌方角色数）。",
}

jiange__huchen:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(jiange__huchen.name) then
      local room = player.room
      local n = #room.logic:getEventsOfScope(GameEvent.Death, 999, function(e)
        local death = e.data[1]
        return death.damage and death.damage.from == player and
          table.contains(U.GetEnemies(room, player, true), room:getPlayerById(death.who))
      end, Player.HistoryGame)
      if n > 0 then
        event:setCostData(skill, n)
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local cost_data = event:getCostData(skill)
    data.n = data.n + cost_data
  end,
})

return jiange__huchen
