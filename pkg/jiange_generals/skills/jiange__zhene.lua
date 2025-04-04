local jiange__zhene = fk.CreateSkill {
  name = "jiange__zhene"
}

Fk:loadTranslationTable{
  ['jiange__zhene'] = '震恶',
  [':jiange__zhene'] = '锁定技，当你于出牌阶段使用牌指定目标后，若目标角色手牌数不大于你，其不能响应。',
}

jiange__zhene:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and player.phase == Player.Play and
      (data.card.type == Card.TypeBasic or data.card:isCommonTrick()) and
      player.room:getPlayerById(data.to):getHandcardNum() <= player:getHandcardNum()
  end,
  on_use = function(self, event, target, player, data)
    data.disresponsiveList = data.disresponsiveList or {}
    table.insert(data.disresponsiveList, data.to)
  end,
})

return jiange__zhene
