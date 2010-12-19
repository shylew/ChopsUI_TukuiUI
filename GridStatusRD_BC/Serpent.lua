local zone = "Serpentshrine Cavern"

--en_zone, debuffID, order, icon_priority, color_priority, timer, stackable, color, default_disable, noicon

--Trash
GridStatusRaidDebuff:Debuff(zone, 39042, 1, 5, 5) --Rampent Infection
GridStatusRaidDebuff:Debuff(zone, 39044, 2, 5, 5, true) --Serpentshrine Parasite

--Hydross
GridStatusRaidDebuff:BossName(zone, 10, "Hydross the Unstable")
GridStatusRaidDebuff:Debuff(zone, 38235, 11, 5, 5, true) --Water Tomb
GridStatusRaidDebuff:Debuff(zone, 38246, 12, 5, 5) --Vile Sludge

--Morogrim
GridStatusRaidDebuff:BossName(zone, 20, "Morogrim Tidewalker")
GridStatusRaidDebuff:Debuff(zone, 37850, 21, 5, 5, true) --Watery Grave

--Leotheras
GridStatusRaidDebuff:BossName(zone, 30, "Leotheras the Blind")
GridStatusRaidDebuff:Debuff(zone, 37676, 31, 5, 5) --insidious whisper
GridStatusRaidDebuff:Debuff(zone, 37641, 32, 5, 5, true) --Whirl wind
GridStatusRaidDebuff:Debuff(zone, 37749, 33, 5, 5) --Madness

--Vashj
GridStatusRaidDebuff:BossName(zone, 40, "Lady Vashj")
GridStatusRaidDebuff:Debuff(zone, 38280, 34, 5, 5, true) --Static Charge

