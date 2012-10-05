﻿-- $Id: InstanceList.lua 3830 2012-10-03 18:41:48Z hegarol $
--[[
Atlasloot Enhanced
Author Hegarol
Loot browser associating loot with instance bosses
Can be integrated with Atlas (http://www.atlasmod.com)

Functions:
]]
AtlasLoot_ModuleList_Loader = {
	"AtlasLootClassicWoW",
	"AtlasLootBurningCrusade",
	"AtlasLootWotLK",
	"AtlasLootCataclysm",
	"AtlasLootMoP",
	"AtlasLootCrafting",
	"AtlasLootWorldEvents"
}

AtlasLoot_InstanceList_Loader = {

["OrderCloudSerpent"] = 5,
["TailoringSoulclothEm"] = 6,
["Bags"] = 4,
["HCHallsKargath"] = 2,
["BlacksmithingPlateSavageSaroniteBattlegear"] = 6,
["Ramkahen"] = 4,
["TJSMari"] = 5,
["PVP90ShamanRestoration"] = 5,
["T456PaladinHoly"] = 2,
["EngineeringMisc"] = 6,
["HCFurnaceMaker"] = 2,
["Ogrila"] = 2,
["WSGArmor"] = 1,
["AQ20Ayamiss"] = 1,
["Gilneas"] = 1,
["AhnkahetTaldaram"] = 3,
["MSVWilloftheEmperor"] = 5,
["AQ40Sets"] = 1,
["T10PriestShadow"] = 3,
["FoSDevourer"] = 3,
["WinterfinRetreat"] = 3,
["PVP70Warrior"] = 2,
["VioletEye"] = 2,
["DeadminesCookie"] = 4,
["TabardsAchievementQuestRare"] = 5,
["HordeExpedition"] = 3,
["LeatherItemEnhancement"] = 6,
["SPKalecgos"] = 2,
["EnchantingGloves"] = 6,
["HCFurnaceBreaker"] = 2,
["PVP90Mage"] = 5,
["EngineeringTinker"] = 6,
["WoETrash"] = 4,
["T1112PriestHoly"] = 4,
["PVP70NonSet"] = 2,
["TailoringItemEnhancement"] = 6,
["ToTMindbender"] = 4,
["PVP90PaladinRetribution"] = 5,
["T14Warlock"] = 5,
["PVP70Mage"] = 2,
["Naxx80AnubRekhan"] = 3,
["KeepersofTime"] = 2,
["HardModeResist"] = 2,
["JewelcraftingDailyDragonEye"] = 6,
["ABSets"] = 1,
["BRDArena"] = 1,
["PVP90NonSet"] = 5,
["SalyisWarband"] = 5,
["AQ40Fankriss"] = 1,
["T13Rogue"] = 4,
["GundrakTrash"] = 3,
["PetsCardGame"] = 5,
["SmithingWeaponRemoved"] = 6,
["UlduarIronCouncil"] = 3,
["WorldBossesBC"] = 2,
["Naxx80Patchwerk"] = 3,
["Stormwind"] = 1,
["BTBloodboil"] = 2,
["T456Hunter"] = 2,
["LeatherworkingMailSwiftarrowBattlefear"] = 6,
["BRDTomb"] = 1,
["Inscription_Scrolls"] = 6,
["LeatherworkingMailNerubianHive"] = 6,
["BreweryOokOok"] = 5,
["TKEyeKaelthas"] = 2,
["SMWhitemane"] = 5,
["Ashtongue"] = 2,
["CFRSlaveRokmar"] = 2,
["TailoringArmorBC"] = 6,
["UlduarRazorscale"] = 3,
["PVP90PaladinHoly"] = 5,
["MountHyjalKazrogal"] = 2,
["STRATMalekithePallid"] = 1,
["T1112ShamanElemental"] = 4,
["Inscription_DeathKnight"] = 6,
["AQ20Sets"] = 1,
["EnchantingMisc"] = 6,
["VPErtan"] = 4,
["JewelcraftingDailyBlue"] = 6,
["SilvermoonCity"] = 1,
["EngineeringReagents"] = 6,
["AQ20Moam"] = 1,
["TheNexusKeristrasza"] = 3,
["GBDrahga"] = 4,
["LBRSFelguard"] = 1,
["NaxxShamanElemental"] = 3,
["STRATSkull"] = 1,
["CFRSerpentHydross"] = 2,
["Gnomish"] = 6,
["UBRSAnvilcrack"] = 1,
["Onyxia"] = 3,
["T14PaladinProtection"] = 5,
["VPAsaad"] = 4,
["LeatherworkingLeatherBoreanEmbrace"] = 6,
["VoAToravon"] = 3,
["FirelandsRagnaros"] = 4,
["PVP80DeathKnight"] = 3,
["FirelandsShannox"] = 4,
["Naxx80Gluth"] = 3,
["T14DeathKnightTank"] = 5,
["EnchantingBoots"] = 6,
["HoORajh"] = 4,
["LeatherLeatherArmorBC"] = 6,
["LostCityBarim"] = 4,
["PVP80ShamanRestoration"] = 3,
["StonecoreTrash"] = 4,
["KnightsoftheEbonBlade"] = 3,
["T14MonkHealer"] = 5,
["T1T2Priest"] = 1,
["T0Warlock"] = 1,
["MSVElegon"] = 5,
["MCGehennas"] = 1,
["AQ40Skeram"] = 1,
["BTIllidanStormrage"] = 2,
["MountsRareDungeon"] = 5,
["ZANalorakk"] = 4,
["Inscription_OffHand"] = 6,
["BDAtramedes"] = 4,
["PVP80Hunter"] = 3,
["LBRSWyrmthalak"] = 1,
["T1112Warlock"] = 4,
["ZFAntusul"] = 1,
["MoguShanGekkan"] = 5,
["TransformationConsumableItems"] = 5,
["T10WarriorFury"] = 3,
["T456ShamanElemental"] = 2,
["HoFUnsok"] = 5,
["HallsofLightningLoken"] = 3,
["NTJinbak"] = 5,
["EngineeringArmorCloth"] = 6,
["CoTHillsbradHunter"] = 2,
["KirinTor"] = 3,
["JewelPrismatic"] = 6,
["Mooncloth"] = 6,
["DMEPusillin"] = 1,
["PVPGladiatorWeapons"] = 2,
["LeatherworkingMailNetherstrikeArmor"] = 6,
["SmithingWeaponCata"] = 6,
["TabardsNeutralFaction"] = 5,
["DMNGuardMoldar"] = 1,
["DMNGuardFengus"] = 1,
["VentureBay"] = 3,
["JewelDragonsEye"] = 6,
["Inscription_StavesEnchants"] = 6,
["AlchemyOtherElixir"] = 6,
["FirelandsTrash"] = 4,
["PVP70PriestHoly"] = 2,
["Naxx80Trash"] = 3,
["Netherwing"] = 2,
["BRDHoundmaster"] = 1,
["MountsAchievement"] = 5,
["PVP60Rogue"] = 1,
["CFRSerpentVashj"] = 2,
["EnchantingBracer"] = 6,
["T9DruidBalance"] = 3,
["TJSFlameheart"] = 5,
["DrakTharonKeepNovos"] = 3,
["FrenzyheartTribe"] = 3,
["ArchaeologyNightElf"] = 6,
["DS3Plate"] = 2,
["VWOWSets"] = 1,
["PetsRare"] = 5,
["Weaponsmith"] = 6,
["TailoringBattlecastG"] = 6,
["MountHyjalWinterchill"] = 2,
["SmithingWeaponWrath"] = 6,
["CardGame"] = 5,
["PVP85NonSet"] = 4,
["JewelYellow"] = 6,
["AhnkahetJedoga"] = 3,
["TheNexusAnomalus"] = 3,
["UldGrimlok"] = 1,
["T9DeathKnightDPS"] = 3,
["T14DruidDPS"] = 5,
["PVP90Rogue"] = 5,
["SPBrutallus"] = 2,
["TailoringArcanoVest"] = 6,
["T9Warlock"] = 3,
["WorldEpics80"] = 3,
["BoTChogall"] = 4,
["STRATTrash"] = 1,
["PVP60Hunter"] = 1,
["LBRSBashguud"] = 1,
["UldShovelphlange"] = 1,
["Therazane"] = 4,
["KaraTrash"] = 2,
["PetsAchievement"] = 5,
["HCFurnaceBroggok"] = 2,
["T9WarriorProtection"] = 3,
["GnomereganLoot"] = 1,
["PVPVengefulWeapons"] = 2,
["BlackrockCavernsLordObsidius"] = 4,
["T13DruidFeral"] = 4,
["AVMisc"] = 1,
["TabardsRemoved"] = 5,
["AzjolNerubHadronox"] = 3,
["LeatherworkingLeatherFelSkin"] = 6,
["Sporeggar"] = 2,
["NaxxPaladinHoly"] = 3,
["PVP85Rogue"] = 4,
["ZFZerillis"] = 1,
["T13Hunter"] = 4,
["ArchaeologyMogu"] = 6,
["DMEZevrimThornhoof"] = 1,
["MountsPvP"] = 5,
["TailoringFrostwovenPower"] = 6,
["Spellfire"] = 6,
["T0Mage"] = 1,
["T456DruidBalance"] = 2,
["HallsofStoneMaiden"] = 3,
["T1112DruidFeral"] = 4,
["PVP90MonkHealer"] = 5,
["ICCFestergut"] = 3,
["PVP60Druid"] = 1,
["Inscription_Paladin"] = 6,
["ArchaeologyTolvir"] = 6,
["FirelandsPatterns"] = 4,
["FoSBronjahm"] = 3,
["T14WarriorFury"] = 5,
["ArchaeologyPandaren"] = 6,
["ArgentDawn"] = 1,
["Skyguard"] = 2,
["T456DruidRestoration"] = 2,
["MSVFeng"] = 5,
["Legendaries"] = 4,
["SmithingArmorOld"] = 6,
["LBRSSmolderweb"] = 1,
["ZFHydromancerVelratha"] = 1,
["LeatherLeatherArmorWrath"] = 6,
["Terokkar"] = 2,
["EmblemofValor"] = 3,
["GotSSRimok"] = 5,
["DarkspearTrolls"] = 1,
["JewelGreen"] = 6,
["HallsofStoneKrystallus"] = 3,
["ValorPointsMoP"] = 5,
["MCRANDOMBOSSDROPPS"] = 1,
["UBRSDrakkisath"] = 1,
["NaxxPaladinRetribution"] = 3,
["ZGKilnara"] = 4,
["LeatherMailArmorCata"] = 6,
["Ironforge"] = 1,
["EndtimeTrash"] = 4,
["AQ40CThun"] = 1,
["STJammalanandOgom"] = 1,
["EmblemofTriumph"] = 3,
["NTVojak"] = 5,
["SHHarlan"] = 5,
["DMWImmolthar"] = 1,
["TailoringSpellstrikeInfu"] = 6,
["MountHyjalTrash"] = 2,
["WSGWeapons"] = 1,
["HoOIsiset"] = 4,
["AuchShadowBlackheart"] = 2,
["CFRSlaveMennu"] = 2,
["TheNexusKolurgStoutbeard"] = 3,
["LBRSSpirestoneLord"] = 1,
["LeatherworkingMailBlackDragonM"] = 6,
["CFRSerpentLurker"] = 2,
["T13PaladinRetribution"] = 4,
["Halion"] = 3,
["LeatherworkingMailScaledDraenicA"] = 6,
["GBErudax"] = 4,
["ICCTrash"] = 3,
["BHAlizabal"] = 4,
["CExpedition"] = 2,
["Naxx80Heigan"] = 3,
["LeatherworkingLeatherEvisceratorBattlegear"] = 6,
["WailingCavernsLoot"] = 1,
["T1T2Shaman"] = 1,
["T9DruidRestoration"] = 3,
["WildhammerClan"] = 4,
["Mining"] = 6,
["ZAHalazzi"] = 4,
["LeatherCloaks"] = 6,
["BlackrockCavernsBeauty"] = 4,
["T1T2Warlock"] = 1,
["BlackrockMountainEntLoot"] = 1,
["AuchManaTavarok"] = 2,
["NTPavalak"] = 5,
["TKArcScryer"] = 2,
["NaxxPriestHoly"] = 3,
["T3Mage"] = 1,
["PVP80ShamanEnhancement"] = 3,
["ArchaeologyDwarf"] = 6,
["TailoringSpellfireWrath"] = 6,
["PVP60Warrior"] = 1,
["AuchShadowGrandmaster"] = 2,
["ThunderBluff"] = 1,
["TailoringShirts"] = 6,
["UldIronaya"] = 1,
["PVP90Warlock"] = 5,
["PVP80Accessories"] = 3,
["PVP85PriestShadow"] = 4,
["BTAkama"] = 2,
["Inscription_Warrior"] = 6,
["BRDPyromantLoregrain"] = 1,
["UBRSRunewatcher"] = 1,
["NaxxWarriorProtection"] = 3,
["BRDWarderStilgiss"] = 1,
["OcuDrakos"] = 3,
["BlacksmithingPlateOrnateSaroniteBattlegear"] = 6,
["VioletHoldCyanigosa"] = 3,
["AugustCelestials"] = 5,
["UlduarAuriaya"] = 3,
["CraftedWeapons"] = 6,
["CoTStratholmeTrash"] = 3,
["PVP70Weapons"] = 2,
["Sartharion"] = 3,
["DMNCaptainKromcrush"] = 1,
["Inscription_Warlock"] = 6,
["CFRUnderStalker"] = 2,
["ZAAkilZon"] = 4,
["CoTStratholmeSalramm"] = 3,
["PVP90DruidBalance"] = 5,
["ToESLeiShi"] = 5,
["EmblemofTriumph2"] = 3,
["PVP90PriestHoly"] = 5,
["ZGJindo"] = 4,
["NaxxPaladinProtection"] = 3,
["SmithingArmorEnhancement"] = 6,
["HardModeCloth"] = 2,
["LeatherDrumsBagsMisc"] = 6,
["GundrakGaldarah"] = 3,
["T10DeathKnightDPS"] = 3,
["T10DruidBalance"] = 3,
["PVP80ShamanElemental"] = 3,
["AllianceVanguard"] = 3,
["BWLChromaggus"] = 1,
["BRDLordIncendius"] = 1,
["HCHallsTrash"] = 2,
["Shadoweave"] = 6,
["VoAEmalon"] = 3,
["MountsAlliance"] = 5,
["DMNTRIBUTERUN"] = 1,
["HardModePlate"] = 2,
["T14DruidRestoration"] = 5,
["ICCLanathel"] = 3,
["ShadowfangWalden"] = 4,
["BWLFlamegor"] = 1,
["LeatherworkingCataVendor"] = 6,
["LeatherworkingMailFelstalkerArmor"] = 6,
["AuchSethekkTalonKing"] = 2,
["PVP85Warlock"] = 4,
["STRATTheUnforgiven"] = 1,
["MountsFaction"] = 5,
["StonecoreAzil"] = 4,
["PVP90Hunter"] = 5,
["PVP70Accessories"] = 2,
["T9Mage"] = 3,
["ScholoJandice"] = 5,
["KaraAran"] = 2,
["TKEyeTrash"] = 2,
["T1T2Hunter"] = 1,
["AuchCryptsExarch"] = 2,
["SmithingWeaponEnhancement"] = 6,
["BWLNefarian"] = 1,
["SmithingArmorBC"] = 6,
["STRATBalnazzar"] = 1,
["ZADaakara"] = 4,
["STRATInstructorGalford"] = 1,
["BlackrockCavernsRomogg"] = 4,
["Goblin"] = 6,
["KaraCharredBoneFragment"] = 2,
["BRDLordRoccor"] = 1,
["TKArcHarbinger"] = 2,
["LBRSVosh"] = 1,
["PetsEvent"] = 5,
["STRATWilleyHopebreaker"] = 1,
["EngineeringExplosives"] = 6,
["NTNeronok"] = 5,
["GundrakColossus"] = 3,
["UtgardeKeepTrash"] = 3,
["UPSkadi"] = 3,
["DMNKingGordok"] = 1,
["Naxx80Loatheb"] = 3,
["ScholoChillheart"] = 5,
["Armorsmith"] = 6,
["UlduarIgnis"] = 3,
["FirelandsFirestone"] = 4,
["MCLucifron"] = 1,
["LBRSGrimaxe"] = 1,
["GuardiansHyjal"] = 4,
["DMNStomperKreeg"] = 1,
["GruulGruul"] = 2,
["Timbermaw"] = 1,
["T10ShamanRestoration"] = 3,
["T9Rogue"] = 3,
["CookingSpecial"] = 6,
["TBCSets"] = 2,
["HCMagtheridon"] = 2,
["PVP85Accessories"] = 4,
["PetsRemoved"] = 5,
["JewelNeck"] = 6,
["WoEMannoroth"] = 4,
["GotSSKiptilak"] = 5,
["T1112WarriorFury"] = 4,
["ScholoTrash"] = 1,
["Inscription_Priest"] = 6,
["ZAJanAlai"] = 4,
["T456PriestHoly"] = 2,
["Tillers"] = 5,
["EmblemofConquest"] = 3,
["ArchaeologyMisc"] = 6,
["UlduarMimiron"] = 3,
["DrakTharonKeepTrash"] = 3,
["VoAKoralon"] = 3,
["UBRSTrash"] = 1,
["MaraudonLoot"] = 1,
["PVP80NonSet"] = 3,
["LBRSTrash"] = 1,
["AQBroodRings"] = 1,
["SHBraun"] = 5,
["ToTUlthok"] = 4,
["PoSTyrannus"] = 3,
["KaraPrince"] = 2,
["T1112PaladinRetribution"] = 4,
["AuchCryptsShirrak"] = 2,
["T14ShamanRestoration"] = 5,
["TransformationNonconsumedItems"] = 5,
["SPMuru"] = 2,
["PVP80PriestShadow"] = 3,
["FirelandsStaghelm"] = 4,
["T0Warrior"] = 1,
["ArgentCrusade"] = 3,
["ZGVenoxis"] = 4,
["PVP90ShamanElemental"] = 5,
["LBRSCrystalFang"] = 1,
["WSGAccessories"] = 1,
["NaxxShamanEnhancement"] = 3,
["AQ40Emperors"] = 1,
["PVP70PriestShadow"] = 2,
["HCRampWatchkeeper"] = 2,
["PVP85Hunter"] = 4,
["PVP60Priest"] = 1,
["BDMaloriak"] = 4,
["T10PaladinRetribution"] = 3,
["PVP90Warrior"] = 5,
["CFRSerpentLeotheras"] = 2,
["TKBotSplinter"] = 2,
["STEranikus"] = 1,
["T3Warrior"] = 1,
["SHKoegler"] = 5,
["ShadoPanCloudstrike"] = 5,
["SmithingMisc"] = 6,
["LBRSSlavener"] = 1,
["BlacksmithingPlateEnchantedAdaman"] = 6,
["OcuUrom"] = 3,
["LeatherworkingLeatherPrimalBatskin"] = 6,
["SunOffensive"] = 2,
["ScholoVoss"] = 5,
["BlacksmithingPlateAdamantiteB"] = 6,
["PVP80PriestHoly"] = 3,
["Consortium"] = 2,
["TailoringCloth"] = 6,
["HallsofStoneTribunal"] = 3,
["ScaleSands"] = 2,
["Stockade"] = 1,
["ShaofAnger"] = 5,
["SPPatterns"] = 2,
["T9PaladinRetribution"] = 3,
["SMTDelrissa"] = 2,
["HallsofLightningBjarngrim"] = 3,
["KaraIllhoof"] = 2,
["WorldEpics3039"] = 1,
["PetsCrafted"] = 5,
["BlacksmithingPlateTheDarksoul"] = 6,
["T3Shaman"] = 1,
["T1112WarriorProtection"] = 4,
["NaxxWarlock"] = 3,
["MiscFactions"] = 1,
["AQ20Trash"] = 1,
["EnchantingWeapon"] = 6,
["TheNexusTelestra"] = 3,
["HoFTayak"] = 5,
["WOTLKSets"] = 3,
["ZFSezzziz"] = 1,
["HoRMarwyn"] = 3,
["BTTrash"] = 2,
["Naxx80Gothik"] = 3,
["STRATNerubenkan"] = 1,
["BTNajentus"] = 2,
["UlduarYoggSaron"] = 3,
["BTShahraz"] = 2,
["AuchManaPandemonius"] = 2,
["T10Rogue"] = 3,
["EnchantingCloak"] = 6,
["T14WarriorProtection"] = 5,
["TailoringBloodvineG"] = 6,
["PVP80Mage"] = 3,
["CookingRating"] = 6,
["UlduarHodir"] = 3,
["T0Paladin"] = 1,
["AuchShadowHellmaw"] = 2,
["TrialoftheCrusaderAnubarak"] = 3,
["CookingDaily"] = 6,
["LBRSDoomhowl"] = 1,
["EnchantingCataVendor"] = 6,
["DMWTrash"] = 1,
["ZFChiefUkorzSandscalp"] = 1,
["T13Warlock"] = 4,
["DMEHydro"] = 1,
["AuchTrash"] = 2,
["Inscription_Rogue"] = 6,
["CookingHitCrit"] = 6,
["GBUmbriss"] = 4,
["TrialoftheCrusaderLordJaraxxus"] = 3,
["DragonSoulDeathwingSpine"] = 4,
["CFRSteamWarlord"] = 2,
["DMWTsuzee"] = 1,
["T9PaladinHoly"] = 3,
["BRDFineousDarkvire"] = 1,
["NaxxMage"] = 3,
["VoAArchavon"] = 3,
["CFRSteamSteamrigger"] = 2,
["T13ShamanRestoration"] = 4,
["PVP80PaladinHoly"] = 3,
["TailoringBags"] = 6,
["CoTHillsbradSkarloc"] = 2,
["BlacksmithingPlateBurningRage"] = 6,
["AlchemyGuardianElixir"] = 6,
["TrialoftheCrusaderFactionChampions"] = 3,
["HallsofStoneSjonnir"] = 3,
["TailoringImbuedNeather"] = 6,
["SmithingMoPVendor"] = 6,
["CookingOtherBuffs"] = 6,
["PVP85PaladinRetribution"] = 4,
["HCHallsNethekurse"] = 2,
["UlduarAlgalon"] = 3,
["SPEredarTwins"] = 2,
["LBRSSpirestoneButcher"] = 1,
["PVP70Rep"] = 2,
["VWOWScholo"] = 1,
["WorldEpics5060"] = 1,
["TKMechCalc"] = 2,
["UPYmiron"] = 3,
["EngineeringArmor"] = 6,
["TabardsHorde"] = 5,
["T9ShamanElemental"] = 3,
["PVP70ShamanRestoration"] = 2,
["MCGarr"] = 1,
["NaxxHunter"] = 3,
["LeatherworkingLeatherPrimalIntent"] = 6,
["PVP70PaladinProtection"] = 2,
["UBRSGyth"] = 1,
["PVP70WarlockDemonology"] = 2,
["WorldEpics85"] = 4,
["T1112DeathKnightTank"] = 4,
["STRATRisenHammersmith"] = 1,
["Heirloom"] = 5,
["AlchemyBattleElixir"] = 6,
["KaraMaiden"] = 2,
["VioletHoldTrash"] = 3,
["JewelcraftingDailyGreen"] = 6,
["CoTTrash"] = 2,
["T13DeathKnightTank"] = 4,
["TKBotThorngrin"] = 2,
["PVP60Shaman"] = 1,
["PVP90MonkDPS"] = 5,
["CoTStratholmeMeathook"] = 3,
["TailoringShadowEmbrace"] = 6,
["PetsNEW"] = 5,
["Naxx80KelThuzad"] = 3,
["T14DeathKnightDPS"] = 5,
["HoFGaralon"] = 5,
["BWLEbonroc"] = 1,
["ZGMadness"] = 4,
["ToESShaofFear"] = 5,
["PoSGarfrost"] = 3,
["JewelMisc"] = 6,
["T0Shaman"] = 1,
["T1112DruidBalance"] = 4,
["T456PaladinRetribution"] = 2,
["STRATTimmytheCruel"] = 1,
["LeatherLeatherArmorCata"] = 6,
["T14PriestHoly"] = 5,
["TKEyeAlar"] = 2,
["T9DruidFeral"] = 3,
["T10WarriorProtection"] = 3,
["T14MonkDPS"] = 5,
["TailoringMisc"] = 6,
["GundrakEck"] = 3,
["BDOmnotron"] = 4,
["TailoringWhitemendWis"] = 6,
["LeatherworkingLeatherWindhawkArmor"] = 6,
["TheSonsofHodir"] = 3,
["ThoriumBrotherhood"] = 1,
["Naxx80Faerlina"] = 3,
["AuchSethekkRavenGod"] = 2,
["AlchemyCauldron"] = 6,
["PoSKrickIck"] = 3,
["ArchaeologyTroll"] = 6,
["JusticePoints"] = 4,
["ToTTrash"] = 4,
["LeatherworkingMailNetherscaleArmor"] = 6,
["NaxxDruidRestoration"] = 3,
["T13PriestHoly"] = 4,
["HardModeAccessories"] = 2,
["TailoringTheUnyielding"] = 6,
["T3Hunter"] = 1,
["EnchantingShieldOffHand"] = 6,
["AuchManaYor"] = 2,
["VPTrash"] = 4,
["CookingBuff"] = 6,
["PVPMercilessWeapons"] = 2,
["PVP85PaladinHoly"] = 4,
["WSGMisc"] = 1,
["SPTrash"] = 2,
["UPTrash"] = 3,
["AuchCryptsAvatar"] = 2,
["ICCPutricide"] = 3,
["AQEnchants"] = 1,
["BlacksmithingPlateImperialPlate"] = 6,
["SmithingArmorWrath"] = 6,
["T10Hunter"] = 3,
["TKBotSarannis"] = 2,
["TJSShaDoubt"] = 5,
["LBRSHalycon"] = 1,
["Maghar"] = 2,
["BlacksmithingPlateKhoriumWard"] = 6,
["ICCLichKing"] = 3,
["Inscription_Druid"] = 6,
["HoFMeljarak"] = 5,
["UldAncientStoneKeeper"] = 1,
["EmblemofFrost"] = 3,
["PetsFaction"] = 5,
["HardModeCloaks"] = 2,
["ShadowfangGodfrey"] = 4,
["HCHallsOmrogg"] = 2,
["StonecoreOzruk"] = 4,
["T1112PaladinHoly"] = 4,
["DeadminesFoeReaper"] = 4,
["TailoringArmorWotLK"] = 6,
["TheWyrmrestAccord"] = 3,
["ToESProtectors"] = 5,
["DMNThimblejack"] = 1,
["BlacksmithingPlateFaithFelsteel"] = 6,
["T456PriestShadow"] = 2,
["BRDBSPlans"] = 1,
["TKBotFreywinn"] = 2,
["CFRSerpentMorogrim"] = 2,
["Naxx80Grobbulus"] = 3,
["T14MonkTank"] = 5,
["T14Hunter"] = 5,
["CookingAPSP"] = 6,
["STRATHearthsingerForresten"] = 1,
["ZAMalacrass"] = 4,
["T1112ShamanEnhancement"] = 4,
["T9PaladinProtection"] = 3,
["HallsofStoneTrash"] = 3,
["CFRSerpentKarathress"] = 2,
["NaxxWarriorFury"] = 3,
["FishingDaily"] = 6,
["PetsPetStore"] = 5,
["STTrash"] = 1,
["Naxx80Noth"] = 3,
["T14Rogue"] = 5,
["UlduarFreya"] = 3,
["ICCGunshipBattle"] = 3,
["AQ40Ouro"] = 1,
["ShadowfangSpringvale"] = 4,
["HoRFalric"] = 3,
["MountHyjalAnetheron"] = 2,
["BWLFiremaw"] = 1,
["ICCValithria"] = 3,
["TrialoftheChampionBlackKnight"] = 3,
["DMWHelnurath"] = 1,
["AQ20Ossirian"] = 1,
["BDNefarian"] = 4,
["ScholoRattlegore"] = 5,
["UPPalehoof"] = 3,
["JewelRed"] = 6,
["STRATStonespine"] = 1,
["AzjolNerubAnubarak"] = 3,
["DS3Mail"] = 2,
["T1T2Mage"] = 1,
["OcuTrash"] = 3,
["BRDFlamelash"] = 1,
["Tranquillien"] = 2,
["BloodsailHydraxian"] = 1,
["T456PaladinProtection"] = 2,
["ShadoPanShaViolence"] = 5,
["BoTWyrmbreaker"] = 4,
["Hellfire"] = 2,
["EngineeringFirework"] = 6,
["T456Warlock"] = 2,
["BTReliquaryofSouls"] = 2,
["PVP80DruidFeral"] = 3,
["LeatherworkingLeatherStormshroudArmor"] = 6,
["LeatherMailArmorOld"] = 6,
["T1112Hunter"] = 4,
["DrakTharonKeepTharonja"] = 3,
["STRATBlackGuardSwordsmith"] = 1,
["ZGTrash"] = 4,
["GundrakMoorabi"] = 3,
["WorldEpics4049"] = 1,
["DMBooks"] = 1,
["PVP90PriestShadow"] = 5,
["AhnkahetAmanitar"] = 3,
["PVP70PaladinRetribution"] = 2,
["HallsofLightningTrash"] = 3,
["BRDHighInterrogatorGerstahn"] = 1,
["AlchemyOil"] = 6,
["Undercity"] = 1,
["UlduarLeviathan"] = 3,
["MountsPromotional"] = 5,
["UlduarDeconstructor"] = 3,
["HoFZorlok"] = 5,
["DeadminesGearbreaker"] = 4,
["VioletHoldLavanthor"] = 3,
["UlduarVezax"] = 3,
["Orgrimmar"] = 1,
["UldTrash"] = 1,
["FirelandsBethtilac"] = 4,
["TailoringArmorCata"] = 6,
["ToESTsulong"] = 5,
["FHTrashMobs"] = 3,
["PVP80DruidBalance"] = 3,
["T456ShamanRestoration"] = 2,
["PVP80PaladinRetribution"] = 3,
["BTCouncil"] = 2,
["ICCSaurfang"] = 3,
["T10ShamanEnhancement"] = 3,
["T14DruidBalance"] = 5,
["ZFTrash"] = 1,
["LeatherMailArmorBC"] = 6,
["PVP70WarlockDestruction"] = 2,
["LostCityHusam"] = 4,
["CFRSteamTrash"] = 2,
["T1T2Druid"] = 1,
["T10Warlock"] = 3,
["BDTrash"] = 4,
["CFRSlaveQuagmirran"] = 2,
["MCShazzrah"] = 1,
["STRATFrasSiabi"] = 1,
["GundrakSladran"] = 3,
["T10DeathKnightTank"] = 3,
["PVP85Mage"] = 4,
["CFRSerpentTrash"] = 2,
["BoTSinestra"] = 4,
["HardModeMail"] = 2,
["HardModeWeapons"] = 2,
["PVP60Warlock"] = 1,
["UtgardeKeepIngvar"] = 3,
["Swordsmith"] = 6,
["T456WarriorProtection"] = 2,
["T14PaladinRetribution"] = 5,
["KaraNetherspite"] = 2,
["BRDImperatorDagranThaurissan"] = 1,
["Blackfathom"] = 1,
["TheNexusOrmorok"] = 3,
["UtgardeKeepKeleseth"] = 3,
["PVP60Paladin"] = 1,
["KaraCurator"] = 2,
["EnchantingRing"] = 6,
["AB4049"] = 1,
["DMETrash"] = 1,
["T9ShamanRestoration"] = 3,
["ICCLordMarrowgar"] = 3,
["ArchaeologyArmorAndWeapons"] = 6,
["HCHallsPorung"] = 2,
["FirelandsRhyolith"] = 4,
["PVP80Weapons"] = 3,
["TailoringCataVendor"] = 6,
["PetsAccessories"] = 5,
["DMNChoRush"] = 1,
["PVP70DeathKnight"] = 2,
["ICCRotface"] = 3,
["T456WarriorFury"] = 2,
["Thrallmar"] = 2,
["LBRSZigris"] = 1,
["NaxxDeathKnightDPS"] = 3,
["NaxxDruidFeral"] = 3,
["T10PriestHoly"] = 3,
["SMTKaelthas"] = 2,
["T10PaladinProtection"] = 3,
["AzjolNerubTrash"] = 3,
["MountsEvent"] = 5,
["DMNGuardSlipkik"] = 1,
["CFRUnderHungarfen"] = 2,
["T9Hunter"] = 3,
["LeatherLeatherArmorOld"] = 6,
["TJSStonestep"] = 5,
["StonecoreSlabhide"] = 4,
["MountsCardGame"] = 5,
["PVP85ShamanRestoration"] = 4,
["EngineeringGem"] = 6,
["T14PriestShadow"] = 5,
["T9ShamanEnhancement"] = 3,
["T9PriestShadow"] = 3,
["TailoringDuskweaver"] = 6,
["UldBaelog"] = 1,
["BlacksmithingPlateFelIronPlate"] = 6,
["BRDPanzor"] = 1,
["T456DruidFeral"] = 2,
["GotSSRaigonn"] = 5,
["TheKaluak"] = 3,
["TheAshenVerdict"] = 3,
["Axesmith"] = 6,
["ShadowfangTrash"] = 4,
["NaxxDruidBalance"] = 3,
["LeatherworkingLeatherBloodTigerH"] = 6,
["LBRSVoone"] = 1,
["BRDVerek"] = 1,
["TKBotLaj"] = 2,
["JewelcraftingDailyRed"] = 6,
["LostCityLockmaw"] = 4,
["AuchSethekkDarkweaver"] = 2,
["SMThalnos"] = 5,
["MoguShanTrialKing"] = 5,
["DMWIllyannaRavenoak"] = 1,
["T0Rogue"] = 1,
["STAvatarofHakkar"] = 1,
["T10ShamanElemental"] = 3,
["MountsNEW"] = 5,
["DS3Cloth"] = 2,
["ICCSindragosa"] = 3,
["AQ40Viscidus"] = 1,
["KaraChess"] = 2,
["BRDMagmus"] = 1,
["T1T2Paladin"] = 1,
["DeadminesGlubtok"] = 4,
["CoTStratholmeMalGanis"] = 3,
["STRATMagistrateBarthilas"] = 1,
["HoRLichKing"] = 3,
["MountHyjalAzgalor"] = 2,
["UBRSSolakar"] = 1,
["EmblemofHeroism"] = 3,
["TKEyeVoidReaver"] = 2,
["T9WarriorFury"] = 3,
["BlackrockCavernsTrash"] = 4,
["OldKeys"] = 1,
["UlduarPatterns"] = 3,
["HoTDawnslayer"] = 4,
["HoTBenedictus"] = 4,
["ShadowfangAshbury"] = 4,
["AlchemyPotion"] = 6,
["LorewalkersGoldenLotus"] = 5,
["UBRSRend"] = 1,
["WoEAzshara"] = 4,
["T3Rogue"] = 1,
["DragonSoulHagara"] = 4,
["DMELethtendrisPimgib"] = 1,
["TKMechSepethrea"] = 2,
["Shatar"] = 2,
["CenarionCircle"] = 1,
["SmithingArmorRemoved"] = 6,
["NaxxShamanRestoration"] = 3,
["LeatherworkingMailStormhideBattlegear"] = 6,
["VioletHoldZuramat"] = 3,
["HoOAnhuur"] = 4,
["HoOPtah"] = 4,
["T13PaladinProtection"] = 4,
["T10DruidFeral"] = 3,
["HallsofLightningVolkhan"] = 3,
["UldObsidianSentinel"] = 1,
["UBRSEmberseer"] = 1,
["STDragons"] = 1,
["AQ20Rajaxx"] = 1,
["Naxx80Sapphiron"] = 3,
["PVP90DruidRestoration"] = 5,
["LBRSOmokk"] = 1,
["ICCCouncil"] = 3,
["JewelTrinket"] = 6,
["LostCityTrash"] = 4,
["BWLRazorgore"] = 1,
["AvengersHyjal"] = 4,
["StonecoreCorborus"] = 4,
["ArchaeologyOrc"] = 6,
["HoFShekzeer"] = 5,
["PVP85DruidBalance"] = 4,
["AuchManaNexusPrince"] = 2,
["PVP80Rogue"] = 3,
["HardModeArena"] = 2,
["ToTOzumat"] = 4,
["AhnkahetNadox"] = 3,
["Naxx80Razuvious"] = 3,
["DMWTendrisWarpwood"] = 1,
["EngineeringArmorMail"] = 6,
["TransformationAdditionalEffects"] = 5,
["PVP90Accessories"] = 5,
["SPFelmyst"] = 2,
["TKArcUnbound"] = 2,
["LostCitySiamat"] = 4,
["Naxx80Maexxna"] = 3,
["PVP90DeathKnight"] = 5,
["T456Mage"] = 2,
["MCTrashMobs"] = 1,
["ZFGahzrilla"] = 1,
["ZGMandokir"] = 4,
["AQ40Huhuran"] = 1,
["ZGZanzil"] = 4,
["PetsMerchant"] = 5,
["BDMagmaw"] = 4,
["GotSSGadok"] = 5,
["MCMagmadar"] = 1,
["AQ20Buru"] = 1,
["AQ40Sartura"] = 1,
["PVP80Warlock"] = 3,
["UlduarKologarn"] = 3,
["CoTStratholmeEpoch"] = 3,
["JewelcraftingDailyOrange"] = 6,
["DragonSoulYorsahj"] = 4,
["BWLVaelastrasz"] = 1,
["T3Priest"] = 1,
["STRATRamsteintheGorger"] = 1,
["T13ShamanEnhancement"] = 4,
["UtgardeKeepSkarvald"] = 3,
["LowerCity"] = 2,
["PVP80DruidRestoration"] = 3,
["PVP70ShamanEnhancement"] = 2,
["KaraNamed"] = 2,
["JewelBlue"] = 6,
["DragonSoulPatterns"] = 4,
["STRATLordAuriusRivendare"] = 1,
["ArchaeologyDraenei"] = 6,
["FirelandsAlysrazor"] = 4,
["MCRagnaros"] = 1,
["DrakTharonKeepKingDred"] = 3,
["MCGeddon"] = 1,
["Malygos"] = 3,
["DragonSoulUltraxion"] = 4,
["FirelandsShared"] = 4,
["ZFDustwraith"] = 1,
["PVP80Warrior"] = 3,
["EndtimeEchoes"] = 4,
["BaradinsWardens"] = 4,
["T3Paladin"] = 1,
["EnchantingChest"] = 6,
["Zangarmarsh"] = 2,
["TKTrash"] = 2,
["WorldEpics70"] = 3,
["BRDGolemLordArgelmach"] = 1,
["BHArgaloth"] = 4,
["TrialoftheChampionChampions"] = 3,
["ZATimedChest"] = 4,
["DMWPrinceTortheldrin"] = 1,
["AlchemyTransmute"] = 6,
["KaraMoroes"] = 2,
["T0Priest"] = 1,
["AB2039"] = 1,
["AzjolNerubKrikthir"] = 3,
["MSVGarajal"] = 5,
["TFWConclave"] = 4,
["EngineeringWeapon"] = 6,
["TFWAlAkir"] = 4,
["T1112PaladinProtection"] = 4,
["LeatherworkingLeatherVolcanicArmor"] = 6,
["SmithingWeaponBC"] = 6,
["T13DruidBalance"] = 4,
["T3Druid"] = 1,
["PVP70Rogue"] = 2,
["MSVSpiritKings"] = 5,
["Kurenai"] = 2,
["BilgewaterCartel"] = 1,
["MCMajordomo"] = 1,
["PVP85DeathKnight"] = 4,
["PVP70DruidBalance"] = 2,
["FirelandsBaleroc"] = 4,
["T10DruidRestoration"] = 3,
["OcuCloudstrider"] = 3,
["EngineeringArmorPlate"] = 6,
["ZFWitchDoctorZumrah"] = 1,
["PVP85DruidRestoration"] = 4,
["TailoringArmorOld"] = 6,
["BoTValionaTheralion"] = 4,
["UlduarTrash"] = 3,
["PetsPromotional"] = 5,
["Exodar"] = 1,
["CFRSteamThespia"] = 2,
["T13DruidRestoration"] = 4,
["PVP85PriestHoly"] = 4,
["Scryer"] = 2,
["SmithingCataVendor"] = 6,
["AhnkahetVolazj"] = 3,
["BTGorefiend"] = 2,
["NaxxDeathKnightTank"] = 3,
["ShadowfangSilverlaine"] = 4,
["JewelOrange"] = 6,
["DragonSoulDeathwingMadness"] = 4,
["PVP70DruidFeral"] = 2,
["LakeWintergrasp"] = 3,
["SMTTrash"] = 2,
["TrialoftheCrusaderPatterns"] = 3,
["HellscreamsReach"] = 4,
["CoTMorassDeja"] = 2,
["RazorfenDownsLoot"] = 1,
["LBRSLordMagus"] = 1,
["BRDBaelGar"] = 1,
["T13Mage"] = 4,
["Darnassus"] = 1,
["CoTMorassAeonus"] = 2,
["T1T2Warrior"] = 1,
["T1112PriestShadow"] = 4,
["T456Rogue"] = 2,
["BlacksmithingPlateFlameG"] = 6,
["DrakTharonKeepTrollgore"] = 3,
["T1112Rogue"] = 4,
["LeatherworkingLeatherDevilsaurArmor"] = 6,
["DeadminesVanessa"] = 4,
["BRDQuestItems"] = 1,
["DeadminesRipsnarl"] = 4,
["PVP90DruidFeral"] = 5,
["SMKorloff"] = 5,
["BDChimaeron"] = 4,
["AhnkahetTrash"] = 3,
["EngineeringArmorLeather"] = 6,
["ArchaeologyFossil"] = 6,
["T1112ShamanRestoration"] = 4,
["NaxxPriestShadow"] = 3,
["CoTHillsbradDrake"] = 2,
["VioletHoldMoragg"] = 3,
["T13DeathKnightDPS"] = 4,
["PVP60Accessories"] = 1,
["ShadoPanTaranZhu"] = 5,
["LBRSQuestItems"] = 1,
["SMTVexallus"] = 2,
["LeatherLeather"] = 6,
["EngineeringPetMount"] = 6,
["HoOTrash"] = 4,
["Inscription_Hunter"] = 6,
["UldArchaedas"] = 1,
["HoOAnraphet"] = 4,
["AQ40Trash"] = 1,
["DMWMagisterKalendris"] = 1,
["Naxx80Thaddius"] = 3,
["T10Mage"] = 3,
["TrialoftheChampionEadricthePure"] = 3,
["WoEPerotharn"] = 4,
["BRDTrash"] = 1,
["DragonmawClan"] = 4,
["UlduarThorim"] = 3,
["PVP60Mage"] = 1,
["BoTCouncil"] = 4,
["T0Hunter"] = 1,
["DragonSoulTrash"] = 4,
["T14ShamanEnhancement"] = 5,
["TKEyeSolarian"] = 2,
["LeatherworkingMailGreenDragonM"] = 6,
["Klaxxi"] = 5,
["BlackrockCavernsCorla"] = 4,
["T3Warlock"] = 1,
["BoTTrash"] = 4,
["KaraNightbane"] = 2,
["KaraAttumen"] = 2,
["DeadminesTrash"] = 4,
["DragonSoulShared"] = 4,
["Inscription_Mage"] = 6,
["CFRUnderGhazan"] = 2,
["EngineeringArmorTrinket"] = 6,
["ABMisc"] = 1,
["T13PaladinHoly"] = 4,
["UBRSBeast"] = 1,
["MSVTheStoneGuard"] = 5,
["T1T2Rogue"] = 1,
["ToTNazjar"] = 4,
["RagefireChasmLoot"] = 1,
["JusticePointsMoP"] = 5,
["T13PriestShadow"] = 4,
["T14DruidTank"] = 5,
["T13ShamanElemental"] = 4,
["GnomereganRep"] = 1,
["EarthenRing"] = 4,
["BTPatterns"] = 2,
["T456ShamanEnhancement"] = 2,
["T1112Mage"] = 4,
["HoTTrash"] = 4,
["T1112DeathKnightDPS"] = 4,
["AQ20Kurinnaxx"] = 1,
["LeatherworkingMailBlueDragonM"] = 6,
["JewelcraftingDailyYellow"] = 6,
["TailoringPrimalMoon"] = 6,
["TailoringNeatherVest"] = 6,
["Inscription_Misc"] = 6,
["BHOccuthar"] = 4,
["BlacksmithingMailBloodsoulEmbrace"] = 6,
["TheOracles"] = 3,
["NaxxRogue"] = 3,
["LeatherworkingLeatherIronfeatherArmor"] = 6,
["DragonSoulBlackhorn"] = 4,
["MountHyjalArchimonde"] = 2,
["T13WarriorFury"] = 4,
["T13WarriorProtection"] = 4,
["UldRevelosh"] = 1,
["CookingAgiStrInt"] = 6,
["KaraOperaEvent"] = 2,
["JewelcraftingDailyRemoved"] = 6,
["T1112DruidRestoration"] = 4,
["BRDTheVault"] = 1,
["LeatherworkingMailFrostscaleBinding"] = 6,
["LeatherworkingMailFelscaleArmor"] = 6,
["LeatherworkingLeatherIceborneEmbrace"] = 6,
["MountsRemoved"] = 5,
["BWLTrashMobs"] = 1,
["PVP70PaladinHoly"] = 2,
["PVP85Warrior"] = 4,
["TKArcDalliah"] = 2,
["RazorfenKraulLoot"] = 1,
["AuchShadowMurmur"] = 2,
["BRDGeneralAngerforge"] = 1,
["Inscription_Shaman"] = 6,
["ShadoPanSnowdrift"] = 5,
["AVBlue"] = 1,
["MoltenFront"] = 4,
["TrialoftheCrusaderTwinValkyrs"] = 3,
["LeatherworkingMailNetherFury"] = 6,
["T10PaladinHoly"] = 3,
["Hammersmith"] = 6,
["TabardsAlliance"] = 5,
["BlacksmithingMailFelIronChain"] = 6,
["DMEAlzzin"] = 1,
["T14ShamanElemental"] = 5,
["MountsCraftQuest"] = 5,
["CookingStandard"] = 6,
["LeatherworkingLeatherWildDraenishA"] = 6,
["BWLLashlayer"] = 1,
["MCGolemagg"] = 1,
["ICCLadyDeathwhisper"] = 3,
["ArchaeologyNerubian"] = 6,
["UBRSFLAME"] = 1,
["BlackrockCavernsSteelbender"] = 4,
["MoguShanXin"] = 5,
["MountsRareRaid"] = 5,
["AlchemyMisc"] = 6,
["SmithingWeaponOld"] = 6,
["ShadoPan"] = 5,
["T0Druid"] = 1,
["VioletHoldIchoron"] = 3,
["PVP60Weapons"] = 1,
["VPAltairus"] = 4,
["TKMechCapacitus"] = 2,
["PVP70Hunter"] = 2,
["Naxx80FourHorsemen"] = 3,
["UPSorrowgrave"] = 3,
["UldGalgannFirehammer"] = 1,
["HCRampOmor"] = 2,
["ZATrash"] = 4,
["BTSupremus"] = 2,
["PVP70DruidRestoration"] = 2,
["GBThrongus"] = 4,
["PVP90ShamanEnhancement"] = 5,
["JewelMeta"] = 6,
["TailoringFrostsavageBattlegear"] = 6,
["CFRUnderSwamplord"] = 2,
["HallsofLightningIonar"] = 3,
["VioletHoldXevozz"] = 3,
["LeatherSpecializations"] = 6,
["Aldor"] = 2,
["ArgentTournamentFaction"] = 3,
["T9DeathKnightTank"] = 3,
["VioletHoldErekem"] = 3,
["ArchaeologyVrykul"] = 6,
["HCRampVazruden"] = 2,
["Nagrand"] = 2,
["PVP85DruidFeral"] = 4,
["LeatherMailArmorWrath"] = 6,
["HoOSetesh"] = 4,
["DS3Leather"] = 2,
["BreweryHoptallus"] = 5,
["EndtimeMurozond"] = 4,
["MCSulfuron"] = 1,
["BRDPrincess"] = 1,
["CoTMorassTemporus"] = 2,
["OcuEregos"] = 3,
["Anglers"] = 5,
["DragonSoulMorchok"] = 4,
["MountsHorde"] = 5,
["AQ40BugFam"] = 1,
["STRATBaronessAnastari"] = 1,
["BRDGuzzler"] = 1,
["SMTFireheart"] = 2,
["JewelRing"] = 6,
["DragonSoulZonozz"] = 4,
["TrialoftheCrusaderNorthrendBeasts"] = 3,
["TrialoftheChampionConfessorPaletress"] = 3,
["LeatherworkingLeatherThickDraenicA"] = 6,
["Enchanting2HWeapon"] = 6,
["PVP85Misc"] = 4,
["HardModeLeather"] = 2,
["PVP85ShamanEnhancement"] = 4,
["HonorHold"] = 2,
["SmithingArmorCata"] = 6,
["PVP70ShamanElemental"] = 2,
["GruulsLairHighKingMaulgar"] = 2,
["LeatherworkingLeatherSClefthoof"] = 6,
["LeatherworkingLeatherOvercasterBattlegear"] = 6,
["GBTrash"] = 4,
["PVP85Weapons4"] = 4,
["BreweryYanZhu"] = 5,
["JewelPurple"] = 6,
["PVP85ShamanElemental"] = 4,
["T9PriestHoly"] = 3,
["JewelChimerasEye"] = 6,
["SPKiljaeden"] = 2,
["FirstAid"] = 6,
["PetsQuest"] = 5,
["T14Mage"] = 5,
["TKMechCacheoftheLegion"] = 2,
["T14PaladinHoly"] = 5,
["HoOAmmunae"] = 4,
["JewelcraftingDailyMeta"] = 6,
["AlchemyFlask"] = 6,
["ScholoGandling"] = 5,
["JewelcraftingDailyNeckRing"] = 6,
["JewelcraftingDailyPurple"] = 6,
["EngineeringScope"] = 6,
["HoTArcurion"] = 4,
}