local jiange__jizhen = fk.CreateSkill {
  name = "jiange__jizhen"
}

Fk:loadTranslationTable{
  ['jiange__jizhen'] = '激阵',
  ['#jiange__jizhen-invoke'] = '激阵：是否令所有友方已受伤角色各摸一张牌？',
  [':jiange__jizhen'] = '结束阶段，你可以令所有友方已受伤角色各摸一张牌。',
}

jiange__jizhen:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiange__jizhen.name) and player.phase == Player.Finish and
      table.find(U.GetFriends(player.room, player), function (p)
        return p:isWounded()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = jiange__jizhen.name,
      prompt = "#jiange__jizhen-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(U.GetFriends(room, player), function (p)
      return p:isWounded()
    end)
    room:doIndicate(player.id, table.map(targets, Util.IdMapper))
    for _, p in ipairs(room:getAlivePlayers()) do
      if table.contains(targets, p) and not p.dead then
        p:drawCards(1, jiange__jizhen.name)
      end
    end
  end,
})

return jiange__jizhen
