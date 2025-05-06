local rule = fk.CreateSkill {
  name = "#chaos_rule&",
}

Fk:loadTranslationTable{
  ["#chaos_rule&"] = "文和乱武",
  ["@[:]chaos_mode_event"] = "事件",
  ["chaos_mode_event_log"] = "本轮的“文和乱武” %arg",
  ["chaos_intro"] = "<b>一人一队</b>，文和乱武的大吃鸡时代，你能入主长安吗？<br>"..
  "<b>每轮会有随机事件</b>，可点击<b>左上角</b>查看详情，祝你好运。（贾诩的谜之笑容）",
  ["chaos_fisrt_round"] = "第一轮时，已受伤角色视为拥有〖八阵〗。",

  ["chaos_e: 1"] = "事件：乱武。从随机一名角色开始，所有角色，需对距离最近的一名角色使用一张【杀】，否则失去1点体力。",
  ["chaos_luanwu"] = "乱武",
  [":chaos_luanwu"] = "从随机一名角色开始，所有角色需对距离最近的一名角色使用一张【杀】，否则失去1点体力。",

  ["chaos_e: 2"] = "事件：重赏。本轮中，击杀角色奖励翻倍。",
  ["generous_reward"] = "重赏",
  [":generous_reward"] = "本轮中，击杀角色奖励翻倍。",

  ["chaos_e: 3"] = "事件：破釜沉舟。一名角色的回合开始时，失去1点体力，摸三张牌。",
  ["burning_one's_boats"] = "破釜沉舟",
  [":burning_one's_boats"] = "一名角色的回合开始时，其失去1点体力，摸三张牌。",

  ["chaos_e: 4"] = "事件：横刀跃马。每个回合结束时，所有装备最少的角色失去1点体力，随机将一张装备牌置入其装备区。",
  ["leveling_the_blades"] = "横刀跃马",
  [":leveling_the_blades"] = "每个回合结束时，所有装备最少的角色失去1点体力，随机将一张装备牌置入其装备区。",
  ["#chaos_mode_event_4_log"] = "%from 由于“%arg”，将 %arg2 置入装备区",

  ["chaos_e: 5"] = "事件：横扫千军。本轮中，所有伤害值+1。",
  ["sweeping_all"] = "横扫千军",
  [":sweeping_all"] = "本轮中，所有伤害值+1。",

  ["chaos_e: 6"] = "事件：饿莩载道。本轮结束时，所有手牌最少的角色失去X点体力。（X为轮数）",
  ["starvation"] = "饿莩载道",
  [":starvation"] = "本轮结束时，所有手牌最少的角色失去X点体力。（X为轮数）",

  ["chaos_e: 7"] = "事件：宴安鸩毒。本轮中，所有的【桃】均视为<a href=':poison'>【毒】</a>。",
  ["poisoned_banquet"] = "宴安鸩毒",
  [":poisoned_banquet"] = "本轮中，所有的【桃】均视为<a href=':poison'>【毒】</a>。",
}

--所有人获得完杀
rule:addEffect(fk.GameStart, {
  can_refresh = function (self, event, target, player, data)
    return player.seat == 1
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.players) do
      room:handleAddLoseSkills(p, "wansha", nil, false, true)
    end
  end,
})

--获胜
rule:addEffect(fk.GameOverJudge, {
  can_refresh = function (self, event, target, player, data)
    return target == player
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    room:setTag("SkipGameRule", true)
    if #room.alive_players == 1 then
      local winner = Fk.game_modes[room.settings.gameMode]:getWinner(player)
      if winner ~= "" then
        room:gameOver(winner)
      end
    end
  end,
})

