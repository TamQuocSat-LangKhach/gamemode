local jiange__huodi = fk.CreateSkill {
  name = "jiange__huodi"
}

Fk:loadTranslationTable{
  ['jiange__huodi'] = '惑敌',
  ['#jiange__huodi-choose'] = '惑敌：你可以令一名敌方角色翻面',
  [':jiange__huodi'] = '结束阶段，若有友方角色武将牌背面朝上，你可以令一名敌方角色翻面。',
}

jiange__huodi:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiange__huodi.name) and player.phase == Player.Finish and
      table.find(U.GetFriends(player.room, player), function (p)
        return not p.faceup
      end) and
      #U.GetEnemies(player.room, player) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askToChoosePlayers(player, {
      targets = table.map(U.GetEnemies(player.room, player), Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#jiange__huodi-choose",
      skill_name = jiange__huodi.name,
    })
    if #to > 0 then
      event:setCostData(skill, to[1])
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:getPlayerById(event:getCostData(skill)):turnOver()
  end,
})

return jiange__huodi
