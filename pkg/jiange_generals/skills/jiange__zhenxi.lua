local jiange__zhenxi = fk.CreateSkill {
  name = "jiange__zhenxi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["jiange__zhenxi"] = "镇西",
  ["@jiange__zhenxi"] = "镇西",
  [":jiange__zhenxi"] = "锁定技，当友方角色受到伤害后，其下个摸牌阶段摸牌数+1。",
}

jiange__zhenxi:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jiange__zhenxi.name) and table.contains(U.GetFriends(player.room, player), target)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    room:addPlayerMark(target, "@jiange__zhenxi", 1)
  end,
})

jiange__zhenxi:addEffect(fk.DrawNCards, {
  can_refresh = function (skill, event, target, player)
    return target == player and player:getMark("@jiange__zhenxi") > 0
  end,
  on_refresh = function (skill, event, target, player)
    data.n = data.n + player:getMark("@jiange__zhenxi")
    player.room:setPlayerMark(player, "@jiange__zhenxi", 0)
  end,
})

return jiange__zhenxi
