

--2012：诸葛瑾
local zhugejin = General(extension, "v33__zhugejin", "wu", 3)
zhugejin.hidden = true
local huanshi = fk.CreateTriggerSkill{
  name = "v33__huanshi",
  anim_type = "support",
  events = {fk.AskForRetrial},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and table.contains(U.GetFriends(player.room, player), target) and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForResponse(player, self.name, ".", "#v33__huanshi-invoke::"..target.id, true)
    if card ~= nil then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:retrial(self.cost_data, player, data, self.name)
  end,
}
local hongyuan = fk.CreateTriggerSkill{
  name = "v33__hongyuan",
  anim_type = "support",
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.n > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.n = data.n - 1
  end,
}
local hongyuan_trigger = fk.CreateTriggerSkill{
  name = "#v33__hongyuan_trigger",
  mute = true,
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Draw and player:usedSkillTimes("v33__hongyuan", Player.HistoryPhase) > 0
  end,
  on_use = function(self, event, target, player, data)
    for _, p in ipairs(U.GetFriends(player.room, player, false)) do
      if not p.dead then
        player.room:doIndicate(player.id, {p.id})
        p:drawCards(1, "v33__hongyuan")
      end
    end
  end,
}
Fk:loadTranslationTable{
  ["v33__huanshi"] = "缓释",
  [":v33__huanshi"] = "当己方角色的判定牌生效前，你可以打出一张牌代替之。",
  ["v33__hongyuan"] = "弘援",
  [":v33__hongyuan"] = "摸牌阶段，你可以少摸一张牌，若如此做，其他己方角色各摸一张牌。",
  ["#v33__huanshi-invoke"] = "缓释：是否打出一张牌修改 %dest 的判定牌？",
}

local zhenwei = fk.CreateDistanceSkill{
  name = "v33__zhenwei",
  correct_func = function(self, from, to)
    if table.contains(U.GetEnemies(Fk:currentRoom(), from), to) then
      return #table.filter(U.GetEnemies(Fk:currentRoom(), from), function (p)
        return p:hasSkill(self)
      end)
    end
  end,
}
Fk:loadTranslationTable{
  ["v33__zhenwei"] = "镇卫",
  [":v33__zhenwei"] = "锁定技，对方角色计算与己方角色的距离+1。",
}

local xiahoudun = General(extension, "v33__xiahoudun", "wei", 4)
xiahoudun.hidden = true
local ganglie = fk.CreateTriggerSkill{
  name = "v33__ganglie",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and #U.GetEnemies(player.room, player) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(U.GetEnemies(room, player), Util.IdMapper), 1, 1,
      "#v33__ganglie-choose", self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    room:doIndicate(player.id, {to.id})
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".|.|^heart",
    }
    room:judge(judge)
    if judge.card.suit ~= Card.Heart and not to.dead then
      local discards = room:askForDiscard(to, 2, 2, false, self.name, true, nil, "#v33__ganglie-discard:"..player.id)
      if #discards < 2 then
        room:damage{
          from = player,
          to = to,
          damage = 1,
          skillName = self.name,
        }
      end
    end
  end,
}
Fk:loadTranslationTable{
  ["v33__ganglie"] = "刚烈",
  [":v33__ganglie"] = "当你受到伤害后，你可以选择一名对方角色，然后判定，若结果不为<font color='red'>♥</font>，其选择一项：1.弃置两张手牌；"..
  "2.你对其造成1点伤害。",
  ["#v33__ganglie-choose"] = "刚烈：选择一名对方角色，你进行判定，若不为<font color='red'>♥</font>，其弃置两张手牌或受到1点伤害",
  ["#v33__ganglie-discard"] = "刚烈：弃置两张手牌，否则 %src 对你造成1点伤害",

  ["$v33__ganglie1"] = "鼠辈，竟敢伤我！",
  ["$v33__ganglie2"] = "以彼之道，还施彼身！",
}

local guanyu = General(extension, "v33__guanyu", "shu", 4)
guanyu.hidden = true
local zhongyi = fk.CreateActiveSkill{
  name = "zhongyi",
  anim_type = "offensive",
  target_num = 0,
  min_card_num = 1,
  prompt = "#zhongyi",
  derived_piles = "zhongyi",
  can_use = function(self, player)
    return #player:getPile(self.name) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return Fk:getCardById(to_select).color == Card.Red
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    player:addToPile(self.name, effect.cards, true, self.name, player.id)
  end,
}
local zhongyi_delay = fk.CreateTriggerSkill{
  name = "#zhongyi_delay",
  mute = true,
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target and #player:getPile("zhongyi") > 0 and
      data.card and data.card.trueName == "slash" and
      table.contains(U.GetFriends(player.room, player), target) and
      table.contains(U.GetEnemies(player.room, player, true), data.to)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("zhongyi")
    room:notifySkillInvoked(player, "zhongyi", "offensive")
    room:moveCardTo(table.random(player:getPile("zhongyi")), Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, "zhongyi", nil, true,
      player.id)
    data.damage = data.damage + 1
  end,
}
Fk:loadTranslationTable{
  ["zhongyi"] = "忠义",
  [":zhongyi"] = "出牌阶段，若你没有“义”，你可以将任意张红色牌置为“义”。当己方角色使用【杀】对对方角色造成伤害时，你移去一张“义”，令此伤害+1。",
  ["#zhongyi"] = "忠义：将任意张红色牌置于武将牌上，友方使用【杀】造成伤害时移去一张，此伤害+1",
}

