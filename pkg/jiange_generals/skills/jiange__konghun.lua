local jiange__konghun = fk.CreateSkill {
  name = "jiange__konghun"
}

Fk:loadTranslationTable{
  ['jiange__konghun'] = '控魂',
  ['#jiange__konghun-invoke'] = '控魂：是否对所有敌方角色各造成1点雷电伤害，你回复体力？',
  [':jiange__konghun'] = '出牌阶段开始时，若你已损失体力值不小于敌方角色数，你可以对所有敌方角色各造成1点雷电伤害，然后你回复X点体力（X为受到伤害的角色数）。',
}

jiange__konghun:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(jiange__konghun.name) and player.phase == Player.Play and player:isWounded() and
      player:getLostHp() >= #U.GetEnemies(player.room, player)
  end,
  on_cost = function(self, event, target, player)
    return player.room:askToSkillInvoke(player, {
      skill_name = jiange__konghun.name,
      prompt = "#jiange__konghun-invoke"
    })
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    room:doIndicate(player.id, table.map(U.GetEnemies(room, player), Util.IdMapper))
    local n = 0
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if table.contains(U.GetEnemies(room, player), p) and not p.dead then
        n = n + 1
        room:damage({
          from = player,
          to = p,
          damage = 1,
          damageType = fk.ThunderDamage,
          skillName = jiange__konghun.name,
        })
      end
    end
    if not player.dead and player:isWounded() then
      room:recover({
        who = player,
        num = math.min(n, player:getLostHp()),
        recoverBy = player,
        skillName = jiange__konghun.name,
      })
    end
  end,
})

return jiange__konghun
