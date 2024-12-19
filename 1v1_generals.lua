-- SPDX-License-Identifier: GPL-3.0-or-later
local extension = Package("1v1_generals")
extension.extensionName = "gamemode"
extension.game_modes_whitelist = {
  "m_1v1_mode",
}

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["1v1_generals"] = "1v1专属武将",
}

-- 流放一名角色（其必须流放区小于3且有剩余武将）
---@param player ServerPlayer @ 操作者
---@param to ServerPlayer @ 被流放的角色
---@return string|nil @ 返回被流放的武将名，无法流放返回nil
local exilePlayer = function(player, to)
  local room = player.room
  local exiled_name = to.role == "lord" and "@&firstExiled" or "@&secondExiled"
  local exiled_generals = room:getBanner(exiled_name) or  {}
  if #exiled_generals > 2 then return nil end
  local rest_name = to.role == "lord" and "@&firstGenerals" or "@&secondGenerals"
  local rest_genrals = room:getBanner(rest_name) or {}
  if #rest_genrals == 0 then return nil end
  -- add prompt for general to exile
  local general = room:askForGeneral(player, rest_genrals, 1, true) ---@type string
  table.insert(exiled_generals, general)
  room:setBanner(exiled_name, exiled_generals)
  table.removeOne(rest_genrals, general)
  room:setBanner(rest_name, rest_genrals)
  return general
end

-- 标将改1v1
--张辽 许褚 甄姬 夏侯渊 刘备 关羽 马超 黄月英 魏延 姜维 孟获 祝融 孙权 甘宁 吕蒙 大乔 孙尚香 貂蝉 华佗 庞德

local xuchu = General(extension, "v11__xuchu", "wei", 4)
xuchu:addSkill("luoyi")

local v11__xiechan = fk.CreateActiveSkill{
  name = "v11__xiechan",
  anim_type = "offensive",
  card_num = 0,
  target_num = 0,
  prompt = "#v11__xiechan",
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and player:canPindian(player.next)
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local to = player.next
    local pindian = player:pindian({to}, self.name)
    local user = (pindian.results[to.id].winner == player) and {player, to} or {to, player}
    room:useVirtualCard("duel", nil, user[1], user[2], self.name)
  end,
}
xuchu:addSkill(v11__xiechan)

Fk:loadTranslationTable{
  ["v11__xuchu"] = "许褚",
  ["#v11__xuchu"] = "虎痴",
  ["v11__xiechan"] = "挟缠",
  [":v11__xiechan"] = "限定技，出牌阶段，你可以与对手拼点，若你赢，则你视为对其使用一张【决斗】，否则其视为对你使用一张【决斗】。",
  ["#v11__xiechan"] = "挟缠：你可以与对手拼点，若赢你视为对其使用【决斗】，否则其对你使用【决斗】",
  ["$v11__xiechan1"] = "休走，你我今日定要分个胜负！",
  ["$v11__xiechan2"] = "不是你死，便是我亡！",
}

local liubei = General(extension, "v11__liubei", "shu", 4)

local renwang = fk.CreateTriggerSkill{
  name = "v11__renwang",
  anim_type = "defensive",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target ~= player and not target:isNude() and target.phase == Player.Play
      and table.contains(TargetGroup:getRealTargets(data.tos), player.id)
      and (data.card.trueName == "slash" or data.card:isCommonTrick()) then
      return #player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data[1]
        return use.from == target.id and use ~= data and (use.card.trueName == "slash" or use.card:isCommonTrick())
        and table.contains(TargetGroup:getRealTargets(use.tos), player.id)
      end, Player.HistoryPhase) > 0
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local id = room:askForCardChosen(player, target, "he", self.name)
    room:throwCard(id, self.name, target, player)
  end,
}
liubei:addSkill(renwang)

Fk:loadTranslationTable{
  ["v11__liubei"] = "刘备",
  ["#v11__liubei"] = "乱世的枭雄",
  ["v11__renwang"] = "仁望",
  [":v11__renwang"] = "当对手于其出牌阶段内对你使用【杀】或普通锦囊牌时，若本阶段你已成为过上述牌的目标，你可以弃置其一张牌。",
  ["$v11__renwang1"] = "忍无可忍，无需再忍！",
  ["$v11__renwang2"] = "休怪我无情了！",
}

local guanyu = General(extension, "v11__guanyu", "shu", 4)

