local zone = "Zul'Aman"

--en_zone, debuffID, order, icon_priority, color_priority, timer, stackable, color, default_disable, noicon

--Nalorakk
GridStatusRaidDebuff:BossName(zone, 10, "Nalorakk")
GridStatusRaidDebuff:Debuff(zone, 42398, 11, 5, 5) --Mangle

--Akilzon
GridStatusRaidDebuff:BossName(zone, 20, "Akil'zon")
GridStatusRaidDebuff:Debuff(zone, 43657, 21, 5, 5) --Electrical Storm
GridStatusRaidDebuff:Debuff(zone, 43622, 22, 5, 5) --Static Distruption

--Zanalai
GridStatusRaidDebuff:BossName(zone, 30, "Jan'alai")
GridStatusRaidDebuff:Debuff(zone, 43299, 31, 5, 5, false, true) --Flame Buffet

--halazzi
GridStatusRaidDebuff:BossName(zone, 40, "Halazzi")
GridStatusRaidDebuff:Debuff(zone, 43303, 41, 5, 5) --Flame Shock

--hex lord
GridStatusRaidDebuff:BossName(zone, 50, "Hex Lord Malacrass")
GridStatusRaidDebuff:Debuff(zone, 43613, 51, 5, 5) --Cold Stare
GridStatusRaidDebuff:Debuff(zone, 43501, 52, 5, 5) --Siphon soul

--Zulzin
GridStatusRaidDebuff:BossName(zone, 60, "Zul'jin")
GridStatusRaidDebuff:Debuff(zone, 43093, 61, 5, 5) --Throw
GridStatusRaidDebuff:Debuff(zone, 43095, 62, 5, 5) --Paralyze
GridStatusRaidDebuff:Debuff(zone, 43150, 63, 5, 5) --Rage

