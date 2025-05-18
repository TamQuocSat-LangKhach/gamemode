local desc_chaos = [[
  # 文和乱武简介

  ---

  ## 身份说明

  游戏由八名玩家进行，**一人一伙，各自为战**，胜利目标为活到最后吃鸡！

  游戏目标：按照角色阵亡顺序进行排名，最终存活的玩家为第一名，依照名次结算积分。

  击杀奖惩：击杀一名其他角色后，击杀者增加1点体力上限并摸三张牌。

  另外每名角色都有〖完杀〗。首轮时，已受伤角色视为拥有〖八阵〗。

  ---

  ## 特殊事件
  
  每轮开始时，执行一个特殊事件。第一轮固定为“乱武”，之后每一轮均随机执行一个。共有以下7条特殊事件：

  **乱武**：从随机一名角色开始结算〖乱武〗（所有角色，需对距离最近的一名角色使用一张【杀】，否则失去1点体力）。

  **重赏**：本轮中，击杀角色奖励翻倍。

  **破釜沉舟**：每个回合开始时，当前回合角色失去1点体力，摸三张牌。

  **横刀跃马**：每个回合结束时，所有装备最少的角色失去1点体力，随机将牌堆里的一张装备牌置入其装备区。

  **横扫千军**：本轮中，所有伤害值+1。

  **饿莩载道**：本轮结束时，所有手牌最少的角色失去X点体力。（X为轮数）

  **宴安鸩毒**：本轮中，所有的【桃】均视为【毒】。（【毒】：锁定技，当此牌正面朝上离开你的手牌区后，你失去1点体力。出牌阶段，你可对自己使用。）

  ---

  ## 特殊锦囊牌

  【**斗转星移**】：出牌阶段，对一名其他角色使用。随机分配你和其的体力（至少为1且无法超出上限）。<font color="#CC3131">♥</font>A/<font color="#CC3131">♦</font>5。

  【**李代桃僵**】：出牌阶段，对一名其他角色使用。随机分配你和其的手牌。♦Q/<font color="#CC3131">♥</font>A/<font color="#CC3131">♥</font>K。

  【**偷梁换柱**】：出牌阶段，对你使用。随机分配所有角色装备区里的牌。♠J/♣Q/♣K/♠K。

  【**文和乱武**】：出牌阶段，对其他角色使用。目标角色各选择一项：1. 对距离最近的一名角色使用【杀】；2. 失去1点体力。♠10/♣4。

  移除兵、乐、无懈、桃园和木马

  ---

  鼓励收人头来“舔包”来加快游戏节奏。

  特殊规则均为了加快游戏进度的效果，并且含有极大随机性，玩家需要提前提防某些情况发生。

  特殊锦囊设置将拖慢游戏节奏的牌移除，改为引进了具有随机性甚至足以改变战局的锦囊牌。
]]

local chaos_getLogic = function()
  local chaos_logic = GameLogic:subclass("chaos_logic") ---@class GameLogic

  function chaos_logic:assignRoles()
    local room = self.room
    local n = #room.players

    for i = 1, n do
      local p = room.players[i]
      p.role = "hidden"
      room:setPlayerProperty(p, "role_shown", true)
      room:broadcastProperty(p, "role")
      --p.role = p._splayer:getScreenName() --结算显示更好，但身份图标疯狂报错
    end

    self.start_role = "hidden"
    -- for adjustSeats
    room.players[1].role = "lord"
  end

  function chaos_logic:chooseGenerals()
    local room = self.room
    local generalNum = room.settings.generalNum
    local n = room.settings.enableDeputy and 2 or 1
    local lord = room:getLord()
    room:setCurrent(lord)
    lord.role = self.start_role

    local players = room.players
    local generals = room:getNGenerals(#players * generalNum)
    local req = Request:new(players, "AskForGeneral")
    table.shuffle(generals)
    for i, p in ipairs(players) do
      local arg = table.slice(generals, (i - 1) * generalNum + 1, i * generalNum + 1)
      req:setData(p, { arg, n })
      req:setDefaultReply(p, table.random(arg, n))
    end

    room:doBroadcastNotify("ShowToast", Fk:translate("chaos_intro"))

    req:ask()

    local selected = {}
    for _, p in ipairs(players) do
      local gs = req:getResult(p)
      local general = gs[1]
      local deputy = gs[2]
      room:setPlayerGeneral(p, general, true, true)
      room:setDeputyGeneral(p, deputy)
    end
    generals = table.filter(generals, function(g) return not table.contains(selected, g) end)
    room:returnToGeneralPile(generals)

    room:askToChooseKingdom(players)

    room:addSkill("#chaos_rule&")
  end

  return chaos_logic
end

local chaos_mode = fk.CreateGameMode{
  name = "chaos_mode",
  minPlayer = 6,
  maxPlayer = 8,
  rule = Fk.skills["#chaos_rule&"] --[[@as TriggerSkill]],
  logic = chaos_getLogic,
  surrender_func = function(self, playedTime)
    return { {
      text = "chaos: left two alive",
      passed = #table.filter(Fk:currentRoom().players, function(p)
        return p.rest > 0 or not p.dead
      end) == 2
    } }
  end,
  winner_getter = function(self, victim)
    if not victim.surrendered and victim.rest > 0 then
      return ""
    end
    local room = victim.room
    local alive = table.filter(room.players, function(p)
      return not p.surrendered and not (p.dead and p.rest == 0)
    end)
    if #alive > 1 then return "" end
    alive[1].role = "renegade" --生草
    return "renegade"
  end,
  build_draw_pile = function(self)
    local draw, void = GameMode.buildDrawPile(self)
    local blacklist = {"god_salvation", "indulgence", "supply_shortage", "nullification"}
    local whitelist = {"time_flying", "substituting", "replace_with_a_fake", "wenhe_chaos"}

    for i = #void, 1, -1 do
      local id = void[i]
      local card = Fk:getCardById(id)
      local name = card.name
      if table.contains(whitelist, name) then
        table.remove(void, i)
        table.insert(draw, id)
      end
    end

    for i = #draw, 1, -1 do
      local id = draw[i]
      local card = Fk:getCardById(id)
      local name = card.name
      if table.contains(blacklist, name) then
        table.remove(draw, i)
        table.insert(void, id)
      end
    end

    return draw, void
  end,
  reward_punish = function (self, victim, killer)
    local room = victim.room
    --事件2重赏，击杀奖励翻倍
    if killer and not killer.dead then
      local invoked = room:getBanner("@[:]chaos_mode_event") == "generous_reward"
      killer:drawCards(invoked and 6 or 3, "kill")
      if not killer.dead then
        room:changeMaxHp(killer, invoked and 2 or 1)
      end
    end
  end,
  friend_enemy_judge = function (self, targetOne, targetTwo)
    return targetOne == targetTwo
  end,
}

Fk:loadTranslationTable{
  ["chaos_mode"] = "文和乱武",
  [":chaos_mode"] = desc_chaos,
  ["chaos: left two alive"] = "仅剩两名角色存活",
}

return chaos_mode
