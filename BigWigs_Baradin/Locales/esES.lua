
local L = BigWigs:NewBossLocale("Argaloth", "esES")
if not L then return end
if L then
	L.darkness_message = "Oscuridad"
	L.firestorm_message = "¡Tormenta de fuego inminente!"
end

L = BigWigs:NewBossLocale("Occu'thar", "esES")
if not L then return end
if L then
	L.shadows_bar = "~Sombras abrasadoras"
	L.destruction_bar = "<Explosión inminente>"
	L.eyes_bar = "~Ojos"

	L.fire_message = "Lazer, Pew Pew"
	L.fire_bar = "~Lazer"
end

L = BigWigs:NewBossLocale("Alizabal", "esES")
if L then
	L.first_ability = "Skewer or Hate"
	L.dance_message = "Blade Dance %d of 3"
end

