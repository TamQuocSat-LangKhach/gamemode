-- SPDX-License-Identifier: GPL-3.0-or-later

local zombie_desc = [=====[
  # 僵尸模式简介

  僵尸模式，当年太阳神三国杀中由 trinfly 和 hypercross 设计，并由 hypercross 实现。
  （膜拜！）又名生化模式。如今挪到新月杀中又实现一下。

  ___

  ## 身份说明

  游戏初始身份配置为一个主公和七名忠臣。

  各个身份胜利条件：

  - 主公：幸存者的头目，目标是杀死全部僵尸或者集齐8枚“退治”标记，拯救世界。
  - 忠臣：诸多幸存者之一，目标是辅佐主公消灭僵尸，胜利条件与主公一致。
  - 反贼：僵尸病毒的感染源头，目标是杀死所有人类玩家，使天下大乱。
  - 内奸：被僵尸感染的可怜人，无论如何无法获胜。但是可以通过杀死人类玩家将身份变为反贼。

  ___

  ## 流程说明

  游戏开始时，由主公选择武将。之后，其他玩家选择武将。
  此时，场上的身份配置是1主7忠。主公的生命上限+1。

  主公在准备阶段获得1枚“退治”标记。若“退治”标记数量达到8，主忠直接获胜。

  在游戏的第二轮，有两名忠臣会在回合开始时立刻死亡，然后变成反贼复活。
  复活时，该玩家将体力值和体力上限调整为5，并获得僵尸副将，且在复活时摸5张牌。

  ___

  ## 专属武将：僵尸

  成为僵尸的玩家，其副将会变成“僵尸”。僵尸具有以下技能：

  - **咆哮**：锁定技，出牌阶段，你使用【杀】无次数限制。
  - **完杀**：锁定技，除进行濒死流程的角色以外的其他角色于你的回合内不能使用【桃】。
  - **迅猛**：锁定技，你的【杀】造成伤害时，令此伤害+1，若此时你的体力值大于1，则你失去1点体力。
  - **灾变**：锁定技，出牌阶段开始时，若人类玩家数-僵尸玩家数+1大于0，则你摸取该数目的牌。
  - **感染**：锁定技，你手牌中的装备牌视为【铁索连环】。

  ___

  ## 奖惩规则

  任意玩家杀死僵尸时，该玩家摸3张牌，生命值回复至上限。

  人类玩家杀死人类时，弃掉所有牌。

  僵尸玩家杀死人类时，该人类玩家在死亡后成为内奸复活，
  生命上限为杀死他的僵尸玩家的生命上限的一半（向上取整）。
  复活时该玩家生命值回复至上限，主武将不变、副武将为僵尸。
  之后杀死人类的僵尸玩家身份若为内奸，则该玩家身份变为反贼。

  若主公死亡，则下一名忠臣玩家立即成为主公，生命与上限+1，
  并获取相当于原主公退治标记数-1的退治标记。

  ___

  ## 游戏结束条件

  - 主公集齐8枚“退治”标记：僵尸被退治，主忠获胜。
  - 僵尸全部死亡：主忠获胜。
  - 人类全部死亡：反贼获胜。注意内奸在杀死最后一名人类的时候，
  身份会先变成反贼再结算胜负。
  - 同类相残惩罚：当场上在没有僵尸（包括死亡的僵尸）时，只剩一名人类存活，则反贼获胜；
  或者在第三轮开始时，若场上没有僵尸（包括已死亡），那么反贼也获胜。
  所以人类切勿在灾变开始之前就自相残杀啊。
]=====]

local zombie_getLogic = function()
  local zombie_logic = GameLogic:subclass("zombie_logic")

  function zombie_logic:assignRoles()
    local room = self.room
    local n = #room.players
    local roles = {
      "lord", "loyalist", "loyalist", "loyalist",
      "loyalist", "loyalist", "loyalist", "loyalist",
    }

    for i = 1, n do
      local p = room.players[i]
      p.role = roles[i]
      room:setPlayerProperty(p, "role_shown", true)
      room:broadcastProperty(p, "role")
    end
    room:setTag("SkipNormalDeathProcess", true)
  end

  return zombie_logic
end

local zombie_mode = fk.CreateGameMode{
  name = "zombie_mode",
  minPlayer = 8,
  maxPlayer = 8,
  logic = zombie_getLogic,
  rule = "#zombie_rule&",
  winner_getter = function(self, victim)
    if not victim.surrendered and victim.rest > 0 then
      return ""
    end
    local room = victim.room
    local haszombie = table.find(room.players, function(p)
      return p.role == "rebel"
    end) ~= nil

    local alive = table.filter(room.players, function(p)
      return not p.surrendered and not (p.dead and p.rest == 0)
    end)
    if #alive == 1 and not haszombie then
      return "rebel"
    end

    local rebel_win = true
    local lord_win = haszombie
    for _, p in ipairs(alive) do
      if table.contains({ "lord", "loyalist" }, p.role) then
        rebel_win = false
      end
      if table.contains({ "rebel", "renegade" }, p.role) then
        lord_win = false
      end
    end

    local winner
    if lord_win then winner = "lord+loyalist" end
    if rebel_win then winner = "rebel" end

    return winner
  end,
}

Fk:loadTranslationTable{
  ["zombie_mode"] = "僵尸模式",
  [":zombie_mode"] = zombie_desc,
}

return zombie_mode
