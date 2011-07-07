local L = BigWigs:NewBossLocale("Beth'tilac", "deDE")
if not L then return end
if L then
	L.devastate_message = "Verwüstung #%d!"
	L.devastate_bar = "~Verwüstung"
	L.drone_bar = "Nächste Drohne"
	L.drone_message = "Drohne kommt!"
	L.kiss_message = "Kuss"
end

L = BigWigs:NewBossLocale("Lord Rhyolith", "deDE")
if L then
	L.molten_message = "%dx Stapel auf Rhyolith!"
	L.armor_message = "%d%% Rüstung noch"
	L.armor_gone_message = "Rüstung weg!"
	L.phase2_soon_message = "Phase 2 bald!"
	L.stomp_message = "Stampfen! Stampfen! Stampfen!"
	L.big_add_message = "Funke kommt!"
	L.small_adds_message = "Fragmente kommen!"
end

L = BigWigs:NewBossLocale("Alysrazor", "deDE")
if L then
	L.tornado_trigger = "Dieser Himmel ist MEIN."
	L.claw_message = "%2$dx Klauen: %1$s"
	L.fullpower_soon_message = "Volle Kraft bald!"
	L.halfpower_soon_message = "Phase 4 bald!"
	L.encounter_restart = "Volle Kraft! Es geht wieder los..."
	L.no_stacks_message = "Du hast keine Federn!"
	L.moonkin_message = "Beschaff' dir richtige Federn!"

	L.worm_emote = "Feurige Lavawürmer brechen aus dem Boden hervor!"
	L.phase2_soon_emote = "Alysrazar beginnt, in einem schnellen Kreis zu fliegen!"
end

L = BigWigs:NewBossLocale("Shannox", "deDE")
if L then
	L.safe = "%s ist sicher!"
	L.immolation_trap = "Brandfalle auf %s!"
	L.crystaltrap = "Kristallfalle"
end

L = BigWigs:NewBossLocale("Baleroc", "deDE")
if L then
	L.torment_message = "%2$dx Qual: %1$s"
	L.blade = "Nächste Klinge"
end

L = BigWigs:NewBossLocale("Majordomo Staghelm", "deDE")
if L then
	L.seed_explosion = "Samenexplosion bald!"
end

L = BigWigs:NewBossLocale("Ragnaros", "deDE")
if L then
	L.seed_explosion = "Samenexplosion!"
	L.intermission = "Übergang"
	L.sons_left = "%d Söhne noch"
	L.engulfing_close = "Nahe %s"
	L.engulfing_middle = "Mittlere %s"
	L.engulfing_far = "Weite %s"
end

