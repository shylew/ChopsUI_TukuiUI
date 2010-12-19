local zone = "The Ruby Sanctum"

--en_zone, debuffID, order, icon_priority, color_priority, timer, stackable, color, default_disable, noicon

--Trash
GridStatusRaidDebuff:Debuff(zone, 13737, 1, 5, 5, true) --Mortal Strike
GridStatusRaidDebuff:Debuff(zone, 15621, 2, 5, 5) --Skull Crack
GridStatusRaidDebuff:Debuff(zone, 75413, 3, 5, 5, true) --Flame Wave
GridStatusRaidDebuff:Debuff(zone, 75418, 4, 5, 5) --Shockwave

--Saviana Ragefire
GridStatusRaidDebuff:BossName(zone, 10, "Saviana Ragefire")
GridStatusRaidDebuff:Debuff(zone, 74453, 11, 5, 5, true) --Flame Beacon
GridStatusRaidDebuff:Debuff(zone, 74456, 12, 5, 5, true) --Conflagration

--Baltharus the Warborn
GridStatusRaidDebuff:BossName(zone, 15, "Baltharus the Warborn")
GridStatusRaidDebuff:Debuff(zone, 74505, 16, 5, 5, false, true) --Enervating Brand
GridStatusRaidDebuff:Debuff(zone, 74509, 17, 5, 5) --Repelling Wave

--General Zarithrian
GridStatusRaidDebuff:BossName(zone, 20, "General Zarithrian")
GridStatusRaidDebuff:Debuff(zone, 74384, 21, 5, 5, true) --Intimidating Roar
GridStatusRaidDebuff:Debuff(zone, 74367, 22, 5, 5, false, true) --Cleave Armor

--Halion
GridStatusRaidDebuff:BossName(zone, 30, "Halion")
GridStatusRaidDebuff:Debuff(zone, 74567, 31, 5, 5, true, true) --Mark of Combustion
GridStatusRaidDebuff:Debuff(zone, 74795, 32, 5, 5, true, true) --Mark of Consumption
