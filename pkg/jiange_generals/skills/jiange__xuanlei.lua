local jiange__xuanlei = fk.CreateSkill {
  name = "jiange__xuanlei",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["jiange__xuanlei"] = "玄雷",
  [":jiange__xuanlei"] = "锁定技，准备阶段，你对判定区内有牌的所有敌方角色各造成1点雷电伤害。",
}

jiange__xuanlei:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and player.phase == Player.Start and
      table.find(U.GetEnemies(player.room, player), function (p)
        return #p:getCardIds("j") > 0
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(U.GetEnemies(room, player), function (p)
      return #p:getCardIds("j") > 0
    end)
    room:doIndicate(player.id, table.map(targets, Util.IdMapper))
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if table.contains(targets, p) and not p.dead then
        room:damage({
          from = player,
          to = p,
          damage = 1,
          damageType = fk.ThunderDamage,
          skillName = jiange__xuanlei.name,
        })
      end
    end
  end,
})

return jiange__xuanlei
