local jiange__danjing = fk.CreateSkill{
  name = "jiange__danjing"
}

Fk:loadTranslationTable{
  ['jiange__danjing'] = '啖睛',
  ['#jiange__danjing-invoke'] = '啖睛：是否失去1点体力，视为对 %dest 使用【桃】？',
  [':jiange__danjing'] = '其他友方角色处于濒死状态时，若你的体力值大于1，你可以失去1点体力，视为你对其使用一张【桃】。',
}

jiange__danjing:addEffect(fk.AskForPeaches, {
  anim_type = "support",
  can_trigger = function(self, event, target, player)
    return player:hasSkill(jiange__danjing.name) and target.dying and table.contains(U.GetFriends(player.room, player, false), target) and
      player.hp > 1
  end,
  on_cost = function (skill, event, target, player)
    return player.room:askToSkillInvoke(player, {
      skill_name = jiange__danjing.name,
      prompt = "#jiange__danjing-invoke::"..target.id
    })
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    room:loseHp(player, 1, jiange__danjing.name)
    if not target.dead then
      room:useVirtualCard("peach", nil, player, target, jiange__danjing.name)
    end
  end,
})

return jiange__danjing
