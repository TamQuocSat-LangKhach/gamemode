local jiange__chuanyun = fk.CreateSkill {
  name = "jiange__chuanyun"
}

Fk:loadTranslationTable{
  ['jiange__chuanyun'] = '穿云',
  ['#jiange__chuanyun-choose'] = '穿云：你可以对一名体力值大于你的角色造成1点伤害',
  [':jiange__chuanyun'] = '结束阶段，你可以对一名体力值大于你的角色造成1点伤害。',
}

jiange__chuanyun:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiange__chuanyun.name) and player.phase == Player.Finish and
      table.find(player.room.alive_players, function (p)
        return p.hp > player.hp
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return p.hp > player.hp
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      prompt = "#jiange__chuanyun-choose",
      skill_name = jiange__chuanyun.name,
      cancelable = true
    })
    if #to > 0 then
      event:setCostData(self, to[1])
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:damage({
      from = player,
      to = room:getPlayerById(event:getCostData(self)),
      damage = 1,
      skillName = jiange__chuanyun.name,
    })
  end,
})

return jiange__chuanyun
