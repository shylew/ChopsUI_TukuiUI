local L = BigWigs:NewBossLocale("Beth'tilac", "zhCN")
if not L then return end
if L then
	L.devastate_message = "Devastation #%d!"
	L.devastate_bar = "~Next devastation"
	L.drone_bar = "Next Cinderweb Drone"
	L.drone_message = "Big drone incoming!"
end

L = BigWigs:NewBossLocale("Lord Rhyolith", "zhCN")
if L then
	L.molten_message = "%dx stacks on boss!"
	L.armor_message = "%d%% armor left"
	L.armor_gone_message = "Armor go bye-bye!"
	L.phase2_soon_message = "Phase 2 soon!"
	L.stomp_message = "Stomp! Stomp! Stomp!"
	L.big_add_message = "Big add spawned!"
	L.small_adds_message = "Small adds inc!"
end

L = BigWigs:NewBossLocale("Alysrazor", "zhCN")
if L then
	L.tornado_trigger = "These skies are MINE!"
	L.claw_message = "%2$dx Claw on %1$s"
	L.fullpower_soon_message = "Full power soon!"
	L.halfpower_soon_message = "Phase 4 soon!"
	L.encounter_restart = "Full power! Here we go again ..."
end

L = BigWigs:NewBossLocale("Shannox", "zhCN")
if L then
	L.safe = "%s safe"
	L.immolation_trap = "Immolation on %s!"
end

L = BigWigs:NewBossLocale("Baleroc", "zhCN")
if L then
	L.torment_message = "%2$dx torment on %1$s"
	L.blade = "~Blade"
end

L = BigWigs:NewBossLocale("Majordomo Staghelm", "zhCN")
if L then
	L.seed_explosion = "Seed explosion soon!"
end

L = BigWigs:NewBossLocale("Ragnaros", "zhCN")
if L then
	L.intermission = "Intermission"
	L.sons_left = "%d Sons Left"
	L.engulfing_close = "Close %s"
	L.engulfing_middle = "Middle %s"
	L.engulfing_far = "Far %s"
end

