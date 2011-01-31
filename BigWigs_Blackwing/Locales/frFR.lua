local L = BigWigs:NewBossLocale("Atramedes", "frFR")
if L then
	L.tracking_me = "Pistage sur moi !"

	L.ground_phase = "Phase au sol"
	L.ground_phase_desc = "Prévient quand Atramédès atterrit."
	L.air_phase = "Phase aérienne"
	L.air_phase_desc = "Prévient quand Atramédès décolle."

	L.air_phase_trigger = "Oui, fuyez ! Chaque foulée accélère votre cœur. Les battements résonnent comme le tonnerre... Assourdissant. Vous ne vous échapperez pas !" -- à vérifier

	L.sonicbreath_cooldown = "~Souffle sonique"
end

L = BigWigs:NewBossLocale("Chimaeron", "frFR")
if L then
	L.bileotron_engage = "Le bile-o-tron s'anime et commence à secréter une substance malodorante."
	L.win_trigger = "Quel dommage de perdre cette expérience"

	L.next_system_failure = "Prochaine Défaillance"
	L.break_message = "%2$dx Brèche sur %1$s"

	L.phase2_message = "Phase Mortalité imminente !"

	L.warmup = "Échauffement"
	L.warmup_desc = "Minuteur de l'échauffement."
end

L = BigWigs:NewBossLocale("Magmaw", "frFR")
if L then
	-- heroic
	L.inferno = (GetSpellInfo(92191))
	L.inferno_desc = "Invoque un Assemblage d'os flamboyant."

	L.phase2 = "Phase 2"
	L.phase2_desc = "Prévient quand la rencontre passe en phase 2 et affiche le vérificateur de portées."
	L.phase2_message = "Phase 2 !"
	L.phase2_yell = "Inconcevable ! Vous pourriez vraiment vaincre mon ver de lave !" -- à vérifier

	-- normal
	L.pillar_of_flame_cd = "~Pilier de flammes"

	L.blazing_message = "Arrivée d'un Assemblage !"
	L.blazing_bar = "Prochain Assemblage"

	L.slump = "Affalement (rodéo)"
	L.slump_desc = "Prévient quand le boss s'affale vers l'avant et s'expose, permettant ainsi au rodéo de commencer."
	L.slump_bar = "Prochain rodéo"
	L.slump_message = "Yeehaw, chevauchez !"
	L.slump_trigger = "%s s'affale vers l'avant et expose ses pinces !"

	L.infection_message = "Vous êtes infecté !"

	L.expose_trigger = "expose sa tête"
	L.expose_message = "Tête exposée !"
end

L = BigWigs:NewBossLocale("Maloriak", "frFR")
if L then
	--heroic
	L.sludge = "Sombre vase"
	L.sludge_desc = "Prévient quand vous vous trouvez dans une Sombre vase."
	L.sludge_message = "Sombre vase sur vous !"

	--normal
	L.final_phase = "Phase finale"

	L.release_aberration_message = "%d aberrations restantes !"
	L.release_all = "%d aberrations libérées !"

	L.bitingchill_say = "Frisson mordant sur moi !"

	L.flashfreeze = "~Gel instantané"
	L.next_blast = "~Déflagration brûlante"

	L.phase = "Phases"
	L.phase_desc = "Prévient quand la rencontre entre dans une nouvelle phase."
	L.next_phase = "Prochaine phase"
	L.green_phase_bar = "Phase verte"

	L.red_phase_trigger = "Mélanger, touiller, faire chauffer..." -- à vérifier
	L.red_phase = "Phase |cFFFF0000rouge|r"
	L.blue_phase_trigger = "Celui-ci est un peu instable, mais que serait le progrès sans échec ?" -- à vérifier
	L.blue_phase = "Phase |cFF809FFEbleue|r"
	L.green_phase_trigger = "Jusqu'où une enveloppe mortelle peut-elle supporter des écarts extrêmes de température ? Je dois trouver ! Pour la science !" -- à vérifier
	L.green_phase = "Phase |cFF33FF00verte|r"
	L.dark_phase = "Phase |cFF660099sombre|r"
	L.dark_phase_trigger = "Tes mixtures sont insipides, Maloriak ! Elles ont besoin d'un peu de... force !" -- à vérifier
end

L = BigWigs:NewBossLocale("Nefarian", "frFR")
if L then
	L.phase = "Phases"
	L.phase_desc = "Prévient quand la rencontre entre dans une nouvelle phase."

	L.phase_two_trigger = "Soyez maudits, mortels ! Un tel mépris pour les possessions d'autrui doit être traité avec une extrême fermeté !" -- à vérifier

	L.phase_three_trigger = "J'ai tout fait pour être un hôte accomodant, mais vous ne daignez pas mourir ! Oublions les bonnes manières et passons aux choses sérieuses... VOUS TUER TOUS !" -- à vérifier

	L.crackle_trigger = "L'électricité crépite dans l'air !" -- à vérifier
	L.crackle_message = "Electrocuter imminent !"

	L.onyxia_power_message = "Explosion imminente !"

	L.cinder_say = "Braises explosives sur moi !"

	L.chromatic_prototype = "Prototype chromatique" -- 3 adds name
end

L = BigWigs:NewBossLocale("Omnotron Defense System", "frFR")
if L then
	L.nef = "Seigneur Victor Nefarius"
	L.nef_desc = "Prévient quand le Seigneur Victor Nefarius utilise une technique."
	L.switch = "Changement"
	L.switch_desc = "Prévient de l'arrivée des changements."
	L.switch_message = "%s %s"

	L.next_switch = "Prochaine activation"

	L.nef_trigger1 = "Vous aviez l'intention d'utiliser les attaques chimiques de Toxitron contre les autres assemblages ?" -- à compléter
	L.nef_trigger2 = "Ces nains stupides et leur fascination pour les runes !" -- à compléter

	L.nef_next = "~Prochain buff de technique"

	L.acquiring_target = "Acquisition d'une cible"

	L.bomb_message = "Une Bombe de poison vous poursuit !"
	L.cloud_say = "Nuage chimique sur moi !"
	L.cloud_message = "Nuage chimique sur vous !"
	L.protocol_message = "Arrivée de Bombes de poison !"

	L.iconomnotron = "Icône sur le boss actif"
	L.iconomnotron_desc = "Place l'icône de raid primaire sur le boss actif (nécessite d'être assistant ou mieux)."
end

