local desc_1v1 = "todo"
local desc_1v2 = "todo"
local desc_brawl = "todo"
local desc_2v2 = "todo"
local desc_chaos = "todo"
local desc_espionage = "todo"
local desc_qixi = "todo"
local desc_vanished_dragon = "todo"
local desc_variation = "todo"
local desc_zombie = "todo"

return {
  ["m_1v1_mode"] = "1v1",
  ["1v1 Lord choose"] = "Lord chose: ",
  ["1v1 Rebel choose"] = "Rebel chose: ",
  ["#1v1ChooseGeneralsLog"] = "%arg chose %arg2 %arg3",
  ["firstPlayer"] = "Lord",
  ["secondPlayer"] = "Rebel",
  ["1v1 choose general"] = "Please choose a character",
  ["1v1 score"] = "Death: Lord ",
  ["_1v1 score"] = " Rebel",
  ["@1v1_fallen"] = "Fallen",
  [":m_1v1_mode"] = desc_1v1,

  ["m_1v2_mode"] = "Happy 1v2",
  ["m_feiyang"] = "Unruly",
  [":m_feiyang"] = "At the start of you Judgement Phase: you can discard 2 hand card then discard 1 card in your judgement area.",
  ["#m_feiyang-invoke"] = "Unruly: you may discard 2 hand cards to discard 1 card in your judgement area",
  ["m_bahu"] = "Haughty",
  [":m_bahu"] = "(forced) You draw 1 card at your Prepare Phase; you can use +1 extra Slash in your Action Phase.",
  ["#m_1v2_rule"] = "Rule",
  ["m_1v2_draw2"] = "Draw 2 cards",
  ["m_1v2_heal"] = "Heal 1 HP",
  ["1v2: left you alive"] = "Only you and the lord is alive",
  [":m_1v2_mode"] = desc_1v2,

  ["brawl_mode"] = "1v2大乱斗",
  ["#brawl_rule"] = "挑选遗产",
  ["#brawl-choose"] = "请选择%arg个技能出战",
  ["@brawl_skills"] = "",
  [":brawl_mode"] = desc_brawl,

  ["m_2v2_mode"] = "2v2",
  [":m_2v2_mode"] = desc_2v2,
  ["time limitation: 2 min"] = "Game time should > 2 min",
  ["2v2: left you alive"] = "Only you are alive",

  ["chaos_mode_cards"] = "文和乱武特殊牌",
  ["poison"] = "毒",
  [":poison"] = "基本牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：体力值大于0的你<br /><b>效果</b>：目标角色失去1点体力。<br />锁定技，当此牌正面朝上离开你的手牌区后，你失去1点体力。",

  ["poison_action"] = "毒",
  ["time_flying"] = "斗转星移",
  [":time_flying"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：一名其他角色<br /><b>效果</b>：随机分配你和目标角色的体力（至少为1且无法超出上限）。",
  ["substituting"] = "李代桃僵",
  [":substituting"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：一名其他角色<br /><b>效果</b>：随机分配你和目标角色的手牌。",
  ["replace_with_a_fake"] = "偷梁换柱",
  [":replace_with_a_fake"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：你<br /><b>效果</b>：随机分配所有角色装备区里的牌。",
  ["wenhe_chaos"] = "文和乱武",
  [":wenhe_chaos"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：所有其他角色<br /><b>效果</b>：目标角色选择一项：1. 对距离最近的一名角色使用【杀】；2. 失去1点体力。",
  ["wenhe_chaos_skill"] = "文和乱武",
  ["chaos_mode"] = "文和乱武",
  [":chaos_mode"] = desc_chaos,
  ["chaos: left two alive"] = "仅剩两名角色存活",
  ["#chaos_rule"] = "乱武事件",
  ["chaos_e: 1"] = "事件：乱武。从随机一名角色开始，所有角色，需对距离最近的一名角色使用一张【杀】，否则失去1点体力。",
  ["chaos_e: 2"] = "事件：重赏。本轮中，击杀角色奖励翻倍。",
  ["chaos_e: 3"] = "事件：破釜沉舟。一名角色的回合开始时，失去1点体力，摸三张牌。",
  ["chaos_e: 4"] = "事件：横刀跃马。每个回合结束时，所有装备最少的角色失去1点体力，随机将一张装备牌置入其装备区。",
  ["chaos_e: 5"] = "事件：横扫千军。本轮中，所有伤害值+1。",
  ["chaos_e: 6"] = "事件：饿莩载道。本轮结束时，所有手牌最少的角色失去X点体力。（X为轮数）",
  ["chaos_e: 7"] = "事件：宴安鸩毒。本轮中，所有的【桃】均视为【毒】。（【毒】：锁定技，当此牌正面朝上离开你的手牌区后，你失去1点体力。出牌阶段，你可对自己使用。）",
  ["@chaos_mode_event"] = "事件",
  ["generous_reward"] = "重赏",
  ["burning_one's_boats"] = "破釜沉舟",
  ["leveling_the_blades"] = "横刀跃马",
  ["sweeping_all"] = "横扫千军",
  ["starvation"] = "饿莩载道",
  ["poisoned_banquet"] = "宴安鸩毒",
  ["#chaos_mode_event_4_log"] = "%from 由于“%arg”，将 %arg2 置入装备区",
  ["#chaos_rule_filter"] = "宴安鸩毒",
  ["chaos_mode_event_log"] = "本轮的“文和乱武” %arg",
  ["chaos_intro"] = "一人一队，文和乱武的大吃鸡时代，你能入主长安吗？<br>每一轮开始会有随机事件发生，祝你好运。（贾诩的谜之笑容）",
  ["chaos_fisrt_round"] = "第一轮时，已受伤角色视为拥有〖八阵〗。",

  ["espionage_cards"] = "用间",
  ["stab__slash"] = "刺杀",
  ["stab__slash_trigger"] = "刺杀",
  [":stab__slash"] = "基本牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：攻击范围内的一名角色<br/><b>效果</b>：对目标角色造成1点伤害。"..
  "当目标角色使用【闪】抵消刺【杀】时，若其有手牌，其需弃置一张手牌，否则此刺【杀】依然造成伤害。",
  ["#stab__slash-discard"] = "请弃置一张手牌，否则%arg依然对你生效",
  ["sincere_treat"] = "推心置腹",
  ["sincere_treat_skill"] = "推心置腹",
  [":sincere_treat"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：距离为1的一名区域内有牌的其他角色<br/><b>效果</b>：你获得目标角色"..
  "区域里至多两张牌，然后交给其等量的手牌。",
  ["#sincere_treat-give"] = "推心置腹：请交给 %dest %arg张手牌",
  ["looting"] = "趁火打劫",
  ["looting_skill"] = "趁火打劫",
  [":looting"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：一名有手牌的其他角色<br/><b>效果</b>：你展示目标角色一张手牌，"..
  "然后令其选择一项：将此牌交给你，或受到你造成的1点伤害。",
  ["#looting-give"] = "趁火打劫：点“确定”将此牌交给 %src ，或点“取消”其对你造成1点伤害",
  ["bogus_flower"] = "树上开花",
  ["bogus_flower_skill"] = "树上开花",
  [":bogus_flower"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：你<br/><b>效果</b>：目标角色弃置至多两张牌，然后摸等量的牌；"..
  "若弃置了装备牌，则多摸一张牌。",
  ["espionage"] = "用间测试版",
  [":espionage"] = desc_espionage,

  ['qixi_sheshen'] = '舍身',
  [':qixi_sheshen'] = '伴侣技，当伴侣不以此法受到伤害时，你可以将伤害转移给自己。',
  ['qixi_gongdou'] = '共斗',
  [':qixi_gongdou'] = '伴侣技，一回合一次，当伴侣使用的非转化杀结算结束后，你可以视为对相同的目标使用了一张【杀】。',
  ['qixi_lianzhi'] = '连枝',
  [':qixi_lianzhi'] = '伴侣技，你使用装备牌时，可以令伴侣摸一张牌。',
  ['qixi_qibie'] = '泣别',
  [':qixi_qibie'] = '伴侣技，当伴侣求桃结束即将阵亡时，你可以令其失去“泣别”，获得你武将牌上所有的技能并回复X点体力' ..
    '（X为你的体力值且至少能令其回复至1点体力），然后你失去所有技能和所有体力。',
  ['qixi_mode'] = '七夕模式',
  [':qixi_mode'] = desc_qixi,
  ['qixi_jieban'] = '结伴',
  [':qixi_jieban'] = '出牌阶段限一次，若你没有伴侣，你可以将一张' ..
    '【桃】或者防具牌交给一名未结伴的异性角色并将其设为追求目标；' ..
    '然后若其的追求目标是你，双方移除追求目标并结为伴侣。' ..
    '<br/>伴侣确定后就无法更改，即使死亡也无法将二人分开。',
  ['@qixi_pay_court'] = '追求',
  ['@qixi_couple'] = '伴侣',
  ['@qixi_couple_blue'] = '<font color="#87CEFA">伴侣</font>',
  ['@qixi_couple_pink'] = '<font color="#FFB6C1">伴侣</font>',

  ["vanished_dragon_cards"] = "忠胆英杰特殊牌",
  ["diversion"] = "声东击西",
  [":diversion"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：距离为1的一名角色<br /><b>效果</b>：你交给目标角色一张手牌并选择一名除其以外的角色，目标角色将两张牌交给该角色。",

  ["diversion_skill"] = "声东击西",
  ["#diversion-give"] = "声东击西：交给 %dest 一张手牌，并选择其要将两张牌交给的目标",
  ["#diversion-give2"] = "声东击西：交给 %dest 两张牌",
  ["paranoid"] = "草木皆兵",
  [":paranoid"] = "延时锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：一名其他角色<br /><b>效果</b>：将【草木皆兵】置于目标角色判定区里。若判定结果不为♣：摸牌阶段，少摸一张牌；摸牌阶段结束时，与其距离为1的角色各摸一张牌。",

  ["@@paranoid-turn"] = "草木皆兵",
  ["#paranoidResult"] = "草木皆兵",
  ["reinforcement"] = "增兵减灶",
  [":reinforcement"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：一名角色<br /><b>效果</b>：目标角色摸三张牌，然后选择一项：1. 弃置一张非基本牌；2. 弃置两张牌。",

  ["reinforcement-nonbasic"] = "弃置一张非基本牌",
  ["reinforcement-2cards"] = "弃置两张牌",
  ["reinforcement_skill"] = "增兵减灶",
  ["abandoning_armor"] = "弃甲曳兵",
  [":abandoning_armor"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：一名装备区里有牌的其他角色<br /><b>效果</b>：目标角色选择一项：1. 弃置手牌区和装备区里所有的武器和进攻坐骑；2. 弃置手牌区和装备区里所有的防具和防御坐骑。",

  ["abandoning_armor-offensive"] = "弃置手牌区和装备区里所有的武器和进攻坐骑",
  ["abandoning_armor-defensive"] = "弃置手牌区和装备区里所有的防具和防御坐骑",
  ["abandoning_armor_skill"] = "弃甲曳兵",
  ["crafty_escape"] = "金蝉脱壳",
  [":crafty_escape"] = "锦囊牌<br /><b>时机</b>：当你成为其他角色使用牌的目标时，若你的手牌里只有【金蝉脱壳】<br /><b>目标</b>：该牌<br /><b>效果</b>：令目标牌对你无效，你摸两张牌。当你因弃置而失去【金蝉脱壳】时，你摸一张牌。",

  ["crafty_escape_skill"] = "金蝉脱壳",
  ["#crafty_escape-ask"] = "是否使用【金蝉脱壳】，令%arg对你无效，你摸两张牌？",
  ["crafty_escape_trigger"] = "金蝉脱壳",
  ["floating_thunder"] = "浮雷",
  [":floating_thunder"] = "延时锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：你<br /><b>效果</b>：将【浮雷】放置于目标角色的判定区里。若判定结果为♠，则目标角色受到X点雷电伤害（X为此牌判定结果为♠的次数）。判定完成后，将此牌移动到下家的判定区里。",
  ["glittery_armor"] = "烂银甲",
  [":glittery_armor"] = "装备牌·防具<br /><b>防具技能</b>：你可以将一张手牌当【闪】使用或打出。【烂银甲】不会被无效或无视。当你受到【杀】造成的伤害时，你弃置装备区里的【烂银甲】。",

  ["glittery_armor_skill&"] = "烂银甲",
  [":glittery_armor_skill&"] = "烂银甲：你可以将一张手牌当【闪】使用或打出。",
  ["#glittery_armor_trigger"] = "烂银甲[弃置]",
  ["seven_stars_sword"] = "七宝刀",
  ["#seven_stars_sword_skill"] = "七宝刀",
  [":seven_stars_sword"] = "装备牌·武器<br /><b>攻击范围</b>：２ <br /><b>武器技能</b>：锁定技，你使用【杀】无视目标防具，若目标角色未损失体力值，此【杀】伤害+1。",
  ["steel_lance"] = "衠钢槊",
  ["#steel_lance_skill"] = "衠钢槊",
  [":steel_lance"] = "装备牌·武器<br /><b>攻击范围</b>：３ <br /><b>武器技能</b>：当你使用【杀】指定一名角色为目标后，你可令其弃置你的一张手牌，然后你弃置其一张手牌。",
  ["vanished_dragon"] = "忠胆英杰",
  [":vanished_dragon"] = desc_vanished_dragon,
  ["vd_intro"] = "是<b>明忠</b>，<b>开始选将</b><br>明忠是代替主公亮出身份牌的忠臣，明忠死后主公再翻出身份牌",
  ["vd_loyalist_skill"] = "明忠获得忠臣技：",
  ["vd_dongcha_rebel"] = "明忠发动了〖洞察〗，一名反贼的身份已被其知晓",
  ["vd_lord_exploded"] = "明忠阵亡，主公暴露：",

  ["vd_dongcha&"] = "洞察",
  [":vd_dongcha&"] = "游戏开始时，随机一名反贼的身份对你可见。准备阶段开始时，你可以弃置场上的一张牌。",
  ["vd_sheshen&"] = "舍身",
  [":vd_sheshen&"] = "锁定技，主公处于濒死状态即将死亡时，你令其体力上限+1，回复体力至X点（X为你的体力值），获得你所有牌，然后你死亡。",
  ["$vd_sheshen&1"] = "舍身为主，死而无憾！",
  ["$vd_sheshen&2"] = "捐躯赴国难，视死忽如归。",

  ["#vd_dongcha-ask"] = "洞察：你可以选择一名角色，弃置其场上一张牌",

  ["variation_cards"] = "应变",
  ["ice__slash"] = "冰杀",
  ["ice_damage_skill"] = "冰杀",
  [":ice__slash"] = "基本牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：攻击范围内的一名角色<br /><b>效果</b>：对目标角色造成1点冰冻伤害。"..
  "（一名角色造成不为连环伤害的冰冻伤害时，若受到此伤害的角色有牌，来源可防止此伤害，然后依次弃置其两张牌）。",
  ["black_chain"] = "乌铁锁链",
  ["#black_chain_skill"] = "乌铁锁链",
  [":black_chain"] = "装备牌·武器<br/><b>攻击范围</b>：3<br/><b>武器技能</b>：当你使用【杀】指定目标后，你可以横置目标角色武将牌。",
  ["five_elements_fan"] = "五行鹤翎扇",
  ["five_elements_fan_skill"] = "五行扇",
  [":five_elements_fan"] = "装备牌·武器<br/><b>攻击范围</b>：4<br/><b>武器技能</b>：你可以将属性【杀】当任意其他属性【杀】使用。",
  ["breastplate"] = "护心镜",
  ["#breastplate_skill"] = "护心镜",
  [":breastplate"] = "装备牌·防具<br/><b>防具技能</b>：当你受到大于1点的伤害或致命伤害时，你可将装备区里的【护心镜】置入弃牌堆，若如此做，防止此伤害。"..
  "出牌阶段，你可将手牌中的【护心镜】置入其他角色的装备区。",
  ["putEquip"] = "置入",
  [":putEquip"] = "你可以将此牌置入其他角色的装备区",
  ["dark_armor"] = "黑光铠",
  ["#dark_armor_skill"] = "黑光铠",
  [":dark_armor"] = "装备牌·防具<br/><b>防具技能</b>：当你成为【杀】、伤害锦囊或黑色锦囊牌的目标后，若你不是唯一目标，此牌对你无效。",
  ["wonder_map"] = "天机图",
  [":wonder_map"] = "装备牌·宝物<br/><b>宝物技能</b>：锁定技，此牌进入你的装备区时，弃置一张其他牌；此牌离开你的装备区时，你将手牌摸至五张。",
  ["#wonder_map-discard"] = "天机图：你须弃置一张【天机图】以外的牌",
  ["taigong_tactics"] = "太公阴符",
  ["#taigong_tactics_skill"] = "太公阴符",
  [":taigong_tactics"] = "装备牌·宝物<br/><b>宝物技能</b>：出牌阶段开始时，你可以横置或重置一名角色；出牌阶段结束时，你可以重铸一张手牌。",
  ["#taigong_tactics-choose"] = "太公阴符：你可以横置或重置一名角色",
  ["#taigong_tactics-invoke"] = "太公阴符：你可以重铸一张手牌",
  ["drowning"] = "水淹七军",
  ["drowning_skill"] = "水淹七军",
  [":drowning"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：一名其他角色<br /><b>效果</b>：目标角色选择一项："..
  "1.弃置装备区所有牌（至少一张）；2.你对其造成1点雷电伤害。",
  ["#drowning-discard"] = "水淹七军：“确定”弃置装备区所有牌，或点“取消” %dest 对你造成1点雷电伤害",
  ["unexpectation"] = "出其不意",
  ["unexpectation_skill"] = "出其不意",
  [":unexpectation"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：一名有手牌的其他角色<br/><b>效果</b>：你展示目标角色的一张手牌，"..
  "若该牌与此【出其不意】花色不同，你对其造成1点伤害。",
  ["adaptation"] = "随机应变",
  ["adaptation_filter_skill"] = "随机应变",
  [":adaptation"] = "锦囊牌<br/><b>效果</b>：此牌视为你本回合使用或打出的上一张基本牌或普通锦囊牌。",
  ["foresight"] = "洞烛先机",
  ["foresight_skill"] = "洞烛先机",
  [":foresight"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：你<br/><b>效果</b>：目标角色卜算2（观看牌堆顶的两张牌，"..
  "将其中任意张以任意顺序置于牌堆顶，其余以任意顺序置于牌堆底），然后摸两张牌。",
  ["chasing_near"] = "逐近弃远",
  ["chasing_near_skill"] = "逐近弃远",
  [":chasing_near"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：一名区域里有牌的其他角色<br/><b>效果</b>：若你与目标角色距离为1，"..
  "你获得其区域里一张牌；若你与目标角色距离大于1，你弃置其区域里一张牌。",
  ["variation"] = "应变测试版",
  [":variation"] = desc_variation,

  ["zombie"] = "僵尸",
  ["zombie_xunmeng"] = "迅猛",
  [":zombie_xunmeng"] = "锁定技，你的杀造成伤害时，令此伤害+1，" ..
    "若此时你的体力值大于1，则你失去1点体力。",
  ["zombie_zaibian"] = "灾变",
  [":zombie_zaibian"] = "锁定技，摸牌阶段，若人类玩家数-僵尸玩家数+1大于0，则你多摸该数目的牌。",
  ["zombie_ganran"] = "感染",
  [":zombie_ganran"] = "锁定技，你手牌中的装备牌视为【铁索连环】。",
  ["zombie_mode"] = "僵尸模式",
  [":zombie_mode"] = desc_zombie,
  ["@zombie_tuizhi"] = "退治",
  ["zombie_tuizhi_success"] = "主公已经集齐8个退治标记！僵尸被退治！",
}