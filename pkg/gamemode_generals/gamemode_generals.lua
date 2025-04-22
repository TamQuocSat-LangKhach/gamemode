
local hiddenone = General(extension, "hiddenone", "jin", 1)
local hidden_skill = fk.CreateTriggerSkill{
  name = "hidden_skill&",
  priority = 0.001,
  mute = true,
  events = {fk.HpChanged, fk.TurnStart, fk.BeforeMaxHpChanged},
  can_trigger = function(self, event, target, player, data)
    if target == player and not player.dead and
    (player:getMark("__hidden_general") ~= 0 or player:getMark("__hidden_deputy") ~= 0) then
      if event == fk.HpChanged then
        return data.num < 0
      else
        return true
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.BeforeMaxHpChanged then
      return true
    else
      room:handleAddLoseSkills(player, "-"..self.name, nil, false, true)
      if Fk.generals[player:getMark("__hidden_general")] then
        player.general = player:getMark("__hidden_general")
      end
      if Fk.generals[player:getMark("__hidden_deputy")] then
        player.deputyGeneral = player:getMark("__hidden_deputy")
      end
      room:setPlayerMark(player, "__hidden_general", 0)
      room:setPlayerMark(player, "__hidden_deputy", 0)
      local general = Fk.generals[player.general]
      local deputy = Fk.generals[player.deputyGeneral]
      player.gender = general.gender
      player.kingdom = general.kingdom
      room:broadcastProperty(player, "gender")
      room:broadcastProperty(player, "general")
      room:broadcastProperty(player, "deputyGeneral")
      room:askForChooseKingdom({player})
      room:broadcastProperty(player, "kingdom")

      if player:getMark("__hidden_record") ~= 0 then
        player.maxHp = player:getMark("__hidden_record").maxHp
        player.hp = player:getMark("__hidden_record").hp
      else
        player.maxHp = player:getGeneralMaxHp()
        player.hp = deputy and math.floor((deputy.hp + general.hp) / 2) or general.hp
      end
      player.shield = math.min(general.shield + (deputy and deputy.shield or 0), 5)
      if player:getMark("__hidden_record") ~= 0 then
        room:setPlayerMark(player, "__hidden_record", 0)
      else
        local changer = Fk.game_modes[room.settings.gameMode]:getAdjustedProperty(player)
        if changer then
          for key, value in pairs(changer) do
            player[key] = value
          end
        end
      end
      room:broadcastProperty(player, "maxHp")
      room:broadcastProperty(player, "hp")
      room:broadcastProperty(player, "shield")

      local lordBuff = player.role == "lord" and player.role_shown == true and #room.players > 4
      local skills = general:getSkillNameList(lordBuff)
      if deputy then
        table.insertTable(skills, deputy:getSkillNameList(lordBuff))
      end
      skills = table.filter(skills, function (s)
        local skill = Fk.skills[s]
        return skill and (#skill.attachedKingdom == 0 or table.contains(skill.attachedKingdom, player.kingdom))
      end)
      if #skills > 0 then
        room:handleAddLoseSkills(player, table.concat(skills, "|"), nil, false)
      end

      room:sendLog{ type = "#RevealGeneral", from = player.id, arg =  "mainGeneral", arg2 = general.name }
      local event_data = {["m"] = general}
      if deputy then
        room:sendLog{ type = "#RevealGeneral", from = player.id, arg =  "deputyGeneral", arg2 = deputy.name }
        event_data["d"] = deputy.name
      end
      room.logic:trigger("fk.GeneralAppeared", player, event_data)
    end
  end,
}
Fk:loadTranslationTable{
  ["hidden_skill&"] = "隐匿",
  [":hidden_skill&"] = "若你为隐匿将，防止你改变体力上限。当你扣减体力后，或你回合开始时，你解除隐匿状态。",
}

local v22__leitong = General(extension, "v22__leitong", "shu", 4)
local v22__kuiji = fk.CreateActiveSkill{
  name = "v22__kuiji",
  anim_type = "offensive",
  target_num = 0,
  card_num = 1,
  prompt = "#v22__kuiji",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0 and not player:hasDelayedTrick("supply_shortage")
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeBasic and Fk:getCardById(to_select).color == Card.Black
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local card = Fk:cloneCard("supply_shortage")
    card:addSubcards(effect.cards)
    card.skillName = self.name
    player:addVirtualEquip(card)
    room:moveCardTo(card, Player.Judge, player, fk.ReasonJustMove, self.name)
    if player.dead then return end
    player:drawCards(1, self.name)
    local targets = table.map(table.filter(U.GetEnemies(room, player), function(p)
      return table.every(U.GetEnemies(room, player), function(p2)
        return p.hp >= p2.hp
      end)
    end), Util.IdMapper)
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#v22__kuiji-damage", self.name, true)
    if #to > 0 then
      room:damage{
        from = player,
        to = room:getPlayerById(to[1]),
        damage = 2,
        skillName = self.name,
      }
    end
  end,
}
local v22__kuiji_trigger = fk.CreateTriggerSkill{
  name = "#v22__kuiji_trigger",
  mute = true,
  events = {fk.EnterDying},
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
      to = room:askForChoosePlayers(player, targets, 1, 1, "#v22__kuiji-recover", "v22__kuiji", false, true)[1]
    end
    room:doIndicate(player.id, {to})
    room:recover({
      who = room:getPlayerById(to),
      num = 1,
      recoverBy = player,
      skillName = "v22__kuiji"
    })
  end,
}
Fk:loadTranslationTable{
  ["v22__kuiji"] = "溃击",
  [":v22__kuiji"] = "出牌阶段限一次，你可以将一张黑色基本牌当作【兵粮寸断】置于你的判定区，然后摸一张牌。若如此做，你可以对体力值最多的一名敌方角色"..
  "造成2点伤害，其因此进入濒死状态时，体力值最少的一名友方角色回复1点体力。",
  ["#v22__kuiji"] = "溃击：将一张黑色基本牌当【兵粮寸断】置于你的判定区并摸一张牌，然后对一名体力最多的敌方造成2点伤害",
  ["#v22__kuiji-damage"] = "溃击：你可以对体力值最多的一名敌方造成2点伤害",
  ["#v22__kuiji-recover"] = "溃击：令体力值最少的一名友方回复1点体力",

  ["$v22__kuiji1"] = "绝域奋击，孤注一掷。",
  ["$v22__kuiji2"] = "舍得一身剐，不畏君王威。",
}

local huangfusong = General(extension, "vd__huangfusong", "qun", 4)
local vd__fenyue = fk.CreateActiveSkill{
  name = "vd__fenyue",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  times = function(self)
    return Self.phase == Player.Play and
    #table.filter(Fk:currentRoom().alive_players, function (p)
      return p.role == "loyalist"
    end) - Self:usedSkillTimes(self.name, Player.HistoryPhase) or -1
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) <
      #table.filter(Fk:currentRoom().alive_players, function (p)
        return p.role == "loyalist"
      end)
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id and Self:canPindian(Fk:currentRoom():getPlayerById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local pindian = player:pindian({target}, self.name)
    if pindian.results[target.id].winner == player then
      if player:prohibitUse(Fk:cloneCard("slash")) or player:isProhibited(target, Fk:cloneCard("slash")) or room:askForChoice(player, {"vd__fenyue_slash", "vd__fenyue_prohibit"}, self.name) == "vd__fenyue_prohibit" then
        room:setPlayerMark(target, "@@vd__fenyue-turn", 1)
      else
        room:useVirtualCard("slash", nil, player, target, self.name, true)
      end
    else
      player:endPlayPhase()
    end
  end,
}
local vd__fenyue_prohibit = fk.CreateProhibitSkill{
  name = "#vd__fenyue_prohibit",
  prohibit_use = function(self, player, card)
    if player:getMark("@@vd__fenyue-turn") > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player.player_cards[Player.Hand], id)
      end)
    end
  end,
  prohibit_response = function(self, player, card)
    if player:getMark("@@vd__fenyue-turn") > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player.player_cards[Player.Hand], id)
      end)
    end
  end,
}
Fk:loadTranslationTable{
  ["vd__fenyue"] = "奋钺",
  [":vd__fenyue"] = "出牌阶段限X次，你可以与一名角色拼点，若你赢，你选择一项：1.其不能使用或打出手牌直到回合结束；2.视为你对其使用一张不计入次数的【杀】。若你没赢，你结束出牌阶段(X为存活的忠臣数)。",
  ["vd__fenyue_slash"] = "视为对其使用【杀】",
  ["vd__fenyue_prohibit"] = "本回合禁止其使用/打出手牌",
  ["@@vd__fenyue-turn"] = "被奋钺",
}