--每轮开始触发随机事件
rule:addEffect(fk.RoundStart, {
  priority = 0.001,
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return player.seat == 1
  end,
  on_trigger = function (self, event, target, player, data)
    local room = player.room
    local index = math.random(1, 7)
    if room:getBanner("RoundCount") == 1 then
      room:doBroadcastNotify("ShowToast", Fk:translate("chaos_fisrt_round"))
      index = 1
    end
    local chaos_event = {
      "chaos_luanwu",
      "generous_reward",
      "burning_one's_boats",
      "leveling_the_blades",
      "sweeping_all",
      "starvation",
      "poisoned_banquet",
    }
    room:setBanner("@[:]chaos_mode_event", chaos_event[index])
    if index == 7 then
      room:setBanner("_chaos_mode_event-round", "poisoned_banquet")
    end
    room:notifyMoveFocus(room.alive_players, rule.name)
    room:sendLog{
      type = "chaos_mode_event_log",
      arg = "chaos_e: " .. tostring(index),
      toast = true,
    }
    room:delay(3500)

    --事件1乱武
    if index == 1 then
      local from = table.random(room.alive_players)
      from:broadcastSkillInvoke("luanwu")
      room:notifySkillInvoked(from, "luanwu", "big")
      local temp = from.next
      local targets = {from}
      while temp ~= from do
        if not temp.dead then
          table.insert(targets, temp)
        end
        temp = temp.next
      end
      for _, target in ipairs(targets) do
        if not target.dead then
          local other_players = table.filter(room:getOtherPlayers(target, false), function(p)
            return not p:isRemoved()
          end)
          local luanwu_targets = table.filter(other_players, function(p2)
            return table.every(other_players, function(p1)
              return target:distanceTo(p1) >= target:distanceTo(p2)
            end)
          end)
          local use = room:askToUseCard(target, {
            pattern = "slash",
            prompt = "#luanwu-use",
            cancelable = true,
            extra_data = {
              exclusive_targets = table.map(luanwu_targets, Util.IdMapper),
              bypass_times = true,
            },
            skill_name = "luanwu",
          })
          if use then
            use.extraUse = true
            room:useCard(use)
          else
            room:loseHp(target, 1, "luanwu")
          end
        end
      end
    end
  end,
})

--事件3破釜沉舟
rule:addEffect(fk.TurnStart, {
  priority = 0.001,
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player.room:getBanner("@[:]chaos_mode_event") == "burning_one's_boats"
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:loseHp(player, 1, rule.name)
    if not player.dead then
      player:drawCards(3, rule.name)
    end
  end,
})

--事件4横刀跃马
rule:addEffect(fk.TurnEnd, {
  priority = 0.001,
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player.room:getBanner("@[:]chaos_mode_event") == "leveling_the_blades"
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return table.every(room.alive_players, function(p2)
        return #p:getCardIds("e") <= #p2:getCardIds("e")
      end)
    end)
    room:sortByAction(targets)
    for _, p in ipairs(targets) do
      if not p.dead then
        room:loseHp(p, 1, rule.name)
        if not p.dead then
          local cards = table.filter(room.draw_pile, function (id)
            return p:canMoveCardIntoEquip(id, false)
          end)
          if #cards > 0 then
            local id = table.random(cards)
            room:sendLog{
              type = "#chaos_mode_event_4_log",
              from = p.id,
              arg = "leveling_the_blades",
              arg2 = Fk:getCardById(id):toLogString(),
            }
            room:moveCardIntoEquip(p, id, rule.name, false)
          end
        end
      end
    end
  end,
})

--事件5横扫千军
rule:addEffect(fk.DamageInflicted, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player.room:getBanner("@[:]chaos_mode_event") == "sweeping_all"
  end,
  on_refresh = function (self, event, target, player, data)
    data:changeDamage(1)
  end,
})

--事件6饿莩载道
rule:addEffect(fk.RoundEnd, {
  priority = 0.001,
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player.room:getBanner("@[:]chaos_mode_event") == "starvation"
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return table.every(room.alive_players, function(p2)
        return p:getHandcardNum() <= p2:getHandcardNum()
      end)
    end)
    room:sortByAction(targets)
    local num = room:getBanner("RoundCount")
    for _, p in ipairs(targets) do
      if not p.dead then
        room:loseHp(p, num, rule.name)
      end
    end
  end,
})

--事件7宴安鸩毒
rule:addEffect("filter", {
  card_filter = function(self, to_select, player)
    return Fk:currentRoom():getBanner("_chaos_mode_event-round") == "poisoned_banquet" and to_select.name == "peach"
  end,
  view_as = function(self, player, card)
    return Fk:cloneCard("poison", card.suit, card.number)
  end,
})

--首轮，已受伤角色视为拥有八阵
local spec = {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:isWounded() and player.room:getBanner("RoundCount") == 1 and
      (data.cardName == "jink" or (data.pattern and Exppattern:Parse(data.pattern):matchExp("jink|0|nosuit|none"))) and
      #player:getEquipments(Card.SubtypeArmor) == 0 and
      Fk.skills["#eight_diagram_skill"] ~= nil and Fk.skills["#eight_diagram_skill"]:isEffectable(player)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = "bazhen",
    })
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:broadcastPlaySound("./packages/standard_cards/audio/card/eight_diagram")
    room:setEmotion(player, "./packages/standard_cards/image/anim/eight_diagram")
    player:broadcastSkillInvoke("bazhen")
    room:notifySkillInvoked(player, "bazhen", "defensive")
    local skill = Fk.skills["#eight_diagram_skill"]
    skill:use(event, target, player, data)
  end,
}
rule:addEffect(fk.AskForCardUse, spec)
rule:addEffect(fk.AskForCardResponse, spec)

return rule
