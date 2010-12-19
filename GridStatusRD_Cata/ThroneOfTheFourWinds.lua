local zone = "Throne of the Four Winds"

--en_zone, debuffID, order, icon_priority, color_priority, timer, stackable, color, default_disable, noicon

--Conclave of Wind
GridStatusRaidDebuff:BossName(zone, 10, "Conclave of Wind")
GridStatusRaidDebuff:Debuff(zone, 84645, 11, 5, 5) --Wind Chill
GridStatusRaidDebuff:Debuff(zone, 86111, 12, 6, 6) --Ice Patch
GridStatusRaidDebuff:Debuff(zone, 86082, 13, 7, 7) --Permafrost
GridStatusRaidDebuff:Debuff(zone, 86481, 14, 7, 7) --Hurricane
GridStatusRaidDebuff:Debuff(zone, 86282, 15, 7, 7) --Toxic Spores
GridStatusRaidDebuff:Debuff(zone, 85573, 16, 8, 8) --Deafening Winds
GridStatusRaidDebuff:Debuff(zone, 85576, 17, 8, 8) --Withering Winds

--Al'Akir
GridStatusRaidDebuff:BossName(zone, 20, "Al'Akir")
GridStatusRaidDebuff:Debuff(zone, 88301, 21, 5, 5) --Acid Rain
GridStatusRaidDebuff:Debuff(zone, 87873, 22, 6, 6) --Static Shock
GridStatusRaidDebuff:Debuff(zone, 88427, 23, 6, 6) --Electrocute
GridStatusRaidDebuff:Debuff(zone, 89666, 24, 6, 6) --Lightning Rod
GridStatusRaidDebuff:Debuff(zone, 89668, 25, 6, 6) --Lightning Rod
