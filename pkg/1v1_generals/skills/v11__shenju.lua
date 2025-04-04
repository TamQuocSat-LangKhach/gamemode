local v11__shenju = fk.CreateSkill {
  name = "v11__shenju"
}

Fk:loadTranslationTable{
  ['v11__shenju'] = '慎拒',
  [':v11__shenju'] = '锁定技，你的手牌上限+X（X为对手的体力值）。',
}

v11__shenju:addEffect('maxcards', {
  correct_func = function(self, player)
    if player:hasSkill(v11__shenju.name) then
      return player.next.hp
    end
  end,
})

return v11__shenju
