local L = BigWigs:NewBossLocale("Cho'gall", "koKR")
if L then
	L.orders = "상태 변경"
	L.orders_desc = "초갈의 그림자/불꽃의 명령 상태를 알립니다."

	L.crash_say = "나에게 부패의 충돌!"
	L.worship_cooldown = "~개종"
	L.adherent_bar = "추종자 추가 (%d)"
	L.adherent_message = "타락의 추종자 (%d) 소환!"
	L.ooze_bar = "슬라임 추가 (%d)"
	L.ooze_message = "곧 슬라임 (%d) 추가!"
	L.tentacles_bar = "촉수 소환"
	L.tentacles_message = "촉수 디스코 파티!"
	L.sickness_message = "당신은 피부 트러블!"
	L.fury_bar = "다음 격노"
	L.fury_message = "격노!"

	L.phase2_message = "2 단계!"
	L.phase2_soon = "곧 2 단계!"
end

L = BigWigs:NewBossLocale("Valiona and Theralion", "koKR")
if L then
	L.phase_switch = "단계 전환"
	L.phase_switch_desc = "단계 전환을 알립니다."

	L.phase_bar = "%s 착지"
	L.breath_message = "곧 깊은 숨결!"
	L.dazzling_message = "곧 황혼 세계"

	L.engulfingmagic_say = "나에게 사로잡힌 마법!"
	L.engulfingmagic_cooldown = "다음 사로잡힌 마법"

	L.devouringflames_cooldown = "다음 파멸의 불길"

	L.valiona_trigger = "테랄리온, 내가 전당에 불을 뿜겠다. 놈들의 퇴로를 막아라!"

	L.twilight_shift = "황혼 이동 x%2$d : %1$s"
end

L = BigWigs:NewBossLocale("Halfus Wyrmbreaker", "koKR")
if L then
	L.strikes_message = "악의의 일격 %2$dx : %1$s"
end

L = BigWigs:NewBossLocale("Sinestra", "koKR")
if L then

end

L = BigWigs:NewBossLocale("Ascendant Council", "koKR")
if L then
	L.static_overload_say = "나에게 전화 과부하!"
	L.gravity_core_say = "나에게 중력 핵!"
	L.health_report = "%s의 체력 -%d%%-, 곧 단계 변화!"
	L.switch = "전환"
	L.switch_desc = "보스의 전환을 알립니다."

	L.shield_up_message = "방패 사용!"
	L.shield_bar = "다음 방패"

	L.lightning_rod_say = "나아게 벼락 막대!"

	L.switch_trigger = "우리가 상대하겠다!"

	L.thundershock_quake_soon = "10초 후 %s!"

	L.quake_trigger = "발밑의 땅이 불길하게 우르릉거립니다..."
	L.thundershock_trigger = "주변의 공기가 에너지로 진동합니다..."

	L.searing_winds_message = "천둥충격이 다가옴!"
	L.grounded_message = "지진이 다가옴!"

	L.last_phase_trigger = "꽤나 인상적이었다만..."
end

L = BigWigs:NewBossLocale("Sinestra", "koKR")
if L then
	L.egg_vulnerable = "알 요리 시간!"

	L.omelet_trigger = "이게 약해진 걸로 보이느냐"	--check

	L.phase13 = "1 & 3 단계"
	L.phase = "단계"
	L.phase_desc = "단계 변화에 대해 알립니다."
end