local var__yangyan = General(extension, "var__yangyan", "jin", 3, 3, General.Female)
local nos__xuanbei = fk.CreateTriggerSkill{
  name = "nos__xuanbei",
  anim_type = "support",
  events = {fk.GameStart, fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.GameStart then
        return true
      elseif event == fk.CardUseFinished then
        return target == player and not data.card:isVirtual() and
          table.find({"@fujia", "@kongchao", "@canqu", "@zhuzhan"}, function(mark) return data.card:getMark(mark) ~= 0 end) and
          player.room:getCardArea(data.card.id) == Card.Processing and
          player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.GameStart then
      return true
    elseif event == fk.CardUseFinished then
      local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player, false), Util.IdMapper),
        1, 1, "#nos__xuanbei-give:::"..data.card:toLogString(), self.name, true)
      if #to > 0 then
        self.cost_data = {tos = to}
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart then
      local cards = {}
      for _, id in ipairs(room.draw_pile) do
        if table.find({"@fujia", "@kongchao", "@canqu", "@zhuzhan"}, function(mark) return Fk:getCardById(id):getMark(mark) ~= 0 end) then
          table.insert(cards, id)
        end
      end
      if #cards > 0 then
        room:moveCardTo(table.random(cards, 2), Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, false, player.id)
      end
    elseif event == fk.CardUseFinished then
      room:moveCardTo(data.card, Card.PlayerHand, room:getPlayerById(self.cost_data.tos[1]), fk.ReasonGive, self.name, nil, true, player.id)
    end
  end,
}
Fk:loadTranslationTable{
  ["nos__xuanbei"] = "选备",
  [":nos__xuanbei"] = "游戏开始时，你获得两张带有应变效果的牌。每回合限一次，当你使用带有应变效果的牌结算后，你可以将之交给一名其他角色。",
  ["#nos__xuanbei-give"] = "选备：你可以将 %arg 交给一名其他角色",

  ["$nos__xuanbei1"] = "男胤有德色，愿陛下以备六宫。",
  ["$nos__xuanbei2"] = "广集良家，召充选者使吾拣择。",
}
