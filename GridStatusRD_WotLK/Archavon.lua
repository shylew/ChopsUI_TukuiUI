local zone = "Vault of Archavon"

--en_zone, debuffID, order, icon_priority, color_priority, timer, stackable, color, default_disable, noicon

--Koralon
GridStatusRaidDebuff:BossName(zone, 10, "Koralon the Flame Watcher")
GridStatusRaidDebuff:Debuff(zone, 67332, 11, 5, 5) --Flaming Cinder

--GridStatusRaidDebuff:BossName(zone, 20, "Toravon the Ice Watcher")
GridStatusRaidDebuff:Debuff(zone, 71993, 21, 5, 5, true, true) --Frozen Mallet
GridStatusRaidDebuff:Debuff(zone, 72098, 23, 5, 5, true, true) --Frostbite
GridStatusRaidDebuff:Debuff(zone, 72104, 23, 5, 5, true) --Freezing Ground