local zhaoyun = General(extension, "v33__zhaoyun", "shu", 4)
zhaoyun.hidden = true
local jiuzhu = fk.CreateTriggerSkill{
  name = "jiuzhu",
  anim_type = "support",
  events = {fk.AskForPeaches},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      table.contains(U.GetFriends(player.room, player, false), player.room:getPlayerById(data.who)) and
      player.hp > 1 and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForDiscard(player, 1, 1, true, self.name, true, nil, "#jiuzhu-invoke::"..data.who, true)
    if #card > 0 then
      self.cost_data = {cards = card}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = player.room:getPlayerById(data.who)
    room:doIndicate(player.id, {data.who})
    room:throwCard(self.cost_data.cards, self.name, player, player)
    if not player.dead then
      room:loseHp(player, 1, self.name)
    end
    if not to.dead and to:isWounded() then
      room:recover({
        who = to,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      })
    end
  end,
}
Fk:loadTranslationTable{
  ["jiuzhu"] = "救主",
  [":jiuzhu"] = "当己方一名其他角色处于濒死状态时，若你的体力值大于1，你可以弃置一张牌并失去1点体力，令该角色回复1点体力。",
  ["#jiuzhu-invoke"] = "救主：你可以弃一张牌并失去1点体力，令 %dest 回复1点体力",
}

local lvbu = General(extension, "v33_nos__lvbu", "qun", 4)
lvbu.hidden = true
local zhanshen = fk.CreateTriggerSkill{
  name = "zhanshen",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player.phase == Player.Start and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return player:isWounded() and table.find(U.GetFriends(player.room, player, true, true), function (p)
      return p.dead
    end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    if not player.dead then
      room:handleAddLoseSkills(player, "mashu|shenji", nil)
    end
  end,
}
Fk:loadTranslationTable{
  ["zhanshen"] = "战神",
  [":zhanshen"] = "觉醒技，准备阶段，若你已受伤且己方有角色已死亡，你减1点体力上限，获得技能〖马术〗和〖神戟〗。",
}

--2019：黄权
local huangquan = General(extension, "v33__huangquan", "shu", 3)
local choujin = fk.CreateTriggerSkill{
  name = "choujin",
  anim_type = "special",
  events = {fk.GamePrepared},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(U.GetEnemies(room, player), Util.IdMapper), 1, 1,
      "#choujin-choose", self.name, false)
    to = room:getPlayerById(to[1])
    room:setPlayerMark(to, "@@choujin", 1)
  end,
}
local choujin_delay = fk.CreateTriggerSkill{
  name = "#choujin_delay",
  mute = true,
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return target and player:usedSkillTimes("choujin", Player.HistoryGame) > 0 and
      data.to:getMark("@@choujin") > 0 and
      table.contains(U.GetFriends(player.room, player), target) and
      table.contains(U.GetEnemies(player.room, player, true), data.to) and
      player:getMark("choujin-turn") < 2
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("choujin")
    room:notifySkillInvoked(player, "choujin", "drawcard")
    room:addPlayerMark(player, "choujin-turn", 1)
    target:drawCards(1, "choujin")
  end,
}
local zhongjianh = fk.CreateActiveSkill{
  name = "zhongjianh",
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  prompt = "#zhongjianh",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function (self, to_select, selected)
    return #selected == 0
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(U.GetFriends(Fk:currentRoom(), Self, false), Fk:currentRoom():getPlayerById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, false, player.id)
    if not player.dead then
      player:drawCards(1, self.name)
    end
  end,
}
Fk:loadTranslationTable{
  ["choujin"] = "筹进",
  [":choujin"] = "锁定技，亮将结束后，你选择一名对方角色：每回合限两次，当己方角色对该角色造成伤害后，该己方角色摸一张牌。",
  --2023削弱版，原2019版不限敌方角色且摸牌无次数限制
  ["zhongjianh"] = "忠谏",
  [":zhongjianh"] = "出牌阶段限一次，你可以交给一名己方其他角色一张牌，然后你摸一张牌。",
  ["#choujin-choose"] = "筹进：标记一名对方角色，每回合限两次，己方角色对该角色造成伤害后摸一张牌",
  ["@@choujin"] = "筹进",
  ["#zhongjianh"] = "忠谏：交给一名己方其他角色一张牌，然后你摸一张牌",

  ["$choujin1"] = "预则立，不预则废！",
  ["$choujin2"] = "就用你，给我军祭旗！",
  ["$zhongjianh1"] = "锦上添花，不如雪中送炭。",
  ["$zhongjianh2"] = "密计交于将军，可解燃眉之困。",
}

