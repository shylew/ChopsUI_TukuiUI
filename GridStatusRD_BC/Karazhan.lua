local zone = "Karazhan"

--en_zone, debuffID, order, icon_priority, color_priority, timer, stackable, color, default_disable, noicon

--Moroes
GridStatusRaidDebuff:BossName(zone, 10, "Moroes")
GridStatusRaidDebuff:Debuff(zone, 37066, 11, 5, 5) --Garrote

--Maiden
GridStatusRaidDebuff:BossName(zone, 20, "Maiden of Virtue")
GridStatusRaidDebuff:Debuff(zone, 29522, 21, 5, 5) --Holy Fire
GridStatusRaidDebuff:Debuff(zone, 29511, 22, 5, 5) --Repentance

--Opera : Bigbad wolf
GridStatusRaidDebuff:BossName(zone, 30, "The Big Bad Wolf")
GridStatusRaidDebuff:Debuff(zone, 30753, 31, 5, 5, true) --Red riding hood

--Illhoof
GridStatusRaidDebuff:BossName(zone, 40, "Terestian Illhoof")
GridStatusRaidDebuff:Debuff(zone, 30115, 41, 5, 5) --Sacrifice

--Malche
GridStatusRaidDebuff:BossName(zone, 50, "Prince Malchezaar")
GridStatusRaidDebuff:Debuff(zone, 30843, 51, 5, 5) --Enfeeble