local huwei = fk.CreateTriggerSkill{
  name = "v11__huwei",
  events = {"fk.Debut"},
  on_use = function(self, event, target, player, data)
    player.room:useVirtualCard("drowning", nil, player, player.next, self.name)
  end,
}
guanyu:addSkill("wusheng")
guanyu:addSkill(huwei)

Fk:loadTranslationTable{
  ["v11__guanyu"] = "关羽",
  ["#v11__guanyu"] = "美髯公",
  ["v11__huwei"] = "虎威",
  [":v11__huwei"] = "当你登场时，你可以视为对对手使用一张【水淹七军】。",
  ["$v11__huwei1"] = "传令，发动水计！",
  ["$v11__huwei2"] = "来人，引水对敌！",
}

local huangyueying = General(extension, "v11__huangyueying", "shu", 3, 3, General.Female)

local cangji = fk.CreateTriggerSkill{
  name = "v11__cangji",
  events = {fk.Death, "fk.Debut"},
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if event == fk.Death then
        return player:hasSkill(self, false, true) and #player:getCardIds("e") > 0
      else
        return player.tag["v11__cangji"] ~= nil
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    return event ~= fk.Death or player.room:askForSkillInvoke(player, self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.Death then
      local cards = player:getCardIds("e")
      player.tag["v11__cangji"] = cards
      room:moveCardTo(cards, Card.Void, nil, fk.ReasonJustMove, self.name, nil, true, player.id)
    else
      local cards = table.simpleClone(player.tag["v11__cangji"])
      player.tag["v11__cangji"] = nil
      room:moveCardIntoEquip(player, cards, self.name, false, player)
    end
  end,
}

huangyueying:addSkill("jizhi")
huangyueying:addSkill(cangji)

Fk:loadTranslationTable{
  ["v11__huangyueying"] = "黄月英",
  ["#v11__huangyueying"] = "归隐的杰女",
  ["v11__cangji"] = "藏机",
  [":v11__cangji"] = "当你死亡时，你可以将你装备区里的所有牌移出游戏，然后你的下一名武将登场时将这些牌置入你的装备区。",
}

local ganning = General(extension, "v11__ganning", "wu", 4)

local qixi = fk.CreateViewAsSkill{
  name = "v11__qixi",
  anim_type = "control",
  pattern = "dismantlement",
  prompt = "#v11__qixi",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return nil end
    local c = Fk:cloneCard("v11__dismantlement")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end
}
ganning:addSkill(qixi)

Fk:loadTranslationTable{
  ["v11__ganning"] = "甘宁",
  ["#v11__ganning"] = "锦帆游侠",
  ["v11__qixi"] = "奇袭",
  [":v11__qixi"] = "你可以将一张黑色牌当【过河拆桥】（1v1版）使用。",
  ["#v11__qixi"] = "你可以将一张黑色牌当【过河拆桥】（1v1版）使用。",
}

local lvmeng = General(extension, "v11__lvmeng", "wu", 4)

local v11__shenju = fk.CreateMaxCardsSkill{
  name = "v11__shenju",
  correct_func = function(self, player)
    if player:hasSkill(self) then
      return player.next.hp
    end
  end,
}
lvmeng:addSkill(v11__shenju)

local botu = fk.CreateTriggerSkill{
  name = "v11__botu",
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
    and #player:getTableMark("@v11__botu-turn") == 4
  end,
  on_use = function(self, event, target, player, data)
    player:gainAnExtraTurn()
  end,

  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return player == target and player:hasSkill(self, true) and player.phase == Player.Play
    and data.card.suit ~= Card.NoSuit and #player:getTableMark("@v11__botu-turn") < 4
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addTableMarkIfNeed(player, "@v11__botu-turn", data.card:getSuitString(true))
  end,
}
lvmeng:addSkill(botu)

Fk:loadTranslationTable{
  ["v11__lvmeng"] = "吕蒙",
  ["#v11__lvmeng"] = "白衣渡江",

  ["v11__shenju"] = "慎拒",
  [":v11__shenju"] = "锁定技，你的手牌上限+X（X为对手的体力值）。",
  ["v11__botu"] = "博图",
  [":v11__botu"] = "回合结束时，若你于出牌阶段内使用过的牌中包含四种花色，你可以执行一个额外的回合。",
  ["@v11__botu-turn"] = "博图",
  ["$v11__botu1"] = "今日起兵，渡江攻敌！",
  ["$v11__botu2"] = "时机已到，全军出击！",
}

local daqiao = General(extension, "v11__daqiao", "wu", 3, 3, General.Female)
daqiao:addSkill("guose")

local wanrong = fk.CreateTriggerSkill{
  name = "v11__wanrong",
  anim_type = "drawcard",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
daqiao:addSkill(wanrong)

Fk:loadTranslationTable{
  ["v11__daqiao"] = "大乔",
  ["#v11__daqiao"] = "矜持之花",
  ["v11__wanrong"] = "婉容",
  [":v11__wanrong"] = "当你成为【杀】的目标后，你可以摸一张牌。",
  ["$v11__wanrong1"] = "呵哼哼~",
  ["$v11__wanrong2"] = "看这里，看这里哦~",
}

local sunshangxiang = General(extension, "v11__sunshangxiang", "wu", 3, 3, General.Female)
sunshangxiang:addSkill("xiaoji")

local yinli = fk.CreateTriggerSkill{
  name = "v11__yinli",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player.phase == Player.NotActive then
      local ids = {}
      local room = player.room
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          if move.from and move.from ~= player.id then
            for _, info in ipairs(move.moveInfo) do
              if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              Fk:getCardById(info.cardId).type == Card.TypeEquip and
              room:getCardArea(info.cardId) == Card.DiscardPile then
                table.insertIfNeed(ids, info.cardId)
              end
            end
          end
        end
      end
      ids = U.moveCardsHoldingAreaCheck(room, ids)
      if #ids > 0 then
        self.cost_data = ids
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = table.simpleClone(self.cost_data)
    if #ids > 1 then
      local cards, _ = U.askforChooseCardsAndChoice(player, ids, {"OK"}, self.name,
      "#v11__yinli-choose", {"get_all"}, 1, #ids)
      if #cards > 0 then
        ids = cards
      end
    end
    room:moveCardTo(ids, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)
  end,
}
sunshangxiang:addSkill(yinli)

Fk:loadTranslationTable{
  ["v11__sunshangxiang"] = "孙尚香",
  ["#v11__sunshangxiang"] = "弓腰姬",

  ["v11__yinli"] = "姻礼",
  [":v11__yinli"] = "对手的回合内，当该角色的装备牌置入弃牌堆时，你可以获得之。",
  ["#v11__yinli-choose"] = "姻礼：选择你要获得的装备牌",
  ["$v11__yinli1"] = "这份大礼我收下啦！",
  ["$v11__yinli2"] = "小女子谢过将军。",
}

local diaochan = General(extension, "v11__diaochan", "qun", 3, 3, General.Female)
diaochan:addSkill("biyue")

local v11__pianyi = fk.CreateTriggerSkill{
  name = "v11__pianyi",
  anim_type = "control",
  frequency = Skill.Compulsory,
  events = {"fk.Debut"},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.room.current ~= player
  end,
  on_use = function(self, event, target, player, data)
    player.room:endTurn()
  end,
}
diaochan:addSkill(v11__pianyi)

Fk:loadTranslationTable{
  ["v11__diaochan"] = "貂蝉",
  ["#v11__diaochan"] = "绝世的舞姬",

  ["v11__pianyi"] = "翩仪",
  [":v11__pianyi"] = "锁定技，当你登场时，若此时是对手的回合，对手结束此回合。",
  ["$v11__pianyi1"] = "呵呵~不能动了吧。",
  ["$v11__pianyi2"] = "将军看呆了吗？",
}

local huatuo = General(extension, "v11__huatuo", "qun", 3)
huatuo:addSkill("jijiu")

local v11__puji = fk.CreateActiveSkill{
  name = "v11__puji",
  anim_type = "control",
  card_num = 1,
  target_num = 0,
  prompt = "#v11__puji",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player.next:isNude()
  end,
  card_filter = function (self, to_select, selected)
    return #selected == 0 and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local drawers = {}
    if Fk:getCardById(effect.cards[1]).suit == Card.Spade then
      table.insert(drawers, player)
    end
    room:throwCard(effect.cards, self.name, player, player)
    local to = player.next
    if not to:isNude() then
      local cid = room:askForCardChosen(player, to, "he", self.name)
      if Fk:getCardById(cid).suit == Card.Spade then
        table.insert(drawers, to)
      end
      room:throwCard(cid, self.name, to, player)
    end
    for _, p in ipairs(drawers) do
      if not p.dead then
        p:drawCards(1, self.name)
      end
    end
  end,
}
huatuo:addSkill(v11__puji)

Fk:loadTranslationTable{
  ["v11__huatuo"] = "华佗",
  ["#v11__huatuo"] = "神医",
  ["v11__puji"] = "普济",
  [":v11__puji"] = "出牌阶段限一次，若对手有牌，你可以弃置一张牌，然后弃置其一张牌。然后以此法失去♠牌的角色摸一张牌。",
  ["#v11__puji"] = "普济：你可以弃置一张牌，再弃置对手一张牌。失去♠牌的角色摸一张牌",
}

-- 已经搬运至OL身份局
Fk:loadTranslationTable{
  ["v11__hejin"] = "何进",
  ["#v11__hejin"] = "色厉内荏",
  ["v11__mouzhu"] = "谋诛",
  [":v11__mouzhu"] = "出牌阶段限一次，你可以令对手交给你一张手牌，然后若其手牌数小于你，其选择视为对你使用【杀】或【决斗】。",
  ["v11__yanhuo"] = "延祸",
  [":v11__yanhuo"] = "当你死亡时，你可以依次弃置对手X张牌（X为你的牌数）。",
}

local v11__niujin = General(extension, "v11__niujin", "wei", 4)

local v11__cuorui = fk.CreateTriggerSkill{
  name = "v11__cuorui",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {"fk.Debut", fk.EventPhaseChanging},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if event == "fk.Debut" then
        return #player.room:getBanner(player.role == "lord" and "@&firstGenerals" or "@&secondGenerals") - 2 > 0
      else
        return data.to == Player.Judge and player:getMark("_v11__cuorui") == 0
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == "fk.Debut" then
      player:drawCards(#room:getBanner(player.role == "lord" and "@&firstGenerals" or "@&secondGenerals") - 2, self.name)
    else
      room:setPlayerMark(player, "_v11__cuorui", 1)
      return true
    end
  end,
}
local v11__liewei = fk.CreateTriggerSkill{
  name = "v11__liewei",
  anim_type = "drawcard",
  events = {fk.Death},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.damage and data.damage.from and data.damage.from == player and player ~= target
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(3, self.name)
  end,
}
v11__niujin:addSkill(v11__cuorui)
v11__niujin:addSkill(v11__liewei)
Fk:loadTranslationTable{
  ["v11__niujin"] = "牛金",
  ["#v11__niujin"] = "独进的兵胆",
  ["illustrator:v11__niujin"] = "青骑士",

  ["v11__cuorui"] = "挫锐",
  [":v11__cuorui"] = "锁定技，当你登场时，你摸X-2张牌（X为你的备用武将数）；你跳过登场后的第一个判定阶段。",
  ["v11__liewei"] = "裂围",
  [":v11__liewei"] = "当你杀死对手的角色后，你可以摸三张牌。",

  ["$v11__cuorui1"] = "区区乌合之众，如何困得住我？！",
  ["$v11__cuorui2"] = "今日就让你见识见识老牛的厉害！",
  ["$v11__liewei1"] = "敌阵已乱，速速突围！",
  ["$v11__liewei2"] = "杀你，如同捻死一只蚂蚁！",
  ["~v11__niujin"] = "这包围圈太厚，老牛，尽力了……",
}

Fk:loadTranslationTable{
  ["v11__hansui"] = "韩遂",
  ["v11__xiaoxi"] = "骁袭",
  [":v11__xiaoxi"] = "当你登场时，你可以视为使用一张【杀】。",
  ["v11__niluan"] = "逆乱",
  [":v11__niluan"] = "对手的结束阶段，若其体力值大于你，或其本回合对你使用过【杀】，你可以将一张黑色牌当【杀】对其使用。",
}

local xiangchong = General(extension, "v11__xiangchong", "shu", 4)

local v11__changjun = fk.CreateViewAsSkill{
  name = "v11__changjun",
  pattern = "slash,jink",
  prompt = "#v11__changjun",
  interaction = function()
    local names = {}
    for _, name in ipairs({"slash","jink"}) do
      local card = Fk:cloneCard(name)
      if (Fk.currentResponsePattern == nil and Self:canUse(card)) or
        (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card)) then
        table.insertIfNeed(names, card.name)
      end
    end
    if #names == 0 then return end
    return UI.ComboBox {choices = names}
  end,
  card_num = 1,
  card_filter = function (self, to_select, selected)
    return #selected == 0 and table.find(Self:getPile(self.name), function (id)
      return Fk:getCardById(id).suit == Fk:getCardById(to_select).suit
    end)
  end,
  view_as = function(self, cards)
    if not self.interaction.data or #cards ~= 1 then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = self.name
    return card
  end,
  enabled_at_play = function(self, player)
    return #player:getPile(self.name) > 0
  end,
  enabled_at_response = function(self, player)
    return #player:getPile(self.name) > 0
  end,
}

local v11__changjun_trigger = fk.CreateTriggerSkill {
  name = "#v11__changjun_trigger",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if player.phase == Player.Play then
        return player:hasSkill(v11__changjun) and not player:isNude()
      elseif player.phase == Player.Start then
        return #player:getPile("v11__changjun") > 0
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    if player.phase ~= Player.Play then return true end
    local room = player.room
    local x = 1 + tonumber(room:getBanner(player.role == "lord" and "@firstFallen" or "@secondFallen")[1])
    local cards = room:askForCard(player, 1, x, true, "v11__changjun", true, ".", "#v11__changjun-card:::"..x)
    if #cards > 0 then
      self.cost_data = cards
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player.phase == Player.Play then
      player:addToPile("v11__changjun", self.cost_data, true, "v11__changjun")
    else
      room:obtainCard(player, player:getPile("v11__changjun"), true, fk.ReasonJustMove, player.id, "v11__changjun")
    end
  end,
}
v11__changjun:addRelatedSkill(v11__changjun_trigger)
xiangchong:addSkill(v11__changjun)

local v11__aibing = fk.CreateTriggerSkill{
  name = "v11__aibing",
  events = {fk.Death, "fk.Debut"},
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if event == fk.Death then
        return player:hasSkill(self, false, true)
      else
        return player.tag["v11__aibing"]
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    return event ~= fk.Death or player.room:askForSkillInvoke(player, self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.Death then
      player.tag["v11__aibing"] = true
    else
      player.tag["v11__aibing"] = false
      room:useVirtualCard("slash", nil, player, player.next, self.name, true)
    end
  end,
}
xiangchong:addSkill(v11__aibing)

Fk:loadTranslationTable{
  ["v11__xiangchong"] = "向宠",
  ["v11__changjun"] = "畅军",
  [":v11__changjun"] = "出牌阶段开始时，你可以将至多X张牌置于你的武将牌上（X为你的登场角色序数），若如此做，直到你下回合开始，你可以将与“畅军”牌花色相同的牌当【杀】或【闪】使用或打出；准备阶段，你获得所有“畅军”牌。",
  ["#v11__changjun"] = "畅军：你可以将与“畅军”牌花色相同的牌当【杀】或【闪】使用或打出",
  ["#v11__changjun-card"] = "畅军：你可以将至多 %arg 张牌置于武将牌上，你可将与“畅军”牌花色相同的牌当【杀】或【闪】使用或打出。",
  ["#v11__changjun_trigger"] = "畅军",
  ["v11__aibing"] = "哀兵",
  [":v11__aibing"] = "当你死亡时，你可以令你下一名武将登场时视为使用一张【杀】。",
}

local v11__sunyi = General(extension, "v11__sunyi", "wu", 4)

local v11__guolie = fk.CreateTriggerSkill{
  name = "v11__guolie",
  anim_type = "offensive",
  events = {fk.CardEffectCancelledOut},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(1)
    room:moveCardTo(cards, Card.Processing, nil, fk.ReasonJustMove, self.name)
    if not player.dead then
      local card = Fk:getCardById(cards[1])
      local use = U.askForUseRealCard(room, player, cards, ".", self.name,
      "#v11__guolie-use:::"..card:toLogString(), {expand_pile = cards}, false, false)
      if not use and card.trueName == "slash" then
        room:obtainCard(player, card, true, fk.ReasonJustMove, player.id, self.name)
      end
    end
    room:cleanProcessingArea(cards, self.name)
  end,
}
v11__sunyi:addSkill(v11__guolie)

local hunbi = fk.CreateTriggerSkill{
  name = "v11__hunbi",
  events = {fk.Death, "fk.Debut"},
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if event == fk.Death then
        if player:hasSkill(self, false, true) then
          local rest = player.room:getBanner(player.next.role == "lord" and "@&firstExiled" or "@&secondExiled") or {}
          return #rest < 3
        end
      else
        return player.tag["v11__hunbi"]
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    return event ~= fk.Death or player.room:askForSkillInvoke(player, self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.Death then
      player.tag["v11__hunbi"] = true
    else
      player.tag["v11__hunbi"] = false
      local to = player.next
      local all_choices = {"draw1", "#v11__hunbi_slash", "#v11__hunbi_exile"}
      local choices = table.simpleClone(all_choices)
      if not player:canUseTo(Fk:cloneCard("slash"), to, {bypass_distances = true, bypass_times = true}) then
        table.remove(choices, 2)
      end
      local choice = room:askForChoice(player, choices, self.name, "", false, all_choices)
      if choice == all_choices[1] then
        player:drawCards(1, self.name)
      elseif choice == all_choices[2] then
        room:useVirtualCard("slash", nil, player, to, self.name, true)
      else
        for i = 1, 2 do
          exilePlayer(player, to)
        end
      end
    end
  end,
}
v11__sunyi:addSkill(hunbi)

Fk:loadTranslationTable{
  ["v11__sunyi"] = "孙翊",
  ["v11__guolie"] = "果烈",
  [":v11__guolie"] = "当你使用【杀】被【闪】抵消时，你可以亮出牌堆顶牌，若你：可以使用此牌，则使用之；不能使用且为【杀】，你获得之。",
  ["v11__hunbi"] = "魂弼",
  [":v11__hunbi"] = "当你死亡时，若对手的流放区未饱和，你可以令你下一名武将登场时选择一项：1.视为使用一张【杀】；2.摸一张牌；3.对对手执行至多两次流放。",

  ["#v11__guolie-use"] = "果烈：你须使用 %arg",
  ["v11__guolie_vs"] = "果烈",
  ["#v11__hunbi_slash"] = "视为使用【杀】",
  ["#v11__hunbi_exile"] = "对对手执行两次流放",
}

Fk:loadTranslationTable{
  ["v11__duosidawang"] = "朵思大王",
  ["v11__mihuo"] = "迷惑",
  [":v11__mihuo"] = "对手使用的锦囊牌结算完毕进入弃牌堆时，你可以将之置于你的武将牌上。对手不能使用与“迷惑”同名的牌。",
  ["v11__fanshu"] = "反术",
  [":v11__fanshu"] = "出牌阶段限一次，你可以将一张“迷惑”牌当任意一张“迷惑”牌使用。",
}

local v11__zhuyi = General(extension, "v11__zhuyi", "qun", 4)

local v11__chengji = fk.CreateTriggerSkill{
  name = "v11__chengji",
  anim_type = "masochism",
  events = {fk.Damage, fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and data.card and #player:getPile(self.name) < 4 then
      local room = player.room
      local subcards = Card:getIdList(data.card)
      return #subcards > 0 and table.every(subcards, function(id) return room:getCardArea(id) == Card.Processing end)
    end
  end,
  on_use = function(self, event, target, player, data)
    player:addToPile(self.name, data.card, true, self.name)
  end,
}
local v11__chengji_trigger = fk.CreateTriggerSkill{
  name = "#v11__chengji_trigger",
  mute = true,
  events = {fk.Death, "fk.Debut"},
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if event == fk.Death then
        return #player:getPile("v11__chengji") > 0 and player.room.settings.gameMode == "m_1v1_mode"
      else
        return player.room:getTag("v11__chengji"..player.id) ~= nil
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.Death then
      room:setTag("v11__chengji"..player.id, table.simpleClone(player:getPile("v11__chengji")))
      room:moveCardTo(player:getPile("v11__chengji"), Card.Void, nil, fk.ReasonJustMove, "v11__chengji", nil, true, player.id)
    else
      local cards = table.simpleClone(room:getTag("v11__chengji"..player.id))
      room:removeTag("v11__chengji"..player.id)
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, "v11__chengji", nil, true, player.id)
    end
  end,
}
v11__chengji:addRelatedSkill(v11__chengji_trigger)
v11__zhuyi:addSkill(v11__chengji)
Fk:loadTranslationTable{
  ["v11__zhuyi"] = "注诣",
  ["v11__chengji"] = "城棘",
  [":v11__chengji"] = "当你造成或受到伤害后，若“城棘”牌少于四张，你可以将造成伤害的牌置于你的武将牌上。你死亡后，你的下一名武将登场时获得所有“城棘”牌。",
}








return extension
