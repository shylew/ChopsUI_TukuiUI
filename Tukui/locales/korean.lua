local T, C, L = unpack(select(2, ...))

if T.client == "koKR" then
	L.chat_BATTLEGROUND_GET = "B"
	L.chat_BATTLEGROUND_LEADER_GET = "B"
	L.chat_BN_WHISPER_GET = "FR"
	L.chat_GUILD_GET = "G"
	L.chat_OFFICER_GET = "O"
	L.chat_PARTY_GET = "P"
	L.chat_PARTY_GUIDE_GET = "P"
	L.chat_PARTY_LEADER_GET = "P"
	L.chat_RAID_GET = "R"
	L.chat_RAID_LEADER_GET = "R"
	L.chat_RAID_WARNING_GET = "W"
	L.chat_WHISPER_GET = "FR"
	L.chat_FLAG_AFK = "[AFK]"
	L.chat_FLAG_DND = "[DND]"
	L.chat_FLAG_GM = "[GM]"
	L.chat_ERR_FRIEND_ONLINE_SS = "|cff298F00접속|r했습니다"
	L.chat_ERR_FRIEND_OFFLINE_S = "|cffff0000접속종료|r했습니다"
 
	L.chat_general = "일반"
	L.chat_trade = "거래"
	L.chat_defense = "수비"
	L.chat_recrutment = "길드모집"
	L.chat_lfg = "파티찾기"
 
	L.disband = "공격대를 해체합니까?"

	L.datatext_notalents ="특성 없음"
	L.datatext_download = "다운로드: "
	L.datatext_bandwidth = "대역폭: "
	L.datatext_guild = "길드"
	L.datatext_noguild = "길드 없음"
	L.datatext_bags = "소지품: "
	L.datatext_friends = "친구"
	L.datatext_online = "온라인: "
	L.datatext_armor = "방어구"
	L.datatext_earned = "수입:"
	L.datatext_spent = "지출:"
	L.datatext_deficit = "적자:"
	L.datatext_profit = "흑자:"
	L.datatext_timeto = "전투 시간"
	L.datatext_friendlist = "친구 목록:"
	L.datatext_playersp = "주문력"
	L.datatext_playerap = "전투력"
	L.datatext_playerhaste = "가속도"
	L.datatext_dps = "dps"
	L.datatext_hps = "hps"
	L.datatext_playerarp = "방관"
	L.datatext_session = "세션: "
	L.datatext_character = "캐릭터: "
	L.datatext_server = "서버: "
	L.datatext_totalgold = "전체: "
	L.datatext_savedraid = "귀속된 던전"
	L.datatext_currency = "화폐:"
	L.datatext_fps = " fps & "
	L.datatext_ms = " ms"
	L.datatext_playercrit = " 치명타율"
	L.datatext_playerheal = " 극대화율"
	L.datatext_avoidancebreakdown = "완방 수치"
	L.datatext_lvl = "레벨"
	L.datatext_boss = "우두머리"
	L.datatext_miss = "빗맞힘"
	L.datatext_dodge = "회피율"
	L.datatext_block = "방패 막기"
	L.datatext_parry = "무기 막기"
	L.datatext_playeravd = "완방: "
	L.datatext_servertime = "서버 시간: "
	L.datatext_localtime = "지역 시간: "
	L.datatext_mitigation = "레벨에 따른 경감수준: "
	L.datatext_healing = "치유량 : "
	L.datatext_damage = "피해량 : "
	L.datatext_honor = "명예 점수 : "
	L.datatext_killingblows = "결정타 : "
	L.datatext_ttstatsfor = "점수 : "
	L.datatext_ttkillingblows = "결정타:"
	L.datatext_tthonorkills = "명예 승수:"
	L.datatext_ttdeaths = "죽은 수:"
	L.datatext_tthonorgain = "획득한 명예:"
	L.datatext_ttdmgdone = "피해량:"
	L.datatext_tthealdone = "치유량:"
	L.datatext_basesassaulted = "거점 공격:"
	L.datatext_basesdefended = "거점 방어:"
	L.datatext_towersassaulted = "경비탑 점령:"
	L.datatext_towersdefended = "경비탑 방어:"
	L.datatext_flagscaptured = "깃발 쟁탈:"
	L.datatext_flagsreturned = "깃발 반환:"
	L.datatext_graveyardsassaulted = "무덤 점령:"
	L.datatext_graveyardsdefended = "무덤 방어:"
	L.datatext_demolishersdestroyed = "파괴한 파괴전차:"
	L.datatext_gatesdestroyed = "파괴한 관문:"
	L.datatext_totalmemusage = "총 메모리 사용량:"
	L.datatext_control = "현재 진영:"
	L.datatext_cta_allunavailable = "Could not get Call To Arms information."
	L.datatext_cta_nodungeons = "No dungeons are currently offering a Call To Arms."
 
	L.bg_warsong = "전쟁노래 협곡"
	L.bg_arathi = "아라시 분지"
	L.bg_eye = "폭풍의 눈"
	L.bg_alterac = "알터랙 계곡"
	L.bg_strand = "고대의 해안"
	L.bg_isle = "정복의 섬"
 
	L.Slots = {
	  [1] = {1, "머리", 1000},
	  [2] = {3, "어깨", 1000},
	  [3] = {5, "가슴", 1000},
	  [4] = {6, "허리", 1000},
	  [5] = {9, "손목", 1000},
	  [6] = {10, "손", 1000},
	  [7] = {7, "다리", 1000},
	  [8] = {8, "발", 1000},
	  [9] = {16, "주장비", 1000},
	  [10] = {17, "보조장비", 1000},
	  [11] = {18, "원거리", 1000}
	}
 
	L.popup_disableui = "Tukui는 현재 해상도에 최적화되어 있지 않습니다. Tukui를 비활성화하시겠습니까? (다른 해상도로 시도해보려면 취소)"
	L.popup_install = "현재 캐릭터는 Tukui를 처음 사용합니다. 행동 단축바, 대화창, 다양한 설정을 위해 UI를 다시 시작하셔야만 합니다."
	L.popup_2raidactive = "2개의 공격대 인터페이스가 사용 중입니다. 한 가지만 사용하셔야 합니다."
	L.popup_reset = "경고! Tukui의 모든것을 기본값으로 변경합니다. 실행하시겠습니까?"
	L.popup_install_yes = "예"
	L.popup_install_no = "아니오"
	L.popup_reset_yes = "예"
	L.popup_reset_no = "아니오"
	L.popup_fix_ab = "귀하의 행동단축바에 문제가 있습니다. reloadui를 하여 문제를 해결하시겠습니까?"
 
	L.merchant_repairnomoney = "수리에 필요한 돈이 충분하지 않습니다!"
	L.merchant_repaircost = "모든 아이템이 수리되었습니다: "
	L.merchant_trashsell = "불필요한 아이템이 판매되었습니다: "
 
	L.goldabbrev = "|cffffd700●|r"
	L.silverabbrev = "|cffc7c7cf●|r"
	L.copperabbrev = "|cffeda55f●|r"
 
	L.error_noerror = "오류가 발견되지 않았습니다."
 
	L.unitframes_ouf_offline = "오프라인"
	L.unitframes_ouf_dead = "죽음"
	L.unitframes_ouf_ghost = "유령"
	L.unitframes_ouf_lowmana = "마나 적음"
	L.unitframes_ouf_threattext = "현재 대상에 대한 위협수준:"
	L.unitframes_ouf_offlinedps = "오프라인"
	L.unitframes_ouf_deaddps = "|cffff0000[죽음]|r"
	L.unitframes_ouf_ghostheal = "유령"
	L.unitframes_ouf_deadheal = "죽음"
	L.unitframes_ouf_gohawk = "매의 상으로 전환"
	L.unitframes_ouf_goviper = "독사의 상으로 전환"
	L.unitframes_disconnected = "연결끊김"
	L.unitframes_ouf_wrathspell = "격노"
	L.unitframes_ouf_starfirespell = "별빛 섬광"
 
	L.tooltip_count = "개수"
 
	L.bags_noslots = "더이상 가방보관함을 구입할 수 없습니다."
	L.bags_costs = "가격: %.2f 골"
	L.bags_buyslots = "가방 보관함을 추가로 구입하시려면 /bags를 입력해주세요."
	L.bags_openbank = "먼저 은행을 열어야 합니다."
	L.bags_sort = "열려있는 가방이나 은행에 있는 아이템을 정리합니다."
	L.bags_stack = "띄엄띄엄 있는 아이템을 정리합니다."
	L.bags_buybankslot = "가방 보관함을 추가로 구입합니다."
	L.bags_search = "검색"
	L.bags_sortmenu = "분류"
	L.bags_sortspecial = "특수물품 분류"
	L.bags_stackmenu = "정리"
	L.bags_stackspecial = "특수물품 정리"
	L.bags_showbags = "가방 보기"
	L.bags_sortingbags = "분류 완료."
	L.bags_nothingsort= "분류할 것이 없습니다."
	L.bags_bids = "사용 중인 가방: "
	L.bags_stackend = "재정리 완료."
	L.bags_rightclick_search = "검색하려면 오른쪽 클릭"
	
	L.loot_fish = "전리품"
	L.loot_empty = "빈 슬롯"
 
	L.chat_invalidtarget = "잘못된 대상"
 
	L.mount_wintergrasp = "겨울손아귀"
 
	L.core_autoinv_enable = "자동초대 활성화: 초대"
	L.core_autoinv_enable_c = "자동초대 활성화: "
	L.core_autoinv_disable = "자동초대 비활성화"
	L.core_wf_unlock = "임무 추적창 잠금 해제"
	L.core_wf_lock = "임무 추적창 잠금"
	L.core_welcome1 = "|cffC495DDTukui|r를 사용해주셔서 감사합니다. 버전 "
	L.core_welcome2 = "자세한 사항은 |cff00FFFF/uihelp|r를 입력하거나 www.tukui.org 에 방문하시면 확인 가능합니다."
 
	L.core_uihelp1 = "|cff00ff00일반적인 명령어|r"
	L.core_uihelp2 = "|cffFF0000/moveui|r - 화면 주위 요소들을 잠금해제하고 이동합니다."
	L.core_uihelp3 = "|cffFF0000/rl|r - 당신의 인터페이스를 다시 불러옵니다."
	L.core_uihelp4 = "|cffFF0000/gm|r - 도움 요청(지식 열람실, GM 요청하기) 창을 엽니다."
	L.core_uihelp5 = "|cffFF0000/frame|r - 커서가 위치한 창의 이름을 보여줍니다. (lua 편집 시 매우 유용)"
	L.core_uihelp6 = "|cffFF0000/heal|r - 힐러용 공격대 레이아웃을 사용합니다."
	L.core_uihelp7 = "|cffFF0000/dps|r - DPS/탱커용 레이아웃을 사용합니다."
	L.core_uihelp8 = "|cffFF0000/bags|r - 분류, 정리, 가방 보관함을 추가 구입을 할 수 있습니다."
	L.core_uihelp9 = "|cffFF0000/resetui|r - Tukui를 기본값으로 초기화 합니다."
	L.core_uihelp10 = "|cffFF0000/rd|r - 공격대를 해체합니다."
	L.core_uihelp11 = "|cffFF0000/ainv|r - 자동초대 기능을 사용합니다. '/ainv 단어'를 입력하여 해당 단어가 들어간 귓속말이 올 경우 자동으로 초대를 합니다."
	L.core_uihelp100 = "(위로 올리십시오 ...)"
 
	L.symbol_CLEAR = "초기화"
	L.symbol_SKULL = "해골"
	L.symbol_CROSS = "가위표"
	L.symbol_SQUARE = "네모"
	L.symbol_MOON = "달"
	L.symbol_TRIANGLE = "세모"
	L.symbol_DIAMOND = "다이아몬드"
	L.symbol_CIRCLE = "동그라미"
	L.symbol_STAR = "별"
 
	L.bind_combat = "전투 중에는 단축키를 지정할 수 없습니다."
	L.bind_saved = "새로 지정한 모든 단축키가 저장되었습니다."
	L.bind_discard = "새로 지정한 모든 단축키가 저장되지 않았습니다."
	L.bind_instruct = "커서가 위치한 단축버튼에 단축키를 지정할 수 있습니다. 오른쪽 클릭으로 해당 단축버튼의 단축키를 초기화할 수 있습니다."
	L.bind_save = "저장"
	L.bind_discardbind = "취소"
 
	L.hunter_unhappy = "소환수의 만족도: 불만족"
	L.hunter_content = "소환수의 만족도: 만족"
	L.hunter_happy = "소환수의 만족도: 매우 만족"
	
	L.move_tooltip = "툴팁 이동"
	L.move_minimap = "미니맵 이동"
	L.move_watchframe = "퀘스트 이동"
	L.move_gmframe = "대기표 이동"
	L.move_buffs = "플레이어 버프 이동"
	L.move_debuffs = "플레이어 디버프 이동"
	L.move_shapeshift = "태세/토템 바 이동"
	L.move_achievements = "업적창 이동"
	L.move_roll = "주사위 창 이동"
	L.move_vehicle = "탈것 창 이동"
	L.move_extrabutton = "추가 버튼"
	
	-- tuto/install
	L.install_header_1 = "환영합니다"
	L.install_header_2 = "1. 필수사항"
	L.install_header_3 = "2. 유닛프레임"
	L.install_header_4 = "3. 기능"
	L.install_header_5 = "4. 알아야할 사항!"
	L.install_header_6 = "5. 명령어"
	L.install_header_7 = "6. 완료"
	L.install_header_8 = "1. 필수 설치"
	L.install_header_9 = "2. 친목"
	L.install_header_10= "3. 프레임"
	L.install_header_11= "4. 성공!"

	L.install_init_line_1 = "Tukui를 사용해 주셔서 감사합니다.!"
	L.install_init_line_2 = "몇차례 간단한 설치 단계를 통해서 안내될것입니다. 각 단계에서 현 설치를 적용시킬지 아닐지를 결정하실수 있습니다."
	L.install_init_line_3 = "간단한 지침서를 볼수있는 몇가지 Tukui 기능들 또한 주어집니다."
	L.install_init_line_4 = "이 간단한 지침을 안내받고 싶으시면 '지침서' 버튼을 누르십시요., 이 단계를 넘기시고 싶으시면 '설치'를 누르시면 됩니다."

	L.tutorial_step_1_line_1 = "이 짧은 지침서는 몇가지 Tukui의 기능들을 보여줄것입니다."
	L.tutorial_step_1_line_2 = "먼저, 이 UI로 플레이 하기 전 알셔야할 필수사항들입니다."
	L.tutorial_step_1_line_3 = "이 설치기는 부분적으로 특정 캐릭터에 해당됩니다. 반면, 몇몇 설정들은 전캐릭터에 추후 적용됩니다. 각 새로운 캐릭터에 Tukui를 실행시키기 위해 설치 스크립트를 실행시켜야 합니다. 스크립트는 최초 Tukui 사용시 매 새로운 캐릭터 로그인할때 마다 자동으로 보여집니다. 또한, 파워사용자는 /Tukui/config/config.lua에서 옵션 설정을 하시면 됩니다. 친근사용자는 게임내에 /tukui 입력을 통해 옵션설정이 가능합니다."
	L.tutorial_step_1_line_4 = "파워 사용자는 보통 사용자들의 능력을 넘어서 고급 기능 (예를들면 Lua 수정)을 사용할 능력을 지닌 개인컴퓨터 사용자를 일컸습니다. 친근 사용자는 보통 사용자를 일컫으며 프로그래밍 능력이 꼭 필요한것은 아닙니다. 이들에게는 Tukui 사용자 설정을 위해 (/tukui)를 통해 게임내 설정도구 사용을 추천합니다."

	L.tutorial_step_2_line_1 = "Tukui는 Trond (Haste) A Ekseth에 의해 고안된 oUF의 버전을 포함하고 있습니다. 이는 화면상에 모든 유닛프레임, 버프 및 디버프, 직업 특정 요소들을 다룹니다."
	L.tutorial_step_2_line_2 = "이 도구에 대해 oUF에 대한 좀더 자세한 정보를 원하시면 wowinterface.com 방문하셔서 찾아보시기 바랍니다."
	L.tutorial_step_2_line_3 = "만약 힐러나 공대장으로 플레이하시는 분이라면, 힐러 유닛 프레임을 선호하실 겁니다. 이는 공격대에서 좀더 자세한 정보를 보여줍니다. (/heal) 딜러나 탱커는 심플한 레이드 표시기를 사용하시면 됩니다.(/dps) 어떤것도 사용하길 원치 않으시는 분이나 다른 애드온을 사용하시는 분은, 로그인시 캐릭터 선택 화면 애드온 설정에서 사용안함으로 하시면 됩니다."
	L.tutorial_step_2_line_4 = "간단한 유닛프레임 위치 이동을 원하시면, /moveui를 입력하시기 바랍니다."

	L.tutorial_step_3_line_1 = "Tukui는 블리자드 UI를 새롭게 디자인한 것입니다. 더도덜도 없습니다. 기본 UI에서 볼수있는 거의 모든 기능들은 Tukui를 통해 가능합니다. 기본 UI의 오직 불가능한 기능은 실제적으로 화면상에선 볼수 없는 몇몇 자동 기능들뿐입니다. 상점에서 회색템 자동 판매와 가방 아이템 자동 정리를 예를 들수 있습니다."
	L.tutorial_step_3_line_2 = "모든 이가 데미지미터기, 보스 경보 모드, 위협수준미터기등 같은것을 선호하는게 아니기 때문에, 최선의 방법이라 판단합니다. Tukui는 모든 직업, 역할, 사양, 게임스타일, 사용자의 취향등에 최대한 맞추기 위해 고안되었습니다. 그래서 Tukui는 현재 가장 선호하는 UI중에 하나입니다. 모든이의 게임스타일에 맞고 최대한 수정가능합니다. 또한 애드온에 의존없이 자신만의 맞춤 UI를 만들기 원하는 모든이를 위한 매우 좋은 개시로 디자인되었습니다. 현재 2009년부터 많은 사용자들이 자신만의 UI를 토대로 Tukui를 사용중입니다. Tukui 웹사이트에 Edited Packages를 한번 살펴보세요.!"
	L.tutorial_step_3_line_3 = "Tukui 웹사이트에 extra mods 부분을 방문해 보시기 바랍니다. 또는 추가 기능 및 양식 설치를 원하시는 분들은 http://www.wowinterface.com 방문하시기 바랍니다."
	L.tutorial_step_3_line_4 = ""

	L.tutorial_step_4_line_1 = "액션바 갯수 설정은 하단 액션바 배경의 왼쪽 혹은 오른쪽에 마우스를 대십시요. 오른쪽 액션바도 마찬가지로 배경 위와 아래쪽에 마우스를 대시면 됩니다. 채팅창에서 텍스트 복사는 채팅창 오른쪽 코너에 마우스를 대시면 나타나는 버튼을 클릭하시면 됩니다."
	L.tutorial_step_4_line_2 = "미니맵 테두리 색상변경. 새 메일을 받으면 녹색으로, 달력 초대를 받으면 빨강색으로, 새 메일과 달력초대가 동시에 있으면 오렌지 색상으로 변경됩니다."
	L.tutorial_step_4_line_3 = "블리자드의 다양한 판넬을 보려면 데이타텍스트의 80%는 마우스 왼쪽 클릭하시면 됩니다. 친구와 길드 데이타텍스트도 물론 마우스 오른쪽 클릭으로 기능을 살펴보실수 있습니다."
	L.tutorial_step_4_line_4 = "몇가지 사용가능한 드롭다운 메뉴가 있습니다. 가방 닫기 버튼을 오른쪽 클릭하시면 드롭다운 메뉴가 보여지며 이는 가방보이기, 아이템 정리, 열쇠가방등이 나타납니다. 마우스 중앙 버튼을 미니맵에 누르시면 micro 메뉴가 나타납니다."

	L.tutorial_step_5_line_1 = "마지막으로, Tukui는 유용한 슬래시 명령어를 포함하고 있습니다. 하기 리스트를 참고하세요."
	L.tutorial_step_5_line_2 = "/moveui는 화면 어디든 많은 프레임 이동을 가능하게 합니다. /enable과 /disable은 빠르게 애드온 적용과 미적용에 사용됩니다. /rl은 UI를 다시 불러올때. /heal은 힐러 레이드 유닛프레임을 사용 /dps는 딜러/탱커 레이드 유닛프레임을 사용."
	L.tutorial_step_5_line_3 = "/tt는 대상타겟에게 귓속말을 보낼때. /rc는 전투준비 체크. /rd 파티나 레이드 해체. /bags 명령어 라인으로 가능한 몇가지 기능을 보여줍니다. /ainv 귓속말 대상 자동초대를 가능하게 합니다. (/ainv off) 자동초대 기능 끄기"
	L.tutorial_step_5_line_4 = "/gm 지엠창 끄기 켜기. /install, /resetui 또는 /tutorial은 설치를 불러옵니다. /frame 커서가 위치한 프레임의 이름과 추가정보를 보여줍니다."

	L.tutorial_step_6_line_1 = "지침서가 완료되었습니다. 재조정을 원하시면 언제든지 /tutorial 입력하시면 됩니다."
	L.tutorial_step_6_line_2 = "config/config.lua 파일을 살펴보시기 바랍니다. 혹은 /Tukui 입력을 통해 원하시는대로 UI 구성을 하시면 됩니다."
	L.tutorial_step_6_line_3 = "아직 완료전이거나 기본으로 리셋을 원하시면 UI 설치를 계속하실수 있습니다.!"
	L.tutorial_step_6_line_4 = ""

	L.install_step_1_line_1 = "이번 단계들은 Tukui의 정확한 CVar 설치를 적용시킬것입니다."
	L.install_step_1_line_2 = "1단계는 필수 설치에 적용됩니다."
	L.install_step_1_line_3 = "특정 부분설치에만 적용시키길 원하지 않는 한, 모든 사용자는 |cffff0000recommended|r 이 적용됩니다."
	L.install_step_1_line_4 = "이 설치를 적용시키려면 '계속' 버튼을 눌러주세요., 이 단계를 넘기시려면 '무시' 버튼을 누르시면 됩니다."

	L.install_step_2_line_0 = "다른 채팅 애드온이 발견되면 이 단계는 무시될것입니다. 계속 설치를 위해 '무시' 버튼을 눌러주세요."
	L.install_step_2_line_1 = "2단계는 옳바른 채팅 구성이 적용됩니다."
	L.install_step_2_line_2 = "이 단계는 처음이신 사용자분에게 추천합니다. 기존 사용자분들은 이 단계는 넘기셔도 됩니다."
	L.install_step_2_line_3 = "이 설치를 기반으로 적용시키면 채팅 폰트는 크게 보여집니다. 설치를 마치면 다시 정상적으로 나타납니다."
	L.install_step_2_line_4 = "이 설치를 적용시키려면 '계속' 버튼을 눌러주세요., 이 단계를 넘기시려면 '무시' 버튼을 누르시면 됩니다."

	L.install_step_3_line_1 = "3단계와 마지막 단계는 기본 프레임 위치 적용입니다."
	L.install_step_3_line_2 = "이 단계 |cffff0000recommended|r 는 처음이신 사용자를 위한것입니다."
	L.install_step_3_line_3 = ""
	L.install_step_3_line_4 = "이 설치를 적용시키려면 '계속' 버튼을 눌러주세요., 이 단계를 넘기시려면 '무시' 버튼을 누르시면 됩니다."

	L.install_step_4_line_1 = "설치가 완료되었습니다."
	L.install_step_4_line_2 = "UI를 다시 불러오시려면 '마침' 버튼을 눌러주세요."
	L.install_step_4_line_3 = ""
	L.install_step_4_line_4 = "Tukui를 즐기세요! http://www.tukui.org를 통해 방문하실수 있습니다.!"

	L.install_button_tutorial = "지침서"
	L.install_button_install = "설치"
	L.install_button_next = "다음"
	L.install_button_skip = "무시"
	L.install_button_continue = "계속"
	L.install_button_finish = "마침"
	L.install_button_close = "종료"
end
