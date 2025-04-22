local v22__kuiji = fk.CreateSkill {
  name = "v22__kuiji"
}

Fk:loadTranslationTable{
  ['v22__kuiji'] = '溃击',
  ['#v22__kuiji'] = '溃击：将一张黑色基本牌当【兵粮寸断】置于你的判定区并摸一张牌，然后对一名体力最多的敌方造成2点伤害',
  ['#v22__kuiji-damage'] = '溃击：你可以对体力值最多的一名敌方造成2点伤害',
  ['#v22__kuiji-recover'] = '溃击：令体力值最少的一名友方回复1点体力',
  [':v22__kuiji'] = '出牌阶段限一次，你可以将一张黑色基本牌当作【兵粮寸断】置于你的判定区，然后摸一张牌。若如此做，你可以对体力值最多的一名敌方角色造成2点伤害，其因此进入濒死状态时，体力值最少的一名友方角色回复1点体力。',
  ['$v22__kuiji1'] = '绝域奋击，孤注一掷。',
  ['$v22__kuiji2'] = '舍得一身剐，不畏君王威。',
}

-- 主动技能
v22__kuiji:addEffect('active', {
  anim_type = "offensive",
  target_num = 0,
  card_num = 1,
  prompt = "#v22__kuiji",
  can_use = function(self, player)
    return player:usedSkillTimes(v22__kuiji.name) == 0 and not player:hasDelayedTrick("supply_shortage")
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeBasic and Fk:getCardById(to_select).color == Card.Black
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local card = Fk:cloneCard("supply_shortage")
    card:addSubcards(effect.cards)
    card.skillName = v22__kuiji.name
    player:addVirtualEquip(card)
    room:moveCardTo(card, Player.Judge, player, fk.ReasonJustMove, v22__kuiji.name)
    if player.dead then return end
    player:drawCards(1, v22__kuiji.name)
    local targets = table.map(table.filter(U.GetEnemies(room, player), function(p)
      return table.every(U.GetEnemies(room, player), function(p2)
        return p.hp >= p2.hp
      end)
    end), Util.IdMapper)
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#v22__kuiji-damage",
      skill_name = v22__kuiji.name
    })
    if #to > 0 then
      room:damage{
        from = player,
        to = to[1],
        damage = 2,
        skillName = v22__kuiji.name,
      }
    end
  end,
})

-- 触发技能
v22__kuiji:addEffect(fk.EnterDying, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return data.damage and data.damage.skillName == "v22__kuiji" and data.damage.from and data.damage.from == player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(U.GetFriends(room, player), function(p)
      return table.every(U.GetFriends(room, player), function(p2)
        return p.hp <= p2.hp and p:isWounded()
      end)
    end), Util.IdMapper)
    if #targets == 0 then return end
    local to = targets[1]
    if #targets > 1 then
      to = room:askToChoosePlayers(player, {
        targets = targets,
        min_num = 1,
        max_num = 1,
        prompt = "#v22__kuiji-recover",
        skill_name = "v22__kuiji"
      })[1]
    end
    room:doIndicate(player.id, {to})
    room:recover({
      who = to,
      num = 1,
      recoverBy = player,
      skillName = v22__kuiji.name
    })
  end,
})

return v22__kuiji
