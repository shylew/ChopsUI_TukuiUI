-- $Id: loottables.lua 3781 2012-09-24 02:00:29Z ananhaid $
--[[
loottables.en.lua
This file assigns a title to every loot table.  The primary use of this table
is in the search function, as when iterating through the loot tables there is no
inherant title to the loot table, given the origins of the mod as an Atlas plugin.
]]

-- Invoke libraries
local AL = LibStub("AceLocale-3.0"):GetLocale("AtlasLoot");
local BabbleBoss = AtlasLoot_GetLocaleLibBabble("LibBabble-Boss-3.0")
local BabbleInventory = AtlasLoot_GetLocaleLibBabble("LibBabble-Inventory-3.0")
local BabbleFaction = AtlasLoot_GetLocaleLibBabble("LibBabble-Faction-3.0")
local BabbleZone = AtlasLoot_GetLocaleLibBabble("LibBabble-Zone-3.0")

-- Using alchemy skill to get localized rank
local JOURNEYMAN = select(2, GetSpellInfo(3101));
local EXPERT = select(2, GetSpellInfo(3464));
local ARTISAN = select(2, GetSpellInfo(11611));
local MASTER = select(2, GetSpellInfo(28596));

local ALCHEMY, APPRENTICE = GetSpellInfo(2259);
local BLACKSMITHING = GetSpellInfo(2018);
local ARMORSMITH = GetSpellInfo(9788);
local WEAPONSMITH = GetSpellInfo(9787);
local AXESMITH = GetSpellInfo(17041);
local HAMMERSMITH = GetSpellInfo(17040);
local SWORDSMITH = GetSpellInfo(17039);
local COOKING = GetSpellInfo(2550);
local ENCHANTING = GetSpellInfo(7411);
local ENGINEERING = GetSpellInfo(4036);
local GNOMISH = GetSpellInfo(20220);
local GOBLIN = GetSpellInfo(20221);
local FIRSTAID = GetSpellInfo(3273);
local FISHING = GetSpellInfo(63275);
local INSCRIPTION = GetSpellInfo(45357);
local JEWELCRAFTING = GetSpellInfo(25229);
local LEATHERWORKING = GetSpellInfo(2108);
local DRAGONSCALE = GetSpellInfo(10656);
local ELEMENTAL = GetSpellInfo(10658);
local TRIBAL = GetSpellInfo(10660);
local MINING = GetSpellInfo(2575);
local TAILORING = GetSpellInfo(3908);
local MOONCLOTH = GetSpellInfo(26798);
local SHADOWEAVE = GetSpellInfo(26801);
local SPELLFIRE = GetSpellInfo(26797);

