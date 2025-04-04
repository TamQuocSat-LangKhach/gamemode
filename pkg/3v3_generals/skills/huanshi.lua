local huanshi = fk.CreateSkill {
  name = "v33__huanshi"
}

Fk:loadTranslationTable{
  ['v33__huanshi'] = '缓释',
  ['#v33__huanshi-invoke'] = '缓释：是否打出一张牌修改 %dest 的判定牌？',
  [':v33__huanshi'] = '当己方角色的判定牌生效前，你可以打出一张牌代替之。',
}

huanshi:addEffect(fk.AskForRetrial, {
  anim_type = "support",
  can_trigger = function(self, event, target, player)
    return player:hasSkill(huanshi.name) and table.contains(U.GetFriends(player.room, player), target) and not player:isNude()
  end,
  on_cost = function(self, event, target, player)
    local card = player.room:askToResponse(player, {
      skill_name = huanshi.name,
      pattern = ".",
      prompt = "#v33__huanshi-invoke::" .. target.id,
      cancelable = true
    })
    if card ~= nil then
      event:setCostData(huanshi, card)
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local data = event:getCostData(huanshi)
    player.room:retrial(data, player, data, huanshi.name)
  end,
})

return huanshi
