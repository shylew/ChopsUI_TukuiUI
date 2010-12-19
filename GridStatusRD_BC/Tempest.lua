local zone = "Tempest Keep"

--en_zone, debuffID, order, icon_priority, color_priority, timer, stackable, color, default_disable, noicon

--Trash
GridStatusRaidDebuff:Debuff(zone, 37123, 1, 5, 5) --Saw Blade
GridStatusRaidDebuff:Debuff(zone, 37120, 2, 5, 5) --Fragmentation Bomb
GridStatusRaidDebuff:Debuff(zone, 37118, 3, 5, 5) --Shell Shock

--Solarian
GridStatusRaidDebuff:BossName(zone, 30, "High Astromancer Solarian")
GridStatusRaidDebuff:Debuff(zone, 42783, 31, 5, 5, true) --Wrath of the Astromancer

--Kaeltahas
GridStatusRaidDebuff:BossName(zone, 40, "Kael'thas Sunstrider")
GridStatusRaidDebuff:Debuff(zone, 37027, 41, 5, 5) --Remote Toy
GridStatusRaidDebuff:Debuff(zone, 36798, 42, 5, 5) --Mind Control

