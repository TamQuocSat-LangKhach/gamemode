local choujin = fk.CreateSkill {
  name = "choujin"
}

Fk:loadTranslationTable{
  ['choujin'] = '筹进',
  ['#choujin-choose'] = '筹进：标记一名对方角色，每回合限两次，己方角色对该角色造成伤害后摸一张牌',
  ['@@choujin'] = '筹进',
  [':choujin'] = '锁定技，亮将结束后，你选择一名对方角色：每回合限两次，当己方角色对该角色造成伤害后，该己方角色摸一张牌。',
  ['$choujin1'] = '预则立，不预则废！',
  ['$choujin2'] = '就用你，给我军祭旗！',
}

choujin:addEffect(fk.GamePrepared, {
  anim_type = "special",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player)
    return player:hasSkill(choujin.name)
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = table.map(U.GetEnemies(room, player), Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#choujin-choose",
      skill_name = choujin.name,
      cancelable = false
    })
    to = room:getPlayerById(to[1])
    room:setPlayerMark(to, "@@choujin", 1)
  end
})

choujin:addEffect(fk.Damage, {
  name = "#choujin_delay",
  mute = true,
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player)
    return target and player:usedSkillTimes(choujin.name, Player.HistoryGame) > 0 and
      data.to:getMark("@@choujin") > 0 and
      table.contains(U.GetFriends(player.room, player), target) and
      table.contains(U.GetEnemies(player.room, player, true), data.to) and
      player:getMark("choujin-turn") < 2
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    player:broadcastSkillInvoke(choujin.name)
    room:notifySkillInvoked(player, choujin.name, "drawcard")
    room:addPlayerMark(player, "choujin-turn", 1)
    target:drawCards(1, choujin.name)
  end
})

return choujin
