----------------------------------------------------------------
-- TUKUI VARS
----------------------------------------------------------------

TukuiCF = { }
TukuiDB = { }
tukuilocal = { }

TukuiDB.dummy = function() return end
TukuiDB.myname, _ = UnitName("player")
_, TukuiDB.myclass = UnitClass("player") 
TukuiDB.client = GetLocale() 
TukuiDB.resolution = GetCurrentResolution()
TukuiDB.getscreenresolution = select(TukuiDB.resolution, GetScreenResolutions())
TukuiDB.getscreenwidth = TukuiDB.getscreenresolution:gsub("(%d+)x(%d+)", "%1") 
TukuiDB.getscreenheight = TukuiDB.getscreenresolution:gsub("(%d+)x(%d+)", "%2")
TukuiDB.version = GetAddOnMetadata("Tukui", "Version")
TukuiDB.incombat = UnitAffectingCombat("player")
TukuiDB.patch = GetBuildInfo()
TukuiDB.level = UnitLevel("player")
TukuiDB.myrole = ""
TukuiDB.myspec = ""