--2023：吕布 徐盛
local v33__lvbu = General(extension, "v33__lvbu", "qun", 4)
local v33__zhanshen = fk.CreateTriggerSkill{
  name = "v33__zhanshen",
  anim_type = "special",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Start then
      for i = 1, 3, 1 do
        if player:getMark("v33__zhanshen_"..i) == 0 then
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = table.map(table.filter({1, 2, 3}, function(n)
      return player:getMark("v33__zhanshen_"..n) == 0
    end), function(n)
      return "v33__zhanshen_"..n
    end)
    local choice = room:askForChoice(player, choices, self.name, "#v33__zhanshen-choice")
    room:setPlayerMark(player, choice, 1)
  end,
}
local v33__zhanshen_trigger = fk.CreateTriggerSkill{
  name = "#v33__zhanshen_trigger",
  mute = true,
  events = {fk.DrawNCards, fk.PreCardUse, fk.AfterCardTargetDeclared},
  can_trigger = function (self, event, target, player, data)
    if target == player then
      if event == fk.DrawNCards then
        return player:getMark("v33__zhanshen_1") > 0
      elseif event == fk.PreCardUse then
        return player:getMark("v33__zhanshen_2") > 0 and data.card.trueName == "slash"
      elseif event == fk.AfterCardTargetDeclared then
        return player:getMark("v33__zhanshen_3") > 0 and data.card.trueName == "slash" and
          #player.room:getUseExtraTargets(data) > 0
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.DrawNCards or event == fk.PreCardUse then
      return true
    elseif event == fk.AfterCardTargetDeclared then
      local targets = player.room:getUseExtraTargets(data)
      local tos = player.room:askForChoosePlayers(player, targets, 1, 1,
        "#v33__zhanshen-choose:::"..data.card:toLogString(), "v33__zhanshen", true)
      if #tos > 0 then
        self.cost_data = tos
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("v33__zhanshen")
    if event == fk.DrawNCards then
      room:notifySkillInvoked(player, "v33__zhanshen", "drawcard")
      data.n = data.n + 1
    elseif event == fk.PreCardUse then
      room:notifySkillInvoked(player, "v33__zhanshen", "offensive")
      data.additionalDamage = (data.additionalDamage or 0) + 1
    elseif event == fk.AfterCardTargetDeclared then
      room:notifySkillInvoked(player, "v33__zhanshen", "offensive")
      table.insert(data.tos, self.cost_data)
    end
  end,
}
Fk:loadTranslationTable{
  ["v33__zhanshen"] = "战神",
  [":v33__zhanshen"] = "锁定技，准备阶段，你选择一项未获得过的效果，获得此效果直到本局游戏结束：<br>"..
  "1.摸牌阶段，你多摸一张牌；<br>2.你使用【杀】造成伤害+1；<br>3.你使用【杀】可以额外选择一个目标。",
  ["#v33__zhanshen-choice"] = "战神：选择一项效果，本局游戏永久获得",
  ["v33__zhanshen_1"] = "摸牌阶段多摸一张牌",
  ["v33__zhanshen_2"] = "使用【杀】伤害+1",
  ["v33__zhanshen_3"] = "使用【杀】可以额外选择一个目标",
  ["#v33__zhanshen-choose"] = "战神：你可以为此%arg增加一个目标",

  ["$v33__zhanshen1"] = "战神降世，神威再临！",
  ["$v33__zhanshen2"] = "战神既出，谁与争锋！",
}

local xusheng = General(extension, "v33__xusheng", "wu", 4)
local yicheng = fk.CreateTriggerSkill{
  name = "v33__yicheng",
  anim_type = "defensive",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and table.contains(U.GetFriends(player.room, player), target) and data.card.trueName == "slash" and
      table.contains(U.GetEnemies(player.room, player, true), player.room:getPlayerById(data.from))
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#v33__yicheng-ask::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    target:drawCards(1, self.name)
    if not target.dead and not target:isKongcheng() then
      local card = room:askForDiscard(target, 1, 1, false, self.name, false, nil, "#v33__yicheng-discard", true)
      if Fk:getCardById(card[1]).type == Card.TypeEquip and not target:prohibitDiscard(card[1]) then
        room:useCard({
          from = target.id,
          tos = {{target.id}},
          card = Fk:getCardById(card[1]),
        })
      else
        room:throwCard(card, self.name, target, target)
      end
    end
  end
}
Fk:loadTranslationTable{
  ["v33__yicheng"] = "疑城",
  [":v33__yicheng"] = "当己方角色成为敌方角色使用【杀】的目标后，你可以令其摸一张牌，然后其弃置一张手牌；若弃置的是装备牌，则改为其使用之。",
  ["#v33__yicheng-ask"] = "疑城：是否令 %dest 摸一张牌并弃置一张手牌？",
  ["#v33__yicheng-discard"] = "疑城：请弃置一张手牌，若为装备牌则改为使用之",

  ["$v33__yicheng1"] = "不怕死，就尽管放马过来！",
  ["$v33__yicheng2"] = "待末将布下疑城，以退曹贼。",
}