AtlasLoot_LootTableRegister = {
	["Instances"] = {

-----------------------------------
--- Mists of Pandaria Instances ---
-----------------------------------

	---- Dungeons
		["TempleOfTheJadeSerpent"] = {
			["Bosses"] = {
				{ "TJSMari", EncounterJournalID = 672 },
				{ "TJSStonestep", EncounterJournalID = 664 },
				{ "TJSFlameheart", EncounterJournalID = 658 },
				{ "TJSShaDoubt", EncounterJournalID = 335 },
			},
			["Info"] = { BabbleZone["Temple of the Jade Serpent"], "AtlasLootMoP", mapname = "Temple of the Jade Serpent", EncounterJournalID = 313 },
		},

		["StormstoutBrewery"] = {
			["Bosses"] = {
				{ "BreweryOokOok", EncounterJournalID = 668 },
				{ "BreweryHoptallus", EncounterJournalID = 669 },
				{ "BreweryYanZhu", EncounterJournalID = 670 },
			},
			["Info"] = { BabbleZone["Stormstout Brewery"], "AtlasLootMoP", mapname = "Stormstout Brewery", EncounterJournalID = 302 },
		},

		["MoguShanPalace"] = {
			["Bosses"] = {
				{ "MoguShanTrialKing", EncounterJournalID = 708 },
				{ "MoguShanGekkan", EncounterJournalID = 690 },
				{ "MoguShanXin", EncounterJournalID = 698 },
			},
			["Info"] = { BabbleZone["Mogu'Shan Palace"], "AtlasLootMoP", mapname = "Mogu'Shan Palace", EncounterJournalID = 321 },
		},

		["ShadoPanMonastery"] = {
			["Bosses"] = {
				{ "ShadoPanCloudstrike", EncounterJournalID = 673 },
				{ "ShadoPanSnowdrift", EncounterJournalID = 657 },
				{ "ShadoPanShaViolence", EncounterJournalID = 685 },
				{ "ShadoPanTaranZhu", EncounterJournalID = 686 },
			},
			["Info"] = { BabbleZone["Shado-pan Monastery"], "AtlasLootMoP", mapname = "Shado-Pan Monastery", EncounterJournalID = 312 },
		},

		["GateoftheSettingSun"] = {
			["Bosses"] = {
				{ "GotSSKiptilak", EncounterJournalID = 655 },
				{ "GotSSGadok", EncounterJournalID = 675 },
				{ "GotSSRimok", EncounterJournalID = 676 },
				{ "GotSSRaigonn", EncounterJournalID = 649 },
			},
			["Info"] = { BabbleZone["Gate of the Setting Sun"], "AtlasLootMoP", mapname = "Gate of the Setting Sun", EncounterJournalID = 303 },
		},

		["NiuzaoTemple"] = {
			["Bosses"] = {
				{ "NTJinbak", EncounterJournalID = 693 },
				{ "NTVojak", EncounterJournalID = 738 },
				{ "NTPavalak", EncounterJournalID = 692 },
				{ "NTNeronok", EncounterJournalID = 727 },
			},
			["Info"] = { BabbleZone["Siege of Niuzao Temple"], "AtlasLootMoP", mapname = "Siege of Niuzao Temple", EncounterJournalID = 324 },
		},

---------------------------
--- Cataclysm Instances ---
---------------------------

	---- Dungeons
		["BlackrockCaverns"] = {
			["Bosses"] = {
				{ "BlackrockCavernsRomogg", 2, EncounterJournalID = 105 },
				{ "BlackrockCavernsCorla", 3, EncounterJournalID = 106 },
				{ "BlackrockCavernsSteelbender", 4, EncounterJournalID = 107 },
				{ "BlackrockCavernsBeauty", 5, EncounterJournalID = 108 },
				{ "BlackrockCavernsLordObsidius", 6, EncounterJournalID = 109 },
				{ "BlackrockCavernsTrash", 11 },
			},
			["Info"] = { BabbleZone["Blackrock Caverns"], "AtlasLootCataclysm", mapname = "BlackrockCaverns", EncounterJournalID = 66 },
		},

		["CoTEndTime"] = {
			["Bosses"] = {
				{ "EndtimeEchoes", {3,4,5,6}, EncounterJournalID = 340 },
				{ "EndtimeMurozond", 7, EncounterJournalID = 289 },
				{ "EndtimeTrash", 10 },
			},
			["Info"] = { BabbleZone["End Time"], "AtlasLootCataclysm", mapname = "EndTime", EncounterJournalID = 184 },
		},

		["CoTHourOfTwilight"] = {
			["Bosses"] = {
				{ "HoTArcurion", 3, EncounterJournalID = 322 },
				{ "HoTDawnslayer", 4, EncounterJournalID = 342 },
				{ "HoTBenedictus", 5, EncounterJournalID = 341 },
				{ "HoTTrash", 8 },
			},
			["Info"] = { BabbleZone["Hour of Twilight"], "AtlasLootCataclysm", mapname = "HourofTwilight", EncounterJournalID = 186 },
		},

		["CoTWellOfEternity"] = {
			["Bosses"] = {
				{ "WoEPerotharn", 3, EncounterJournalID = 290 },
				{ "WoEAzshara", 4, EncounterJournalID = 291 },
				{ "WoEMannoroth", 5, EncounterJournalID = 292 },
				{ "WoETrash", 8 },
			},
			["Info"] = { BabbleZone["Well of Eternity"], "AtlasLootCataclysm", mapname = "WellOfEternity", EncounterJournalID = 185 },
		},

		["GrimBatol"] = {
			["Bosses"] = {
				{ "GBUmbriss", 2, EncounterJournalID = 131 },
				{ "GBThrongus", 3, EncounterJournalID = 132 },
				{ "GBDrahga", 4, EncounterJournalID = 133 },
				{ "GBErudax", 5, EncounterJournalID = 134 },
				{ "GBTrash", 10 },
			},
			["Info"] = { BabbleZone["Grim Batol"], "AtlasLootCataclysm", mapname = "GrimBatol", EncounterJournalID = 71 },
		},

		["HallsOfOrigination"] = {
			["Bosses"] = {
				{ "HoOAnhuur", 2, EncounterJournalID = 124 },
				{ "HoOPtah", 3, EncounterJournalID = 125 },
				{ "HoOAnraphet", 4, EncounterJournalID = 126 },
				{ "HoOIsiset", 5, EncounterJournalID = 127 },
				{ "HoOAmmunae", 6, EncounterJournalID = 128 },
				{ "HoOSetesh", 7, EncounterJournalID = 129 },
				{ "HoORajh", 8, EncounterJournalID = 130 },
				{ "HoOTrash", 13 },
			},
			["Info"] = { BabbleZone["Halls of Origination"], "AtlasLootCataclysm", mapname = "HallsOfOrigination", EncounterJournalID = 70 },
		},

		["LostCityOfTolvir"] = {
			["Bosses"] = {
				{ "LostCityHusam", 3, EncounterJournalID = 117 },
				{ "LostCityLockmaw", {4,5}, EncounterJournalID = 118 },
				{ "LostCityBarim", 6, EncounterJournalID = 119 },
				{ "LostCitySiamat", 7, EncounterJournalID = 122 },
				{ "LostCityTrash", 10 },
			},
			["Info"] = { BabbleZone["Lost City of the Tol'vir"], "AtlasLootCataclysm", mapname = "LostCityofTolvir", EncounterJournalID = 69 },
		},

		["TheStonecore"] = {
			["Bosses"] = {
				{ "StonecoreCorborus", 4, EncounterJournalID = 110 },
				{ "StonecoreSlabhide", 5, EncounterJournalID = 111 },
				{ "StonecoreOzruk", 6, EncounterJournalID = 112 },
				{ "StonecoreAzil", 7, EncounterJournalID = 113 },
				{ "StonecoreTrash", 10 },
			},
			["Info"] = { BabbleZone["The Stonecore"], "AtlasLootCataclysm", mapname = "TheStonecore", EncounterJournalID = 67 },
		},

		["TheVortexPinnacle"] = {
			["Bosses"] = {
				{ "VPErtan", 3, EncounterJournalID = 114 },
				{ "VPAltairus", 4 , EncounterJournalID = 115},
				{ "VPAsaad", 5, EncounterJournalID = 116 },
				{ "VPTrash", 9 },
			},
			["Info"] = { BabbleZone["The Vortex Pinnacle"], "AtlasLootCataclysm", mapname = "SkywallDungeon", EncounterJournalID = 68 },
		},

		["ThroneOfTheTides"] = {
			["Bosses"] = {
				{ "ToTNazjar", 5, EncounterJournalID = 101 },
				{ "ToTUlthok",  6, EncounterJournalID = 102 },
				{ "ToTMindbender", 7, EncounterJournalID = 103 },
				{ "ToTOzumat", 8, EncounterJournalID = 104 },
				{ "ToTTrash", 12 },
			},
			["Info"] = { BabbleZone["Throne of the Tides"], "AtlasLootCataclysm", mapname = "ThroneOfTheTides", EncounterJournalID = 65 },
		},

		["ZulAman"] = {
			["Bosses"] = {
				{ "ZAAkilZon", 6, EncounterJournalID = 186 },
				{ "ZANalorakk", 8, EncounterJournalID = 187 },
				{ "ZAJanAlai", 11, EncounterJournalID = 188 },
				{ "ZAHalazzi", 13, EncounterJournalID = 189 },
				{ "ZAMalacrass", 15, EncounterJournalID = 190 },
				{ "ZADaakara", 24, EncounterJournalID = 191 },
				{ "ZATimedChest", 40 },
				{ "ZATrash", 41 },
			},
			["Info"] = { BabbleZone["Zul'Aman"].." ", "AtlasLootCataclysm", mapname = "ZulAman", EncounterJournalID = 77 },
		},

		["ZulGurub"] = {
			["Bosses"] = {
				{ "ZGVenoxis", 17, EncounterJournalID = 175 },
				{ "ZGMandokir", 22, EncounterJournalID = 176 },
				{ "ZGMadness", 26, EncounterJournalID = { 177, 178, 179, 180 } },
				{ "ZGKilnara", 34, EncounterJournalID = 181 },
				{ "ZGZanzil", 36, EncounterJournalID = 184 },
				{ "ZGJindo", 40, EncounterJournalID = 185 },
				{ "ZGTrash", 42 },
			},
			["Info"] = { BabbleZone["Zul'Gurub"], "AtlasLootCataclysm", mapname = "ZulGurub", EncounterJournalID = 76 },
		},

	---- Raids

		["BlackwingDescent"] = {
			["Bosses"] = {
				{ "BDMagmaw", 2, EncounterJournalID = 170 },
				{ "BDOmnotron", 3, EncounterJournalID = 169 },
				{ "BDChimaeron", 4, EncounterJournalID = 172 },
				{ "BDMaloriak", 5, EncounterJournalID = 173 },
				{ "BDAtramedes", 6, EncounterJournalID = 171 },
				{ "BDNefarian", 7, EncounterJournalID = 174 },
				{ "BDTrash", 9 },
			},
			["Info"] = { BabbleZone["Blackwing Descent"], "AtlasLootCataclysm", mapname = "BlackwingDescent", raid = true, EncounterJournalID = 73 },
		},

		["BaradinHold"] = {
			["Bosses"] = {
				{ "BaradinsWardens", 1, hide = true },
				{ "HellscreamsReach", 2, hide = true },
				{ "ARGALOTH", 4, EncounterJournalID = 139 },
				{ "OCCUTHAR", 5, EncounterJournalID = 140 },
				{ "ALIZABAL", 6, EncounterJournalID = 339 },
			},
			["Info"] = { BabbleZone["Baradin Hold"], "AtlasLootCataclysm", mapname = "Baradinhold", raid = true, disableCompare = true, EncounterJournalID = 75 },
		},

		["CoTDragonSoulA"] = "CoTDragonSoul",
		["CoTDragonSoulB"] = "CoTDragonSoul",
		["CoTDragonSoulC"] = "CoTDragonSoul",
		["CoTDragonSoul"] = {
			["CoTDragonSoulA"] = {
				{ "DragonSoulMorchok", 3, EncounterJournalID = 311 },
				{ "DragonSoulUltraxion", 4, EncounterJournalID = 331, hide = true },
				{ "DragonSoulShared", 6, hide = true },
				{ "DragonSoulTrash", 7, hide = true },
				{ "DragonSoulPatterns", 8, hide = true },
			},
			["CoTDragonSoulB"] = {
				{ "DragonSoulZonozz", 2, EncounterJournalID = 324 },
				{ "DragonSoulYorsahj", 3, EncounterJournalID = 325 },
				{ "DragonSoulHagara", 4, EncounterJournalID = 317 },
				{ "DragonSoulUltraxion", EncounterJournalID = 331 },
				{ "DragonSoulShared", 6, hide = true },
				{ "DragonSoulTrash", 7, hide = true },
				{ "DragonSoulPatterns", 8, hide = true },
			},
			["CoTDragonSoulC"] = {
				{ "DragonSoulBlackhorn", 1, EncounterJournalID = 332 },
				{ "DragonSoulDeathwingSpine", 2, EncounterJournalID = 318 },
				{ "DragonSoulDeathwingMadness", 3, EncounterJournalID = 333 },
				{ "DragonSoulShared", 5 },
				{ "DragonSoulTrash", 6 },
				{ "DragonSoulPatterns", 7 },
			},
			["Info"] = { BabbleZone["Dragon Soul"], "AtlasLootCataclysm", mapname = "DragonSoul", sortOrder = { "CoTDragonSoulA", "CoTDragonSoulB", "CoTDragonSoulC" }, raid = true, EncounterJournalID = 187 },
		},

		["Firelands"] = {
			["Bosses"] = {
				{ "AvengersHyjal", {1,4}, hide = true },
				{ "FirelandsBethtilac", 6, EncounterJournalID = 192 },
				{ "FirelandsRhyolith", 7, EncounterJournalID = 193 },
				{ "FirelandsAlysrazor", 8, EncounterJournalID = 194 },
				{ "FirelandsShannox", 9, EncounterJournalID = 195 },
				{ "FirelandsBaleroc", 10, EncounterJournalID = 196 },
				{ "FirelandsStaghelm", 11, EncounterJournalID = 197 },
				{ "FirelandsRagnaros", 12, EncounterJournalID = 198 },
				{ "FirelandsShared", 15 },
				{ "FirelandsTrash", 16 },
				{ "FirelandsPatterns", 17 },
				{ "FirelandsFirestone", 3 },
			},
			["Info"] = { BabbleZone["Firelands"], "AtlasLootCataclysm", mapname = "Firelands", raid = true, EncounterJournalID = 78 },
		},

		["TheBastionOfTwilight"] = {
			["Bosses"] = {
				{ "BoTWyrmbreaker", 3, EncounterJournalID = 156 },
				{ "BoTValionaTheralion", 4, EncounterJournalID = 157 },
				{ "BoTCouncil", 6, EncounterJournalID = 158 },
				{ "BoTChogall", 8, EncounterJournalID = 167 },
				{ "BoTSinestra", 9, EncounterJournalID = 168 },
				{ "BoTTrash", 12 },
			},
			["Info"] = { BabbleZone["The Bastion of Twilight"], "AtlasLootCataclysm", mapname = "TheBastionofTwilight", raid = true, EncounterJournalID = 72 },
		},

		["ThroneOfTheFourWinds"] = {
			["Bosses"] = {
				{ "TFWConclave", 2, EncounterJournalID = 154 },
				{ "TFWAlAkir", 6, EncounterJournalID = 155 },
			},
			["Info"] = { BabbleZone["Throne of the Four Winds"], "AtlasLootCataclysm", mapname = "Throneofthefourwinds", raid = true, EncounterJournalID = 74 },
		},

-----------------------
--- WotLK Instances ---
-----------------------

	---- Dungeons
		["AhnKahet"] = {
			["Bosses"] = {
				{ "AhnkahetNadox", 3, EncounterJournalID = 580 },
				{ "AhnkahetTaldaram", 4, EncounterJournalID = 581 },
				{ "AhnkahetAmanitar", 5 },
				{ "AhnkahetJedoga", 6, EncounterJournalID = 582 },
				{ "AhnkahetVolazj", 7, EncounterJournalID = 584 },
				{ "AhnkahetTrash", 10 },
			},
			["Info"] = { BabbleZone["Ahn'kahet: The Old Kingdom"], "AtlasLootWotLK", mapname = "Ahnkahet", EncounterJournalID = 271 },
		},

		["AzjolNerub"] = {
			["Bosses"] = {
				{ "AzjolNerubKrikthir", 4, EncounterJournalID = 585 },
				{ "AzjolNerubHadronox", 8, EncounterJournalID = 586 },
				{ "AzjolNerubAnubarak", 9, EncounterJournalID = 587 },
				{ "LunarFestival", 10, hide = true },
				{ "AzjolNerubTrash", 12 },
			},
			["Info"] = { BabbleZone["Azjol-Nerub"], "AtlasLootWotLK", mapname = "AzjolNerub", EncounterJournalID = 272 },
		},

		["CoTOldStratholme"] = {
			["Bosses"] = {
				{ "CoTStratholmeMeathook", 5, EncounterJournalID = 611 },
				{ "CoTStratholmeSalramm", 6, EncounterJournalID = 612 },
				{ "CoTStratholmeEpoch", 7, EncounterJournalID = 613 },
				{ "CoTStratholmeTrash", 8, hide = true },
				{ "CoTStratholmeMalGanis", 10, EncounterJournalID = 614 },
				{ "CoTStratholmeTrash", 14 },
			},
			["Info"] = { BabbleZone["Old Stratholme"], "AtlasLootWotLK", mapname = "CoTStratholme", EncounterJournalID = 279 },
		},
		
		["DrakTharonKeep"] = {
			["Bosses"] = {
				{ "DrakTharonKeepTrollgore", 3, EncounterJournalID = 588 },
				{ "DrakTharonKeepNovos", 4, EncounterJournalID = 589 },
				{ "DrakTharonKeepKingDred", 5, EncounterJournalID = 590 },
				{ "DrakTharonKeepTharonja", 6, EncounterJournalID = 591 },
				{ "LunarFestival", 8, hide = true },
				{ "DrakTharonKeepTrash", 11 },
			},
			["Info"] = { BabbleZone["Drak'Tharon Keep"], "AtlasLootWotLK", mapname = "DrakTharonKeep", EncounterJournalID = 273 },
		},

		["FHTheForgeOfSouls"] = {
			["Bosses"] = {
				{ "FoSBronjahm", 3, EncounterJournalID = 615 },
				{ "FoSDevourer", 4, EncounterJournalID = 616 },
				{ "FHTrashMobs", 12 },
			},
			["Info"] = { BabbleZone["The Forge of Souls"], "AtlasLootWotLK", mapname = "TheForgeofSouls", EncounterJournalID = 280 },
		},

		["FHHallsOfReflection"] = {
			["Bosses"] = {
				{ "HoRFalric", 4, EncounterJournalID = 601 },
				{ "HoRMarwyn", 5, EncounterJournalID = 602 },
				{ "HoRLichKing", {6,7}, EncounterJournalID = 603 },
				{ "FHTrashMobs", 13 },
			},
			["Info"] = { BabbleZone["Halls of Reflection"], "AtlasLootWotLK", mapname = "HallsofReflection", EncounterJournalID = 276 },
		},

		["FHPitOfSaron"] = {
			["Bosses"] = {
				{ "PoSGarfrost", 4, EncounterJournalID = 608 },
				{ "PoSKrickIck", 7, EncounterJournalID = 609 },
				{ "PoSTyrannus", 8, EncounterJournalID = 610 },
				{ "FHTrashMobs", 17 },
			},
			["Info"] = { BabbleZone["Pit of Saron"], "AtlasLootWotLK", mapname = "PitofSaron", EncounterJournalID = 278 },
		},

		["Gundrak"] = {
			["Bosses"] = {
				{ "GundrakSladran", 3, EncounterJournalID = 592 },
				{ "GundrakColossus", 4, EncounterJournalID = 593 },
				{ "GundrakMoorabi", 5, EncounterJournalID = 594 },
				{ "GundrakEck", 6 },
				{ "GundrakGaldarah", 7, EncounterJournalID = 596 },
				{ "LunarFestival", 8, hide = true },
				{ "GundrakTrash", 10 },
			},
			["Info"] = { BabbleZone["Gundrak"], "AtlasLootWotLK", mapname = "Gundrak", EncounterJournalID = 274 },
		},

		["TheNexus"] = {
			["Bosses"] = {
				{ "TheNexusKolurgStoutbeard", {2,3} },
				{ "TheNexusTelestra", 5, EncounterJournalID = 618 },
				{ "TheNexusAnomalus", 6, EncounterJournalID = 619 },
				{ "TheNexusOrmorok", 7, EncounterJournalID = 620 },
				{ "TheNexusKeristrasza", 8, EncounterJournalID = 621 },
				{ "LunarFestival", 9, hide = true },
			},
			["Info"] = { BabbleZone["The Nexus"], "AtlasLootWotLK", mapname = "TheNexus", EncounterJournalID = 281 },
		},

		["TheOculus"] = {
			["Bosses"] = {
				{ "OcuDrakos", 3, EncounterJournalID = 622 },
				{ "OcuCloudstrider", 4, EncounterJournalID = 623 },
				{ "OcuUrom", 5, EncounterJournalID = 624 },
				{ "OcuEregos", {6,8}, EncounterJournalID = 625 },
				{ "OcuTrash", 10 },
			},
			["Info"] = { BabbleZone["The Oculus"], "AtlasLootWotLK", mapname = "Nexus80", EncounterJournalID = 282 },
		},

		["TrialOfTheChampion"] = {
			["Bosses"] = {
				{ "TrialoftheChampionChampions", 2, EncounterJournalID = 634 },
				{ "TrialoftheChampionEadricthePure", 15, EncounterJournalID = 635 },
				{ "TrialoftheChampionConfessorPaletress", 16, EncounterJournalID = 636 },
				{ "TrialoftheChampionBlackKnight", 17, EncounterJournalID = 637 },
			},
			["Info"] = { BabbleZone["Trial of the Champion"], "AtlasLootWotLK", mapname = "TheArgentColiseum", EncounterJournalID = 284 },
		},

		["UlduarHallsofStone"] = {
			["Bosses"] = {
				{ "HallsofStoneKrystallus", 2, EncounterJournalID = 604 },
				{ "HallsofStoneMaiden", 3, EncounterJournalID = 605 },
				{ "HallsofStoneTribunal", {4,5}, EncounterJournalID = 606 },
				{ "HallsofStoneSjonnir", 6, EncounterJournalID = 607 },
				{ "LunarFestival", 7, hide = true },
				{ "HallsofStoneTrash", 10 },
			},
			["Info"] = { BabbleZone["Halls of Stone"], "AtlasLootWotLK", mapname = "Ulduar77", EncounterJournalID = 277 },
		},

		["UlduarHallsofLightning"] = {
			["Bosses"] = {
				{ "HallsofLightningBjarngrim", 2, EncounterJournalID = 597 },
				{ "HallsofLightningVolkhan", 3, EncounterJournalID = 598 },
				{ "HallsofLightningIonar", 4, EncounterJournalID = 599 },
				{ "HallsofLightningLoken", 5, EncounterJournalID = 600 },
				{ "HallsofLightningTrash", 7 },
			},
			["Info"] = { BabbleZone["Halls of Lightning"], "AtlasLootWotLK", mapname = "HallsofLightning", EncounterJournalID = 275 },
		},

		["UtgardeKeep"] = {
			["Bosses"] = {
				{ "UtgardeKeepKeleseth", 4, EncounterJournalID = 638 },
				{ "UtgardeKeepSkarvald", {5,6}, EncounterJournalID = 639 },
				{ "UtgardeKeepIngvar", 7, EncounterJournalID = 640 },
				{ "LunarFestival", 8, hide = true },
				{ "UtgardeKeepTrash", 10 },
			},
			["Info"] = { BabbleZone["Utgarde Keep"], "AtlasLootWotLK", mapname = "UtgardeKeep", EncounterJournalID = 285 },
		},

		["UtgardePinnacle"] = {
			["Bosses"] = {
				{ "UPSorrowgrave", 3, EncounterJournalID = 641 },
				{ "UPPalehoof", 4, EncounterJournalID = 642 },
				{ "UPSkadi", 5, EncounterJournalID = 643 },
				{ "UPYmiron", 6, EncounterJournalID = 644 },
				{ "LunarFestival", 7, hide = true },
				{ "UPTrash", 9 },
			},
			["Info"] = { BabbleZone["Utgarde Pinnacle"], "AtlasLootWotLK", mapname = "UtgardePinnacle", EncounterJournalID = 286 },
		},

		["VioletHold"] = {
			["Bosses"] = {
				{ "VioletHoldErekem", 2, EncounterJournalID = 626 },
				{ "VioletHoldZuramat", 3, EncounterJournalID = 631 },
				{ "VioletHoldXevozz", 4, EncounterJournalID = 629 },
				{ "VioletHoldIchoron", 5, EncounterJournalID = 628 },
				{ "VioletHoldMoragg", 6, EncounterJournalID = 627 },
				{ "VioletHoldLavanthor", 7, EncounterJournalID = 630 },
				{ "VioletHoldCyanigosa", 8, EncounterJournalID = 632 },
				{ "VioletHoldTrash", 10 },
			},
			["Info"] = { BabbleZone["The Violet Hold"], "AtlasLootWotLK", mapname = "VioletHold", EncounterJournalID = 283 },
		},

	---- Raids

		["IcecrownCitadelA"] = "IcecrownCitadel",
		["IcecrownCitadelB"] = "IcecrownCitadel",
		["IcecrownCitadelC"] = "IcecrownCitadel",
		["IcecrownCitadel"] = {
			["IcecrownCitadelA"] = {
				{ "TheAshenVerdict", 1, hide = true},
				{ "ICCLordMarrowgar", 5},
				{ "ICCLadyDeathwhisper", 6},
				{ "ICCGunshipBattle", {7,8}},
				{ "ICCSaurfang", 9},
				{ "ICCTrash", 15, hide = true},
			},
			["IcecrownCitadelB"] = {
				{ "TheAshenVerdict", 1, hide = true},
				{ "ICCFestergut", 7},
				{ "ICCRotface", 8},
				{ "ICCPutricide", 9},
				{ "ICCCouncil", {10,11,12,13} },
				{ "ICCLanathel", 14},
				{ "ICCValithria", 16},
				{ "ICCSindragosa", 17},
				{ "ICCTrash", 23, hide = true},
			},
			["IcecrownCitadelC"] = {
				{ "TheAshenVerdict", 1, hide = true},
				{ "ICCLichKing", 3},
				{ "ICCTrash", 5},
			},
			["Info"] = { BabbleZone["Icecrown Citadel"], "AtlasLootWotLK", sortOrder = { "IcecrownCitadelA", "IcecrownCitadelB", "IcecrownCitadelC" }, mapname = "IcecrownCitadel", raid = true },
		},

		["Naxxramas"] = {
			["Bosses"] = {
				{ "Naxx80Patchwerk", 4 },
				{ "Naxx80Grobbulus", 5 },
				{ "Naxx80Gluth", 6 },
				{ "Naxx80Thaddius", 7 },
				{ "Naxx80AnubRekhan", 11 },
				{ "Naxx80Faerlina", 12 },
				{ "Naxx80Maexxna", 13 },
				{ "Naxx80Razuvious", 15 },
				{ "Naxx80Gothik", 16 },
				{ "Naxx80FourHorsemen", {17,22} },
				{ "Naxx80Noth", 24 },
				{ "Naxx80Heigan", 25 },
				{ "Naxx80Loatheb", 26 },
				{ "Naxx80Sapphiron", 28 },
				{ "Naxx80KelThuzad", 29 },
				{ "Naxx80Trash", 33 },
				{ "T7T8SET", 34, hide = true },
			},
			["Info"] = { BabbleZone["Naxxramas"], "AtlasLootWotLK", mapname = "IcecrownCitadel", mapname = "Naxxramas", raid = true },
		},

		["ObsidianSanctum"] = {
			["Bosses"] = {
				{ "Sartharion", 6 },
			},
			["Info"] = { BabbleZone["The Obsidian Sanctum"], "AtlasLootWotLK", mapname = "TheObsidianSanctum", raid = true },
		},

		["OnyxiasLair"] = {
			["Bosses"] = {
				{ "Onyxia", 2 },
			},
			["Info"] = { BabbleZone["Onyxia's Lair"], "AtlasLootWotLK", mapname = "OnyxiasLair", raid = true },
		},

		["RubySanctum"] = {
			["Bosses"] = {
				{ "Halion", 6 },
			},
			["Info"] = { BabbleZone["The Ruby Sanctum"], "AtlasLootWotLK", mapname = "TheRubySanctum", raid = true },
		},

		["TheEyeOfEternity"] = {
			["Bosses"] = {
				{ "Malygos", 2 },
			},
			["Info"] = { BabbleZone["The Eye of Eternity"], "AtlasLootWotLK", mapname = "TheEyeOfEternity", raid = true },
		},

		["TrialOfTheCrusader"] = {
			["Bosses"] = {
				{ "TrialoftheCrusaderNorthrendBeasts", 4 },
				{ "TrialoftheCrusaderLordJaraxxus", 9 },
				{ "TrialoftheCrusaderFactionChampions", 10 },
				{ "TrialoftheCrusaderTwinValkyrs", 11 },
				{ "TrialoftheCrusaderAnubarak", 14 },
				{ "TrialoftheCrusaderPatterns", 16 },
			},
			["Info"] = { BabbleZone["Trial of the Crusader"], "AtlasLootWotLK", mapname = "TheArgentColiseum", raid = true },
		},

		["UlduarA"] = "Ulduar",
		["UlduarB"] = "Ulduar",
		["UlduarC"] = "Ulduar",
		["UlduarD"] = "Ulduar",
		["UlduarE"] = "Ulduar",
		["Ulduar"] = {
			["UlduarA"] = {
				{ "UlduarLeviathan", 7 },
				{ "UlduarRazorscale", 8},
				{ "UlduarIgnis", 9 },
				{ "UlduarDeconstructor", 10 },
				{ "UlduarTrash", 16, hide = true},
				{ "UlduarPatterns", 17, hide = true},
				{ "T7T8SET", 18 , hide = true},
			},
			["UlduarB"] = {
				{ "UlduarIronCouncil", 3 },
				{ "UlduarKologarn", 7 },
				{ "UlduarAlgalon", 8 },
				{ "UlduarTrash", 13, hide = true },
				{ "UlduarPatterns", 14, hide = true },
				{ "T7T8SET", 15, hide = true },
			},
			["UlduarC"] = {
				{ "UlduarAuriaya", 4 },
				{ "UlduarHodir", 5 },
				{ "UlduarThorim", 6 },
				{ "UlduarFreya", 8 },
				{ "UlduarTrash", 15, hide = true },
				{ "UlduarPatterns", 16, hide = true },
				{ "T7T8SET", 17, hide = true },
			},
			["UlduarD"] = {
				{ "UlduarMimiron", 2 },
				{ "UlduarTrash", 5, hide = true },
				{ "UlduarPatterns", 6, hide = true },
				{ "T7T8SET", 7, hide = true },
			},
			["UlduarE"] = {
				{ "UlduarVezax", 2 },
				{ "UlduarYoggSaron", 3 },
				{ "UlduarTrash", 7 },
				{ "UlduarPatterns", 8 },
				{ "T7T8SET", 9, hide = true },
			},
			["Info"] = { BabbleZone["Ulduar"], "AtlasLootWotLK", sortOrder = { "UlduarA", "UlduarB", "UlduarC", "UlduarD", "UlduarE" }, mapname = "Ulduar", raid = true },
		},

		["VaultOfArchavon"] = {
			["Bosses"] = {
				{ "ARCHAVON", 2 },
				{ "EMALON", 3 },
				{ "KORALON", 4 },
				{ "TORAVON", 5 },
			},
			["Info"] = { BabbleZone["Vault of Archavon"], "AtlasLootWotLK", mapname = "VaultofArchavon", raid = true, disableCompare = true },
		},

--------------------
--- BC Instances ---
--------------------

	---- Dungeons
		["AuchAuchenaiCrypts"] = {
			["Bosses"] = {
				{ "LowerCity", 1, hide = true },
				{ "AuchCryptsShirrak", 3, EncounterJournalID = 523 },
				{ "AuchCryptsExarch", 4, EncounterJournalID = 524 },
				{ "AuchCryptsAvatar", 5 },
				{ "AuchTrash", 8 },
			},
			["Info"] = { BabbleZone["Auchenai Crypts"], "AtlasLootBurningCrusade", EncounterJournalID = 247 },
		},
		
		["AuchManaTombs"] = {
			["Bosses"] = {
				{ "Consortium", 1, hide = true },
				{ "AuchManaPandemonius", 4, EncounterJournalID = 534 },
				{ "AuchManaTavarok", 6, EncounterJournalID = 535 },
				{ "AuchManaNexusPrince", 7, EncounterJournalID = 537 },
				{ "AuchManaYor", 8 },
				{ "AuchTrash", 13 },
			},
			["Info"] = { BabbleZone["Mana-Tombs"], "AtlasLootBurningCrusade", mapname = "ManaTombs1", EncounterJournalID = 250 },
		},

		["AuchSethekkHalls"] = {
			["Bosses"] = {
				{ "LowerCity", 1, hide = true },
				{ "AuchSethekkDarkweaver", 3, EncounterJournalID = 541 },
				{ "AuchSethekkRavenGod", 5 },
				{ "AuchTrash", 6, hide = true },
				{ "AuchSethekkTalonKing", 7, EncounterJournalID = 543 },
				{ "AuchTrash", 9 },
			},
			["Info"] = { BabbleZone["Sethekk Halls"], "AtlasLootBurningCrusade", EncounterJournalID = 252 },
		},

		["AuchShadowLabyrinth"] = {
			["Bosses"] = {
				{ "LowerCity", 1, hide = true },
				{ "AuchShadowHellmaw", 3, EncounterJournalID = 544 },
				{ "AuchShadowBlackheart", 4, EncounterJournalID = 545 },
				{ "AuchShadowGrandmaster", 5, EncounterJournalID = 546 },
				{ "AuchShadowMurmur", 7, EncounterJournalID = 547 },
				{ "AuchTrash", 9, hide = true },
				{ "AuchTrash", 12 },
			},
			["Info"] = { BabbleZone["Shadow Labyrinth"], "AtlasLootBurningCrusade", mapname = "ShadowLabyrinth1", EncounterJournalID = 253 },
		},

		["CoTOldHillsbrad"] = {
			["Bosses"] = {
				{ "KeepersofTime", 3, hide = true },
				{ "CoTHillsbradDrake", 10, EncounterJournalID = 538 },
				{ "CoTHillsbradSkarloc", 12, EncounterJournalID = 539 },
				{ "CoTHillsbradHunter", 15, EncounterJournalID = 540 },
				{ "CoTTrash", {18,20,21}, hide = true },
				{ "CoTTrash", 25 },
			},
			["Info"] = { BabbleZone["Old Hillsbrad Foothills"], "AtlasLootBurningCrusade", EncounterJournalID = 251 },
		},

		["CoTBlackMorass"] = {
			["Bosses"] = {
				{ "KeepersofTime", 3, hide = true },
				{ "CoTMorassDeja", 7, EncounterJournalID = 552 },
				{ "CoTMorassTemporus", 8, EncounterJournalID = 553 },
				{ "CoTMorassAeonus", 9, EncounterJournalID = 554 },
				{ "CoTTrash", 13 },	
			},
			["Info"] = { BabbleZone["The Black Morass"], "AtlasLootBurningCrusade", EncounterJournalID = 255 },
		},

		["CFRTheSlavePens"] = {
			["Bosses"] = {
				{ "CExpedition", 1, hide = true },
				{ "CFRSlaveMennu", 3, EncounterJournalID = 570 },
				{ "CFRSlaveRokmar", 4, EncounterJournalID = 571 },
				{ "CFRSlaveQuagmirran", 5, EncounterJournalID = 572 },
				{ "LordAhune", 6, hide = true },
			},
			["Info"] = { BabbleZone["The Slave Pens"], "AtlasLootBurningCrusade", EncounterJournalID = 260 },
		},

		["CFRTheSteamvault"] = {
			["Bosses"] = {
				{ "CExpedition", 1, hide = true },
				{ "CFRSteamThespia", 3, EncounterJournalID = 573 },
				{ "CFRSteamSteamrigger", 5, EncounterJournalID = 574 },
				{ "CFRSteamWarlord", 7, EncounterJournalID = 575 },
				{ "CFRSteamTrash", 9, hide = true },
				{ "CFRSteamTrash", 11 },
			},
			["Info"] = { BabbleZone["The Steamvault"], "AtlasLootBurningCrusade", EncounterJournalID = 261 },
		},

		["CFRTheUnderbog"] = {
			["Bosses"] = {
				{ "CExpedition", 1, hide = true },
				{ "CFRUnderHungarfen", 3, EncounterJournalID = 576 },
				{ "CFRUnderGhazan", 5, EncounterJournalID = 577 },
				{ "CFRUnderSwamplord", 6, EncounterJournalID = 578 },
				{ "CFRUnderStalker", 8, EncounterJournalID = 579 },
			},
			["Info"] = { BabbleZone["The Underbog"], "AtlasLootBurningCrusade", EncounterJournalID = 262 },
		},

		["HCHellfireRamparts"] = {
			["Bosses"] = {
				{ "HonorHold", 1, hide = true },
				{ "Thrallmar", 2, hide = true },
				{ "HCRampWatchkeeper", 4, EncounterJournalID = 527 },
				{ "HCRampOmor", 5, EncounterJournalID = 528 },
				{ "HCRampVazruden", {6,8}, EncounterJournalID = 529 },
			},
			["Info"] = { BabbleZone["Hellfire Ramparts"], "AtlasLootBurningCrusade", EncounterJournalID = 248 },
		},

		["HCBloodFurnace"] = {
			["Bosses"] = {
				{ "HonorHold", 1, hide = true },
				{ "Thrallmar", 2, hide = true },
				{ "HCFurnaceMaker", 4, EncounterJournalID = 555 },
				{ "HCFurnaceBroggok", 5, EncounterJournalID = 556 },
				{ "HCFurnaceBreaker", 6, EncounterJournalID = 557 },
			},
			["Info"] = { BabbleZone["The Blood Furnace"], "AtlasLootBurningCrusade", EncounterJournalID = 256 },
		},

		["HCTheShatteredHalls"] = {
			["Bosses"] = {
				{ "HonorHold", 1, hide = true },
				{ "Thrallmar", 2, hide = true },
				{ "HCHallsNethekurse", 4, EncounterJournalID = 566 },
				{ "HCHallsPorung", 5 },
				{ "HCHallsOmrogg", 6, EncounterJournalID = 568 },
				{ "HCHallsKargath", 7, EncounterJournalID = 569 },
				{ "HCHallsTrash", 8, hide = true },
				{ "HCHallsTrash", 18 },
			},
			["Info"] = { BabbleZone["The Shattered Halls"], "AtlasLootBurningCrusade", EncounterJournalID = 259 },
		},

		["MagistersTerrace"] = {
			["Bosses"] = {
				{ "SunOffensive", 1, hide = true },
				{ "SMTFireheart", 4, EncounterJournalID = 530 },
				{ "SMTVexallus", 6, EncounterJournalID = 531 },
				{ "SMTDelrissa", 7, EncounterJournalID = 532 },
				{ "SMTKaelthas", 18, EncounterJournalID = 533 },
				{ "SMTTrash", 23 },
			},
			["Info"] = { BabbleZone["Magisters' Terrace"], "AtlasLootBurningCrusade", EncounterJournalID = 249 },
		},

		["TempestKeepArcatraz"] = {
			["Bosses"] = {
				{ "Shatar", 1, hide = true },
				{ "TKArcUnbound", 3, EncounterJournalID = 548 },
				{ "TKArcDalliah", 4, EncounterJournalID = 549 },
				{ "TKArcScryer", 5, EncounterJournalID = 550 },
				{ "TKArcHarbinger", 6, EncounterJournalID = 551 },
				{ "TKTrash", 10, hide = true },
				{ "TKTrash", 13 },
			},
			["Info"] = { BabbleZone["The Arcatraz"], "AtlasLootBurningCrusade", EncounterJournalID = 254 },
		},

		["TempestKeepBotanica"] = {
			["Bosses"] = {
				{ "Shatar", 1, hide = true },
				{ "TKBotSarannis", 4, EncounterJournalID = 558 },
				{ "TKBotFreywinn", 5, EncounterJournalID = 559 },
				{ "TKBotThorngrin", 6, EncounterJournalID = 560 },
				{ "TKBotLaj", 7, EncounterJournalID = 561 },
				{ "TKBotSplinter", 8, EncounterJournalID = 562 },
				{ "TKTrash", 10 },
			},
			["Info"] = { BabbleZone["The Botanica"], "AtlasLootBurningCrusade", EncounterJournalID = 257 },
		},

		["TempestKeepMechanar"] = {
			["Bosses"] = {
				{ "Shatar", 1, hide = true },
				{ "TKMechCapacitus", 6, EncounterJournalID = 563 },
				{ "TKTrash", 7, hide = true },
				{ "TKMechSepethrea", 8, EncounterJournalID = 564 },
				{ "TKMechCalc", 9, EncounterJournalID = 565 },
				{ "TKMechCacheoftheLegion", 10 },
				{ "TKTrash", 12 },
			},
			["Info"] = { BabbleZone["The Mechanar"], "AtlasLootBurningCrusade", EncounterJournalID = 258 },
		},

	---- Raids

		["BlackTempleStart"] = "BlackTemple",
		["BlackTempleBasement"] = "BlackTemple",
		["BlackTempleTop"] = "BlackTemple",
		["BlackTemple"] = {
			["BlackTempleStart"] = {
				{ "Ashtongue", 1, hide = true },
				{ "BTNajentus", 6 },
				{ "BTSupremus", 7 },
				{ "BTAkama", 8 },
				{ "BTTrash", 15, hide = true },
				{ "BTPatterns", 16, hide = true },
			},
			["BlackTempleBasement"] = {
				{ "Ashtongue", 1, hide = true },
				{ "BTBloodboil", 4 },
				{ "BTReliquaryofSouls", 5 },
				{ "BTGorefiend", 9 },
				{ "BTTrash", 11, hide = true },
				{ "BTPatterns", 12, hide = true },
			},
			["BlackTempleTop"] = {
				{ "Ashtongue", 1, hide = true },
				{ "BTShahraz", 4 },
				{ "BTCouncil", 5 },
				{ "BTIllidanStormrage", 10 },
				{ "BTTrash", 12 },
				{ "BTPatterns", 13 },
			},
			["Info"] = { BabbleZone["Black Temple"], "AtlasLootBurningCrusade", sortOrder = { "BlackTempleStart", "BlackTempleBasement", "BlackTempleTop" }, raid = true },
		},

		["CoTHyjalEnt"] = "CoTHyjalEaI",
		["CoTHyjal"] = "CoTHyjalEaI",
		["CoTHyjalEaI"] = {
			["CoTHyjalEnt"] = {
				{ "ScaleSands", 2, hide = true },
			},
			["CoTHyjal"] = {
				{ "ScaleSands", 2, hide = true },
				{ "MountHyjalWinterchill", 9 },
				{ "MountHyjalAnetheron", 10 },
				{ "MountHyjalKazrogal", 11 },
				{ "MountHyjalAzgalor", 12 },
				{ "MountHyjalArchimonde", 13 },
				{ "MountHyjalTrash", 15 },
			},
			["Info"] = { BabbleZone["Hyjal"], "AtlasLootBurningCrusade", sortOrder = { "CoTHyjalEnt", "CoTHyjal" }, raid = true },
		},

		["CFRSerpentshrineCavern"] = {
			["Bosses"] = {
				{ "CExpedition", 1, hide = true },
				{ "CFRSerpentHydross", 3 },
				{ "CFRSerpentLurker", 4 },
				{ "CFRSerpentLeotheras", 5 },
				{ "CFRSerpentKarathress", 6 },
				{ "CFRSerpentMorogrim", 8 },
				{ "CFRSerpentVashj", 9 },
				{ "CFRSerpentTrash", 11 },
			},
			["Info"] = { BabbleZone["Serpentshrine Cavern"], "AtlasLootBurningCrusade", raid = true },
		},

		["GruulsLair"] = {
			["Bosses"] = {
				{ "GruulsLairHighKingMaulgar", 2 },
				{ "GruulGruul", 7 },
			},
			["Info"] = { BabbleZone["Gruul's Lair"], "AtlasLootBurningCrusade", raid = true },
		},

		["HCMagtheridonsLair"] = {
			["Bosses"] = {
				{ "HCMagtheridon", 2 },
			},
			["Info"] = { BabbleZone["Magtheridon's Lair"], "AtlasLootBurningCrusade", raid = true },
		},

		["KarazhanEnt"] = "KarazhanEaI",
		["KarazhanStart"] = "KarazhanEaI",
		["KarazhanEnd"] = "KarazhanEaI",
		["KarazhanEaI"] = {
			["KarazhanEnt"] = {
				{ "KaraCharredBoneFragment", 8, hide = true },
			},
			["KarazhanStart"] = {
				{ "VioletEye", 1, hide = true },
				{ "KaraAttumen", 4 },
				{ "KaraMoroes", 6 },
				{ "KaraMaiden", 13 },
				{ "KaraOperaEvent", 14 },
				{ "KaraNightbane", 27 },
				{ "KaraNamed", {29,30,31,32} },
				{ "KaraTrash", 38, hide = true },
				{ "KaraTrash", 43, hide = true },
			},
			["KarazhanEnd"] = {
				{ "VioletEye", 1, hide = true },
				{ "KaraCurator", 10 },
				{ "KaraIllhoof", 11 },
				{ "KaraAran", 13 },
				{ "KaraNetherspite", 14 },
				{ "KaraChess", {15,16} },
				{ "KaraPrince", 17 },
				{ "KaraTrash", 24 },
			},
			["Info"] = { BabbleZone["Karazhan"], "AtlasLootBurningCrusade", sortOrder = { "KarazhanEnt", "KarazhanStart", "KarazhanEnd" }, raid = true },
		},

		["SunwellPlateau"] = {
			["Bosses"] = {
				{ "SPKalecgos", 2 },
				{ "SPBrutallus", 4 },
				{ "SPFelmyst", 5 },
				{ "SPEredarTwins", 7 },
				{ "SPMuru", 10 },
				{ "SPKiljaeden", 12 },
				{ "SPTrash", 14 },
				{ "SPPatterns", 15 },
			},
			["Info"] = { BabbleZone["Sunwell Plateau"], "AtlasLootBurningCrusade", raid = true },
		},

		["TempestKeepTheEye"] = {
			["Bosses"] = {
				{ "Shatar", 1, hide = true },
				{ "TKEyeAlar", 3 },
				{ "TKEyeVoidReaver", 4 },
				{ "TKEyeSolarian", 5 },
				{ "TKEyeKaelthas", 6 },
				{ "TKEyeTrash", 12 },
			},
			["Info"] = { BabbleZone["The Eye"], "AtlasLootBurningCrusade", raid = true },
		},

-------------------------
--- Classic Instances ---
-------------------------

		["BlackfathomDeeps"] = {
			["Bosses"] = {
				{ "Blackfathom#1", {3,4,5,7,8,11} },
				{ "Blackfathom#2", {9,12,19}, hide = true },
			},
			["Info"] = { BabbleZone["Blackfathom Deeps"], "AtlasLootClassicWoW", mapname = "BlackFathomDeeps", EncounterJournalID = 227 },
		},

		["BlackrockDepths"] = {
			["Bosses"] = {
				{ "BRDHighInterrogatorGerstahn", 6, EncounterJournalID = 369 },
				{ "BRDLordRoccor", 7, EncounterJournalID = 370 },
				{ "BRDHoundmaster", 8, EncounterJournalID = 371 },
				{ "BRDBaelGar", 9, EncounterJournalID = 377 },
				{ "BRDLordIncendius", 10, EncounterJournalID = 374 },
				{ "BRDFineousDarkvire", 12, EncounterJournalID = 376 },
				{ "BRDTheVault", 13 },
				{ "BRDWarderStilgiss", 14, EncounterJournalID = 375 },
				{ "BRDVerek", 15 },
				{ "BRDPyromantLoregrain", 17, EncounterJournalID = 373 },
				{ "BRDArena", {18,20,21,22,23,24,25}, EncounterJournalID = 372 },
				{ "LunarFestival", 26, hide = true },
				{ "BRDGeneralAngerforge", 27, EncounterJournalID = 378 },
				{ "BRDGolemLordArgelmach", 28, EncounterJournalID = 379 },
				{ "BRDBSPlans", {30,59}, hide = true },
				{ "BRDGuzzler", {31,33,34,35} },
				{ "CorenDirebrew", 32, hide = true },
				{ "BRDFlamelash", 38, EncounterJournalID = 384 },
				{ "BRDTomb", 39, EncounterJournalID = 385 },
				{ "BRDMagmus", 40, EncounterJournalID = 386 },
				{ "BRDImperatorDagranThaurissan", 41, EncounterJournalID = 387 },
				{ "BRDPrincess", 42 },
				{ "BRDPanzor", 44 },
				{ "BRDQuestItems", {69,70}, hide = true },
				{ "BRDTrash", 72 },
				{ "VWOWSets#1", 73, hide = true },
			},
			["Info"] = { BabbleZone["Blackrock Depths"], "AtlasLootClassicWoW", mapname = "BlackrockDepths", EncounterJournalID = 228 },
		},

		["BlackrockMountainEnt"] = {
			["Bosses"] = {
				{ "BlackrockMountainEntLoot", {12,13,14}, hide = true },
			},
			["Info"] = { BabbleZone["Blackrock Mountain"], "AtlasLootClassicWoW" },
		},

		["BlackrockSpireLower"] = {
			["Bosses"] = {
				{ "LBRSOmokk", 4, EncounterJournalID = 398 },
				{ "LBRSVosh", 5, EncounterJournalID = 399 },
				{ "LBRSVoone", 6, EncounterJournalID = 390 },
				{ "LBRSSmolderweb", 7, EncounterJournalID = 391 },
				{ "LBRSDoomhowl", 8, EncounterJournalID = 392 },
				{ "LBRSZigris", 10, EncounterJournalID = 393 },
				{ "LBRSHalycon", 11, EncounterJournalID = 394 },
				{ "LBRSSlavener", 12, EncounterJournalID = 395 },
				{ "LBRSWyrmthalak", 13, EncounterJournalID = 396 },
				{ "LBRSFelguard", 14 },
				{ "LBRSSpirestoneButcher", 15 },
				{ "LBRSGrimaxe", 16 },
				{ "LBRSCrystalFang", 17 },
				{ "LBRSSpirestoneLord", 18 },
				{ "LBRSLordMagus", 19 },
				{ "LBRSBashguud", 20 },
				{ "LunarFestival", 22, hide = true },
				{ "LBRSQuestItems", 23, hide = true },
				{ "LBRSTrash", 25 },
				{ "T0SET", 26, hide = true },
				{ "VWOWSets#3", 27, hide = true },
			},
			["Info"] = { BabbleZone["Lower Blackrock Spire"], "AtlasLootClassicWoW", mapname = "BlackrockSpire", EncounterJournalID = 229 },
		},

		["BlackrockSpireUpper"] = {
			["Bosses"] = {
				{ "UBRSEmberseer", 5, EncounterJournalID = 397 },
				{ "UBRSSolakar", 6, EncounterJournalID = 398 },
				{ "UBRSAnvilcrack", 7 },
				{ "UBRSRend", 8, EncounterJournalID = 399 },
				{ "UBRSGyth", 9 },
				{ "UBRSBeast", 10, EncounterJournalID = 400 },
				{ "UBRSDrakkisath", 12, EncounterJournalID = 401 },
				{ "UBRSRunewatcher", 14 },
				{ "UBRSFLAME", 16 },
				{ "UBRSTrash", 18 },
				{ "T0SET", 19, hide = true },
				{ "VWOWSets#3", 20, hide = true },
			},
			["Info"] = { BabbleZone["Upper Blackrock Spire"], "AtlasLootClassicWoW", mapname = "BlackrockSpire", EncounterJournalID = 229 },
		},	

		["BlackwingLair"] = {
			["Bosses"] = {
				{ "BWLRazorgore", 6 },
				{ "BWLVaelastrasz", 7 },
				{ "BWLLashlayer", 8 },
				{ "BWLFiremaw", 9 },
				{ "BWLEbonroc", 10 },
				{ "BWLTrashMobs",  11, hide = true },
				{ "BWLFlamegor", 12 },
				{ "BWLChromaggus", 13 },
				{ "BWLNefarian", 14 },
				{ "BWLTrashMobs",  17 },
				{ "T1T2T3SET", 18, hide = true },
			},
			["Info"] = { BabbleZone["Blackwing Lair"], "AtlasLootClassicWoW", mapname = "BlackwingLair", raid = true },
		},

		["DireMaulEnt"] = {
			["Bosses"] = {
				{ "LunarFestival", 7, hide = true },
			},
			["Info"] = { BabbleZone["Dire Maul"], "AtlasLootWorldEvents" },
		},

		["DireMaulNorth"] = {
			["Bosses"] = {
				{ "DMNGuardMoldar", 4, EncounterJournalID = 411 },
				{ "DMNStomperKreeg", 5, EncounterJournalID = 412 },
				{ "DMNGuardFengus", 6, EncounterJournalID = 413 },
				{ "DMNGuardSlipkik", 7, EncounterJournalID = 414 },
				{ "DMNThimblejack", 8 },
				{ "DMNCaptainKromcrush", 9, EncounterJournalID = 415 },
				{ "DMNKingGordok", 10, EncounterJournalID = 417 },
				{ "DMNChoRush", 11, EncounterJournalID = 416 }, 
				{ "DMNTRIBUTERUN", 13 },
				{ "DMBooks", 14 },
			},
			["Info"] = { BabbleZone["Dire Maul (North)"], "AtlasLootClassicWoW", mapname = "DireMaul", EncounterJournalID = 230 },
		},

		["DireMaulEast"] = {
			["Bosses"] = {
				{ "DMELethtendrisPimgib", {8,9}, EncounterJournalID = 404 },
				{ "DMEHydro", 10, EncounterJournalID = 403 },
				{ "DMEZevrimThornhoof", 11, EncounterJournalID = 402 },
				{ "DMEAlzzin", 12, EncounterJournalID = 405 },
				{ "DMEPusillin", {13,14} },
				{ "DMETrash", 17 },
				{ "DMBooks", 18 },
			},
			["Info"] = { BabbleZone["Dire Maul (East)"], "AtlasLootClassicWoW", mapname = "DireMaul", EncounterJournalID = 230 },
		},

		["DireMaulWest"] = {
			["Bosses"] = {
				{ "OldKeys", 1, hide = true },
				{ "DMWTendrisWarpwood", 4, EncounterJournalID = 406 },
				{ "DMWMagisterKalendris", 5, EncounterJournalID = 408 },
				{ "DMWIllyannaRavenoak", 6, EncounterJournalID = 407 },
				{ "DMWImmolthar", 8, EncounterJournalID = 409 },
				{ "DMWHelnurath", 9 },
				{ "DMWPrinceTortheldrin", 10, EncounterJournalID = 410 },
				{ "DMWTsuzee", 11 },
				{ "DMWTrash", 23, hide = true },
				{ "DMWTrash", 25 },
				{ "DMBooks", 26 },
			},
			["Info"] = { BabbleZone["Dire Maul (West)"], "AtlasLootClassicWoW", mapname = "DireMaul", EncounterJournalID = 230 },
		},

		["Maraudon"] = {
			["Bosses"] = {
				{ "MaraudonLoot#1", {4,5,6,7,12} },
				{ "MaraudonLoot#2", {8,9,10,11}, hide = true }, 
				{ "LunarFestival", 13, hide = true },
			},
			["Info"] = { BabbleZone["Maraudon"], "AtlasLootClassicWoW", mapname = "Maraudon", EncounterJournalID = 232 },
		},

		["Uldaman"] = {
			["Bosses"] = {
				{ "UldShovelphlange", },
				{ "UldBaelog", {4,5,6,7} },
				{ "UldRevelosh", 8, EncounterJournalID = 467 },
				{ "UldIronaya", 9, EncounterJournalID = 469 },
				{ "UldObsidianSentinel", 10, EncounterJournalID = 748 },
				{ "UldAncientStoneKeeper", 11, EncounterJournalID = 470 },
				{ "UldGalgannFirehammer", 12, EncounterJournalID = 471 },
				{ "UldGrimlok", 13, EncounterJournalID = 472 },
				{ "UldArchaedas", 14, EncounterJournalID = 473 },
				{ "UldTrash", 24 },
			},
			["Info"] = { BabbleZone["Uldaman"], "AtlasLootClassicWoW", mapname = "Uldaman", EncounterJournalID = 239 },
		},

		["StratholmeCrusader"] = {
			["Bosses"] = {
				{ "STRATTheUnforgiven", 5, EncounterJournalID = 450 },
				{ "STRATTimmytheCruel", 6, EncounterJournalID = 445 },
				{ "STRATWilleyHopebreaker", 8, EncounterJournalID = 446 },
				{ "STRATInstructorGalford", 9, EncounterJournalID = 448 },
				{ "STRATBalnazzar", 10, EncounterJournalID = 449 },
				{ "STRATSkull", 12 },
				{ "STRATFrasSiabi", 13 },
				{ "STRATHearthsingerForresten", 14, EncounterJournalID = 443 },
				{ "STRATRisenHammersmith", {15,16} },
				{ "LunarFestival", 19, hide = true },
				{ "STRATTrash", 23 },
				{ "VWOWSets#2", {17,18,20,21}, hide = true },
			},
			["Info"] = { BabbleZone["Stratholme"].." - "..AL["Crusader's Square"], "AtlasLootClassicWoW", mapname = "Stratholme", EncounterJournalID = 236 },
		},

		["StratholmeGauntlet"] = {
			["Bosses"] = {
				{ "STRATBaronessAnastari", 3, EncounterJournalID = 451 },
				{ "STRATNerubenkan", 4, EncounterJournalID = 452 },
				{ "STRATMalekithePallid", 5, EncounterJournalID = 453 },
				{ "STRATMagistrateBarthilas", 6, EncounterJournalID = 454 },
				{ "STRATRamsteintheGorger", 7, EncounterJournalID = 455 },
				{ "STRATLordAuriusRivendare", 8, EncounterJournalID = 456 },
				{ "STRATBlackGuardSwordsmith", {9,10} },
				{ "STRATStonespine", },
				{ "STRATTrash", 17 },
				{ "VWOWSets#2", 11, hide = true },
			},
			["Info"] = { BabbleZone["Stratholme"].." - "..AL["The Gauntlet"], "AtlasLootClassicWoW", mapname = "Stratholme", EncounterJournalID = 236 },
		},

		["RazorfenDowns"] = {
			["Bosses"] = {
				{ "RazorfenDownsLoot#1", {3,4,5,8,10} },
				{ "RazorfenDownsLoot#2", {6,7}, hide = true },
			},
			["Info"] = { BabbleZone["Razorfen Downs"], "AtlasLootClassicWoW", mapname = "RazorfenDowns", EncounterJournalID = 233 },
		},

		["RazorfenKraul"] = {
			["Bosses"] = {
				{ "RazorfenKraulLoot#1", {3,4,5,6,7,10} }, 
				{ "RazorfenKraulLoot#2", {8,11}, hide = true }, 
			},
			["Info"] = { BabbleZone["Razorfen Kraul"], "AtlasLootClassicWoW", mapname = "RazorfenKraul", EncounterJournalID = 234 },
		},

		["TheSunkenTemple"] = {
			["Bosses"] = { 
				{ "STAvatarofHakkar", 3, EncounterJournalID = 457 },
				{ "STJammalanandOgom", {4,5}, EncounterJournalID = 458 },
				{ "STDragons", {6,7,8,9}, EncounterJournalID = 459 },
				{ "STEranikus", 10, EncounterJournalID = 463 },
				{ "LunarFestival", 12, hide = true },
				{ "STTrash", 14 },
			},
			["Info"] = { BabbleZone["Sunken Temple"], "AtlasLootClassicWoW", mapname = "TempleOfAtalHakkar", EncounterJournalID = 237 },
		},

		["RagefireChasm"] = {
			["Bosses"] = {
				{ "RagefireChasmLoot", {2,3,4,5} },
			},
			["Info"] = { BabbleZone["Ragefire Chasm"], "AtlasLootClassicWoW", mapname = "Ragefire", EncounterJournalID = 226 },
		},

		["MoltenCore"] = {
			["Bosses"] = {
				{ "BloodsailHydraxian", 2, hide = true },
				{ "MCLucifron", 4 },
				{ "MCMagmadar", 5 },
				{ "MCGehennas", 6 },
				{ "MCGarr", 7 },
				{ "MCShazzrah", 8 },
				{ "MCGeddon", 9 },
				{ "MCGolemagg", 10 },
				{ "MCSulfuron", 11 },
				{ "MCMajordomo", 12 },
				{ "MCRagnaros", 13 },
				{ "T1T2T3SET", 15, hide = true },
				{ "MCRANDOMBOSSDROPPS", 16 },
				{ "MCTrashMobs", 17 },
			},
			["Info"] = { BabbleZone["Molten Core"], "AtlasLootClassicWoW", mapname = "MoltenCore", raid = true },
		},

		["TheTempleofAhnQiraj"] = {
			["Bosses"] = {
				{ "AQBroodRings", 1, hide = true },
				{ "AQ40Skeram", 4 },
				{ "AQ40BugFam", {5,6,7,8} },
				{ "AQ40Sartura", 9 },
				{ "AQ40Fankriss", 10 },
				{ "AQ40Viscidus", 11 },
				{ "AQ40Huhuran", 12 },
				{ "AQ40Emperors", {13,14,15} },
				{ "AQ40Ouro", 17 },
				{ "AQ40CThun", {18,19} },
				{ "AQ40Trash", 28 },
				{ "AQ40Sets", 29, hide = true },
				{ "AQEnchants", 30 },
			},
			["Info"] = { BabbleZone["Temple of Ahn'Qiraj"], "AtlasLootClassicWoW", mapname = "TempleofAhnQiraj", raid = true },
		},

		["ShadowfangKeep"] = {
			["Bosses"] = {
				{ "ShadowfangAshbury", 3, EncounterJournalID = 96 },
				{ "ShadowfangSilverlaine", 4, EncounterJournalID = 97 },
				{ "ShadowfangSpringvale", 9, EncounterJournalID = 98 },
				{ "ShadowfangWalden", 10, EncounterJournalID = 99 },
				{ "ShadowfangGodfrey", 11, EncounterJournalID = 100 },
				{ "Valentineday#3", 12, hide = true },
				{ "ShadowfangTrash", 21 },
			},
			["Info"] = { BabbleZone["Shadowfang Keep"], {"AtlasLootClassicWoW", "AtlasLootCataclysm"}, mapname = "ShadowfangKeep", EncounterJournalID = 64 },
		},

		["Gnomeregan"] = {
			["Bosses"] = {
				{ "GnomereganLoot#1", {4,7,8,9} },
				{ "GnomereganLoot#2", {10}, hide = true },
			},
			["Info"] = { BabbleZone["Gnomeregan"], "AtlasLootClassicWoW", mapname = "Gnomeregan", EncounterJournalID = 231 },
		},

		["ScarletHalls"] = {
			["Bosses"] = {
				{ "SHBraun", EncounterJournalID = 660 },
				{ "SHHarlan", EncounterJournalID = 654 },
				{ "SHKoegler", EncounterJournalID = 656 },
			},
			["Info"] = { BabbleZone["Scarlet Halls"], {"AtlasLootClassicWoW", "AtlasLootMoP"}, mapname = "ScarletHalls", EncounterJournalID = 311 },
		},

		["ScarletMonastery"] = {
			["Bosses"] = {
				{ "SMThalnos", EncounterJournalID = 688 },
				{ "SMKorloff", EncounterJournalID = 671 },
				{ "SMWhitemane", EncounterJournalID = 674 },
			},
			["Info"] = { BabbleZone["Scarlet Monastery"], {"AtlasLootClassicWoW", "AtlasLootMoP"}, mapname = "ScarletMonastery", EncounterJournalID = 316 },
		},

		["Scholomance"] = {
			["Bosses"] = {
				{ "ScholoChillheart", EncounterJournalID = 659 },
				{ "ScholoJandice", EncounterJournalID = 663 },
				{ "ScholoRattlegore", EncounterJournalID = 665 },
				{ "ScholoVoss", EncounterJournalID = 666 },
				{ "ScholoGandling", EncounterJournalID = 684 },
				{ "ScholoTrash", },
			},
			["Info"] = { BabbleZone["Scholomance"], {"AtlasLootClassicWoW", "AtlasLootMoP"}, mapname = "Scholomance", EncounterJournalID = 246 },
		},

		["TheDeadminesEnt"] = "TheDeadminesEaI",
		["TheDeadmines"] = "TheDeadminesEaI",
		["TheDeadminesEaI"] = {
			["TheDeadminesEnt"] = {
				{ "DeadminesTrash", {4,5}, hide = true },
			},
			["TheDeadmines"] = {
				{ "DeadminesGlubtok", 3, EncounterJournalID = 89 },
				{ "DeadminesGearbreaker", 5, EncounterJournalID = 90 },
				{ "DeadminesFoeReaper", 6, EncounterJournalID = 91 },
				{ "DeadminesRipsnarl", 7, EncounterJournalID = 92 },
				{ "DeadminesCookie", 8, EncounterJournalID = 93 },
				{ "DeadminesVanessa", 9, EncounterJournalID = 95 },
				{ "DeadminesTrash", 18 },
			},
			["Info"] = { BabbleZone["The Deadmines"], {"AtlasLootClassicWoW", "AtlasLootCataclysm"}, sortOrder = { "TheDeadminesEnt", "TheDeadmines" }, mapname = "TheDeadmines", EncounterJournalID = 63 },
		},

		["WailingCavernsEnt"] = "WailingCavernsEaI",
		["WailingCaverns"] = "WailingCavernsEaI",
		["WailingCavernsEaI"] = {
			["WailingCavernsEnt"] = {
				{ "WailingCavernsLoot#1", 3, hide = true },
			},
			["WailingCaverns"] = {
				{ "WailingCavernsLoot#1", {2,3,4,5} },
				{ "WailingCavernsLoot#2", {6,7,8,10,11}, hide = true },
				{ "VWOWSets#1", 16, hide = true },
			},
			["Info"] = { BabbleZone["Wailing Caverns"], "AtlasLootClassicWoW", sortOrder = { "WailingCavernsEnt", "WailingCaverns" }, mapname = "WailingCaverns", EncounterJournalID = 240 },
		},

		["TheStockade"] = {
			["Bosses"] = {
				{ "Stockade", {2,3,4} },
			},
			["Info"] = { BabbleZone["The Stockade"], "AtlasLootClassicWoW", mapname = "TheStockade", EncounterJournalID = 238 },
		},

		["TheRuinsofAhnQiraj"] = {
			["Bosses"] = {
				{ "CenarionCircle", 1, hide = true },
				{ "AQ20Kurinnaxx", 3 },
				{ "AQ20Rajaxx", {6,7,8,9,10,11,12,13} },
				{ "AQ20Moam", 14 },
				{ "AQ20Buru", 15 },
				{ "AQ20Ayamiss", 16 },
				{ "AQ20Ossirian", 17 },
				{ "AQ20Trash", 20 },
				{ "AQ20Sets", 21, hide = true },
				{ "AQEnchants", 22 },
			},
			["Info"] = { BabbleZone["Ruins of Ahn'Qiraj"], "AtlasLootClassicWoW", mapname = "RuinsofAhnQiraj", raid = true },
		},

		["ZulFarrak"] = {
			["Bosses"] = {
				{ "ZFGahzrilla", 5 },
				{ "ZFSezzziz", 12 },
				{ "ZFChiefUkorzSandscalp", 14 },
				{ "ZFWitchDoctorZumrah", 16 },
				{ "ZFAntusul", 17 },
				{ "ZFHydromancerVelratha", 19 },
				{ "ZFDustwraith", 21 },
				{ "ZFZerillis", 22 },
				{ "LunarFestival", 23, hide = true },
				{ "ZFTrash", 25 },
			},
			["Info"] = { BabbleZone["Zul'Farrak"], "AtlasLootClassicWoW", mapname = "ZulFarrak", EncounterJournalID = 241 },
		},
	},

---------------------
--- Battlegrounds ---
---------------------

	["Battlegrounds"] = {

		["AlteracValleyNorth"] = {
			["Bosses"] = {
				{ "MiscFactions", 1 },
				{ "AVMisc", 48 },
				{ "AVBlue", 49 },
			},
			["Info"] = { BabbleZone["Alterac Valley"], "AtlasLootClassicWoW" },
		},

		["AlteracValleySouth"] = {
			["Bosses"] = {
				{ "MiscFactions", 1 },
				{ "AVMisc", 31 },
				{ "AVBlue", 32 },
			},
			["Info"] = { BabbleZone["Alterac Valley"], "AtlasLootClassicWoW" },
		},

		["ArathiBasin"] = {
			["Bosses"] = {
				{ "MiscFactions", {1,2} },
				{ "AB2039", 11 },
				{ "AB4049", 12 },
				{ "ABSets", 13 },
				{ "ABMisc", 14 },
			},
			["Info"] = { BabbleZone["Arathi Basin"], "AtlasLootClassicWoW" },
		},

		["HalaaPvP"] = {
			["Bosses"] = {
				{ "Nagrand", 1 },
			},
			["Info"] = { BabbleZone["Nagrand"]..": "..AL["Halaa"], "AtlasLootBurningCrusade" },
		},

		["HellfirePeninsulaPvP"] = {
			["Bosses"] = {
				{ "Hellfire", 1 },
			},
			["Info"] = { BabbleZone["Hellfire Peninsula"]..": "..AL["Hellfire Fortifications"], "AtlasLootBurningCrusade" },
		},

		["TerokkarForestPvP"] = {
			["Bosses"] = {
				{ "Terokkar", 1 },
			},
			["Info"] = { BabbleZone["Terokkar Forest"]..": "..AL["Spirit Towers"], "AtlasLootBurningCrusade" },
		},

		["ZangarmarshPvP"] = {
			["Bosses"] = {
				{ "Zangarmarsh", 1 },
			},
			["Info"] = { BabbleZone["Zangarmarsh"]..": "..AL["Twin Spire Ruins"], "AtlasLootBurningCrusade" },
		},

		["WintergraspPvP"] = {
			["Bosses"] = {
				{ "LakeWintergrasp", 1 },
			},
			["Info"] = { BabbleZone["Wintergrasp"], "AtlasLootWotLK" },
		},

		["TolBarad"] = {
			["Bosses"] = {
				{ "BaradinsWardens", 1 },
				{ "HellscreamsReach", 2 },
			},
			["Info"] = { BabbleZone["Tol Barad"], "AtlasLootCataclysm" },
		},

		["TwinPeaks"] = {
			["Bosses"] = {
				{ "WildhammerClan", 1 },
				{ "DragonmawClan", 2 },
			},
			["Info"] = { BabbleZone["Twin Peaks"], "AtlasLootCataclysm" },
		},
	},

--------------------
--- World Bosses ---
--------------------

	["WorldBosses"] = {

		["DoomLordKazzak"] = {
			["Bosses"] = {
				{ "WorldBossesBC", 1 },
				{ "Thrallmar", 5, hide = true },
			},
			["Info"] = { BabbleBoss["Doom Lord Kazzak"], "AtlasLootBurningCrusade" },
		},

		["Doomwalker"] = {
			["Bosses"] = {
				{ "WorldBossesBC", 1 },
			},
			["Info"] = { BabbleBoss["Doomwalker"], "AtlasLootBurningCrusade" },
		},

		["Skettis"] = {
			["Bosses"] = {
				{ "Terokk", 9 },
				{ "DarkscreecherAkkarai", 18 },
				{ "GezzaraktheHuntress", 19 },
				{ "Karrog", 20 },
				{ "VakkiztheWindrager", 21 },
			},
			["Info"] = { AL["Skettis"], "AtlasLootWorldEvents" },
		},
	},

--------------------
--- World Events ---
--------------------

	["WorldEvents"] = {

		["MidsummerFestival"] = {
			["Bosses"] = {
				{ "MidsummerFestival" },
				{ "LordAhune" },
			},
			["Info"] = { AL["Midsummer Fire Festival"], "AtlasLootWorldEvents"},
		},
	},

----------------
--- Crafting ---
----------------

	["Crafting"] = {

		["Leatherworking"] = {
			["Bosses"] = {
				{ "Dragonscale" },
				{ "Elemental" },
				{ "Tribal" },
			},
			["Info"] = { LEATHERWORKING, "AtlasLootCrafting"},
		},

		["Tailoring"] = {
			["Bosses"] = {
				{ "Mooncloth" },
				{ "Shadoweave" },
				{ "Spellfire" },
			},
			["Info"] = { TAILORING, "AtlasLootCrafting"},
		},

		["BlacksmithingMail"] = {
			["Bosses"] = {
				{ "BlacksmithingMailBloodsoulEmbrace" },
				{ "BlacksmithingMailFelIronChain" },
			},
			["Info"] = { BLACKSMITHING..": "..BabbleInventory["Mail"], "AtlasLootCrafting"},
		},

		["BlacksmithingPlate"] = {
			["Bosses"] = {
				{ "BlacksmithingPlateImperialPlate" },
				{ "BlacksmithingPlateTheDarksoul" },
				{ "BlacksmithingPlateFelIronPlate" },
				{ "BlacksmithingPlateAdamantiteB" },
				{ "BlacksmithingPlateFlameG" },
				{ "BlacksmithingPlateEnchantedAdaman" },
				{ "BlacksmithingPlateKhoriumWard" },
				{ "BlacksmithingPlateFaithFelsteel" },
				{ "BlacksmithingPlateBurningRage" },
				{ "BlacksmithingPlateOrnateSaroniteBattlegear" },
				{ "BlacksmithingPlateSavageSaroniteBattlegear" },
			},
			["Info"] = { BLACKSMITHING..": "..BabbleInventory["Plate"], "AtlasLootCrafting"},
		},

		["LeatherworkingLeather"] = {
			["Bosses"] = {
				{ "LeatherworkingLeatherVolcanicArmor" },
				{ "LeatherworkingLeatherIronfeatherArmor" },
				{ "LeatherworkingLeatherStormshroudArmor" },
				{ "LeatherworkingLeatherDevilsaurArmor" },
				{ "LeatherworkingLeatherBloodTigerH" },
				{ "LeatherworkingLeatherPrimalBatskin" },
				{ "LeatherworkingLeatherWildDraenishA" },
				{ "LeatherworkingLeatherThickDraenicA" },
				{ "LeatherworkingLeatherFelSkin" },
				{ "LeatherworkingLeatherSClefthoof" },
				{ "LeatherworkingLeatherPrimalIntent" },
				{ "LeatherworkingLeatherWindhawkArmor" },
				{ "LeatherworkingLeatherBoreanEmbrace" },
				{ "LeatherworkingLeatherIceborneEmbrace" },
				{ "LeatherworkingLeatherEvisceratorBattlegear" },
				{ "LeatherworkingLeatherOvercasterBattlegear" },
			},
			["Info"] = { LEATHERWORKING..": "..BabbleInventory["Leather"], "AtlasLootCrafting"},
		},

		["LeatherworkingMail"] = {
			["Bosses"] = {
				{ "LeatherworkingMailGreenDragonM" },
				{ "LeatherworkingMailBlueDragonM" },
				{ "LeatherworkingMailBlackDragonM" },
				{ "LeatherworkingMailScaledDraenicA" },
				{ "LeatherworkingMailFelscaleArmor" },
				{ "LeatherworkingMailFelstalkerArmor" },
				{ "LeatherworkingMailNetherFury" },
				{ "LeatherworkingMailNetherscaleArmor" },
				{ "LeatherworkingMailNetherstrikeArmor" },
				{ "LeatherworkingMailFrostscaleBinding" },
				{ "LeatherworkingMailNerubianHive" },
				{ "LeatherworkingMailStormhideBattlegear" },
				{ "LeatherworkingMailSwiftarrowBattlefear" },
			},
			["Info"] = { LEATHERWORKING..": "..BabbleInventory["Mail"], "AtlasLootCrafting"},
		},

		["TailoringSets"] = {
			["Bosses"] = {
				{ "TailoringBloodvineG" },
				{ "TailoringNeatherVest" },
				{ "TailoringImbuedNeather" },
				{ "TailoringArcanoVest" },
				{ "TailoringTheUnyielding" },
				{ "TailoringWhitemendWis" },
				{ "TailoringSpellstrikeInfu" },
				{ "TailoringBattlecastG" },
				{ "TailoringSoulclothEm" },
				{ "TailoringPrimalMoon" },
				{ "TailoringShadowEmbrace" },
				{ "TailoringSpellfireWrath" },
				{ "TailoringFrostwovenPower" },
				{ "TailoringDuskweaver" },
				{ "TailoringFrostsavageBattlegear" },
			},
			["Info"] = { TAILORING..": "..BabbleInventory["Cloth"], "AtlasLootCrafting"},
		},
	},

	["Misc"] = {
		["Pets"] = {
			["Bosses"] = {
				{ "PetsMerchant" },
				{ "PetsQuest" },
				{ "PetsCrafted" },
				{ "PetsAchievement" },
				{ "PetsFaction" },
				{ "PetsRare" },
				{ "PetsEvent" },
				{ "PetsPromotional" },
				{ "PetsCardGame" },
				{ "PetsPetStore" },
				{ "PetsRemoved" },
				{ "PetsNEW" },
				{ "PetsAccessories" },
			},
			["Info"] = { BabbleInventory["Companions"], "AtlasLootCataclysm"},
		},

		["Mounts"] = {
			["Bosses"] = {
				{ "MountsFaction" },
				{ "MountsPvP" },
				{ "MountsRareDungeon" },
				{ "MountsRareRaid" },
				{ "MountsAchievement" },
				{ "MountsCraftQuest" },
				{ "MountsCardGame" },
				{ "MountsPromotional" },
				{ "MountsEvent" },
				{ "MountsRemoved" },
				{ "MountsNEW" },
			},
			["Info"] = { BabbleInventory["Mounts"], "AtlasLootCataclysm"},
		},

		["Tabards"] = {
			["Bosses"] = {
				{ "TabardsAlliance" },
				{ "TabardsHorde" },
				{ "TabardsNeutralFaction" },
				{ "TabardsAchievementQuestRare" },
				{ "TabardsRemoved" },
			},
			["Info"] = { BabbleInventory["Tabards"], "AtlasLootCataclysm"},
		},
		
		["TransformationItems"] = {
			["Bosses"] = {
				{ "TransformationNonconsumedItems" },
				{ "TransformationConsumableItems" },
				{ "TransformationAdditionalEffects" },
			},
			["Info"] = { AL["Transformation Items"], "AtlasLootCataclysm"},
		},
		
		["WorldEpics"] = {
			["Bosses"] = {
				{ "WorldEpics85" },
				{ "WorldEpics80" },
				{ "WorldEpics70" },
				{ "WorldEpics5060" },
				{ "WorldEpics4049" },
				{ "WorldEpics3039" },
			},
			["Info"] = { AL["BoE World Epics"], "AtlasLootWotLK"},
		},
	},

	["PVP"] = {
		["AlteracValley"] = {
			["Bosses"] = {
				{ "AVMisc" },
				{ "AVBlue" },
			},
			["Info"] = { BabbleZone["Alterac Valley"].." "..AL["Rewards"], "AtlasLootClassicWoW"},
		},

		["WarsongGulch"] = {
			["Bosses"] = {
				{ "WSGMisc", 6 },
				{ "WSGAccessories", 7 },
				{ "WSGWeapons", 8 },
				{ "WSGArmor", 10 },
			},
			["Info"] = { BabbleZone["Warsong Gulch"].." "..AL["Rewards"], "AtlasLootClassicWoW"},
		},
	},

	["Sets"] = {
		["EmblemofTriumph"] = {
			["Bosses"] = {
				{ "EmblemofTriumph" },
				{ "EmblemofTriumph2" },
			},
			["Info"] = { AL["ilvl 245"].." - "..AL["Rewards"], "AtlasLootWotLK"},
		},
	},	
}

AtlasLoot_LootTableRegister["Instances"]["EmptyPage"] = {
	["Bosses"] = {{"EmptyPage"}},
	["Info"] = { "EmptyPage" },
}

AtlasLoot_Data["EmptyPage"] = {
	["Normal"] = {{}};
	info = {
		name = "EmptyPage",
		instance = "EmptyPage",
	};
}