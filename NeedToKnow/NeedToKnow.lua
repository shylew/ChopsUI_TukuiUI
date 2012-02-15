-- ----------------------
-- NeedToKnow
-- by Kitjan, lieandswell
-- ----------------------


if not trace then trace = print end
--function maybe_trace(...)
  --local so_far = ""
  --local p = _G
  --for idx = 1,40,1 do
      --local v = select(idx,...)
      --if not v then 
        --break 
      --end
      --p = p[v]
      --if not p then
        --if so_far == "" then
          --trace("global variable",v,"does not exist")
        --else
          --trace(so_far,"does not have member",v)
        --end
        --return;
      --end
      --so_far = so_far .. "." .. v
  --end
  --trace(so_far,"=",p)
--end
--
-- -------------
-- ADDON GLOBALS
-- -------------

NeedToKnow = {}
NeedToKnowLoader = {}
NeedToKnow.scratch = {}
NeedToKnow.scratch.all_stacks = 
    {
        min = 
        {
            buffName = "", 
            duration = 0, 
            expirationTime = 0, 
            iconPath = "",
            caster = ""
        },
        max = 
        {
            duration = 0, 
            expirationTime = 0, 
        },
        total = 0
    }
NeedToKnow.scratch.buff_stacks = 
    {
        min = 
        {
            buffName = "", 
            duration = 0, 
            expirationTime = 0, 
            iconPath = "",
            caster = ""
        },
        max = 
        {
            duration = 0, 
            expirationTime = 0, 
        },
        total = 0
    }
NeedToKnow.scratch.bar_entry = 
    {
        idxName = 0,
        barSpell = "",
        isSpellID = false,
    }
-- NEEDTOKNOW = {} is defined in the localization file, which must be loaded before this file

NEEDTOKNOW.VERSION = "4.0.02"
NEEDTOKNOW.UPDATE_INTERVAL = 0.05
NEEDTOKNOW.MAXBARS = 20

-- Get the localized name of spell 75, which is "Auto Shot" in US English
NEEDTOKNOW.AUTO_SHOT = GetSpellInfo(75)


-- COMBAT_LOG_EVENT_UNFILTERED events where select(6,...) is the caster, 9 is the spellid, and 10 is the spell name
-- (used for Target-of-target monitoring)
NEEDTOKNOW.AURAEVENTS = {
    SPELL_AURA_APPLIED = true,
    SPELL_AURA_REMOVED = true,
    SPELL_AURA_APPLIED_DOSE = true,
    SPELL_AURA_REMOVED_DOSE = true,
    SPELL_AURA_REFRESH = true,
    SPELL_AURA_BROKEN = true,
    SPELL_AURA_BROKEN_SPELL = true
}
    
    
NEEDTOKNOW.BAR_DEFAULTS = {
    Enabled         = true,
    AuraName        = "",
    Unit            = "player",
    BuffOrDebuff    = "HELPFUL",
    OnlyMine        = true,
    BarColor        = { r=0.6, g=0.6, b=0.6, a=1.0 },
    MissingBlink    = { r=0.9, g=0.1, b=0.1, a=0.5 },
    TimeFormat      = "Fmt_SingleUnit",
    vct_enabled     = false,
    vct_color       = { r=0.6, g=0.6, b=0.0, a=0.3 },
    vct_spell       = "",
    vct_extra       = 0,
    bDetectExtends  = false,
    show_text       = true,
    show_count      = true,
    show_time       = true,
    show_spark      = true,
    show_icon       = false,
    show_mypip      = false,
    show_all_stacks = false,
    show_text_user  = "",
    blink_enabled   = false,
    blink_ooc       = true,
    blink_boss      = false,
    blink_label     = "",
    buffcd_duration = 0,
    buffcd_reset_spells = "",
    usable_duration = 0,
    append_cd       = true,
    append_usable   = false,
}
NEEDTOKNOW.GROUP_DEFAULTS = {
    Enabled          = true,
    NumberBars       = 3,
    Scale            = 1.0,
    Width            = 270,
    Bars             = { NEEDTOKNOW.BAR_DEFAULTS, NEEDTOKNOW.BAR_DEFAULTS, NEEDTOKNOW.BAR_DEFAULTS },
    Position         = { "TOPLEFT", "TOPLEFT", 100, -100 },
    FixedDuration    = 0, 
}
NEEDTOKNOW.DEFAULTS = {
    Version       = NEEDTOKNOW.VERSION,
    OldVersion  = NEEDTOKNOW.VERSION,
    Profiles    = {},
    Chars       = {},
}
NEEDTOKNOW.CHARACTER_DEFAULTS = {
    Specs       = {},
    Locked      = false,
    Profiles    = {},
}
NEEDTOKNOW.PROFILE_DEFAULTS = {
    name        = "Default",
    nGroups     = 1,
    Groups      = { NEEDTOKNOW.GROUP_DEFAULTS },
    BarTexture  = "BantoBar",
    BarFont     = "Fritz Quadrata TT",
    BkgdColor   = { 0, 0, 0, 0.8 },
    BarSpacing  = 3,
    BarPadding  = 3,
    FontSize    = 12,
}

NEEDTOKNOW.SHORTENINGS= {
    Enabled         = "On",
    AuraName        = "Aura",
    --Unit            = "Unit",
    BuffOrDebuff    = "Typ",
    OnlyMine        = "Min",
    BarColor        = "Clr",
    MissingBlink    = "BCl",
    TimeFormat      = "TF",
    vct_enabled     = "VOn",
    vct_color       = "VCl",
    vct_spell       = "VSp",
    vct_extra       = "VEx",
    bDetectExtends  = "Ext",
    show_text       = "sTx",
    show_count      = "sCt",
    show_time       = "sTm",
    show_spark      = "sSp",
    show_icon       = "sIc",
    show_mypip      = "sPp",
    show_all_stacks = "All",
    show_text_user  = "sUr",
    blink_enabled   = "BOn",
    blink_ooc       = "BOC",
    blink_boss      = "BBs",
    blink_label     = "BTx",
    buffcd_duration = "cdd",
    buffcd_reset_spells = "cdr",
    usable_duration = "udr",
    append_cd       = "acd",
    append_usable   = "aus",
    --NumberBars       = "NmB",
    --Scale            = "Scl",
    --Width            = "Cx",
    --Bars             = "Brs",
    --Position         = "Pos",
    --FixedDuration    = "FxD", 
    --Version       = "Ver",
    --OldVersion  = "OVr",
    --Profiles    = "Pfl",
    --Chars       = "Chr",
    --Specs       = "Spc",
    --Locked      = "Lck",
    --name        = "nam",
    --nGroups     = "nGr",
    --Groups      = "Grp",
    --BarTexture  = "Tex",
    --BarFont     = "Fnt",
    --BkgdColor   = "BgC",
    --BarSpacing  = "BSp",
    --BarPadding  = "BPd",
    --FontSize    = "FSz",
}

NEEDTOKNOW.LENGTHENINGS= {
   On = "Enabled",
   Aura = "AuraName",
--   Unit = "Unit",
   Typ = "BuffOrDebuff",
   Min = "OnlyMine",
   Clr = "BarColor",
   BCl = "MissingBlink",
   TF  = "TimeFormat",
   VOn = "vct_enabled",
   VCl = "vct_color",
   VSp = "vct_spell",
   VEx = "vct_extra",
   Ext = "bDetectExtends",
   sTx = "show_text",
   sCt = "show_count",
   sTm = "show_time",
   sSp = "show_spark",
   sIc = "show_icon",
   sPp = "show_mypip",
   All = "show_all_stacks",
   sUr = "show_text_user",
   BOn = "blink_enabled",
   BOC = "blink_ooc",
   BBs = "blink_boss",
   BTx = "blink_label",
   cdd = "buffcd_duration",
   cdr = "buffcd_reset_spells",
   udr = "usable_duration",
   acd = "append_cd",
   aus = "append_usable",
    --NumberBars       = "NmB",
    --Scale            = "Scl",
    --Width            = "Cx",
    --Bars             = "Brs",
    --Position         = "Pos",
    --FixedDuration    = "FxD", 
    --Version       = "Ver",
    --OldVersion  = "OVr",
    --Profiles    = "Pfl",
    --Chars       = "Chr",
    --Specs       = "Spc",
    --Locked      = "Lck",
    --name        = "nam",
    --nGroups     = "nGr",
    --Groups      = "Grp",
    --BarTexture  = "Tex",
    --BarFont     = "Fnt",
    --BkgdColor   = "BgC",
    --BarSpacing  = "BSp",
    --BarPadding  = "BPd",
    --FontSize    = "FSz",
}

-- -------------------
-- SharedMedia Support
-- -------------------

    NeedToKnow.LSM = LibStub("LibSharedMedia-3.0", true)
    
    if not NeedToKnow.LSM:Fetch("statusbar", "Aluminum", true) then NeedToKnow.LSM:Register("statusbar", "Aluminum",           [[Interface\Addons\NeedToKnow\Textures\Aluminum.tga]]) end
    if not NeedToKnow.LSM:Fetch("statusbar", "Armory", true) then NeedToKnow.LSM:Register("statusbar", "Armory",             [[Interface\Addons\NeedToKnow\Textures\Armory.tga]]) end
    if not NeedToKnow.LSM:Fetch("statusbar", "BantoBar", true) then NeedToKnow.LSM:Register("statusbar", "BantoBar",           [[Interface\Addons\NeedToKnow\Textures\BantoBar.tga]]) end
    if not NeedToKnow.LSM:Fetch("statusbar", "DarkBottom", true) then NeedToKnow.LSM:Register("statusbar", "DarkBottom",         [[Interface\Addons\NeedToKnow\Textures\Darkbottom.tga]]) end
    if not NeedToKnow.LSM:Fetch("statusbar", "Default", true) then NeedToKnow.LSM:Register("statusbar", "Default",            [[Interface\Addons\NeedToKnow\Textures\Default.tga]]) end
    if not NeedToKnow.LSM:Fetch("statusbar", "Flat", true) then NeedToKnow.LSM:Register("statusbar", "Flat",               [[Interface\Addons\NeedToKnow\Textures\Flat.tga]]) end
    if not NeedToKnow.LSM:Fetch("statusbar", "Glaze", true) then NeedToKnow.LSM:Register("statusbar", "Glaze",              [[Interface\Addons\NeedToKnow\Textures\Glaze.tga]]) end
    if not NeedToKnow.LSM:Fetch("statusbar", "Gloss", true) then NeedToKnow.LSM:Register("statusbar", "Gloss",              [[Interface\Addons\NeedToKnow\Textures\Gloss.tga]]) end
    if not NeedToKnow.LSM:Fetch("statusbar", "Graphite", true) then NeedToKnow.LSM:Register("statusbar", "Graphite",           [[Interface\Addons\NeedToKnow\Textures\Graphite.tga]]) end
    if not NeedToKnow.LSM:Fetch("statusbar", "Minimalist", true) then NeedToKnow.LSM:Register("statusbar", "Minimalist",         [[Interface\Addons\NeedToKnow\Textures\Minimalist.tga]]) end
    if not NeedToKnow.LSM:Fetch("statusbar", "Otravi", true) then NeedToKnow.LSM:Register("statusbar", "Otravi",             [[Interface\Addons\NeedToKnow\Textures\Otravi.tga]]) end
    if not NeedToKnow.LSM:Fetch("statusbar", "Smooth", true) then NeedToKnow.LSM:Register("statusbar", "Smooth",             [[Interface\Addons\NeedToKnow\Textures\Smooth.tga]]) end
    if not NeedToKnow.LSM:Fetch("statusbar", "Smooth v2", true) then NeedToKnow.LSM:Register("statusbar", "Smooth v2",          [[Interface\Addons\NeedToKnow\Textures\Smoothv2.tga]]) end
    if not NeedToKnow.LSM:Fetch("statusbar", "Striped", true) then NeedToKnow.LSM:Register("statusbar", "Striped",            [[Interface\Addons\NeedToKnow\Textures\Striped.tga]]) end

-- ---------------
-- EXECUTIVE FRAME
-- ---------------

function NeedToKnow.ExecutiveFrame_OnEvent(self, event, ...)
    local fnName = "ExecutiveFrame_"..event
    local fn = NeedToKnow[fnName]
    if ( fn ) then
        fn(...)
    end
end

function NeedToKnow.ExecutiveFrame_UNIT_SPELLCAST_SUCCEEDED(unit, spell, rank)
    if unit == "player" then
        local r = NeedToKnow.last_cast[spell]
        if ( r and r.state == 1 ) then
            r.state = 2
            
            -- A little extra safety just in case we get two SUCCEEDED entries
            -- before we get the combat log events for them (though I don't
            -- think this is possible.)
            NeedToKnow.last_success = spell
            
            -- We need the actual target, which we can only get from the combat log.
            -- Thankfully, the combat log event always comes after this one, so we
            -- don't need to register for the combat log for long at all.
            NeedToKnow_ExecutiveFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

            if ( NeedToKnow.nSent > 1 ) then
                NeedToKnow.nSent = NeedToKnow.nSent - 1
            else
                NeedToKnow.nSent = 0
                NeedToKnow_ExecutiveFrame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
            end
        end
    end
end

function NeedToKnow.ExecutiveFrame_COMBAT_LOG_EVENT_UNFILTERED(tod, event, hideCaster, guidCaster, ...)
    -- the time that's passed in appears to be time of day, not game time like everything else.
    local time = GetTime() 
    -- TODO: Is checking r.state sufficient or must event be checked instead?
    if ( guidCaster == NeedToKnow.guidPlayer ) then
        local guidTarget, _, _, _, _, spell = select(4, ...)
        local r = NeedToKnow.last_cast[spell]
        if ( r and r.state == 2) then
            r.state = 0
            -- record this spellcast
            if ( not r[guidTarget] ) then
                r[guidTarget] = { time = time, dur = 0 }
            else
                r[guidTarget].time = time
                r[guidTarget].dur = 0
            end
            
            -- Use this event to expire some targets. This should limit us to 
            -- two combats' worth of targets (since GC doesn't happen in combat)
            for kG, vG in pairs(r) do
                if ( type(vG) == "table" and ( vG.time + 300 < time ) ) then
                    r[kG] = nil
                end
            end
        end

        if ( spell == NeedToKnow.last_success ) then
            -- We saw our spell, we can disconnect from the spam hose
            NeedToKnow_ExecutiveFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        end
    end
end


function NeedToKnow.ExecutiveFrame_ADDON_LOADED(addon)
    if ( addon == "NeedToKnow") then
        if ( not NeedToKnow_Visible ) then
            NeedToKnow_Visible = true
        end
        
        NeedToKnow.last_cast = {} -- [spell][guidTarget] = { time, dur }
        NeedToKnow.nSent = 0
        NeedToKnow.totem_drops = {} -- array 1-4 of precise times the totems appeared
        NeedToKnow.weapon_enchants = { mhand = {}, ohand = {} }
        
        SlashCmdList["NEEDTOKNOW"] = NeedToKnow.SlashCommand
        SLASH_NEEDTOKNOW1 = "/needtoknow"
        SLASH_NEEDTOKNOW2 = "/ntk"
    end
end


function NeedToKnow.ExecutiveFrame_PLAYER_LOGIN()
    NeedToKnowLoader.SafeUpgrade()
    NeedToKnow.ExecutiveFrame_PLAYER_TALENT_UPDATE()
    NeedToKnow.guidPlayer = UnitGUID("player")

    local _, player_CLASS = UnitClass("player")
    if player_CLASS == "DEATHKNIGHT" then
        NeedToKnow.is_DK = 1
    end
    if player_CLASS == "DRUID" then
        NeedToKnow.is_Druid = 1
    end

    NeedToKnow_ExecutiveFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
    NeedToKnow_ExecutiveFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    NeedToKnow_ExecutiveFrame:RegisterEvent("UNIT_TARGET")
    NeedToKnow_ExecutiveFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    NeedToKnow_ExecutiveFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    if ( NeedToKnow.is_DK ) then
        NeedToKnow_ExecutiveFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
    end
    NeedToKnow.Update()
    
    NeedToKnow_ExecutiveFrame:UnregisterEvent("PLAYER_LOGIN")
    NeedToKnow_ExecutiveFrame:UnregisterEvent("ADDON_LOADED")
    NeedToKnow.ExecutiveFrame_ADDON_LOADED = nil
    NeedToKnow.ExecutiveFrame_PLAYER_LOGIN = nil
    NeedToKnowLoader = nil

    NeedToKnow.UpdateWeaponEnchants()
end


function NeedToKnow.ExecutiveFrame_ACTIVE_TALENT_GROUP_CHANGED()
    -- This is the only event we're guaranteed to get on a talent switch,
    -- so we have to listen for it.  However, the client may not yet have
    -- the spellbook updates, so trying to evaluate the cooldows may fail.
    -- This is one of the reasons the cooldown logic has to fail silently
    -- and try again later
    NeedToKnow.ExecutiveFrame_PLAYER_TALENT_UPDATE()
end


function NeedToKnow.ExecutiveFrame_PLAYER_TALENT_UPDATE()
    if NeedToKnow.CharSettings then
        local spec = GetActiveTalentGroup()

        local profile_key = NeedToKnow.CharSettings.Specs[spec]
        if not profile_key then
            print("NeedToKnow: Switching to spec",spec,"for the first time")
            profile_key = NeedToKnow.CreateProfile(CopyTable(NEEDTOKNOW.PROFILE_DEFAULTS), spec)
        end
    
        NeedToKnow.ChangeProfile(profile_key);
    end
end


function NeedToKnow.ExecutiveFrame_UNIT_TARGET(unitTargeting)
    if NeedToKnow.bInCombat and not NeedToKnow.bCombatWithBoss then
        if UnitLevel(unitTargeting .. 'target') == -1 then
            NeedToKnow.bCombatWithBoss = true
            if NeedToKnow.BossStateBars then
                for bar, unused in pairs(NeedToKnow.BossStateBars) do
                    NeedToKnow.Bar_AuraCheck(bar)
                end
            end
        end
    end
end


function NeedToKnow.ExecutiveFrame_PLAYER_REGEN_DISABLED(unitTargeting)
    NeedToKnow.bInCombat = true
    NeedToKnow.bCombatWithBoss = false
    if GetNumRaidMembers() > 0 then
        for i = 1, 40 do
            if UnitLevel("raid"..i.."target") == -1 then
                NeedToKnow.bCombatWithBoss = true;
                break;
            end
        end
    elseif GetNumPartyMembers() > 0 then
        for i = 1, 5 do
            if UnitLevel("party"..i.."target") == -1 then
                NeedToKnow.bCombatWithBoss = true;
                break;
            end
        end
    elseif UnitLevel("target") == -1 then
        NeedToKnow.bCombatWithBoss = true
    end
    if NeedToKnow.BossStateBars then
        for bar, unused in pairs(NeedToKnow.BossStateBars) do
            NeedToKnow.Bar_AuraCheck(bar)
        end
    end
end


function NeedToKnow.ExecutiveFrame_PLAYER_REGEN_ENABLED(unitTargeting)
    NeedToKnow.bInCombat = false
    NeedToKnow.bCombatWithBoss = false
    if NeedToKnow.BossStateBars then
        for bar, unused in pairs(NeedToKnow.BossStateBars) do
            NeedToKnow.Bar_AuraCheck(bar)
        end
    end
end


function NeedToKnow.ExecutiveFrame_UNIT_SPELLCAST_SENT(unit, spell)
    if NeedToKnow.is_DK then
        -- TODO: I hate that DKs have to pay this memory cost for every "spell" they ever cast.
        --       Would be nice to at least garbage collect this data at some point, but that
        --       may add more overhead than just keeping track of a 100 spells.
        if unit == "player" then
            if not NeedToKnow.last_sent then
                NeedToKnow.last_sent = {}
            end
            NeedToKnow.last_sent[spell] = GetTime()
        end
    end
end


function NeedToKnow.RemoveDefaultValues(t, def, k)
  if not k then k = "" end
  if def == nil then
    -- Some obsolete setting, or perhaps bUncompressed
    return true
  end
  if type(t) ~= "table" then
    return t == def
  end
  
  if #t > 0 then
    -- An array, like Groups or Bars. Compare each element against def[1]
    for i,v in ipairs(t)do
      local rhs = def[i]
      if rhs == nil then rhs = def[1] end
      if NeedToKnow.RemoveDefaultValues(v, rhs, k .. " " .. i) then
        t[i] = nil
      end
    end
  else
    for kT, vT in pairs(t) do
      if NeedToKnow.RemoveDefaultValues(t[kT], def[kT], k .. " " .. kT) then
        t[kT] = nil
      end
    end
  end
  local fn = pairs(t)
  return fn(t) == nil
end

function NeedToKnow.CompressProfile(profileSettings)
    -- Remove unused bars/groups
    for iG,vG in ipairs(profileSettings["Groups"]) do
        if iG > profileSettings.nGroups then
            profileSettings["Groups"][iG] = nil
        elseif vG.NumberBars then
            for iB, vB in ipairs(vG["Bars"]) do
                if iB > vG.NumberBars then
                    vG["Bars"][iB] = nil
                end
            end
        end
    end
    NeedToKnow.RemoveDefaultValues(profileSettings, NEEDTOKNOW.PROFILE_DEFAULTS);
end

-- DEBUG: remove k, it's just for debugging
function NeedToKnow.AddDefaultsToTable(t, def, k)
    if type(t) ~= "table" then return end
        if def == nil then
            return
        end
    if not k then k = "" end
    local n = table.maxn(t)
    if n > 0 then
        for i=1,n do
            local rhs = def[i]
            if rhs == nil then rhs = def[1] end
            if t[i] == nil then
                t[i] = NeedToKnow.DeepCopy(rhs)
            else
                NeedToKnow.AddDefaultsToTable(t[i], rhs, k .. " " .. i)
            end
        end
        else
        for kD,vD in pairs(def) do
            if t[kD] == nil then
                if type(vD) == "table" then
                    t[kD] = NeedToKnow.DeepCopy(vD)
                else
                    t[kD] = vD
                end
            else
                NeedToKnow.AddDefaultsToTable(t[kD], vD, k .. " " .. kD)
            end
        end
    end
end

function NeedToKnow.UncompressProfile(profileSettings)
    -- Make sure the arrays have the right number of elements so that
    -- AddDefaultsToTable will find them and fill them in
    if profileSettings.nGroups then
        if not profileSettings.Groups then
            profileSettings.Groups = {}
        end
        if not profileSettings.Groups[profileSettings.nGroups] then
            profileSettings.Groups[profileSettings.nGroups] = {}
        end
    end
    if profileSettings.Groups then
        for i,g in ipairs(profileSettings.Groups) do
            if g.NumberBars then
                if not g.Bars then
                    g.Bars = {}
                end
                if not g.Bars[g.NumberBars] then
                    g.Bars[g.NumberBars] = {}
                end
            end
        end
    end
        
    NeedToKnow.AddDefaultsToTable(profileSettings, NEEDTOKNOW.PROFILE_DEFAULTS)
    
    profileSettings.bUncompressed = true
end


function NeedToKnow.ChangeProfile(profile_key)
    if NeedToKnow_Profiles[profile_key] and
       NeedToKnow.ProfileSettings ~= NeedToKnow_Profiles[profile_key] then
        -- Compress the old profile by removing defaults
        if NeedToKnow.ProfileSettings and NeedToKnow.ProfileSettings.bUncompressed then
            NeedToKnow.CompressProfile(NeedToKnow.ProfileSettings)
        end

        -- Switch to the new profile
        NeedToKnow.ProfileSettings = NeedToKnow_Profiles[profile_key]
        local spec = GetActiveTalentGroup()
        NeedToKnow.CharSettings.Specs[spec] = profile_key

        -- fill in any missing defaults
        NeedToKnow.UncompressProfile(NeedToKnow.ProfileSettings)
        -- FIXME: We currently display 4 groups in the options UI, not nGroups
        -- FIXME: We don't handle nGroups changing (showing/hiding groups based on nGroups changing)
        -- Forcing 4 groups for now
        NeedToKnow.ProfileSettings.nGroups = 4
        for groupID = 1,4 do
            if ( nil == NeedToKnow.ProfileSettings.Groups[groupID] ) then
                NeedToKnow.ProfileSettings.Groups[groupID] = CopyTable( NEEDTOKNOW.GROUP_DEFAULTS )
                local groupSettings = NeedToKnow.ProfileSettings.Groups[groupID]
                groupSettings.Enabled = false;
                groupSettings.Position[4] = -100 - (groupID-1) * 100
            end
        end

        -- Hide any groups not in use
        local iGroup = NeedToKnow.ProfileSettings.nGroups + 1
        while true do
            local group = _G["NeedToKnow_Group"..iGroup]
            if not group then
                break
            end
            group:Hide()
            iGroup = iGroup + 1
        end
        
        -- Update the bars and options panel (if it's open)
        NeedToKnow.Update()
        NeedToKnowOptions.UIPanel_Update()
    elseif not NeedToKnow_Profiles[profile_key] then
        print("NeedToKnow profile",profile_key,"does not exist!") -- LOCME!
    end
end


local function SetStatusBarValue(bar,texture,value,value0)
  local pct0 = 0
  if value0 then
    pct0 = value0 / bar.max_value
    if pct0 > 1 then pct0 = 1 end
  end
  
  -- This happened to me when there was lag right around the time
  -- a bar was ending
  if value < 0 then
    value = 0
  end

  local pct = value / bar.max_value
  texture.cur_value = value
  if pct > 1 then pct = 1 end
  local w = (pct-pct0) * bar:GetWidth()
  if w < 1 then 
      texture:Hide()
  else
      texture:SetWidth(w)
      texture:SetTexCoord(pct0,0, pct0,1, pct,0, pct,1)
      texture:Show()
  end
end


function NeedToKnowLoader.Reset(bResetCharacter)
    NeedToKnow_Globals = CopyTable( NEEDTOKNOW.DEFAULTS )
    
    if bResetCharacter == nil or bResetCharacter then
        NeedToKnow.ResetCharacter()
    end
end


function NeedToKnow.ResetCharacter(bCreateSpecProfile)
    local charKey = UnitName("player") .. ' - ' .. GetRealmName(); 
    NeedToKnow_CharSettings = CopyTable(NEEDTOKNOW.CHARACTER_DEFAULTS)
    NeedToKnow.CharSettings = NeedToKnow_CharSettings
    if bCreateSpecProfile == nil or bCreateSpecProfile then
        NeedToKnow.ExecutiveFrame_PLAYER_TALENT_UPDATE()    
    end
end


function NeedToKnow.CreateProfile(settings, idxSpec, nameProfile)
    if not nameProfile then
        nameProfile = UnitName("player") .. "-"..GetRealmName() .. "." .. idxSpec
    end
    settings.name = nameProfile

    local keyProfile
    for k,t in pairs(NeedToKnow_Globals.Profiles) do
        if t.name == nameProfile then
            keyProfile = k
            break;
        end
    end

    if not keyProfile then
        local n=NeedToKnow_Globals.NextProfile or 1
        while NeedToKnow_Profiles["G"..n] do
            n = n+1
        end
        NeedToKnow_Globals.NextProfile = n+1
        keyProfile = "G"..n
    end

    if NeedToKnow_CharSettings.Profiles[keyProfile] then
        print("NeedToKnow: Clearing profile ",nameProfile); -- FIXME - Localization
    else
        print("NeedToKnow: Adding profile",nameProfile) -- FIXME - Localization
    end

    if idxSpec then
        NeedToKnow.CharSettings.Specs[idxSpec] = keyProfile
    end
    NeedToKnow_CharSettings.Profiles[keyProfile] = settings
    NeedToKnow_Profiles[keyProfile] = settings
    return keyProfile
end


function NeedToKnowLoader.RoundSettings(t)
  for k,v in pairs(t) do
    local typ = type(v)
    if typ == "number" then
      t[k] = tonumber(string.format("%0.4f",v))
    elseif typ == "table" then
      NeedToKnowLoader.RoundSettings(v)
    end
  end    
end


function NeedToKnowLoader.MigrateSpec(specSettings, idxSpec)
    if not specSettings or not specSettings.Groups or not specSettings.Groups[1] or not 
       specSettings.Groups[2] or not specSettings.Groups[3] or not specSettings.Groups[4] then
        return false
    end
    
    -- Round floats to 0.00001, since old versions left really stange values of
    -- BarSpacing and BarPadding around
    NeedToKnowLoader.RoundSettings(specSettings)
    specSettings.Spec = nil
    specSettings.Locked = nil
    specSettings.nGroups = 4
    specSettings.BarFont = NeedToKnowLoader.FindFontName(specSettings.BarFont)
    NeedToKnow.CreateProfile(specSettings, idxSpec)
    return true
end


function NeedToKnowLoader.MigrateCharacterSettings()
    print("NeedToKnow: Migrating settings from", NeedToKnow_Settings["Version"]);
    local oldSettings = NeedToKnow_Settings
    NeedToKnow.ResetCharacter(false)
    if ( not oldSettings["Spec"] ) then 
        NeedToKnow_Settings = nil 
        return 
    end

    -- Blink was controlled purely by the alpha of MissingBlink for awhile,
    -- But then I introduced an explicit blink_enabled variable.  Fill that in
    -- if it's missing
    for kS,vS in pairs(oldSettings["Spec"]) do
      for kG,vG in pairs(vS["Groups"]) do
        for kB,vB in pairs(vG["Bars"]) do
            if nil == vB.blink_enabled and vB.MissingBlink then
                vB.blink_enabled = vB.MissingBlink.a > 0
            end
        end
      end
    end

    NeedToKnow.CharSettings["Locked"] = oldSettings["Locked"]

    local bOK
    if ( oldSettings["Spec"] ) then -- The Spec member existed from versions 2.4 to 3.1.7
        for idxSpec = 1,2 do
            local newprofile = oldSettings.Spec[idxSpec]
            for kD,_ in pairs(NEEDTOKNOW.PROFILE_DEFAULTS) do
              if oldSettings[kD] then
                newprofile[kD] = oldSettings[kD]
              end
            end
            bOK = NeedToKnowLoader.MigrateSpec(newprofile, idxSpec)
        end
    -- if before dual spec support, copy old settings to both specs    
    elseif oldSettings["Version"] >= "2.0" and oldSettings["Groups"] then    
        bOK = NeedToKnowLoader.MigrateSpec(oldSettings, 1) and 
              NeedToKnowLoader.MigrateSpec(CopyTable(oldSettings), 2)

        -- save group positions if upgrading from version that used layout-local.txt
        if ( bOK and NeedToKnow_Settings.Version < "2.1" ) then    
            for groupID = 1, 4 do -- Prior to 3.2, there were always 4 groups
                NeedToKnow.SavePosition(_G["NeedToKnow_Group"..groupID], groupID)
            end
        end        
    end
        
    if not bOK then
        print("Old NeedToKnow character settings corrupted or not compatible with current version... starting from scratch")
        NeedToKnow.ResetCharacter()
    end
    NeedToKnow_Settings = nil
end


function NeedToKnowLoader.FindFontName(fontPath)
    local fontList = NeedToKnow.LSM:List("font")
    for i=1,#fontList do
        local fontName = fontList[i]
        local iPath = NeedToKnow.LSM:Fetch("font", fontName)
        if iPath == fontPath then
            return fontName
        end
    end
    return NEEDTOKNOW.PROFILE_DEFAULTS.BarFont
end

function NeedToKnowLoader.SafeUpgrade()
    local defPath = GameFontHighlight:GetFont()
    NEEDTOKNOW.PROFILE_DEFAULTS.BarFont = NeedToKnowLoader.FindFontName(defPath)
    NeedToKnow_Profiles = {}

    -- If there had been an error during the previous upgrade, NeedToKnow_Settings 
    -- may be in an inconsistent, halfway state.  
    if not NeedToKnow_Globals then
        NeedToKnowLoader.Reset(false)
    end

    if NeedToKnow_Settings then -- prior to 4.0
        NeedToKnowLoader.MigrateCharacterSettings()
    end
    if not NeedToKnow_CharSettings then
        -- we'll call talent update right after this, so we pass false now
        NeedToKnow.ResetCharacter(false)
    end
    NeedToKnow.CharSettings = NeedToKnow_CharSettings

    -- 4.0 settings sanity check 
    if not NeedToKnow_Globals or
       not NeedToKnow_Globals["Version"] or
       not NeedToKnow_Globals.Profiles
    then
        print("NeedToKnow settings corrupted, resetting")
        NeedToKnowLoader.Reset()
    end

    for iS,vS in pairs(NeedToKnow_Globals.Profiles) do
        if vS.bUncompressed then
            NeedToKnow.CompressProfile(vS)
        end

        NeedToKnow_Profiles[iS] = vS
    end
    if NeedToKnow_CharSettings.Profiles then
        for iS,vS in pairs(NeedToKnow_CharSettings.Profiles) do
            NeedToKnow_Profiles[iS] = vS
        end
    end

     -- TODO: check the required members for existence and delete any corrupted profiles
end



function NeedToKnow.DeepCopy(object)
    if type(object) ~= "table" then
        return object
    else
        local new_table = {}
        for k,v in pairs(object) do
            new_table[k] = NeedToKnow.DeepCopy(v)
        end
        return new_table
    end
end


---- Copies anything (int, table, whatever).  Unlike DeepCopy (and CopyTable), CopyRefGraph can 
---- recreate a recursive reference structure (CopyTable will stack overflow.)
---- Copied from http://lua-users.org/wiki/CopyTable
--function NeedToKnow.CopyRefGraph(object)
    --local lookup_table = {}
    --local function _copy(object)
        --if type(object) ~= "table" then
            --return object
        --elseif lookup_table[object] then
            --return lookup_table[object]
        --end
        --local new_table = {}
        --lookup_table[object] = new_table
        --for index, value in pairs(object) do
            --new_table[_copy(index)] = _copy(value)
        --end
        --return setmetatable(new_table, getmetatable(object))
    --end
    --return _copy(object)
--end

function NeedToKnow.RestoreTableFromCopy(dest, source)
    for key,value in pairs(source) do
        if type(value) == "table" then
           if dest[key] then
               NeedToKnow.RestoreTableFromCopy(dest[key], value)
           else
               dest[key] = value
           end
        else
            dest[key] = value
        end
    end
    for key,value in pairs(dest) do
        if source[key] == nil then
            dest[key] = nil
        end
    end
end

function NeedToKnow.Update()
    if UnitExists("player") and NeedToKnow.ProfileSettings then
        NeedToKnow.UpdateWeaponEnchants()
        for groupID = 1, NeedToKnow.ProfileSettings.nGroups do
            NeedToKnow.Group_Update(groupID)
        end
    end
end


function NeedToKnow.Show(bShow)
    NeedToKnow_Visible = bShow
    for groupID = 1, NeedToKnow.ProfileSettings.nGroups do
        local groupName = "NeedToKnow_Group"..groupID
        local group = _G[groupName]
        local groupSettings = NeedToKnow.ProfileSettings.Groups[groupID]
        
        if (NeedToKnow_Visible and groupSettings.Enabled) then
            group:Show()
        else
            group:Hide()
        end
    end
end

do
    local executiveFrame = CreateFrame("Frame", "NeedToKnow_ExecutiveFrame")
    executiveFrame:SetScript("OnEvent", NeedToKnow.ExecutiveFrame_OnEvent)
    executiveFrame:RegisterEvent("ADDON_LOADED")
    executiveFrame:RegisterEvent("PLAYER_LOGIN")
end



-- ------
-- GROUPS
-- ------

function NeedToKnow.Group_Update(groupID)
    local groupName = "NeedToKnow_Group"..groupID
    local group = _G[groupName]
    local groupSettings = NeedToKnow.ProfileSettings.Groups[groupID]

    local bar
    for barID = 1, groupSettings.NumberBars do
        local barName = groupName.."Bar"..barID
        bar = _G[barName] or CreateFrame("Frame", barName, group, "NeedToKnow_BarTemplate")
        bar:SetID(barID)

        if ( barID > 1 ) then
            bar:SetPoint("TOP", _G[groupName.."Bar"..(barID-1)], "BOTTOM", 0, -NeedToKnow.ProfileSettings.BarSpacing)
        else
            bar:SetPoint("TOPLEFT", group, "TOPLEFT")
        end

        NeedToKnow.Bar_Update(groupID, barID)

        if ( not groupSettings.Enabled ) then
            NeedToKnow.ClearScripts(bar)
        end
    end

    local resizeButton = _G[groupName.."ResizeButton"]
    resizeButton:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 8, -8)

    local barID = groupSettings.NumberBars+1
    while true do
        bar = _G[groupName.."Bar"..barID]
        if bar then
            bar:Hide()
            NeedToKnow.ClearScripts(bar)
            barID = barID + 1
        else
            break
        end
    end

    if ( NeedToKnow.CharSettings["Locked"] ) then
        resizeButton:Hide()
    else
        resizeButton:Show()
    end

    -- Early enough in the loading process (before PLAYER_LOGIN), we might not
    -- know the position yet
    if groupSettings.Position then
        group:ClearAllPoints()
        local point, relativePoint, xOfs, yOfs = unpack(groupSettings.Position)
        group:SetPoint(point, UIParent, relativePoint, xOfs, yOfs)
        group:SetScale(groupSettings.Scale)
    end
    
    if ( NeedToKnow_Visible and groupSettings.Enabled ) then
        group:Show()
    else
        group:Hide()
    end
end



-- ----
-- BARS
-- ----

-- Attempt to figure out if a name is an item or a spell, and if a spell
-- try to choose a spell with that name that has a cooldown
-- This may fail for valid names if the client doesn't have the data for
-- that spell yet (just logged in or changed talent specs), in which case 
-- we mark that spell to try again later
function NeedToKnow.SetupSpellCooldown(bar, idx, barSpell)
    local isSpellID = barSpell:match("%d+") == barSpell
    if ( barSpell == "Auto Shot" or
            barSpell == NEEDTOKNOW.AUTO_SHOT or
            barSpell == "75" ) 
    then
        bar.settings.bAutoShot = true
        bar.cd_functions[idx] = NeedToKnow.GetAutoShotCooldown
    elseif not isSpellID then
        local item_id = NeedToKnow.GetItemIDString(barSpell)
        if item_id then
            bar.spells[idx] = item_id
            bar.cd_functions[idx] = NeedToKnow.GetItemCooldown
        else
            local betterSpell = barSpell
            betterSpell = NeedToKnow.TryToFindSpellWithCD(barSpell)
            if nil ~= betterSpell then
                bar.spells[idx] = betterSpell
                bar.cd_functions[idx] = NeedToKnow.GetSpellCooldown
            elseif not GetSpellCooldown(barSpell) then
                bar.cd_functions[idx] = NeedToKnow.GetUnresolvedCooldown
            end
        end
    end
end

-- Called when the configuration of the bar has changed, when the addon
-- is loaded or when ntk is locked and unlocked
function NeedToKnow.Bar_Update(groupID, barID)
    local groupSettings = NeedToKnow.ProfileSettings.Groups[groupID]

    local barName = "NeedToKnow_Group"..groupID.."Bar"..barID
    local bar = _G[barName]
    if not bar then
        -- New bar added in the UI; need to create it!
        local group = _G["NeedToKnow_Group"..groupID]
        bar = CreateFrame("Button", barName, group, "NeedToKnow_BarTemplate")
        if barID > 1 then
            bar:SetPoint("TOPLEFT", "NeedToKnow_Group"..groupID.."Bar"..(barID-1), "BOTTOMLEFT", 0, 0)
        else
            bar:SetPoint("TOPLEFT", "NeedToKnow_Group"..groupID, "TOPLEFT")
        end
        bar:SetPoint("RIGHT", group, "RIGHT", 0, 0)
        --trace("Creating bar for", groupID, barID)
    end

    local background = _G[barName.."Background"]
    bar.spark = _G[barName.."Spark"]
    bar.text = _G[barName.."Text"]
    bar.time = _G[barName.."Time"]
    bar.bar1 = _G[barName.."Texture"]

    local barSettings = groupSettings["Bars"][barID]
    if not barSettings then
        --trace("Adding bar settings for", groupID, barID)
        barSettings = CopyTable(NEEDTOKNOW.BAR_DEFAULTS)
        groupSettings.Bars[barID] = CopyTable(NEEDTOKNOW.BAR_DEFAULTS)
    end
    bar.auraName = barSettings.AuraName
    
    if ( barSettings.BuffOrDebuff == "BUFFCD" or
         barSettings.BuffOrDebuff == "TOTEM" or
         barSettings.BuffOrDebuff == "USABLE" or
         barSettings.BuffOrDebuff == "EQUIPSLOT" or
         barSettings.BuffOrDebuff == "CASTCD") 
    then
        barSettings.Unit = "player"
    end

    bar.settings = barSettings
    bar.unit = barSettings.Unit
    bar.nextUpdate = GetTime() + NEEDTOKNOW.UPDATE_INTERVAL

    bar.fixedDuration = tonumber(groupSettings.FixedDuration)
    if ( not bar.fixedDuration or 0 >= bar.fixedDuration ) then
        bar.fixedDuration = nil
    end

    bar.max_value = 1
    SetStatusBarValue(bar,bar.bar1,1)
    bar.bar1:SetTexture(NeedToKnow.LSM:Fetch("statusbar", NeedToKnow.ProfileSettings["BarTexture"]))
    if ( bar.bar2 ) then
        bar.bar2:SetTexture(NeedToKnow.LSM:Fetch("statusbar", NeedToKnow.ProfileSettings["BarTexture"]))
    end
    local fontPath = NeedToKnow.LSM:Fetch("font", NeedToKnow.ProfileSettings["BarFont"])
    if ( fontPath ) then
        bar.text:SetFont(fontPath, NeedToKnow.ProfileSettings["FontSize"])
        bar.time:SetFont(fontPath, NeedToKnow.ProfileSettings["FontSize"])
    end
    
    bar:SetWidth(groupSettings.Width)
    bar.text:SetWidth(groupSettings.Width-60)
    NeedToKnow.SizeBackground(bar, barSettings.show_icon)

    background:SetHeight(bar:GetHeight() + 2*NeedToKnow.ProfileSettings["BarPadding"])
    background:SetVertexColor(unpack(NeedToKnow.ProfileSettings["BkgdColor"]))

    -- Set up the Visual Cast Time overlay.  It isn't a part of the template 
    -- because most bars won't use it and thus don't need to pay the cost of
    -- a hidden frame
    if ( barSettings.vct_enabled ) then
        if ( nil == bar.vct ) then
            bar.vct = bar:CreateTexture(barName.."VisualCast", "ARTWORK")
            bar.vct:SetPoint("TOPLEFT", bar, "TOPLEFT")
        end
        local argb = barSettings.vct_color
        bar.vct:SetTexture(argb.r, argb.g, argb.b, argb.a )
        bar.vct:SetBlendMode("ADD")
        bar.vct:SetHeight(bar:GetHeight())
    elseif (nil ~= bar.vct) then
        bar.vct:Hide()
    end
    
    if ( barSettings.show_icon ) then
        if ( not bar.icon ) then
            bar.icon = bar:CreateTexture(bar:GetName().."Icon", "ARTWORK")
        end
        local size = bar:GetHeight()
        bar.icon:SetWidth(size)
        bar.icon:SetHeight(size)
        bar.icon:ClearAllPoints()
        bar.icon:SetPoint("TOPRIGHT", bar, "TOPLEFT", -NeedToKnow.ProfileSettings["BarPadding"], 0)
        bar.icon:Show()
    elseif (bar.icon) then
        bar.icon:Hide()
    end

    if ( NeedToKnow.CharSettings["Locked"] ) then
        local enabled = groupSettings.Enabled and barSettings.Enabled
        if enabled then
            -- Set up the bar to be functional
            -- click through
            bar:EnableMouse(0)

            -- Split the spell names    
            bar.spells = {}
            bar.cd_functions = {}
            for barSpell in bar.auraName:gmatch("([^,]+)") do
                barSpell = strtrim(barSpell)
                table.insert(bar.spells, barSpell)
            end

            -- split the user name overrides
            bar.spell_names = {}
            for un in barSettings.show_text_user:gmatch("([^,]+)") do
                un = strtrim(un)
                table.insert(bar.spell_names, un)
            end

            -- split the "reset" spells (for internal cooldowns which reset when the player gains an aura)
            if barSettings.buffcd_reset_spells and barSettings.buffcd_reset_spells ~= "" then
                bar.reset_spells = {}
                bar.reset_start = {}
                for resetSpell in barSettings.buffcd_reset_spells:gmatch("([^,]+)") do
                    resetSpell = strtrim(resetSpell)
                    table.insert(bar.reset_spells, resetSpell)
                    table.insert(bar.reset_start, 0)
                end
            else
                bar.reset_spells = nil
                bar.reset_start = nil
            end

            barSettings.bAutoShot = nil
            
            -- Determine which helper functions to use
            if     "BUFFCD" == barSettings.BuffOrDebuff then
                bar.fnCheck = NeedToKnow.AuraCheck_BUFFCD
            elseif "TOTEM" == barSettings.BuffOrDebuff then
                bar.fnCheck = NeedToKnow.AuraCheck_TOTEM
            elseif "USABLE" == barSettings.BuffOrDebuff then
                bar.fnCheck = NeedToKnow.AuraCheck_USABLE
            elseif "EQUIPSLOT" == barSettings.BuffOrDebuff then
                bar.fnCheck = NeedToKnow.AuraCheck_EQUIPSLOT
            elseif "CASTCD" == barSettings.BuffOrDebuff then
                bar.fnCheck = NeedToKnow.AuraCheck_CASTCD
                for idx, barSpell in ipairs(bar.spells) do
                    table.insert(bar.cd_functions, NeedToKnow.GetSpellCooldown)
                    NeedToKnow.SetupSpellCooldown(bar, idx, barSpell)
                end
            elseif "mhand" == barSettings.Unit or "ohand" == barSettings.Unit then
                bar.fnCheck = NeedToKnow.AuraCheck_Weapon
            elseif barSettings.show_all_stacks then
                bar.fnCheck = NeedToKnow.AuraCheck_AllStacks
            else
                bar.fnCheck = NeedToKnow.AuraCheck_Single
            end
        
            if ( barSettings.BuffOrDebuff == "BUFFCD" ) then
                local dur = tonumber(barSettings.buffcd_duration)
                if (not dur or dur < 1) then
                    print("Internal cooldown bar watching",barSettings.AuraName,"did not set a cooldown duration.  Disabling the bar")
                    enabled = false
                end
            end
        
            NeedToKnow.SetScripts(bar)
            -- Events were cleared while unlocked, so need to check the bar again now
            NeedToKnow.Bar_AuraCheck(bar)
        else
            NeedToKnow.ClearScripts(bar)
            bar:Hide()
        end
    else
        NeedToKnow.ClearScripts(bar)
        -- Set up the bar to be configured
        bar:EnableMouse(1)

        bar.bar1:SetVertexColor(barSettings.BarColor.r, barSettings.BarColor.g, barSettings.BarColor.b)
        bar.bar1:SetAlpha(barSettings.BarColor.a)
        bar:Show()
        bar.spark:Hide()
        bar.time:Hide()
        if ( bar.icon ) then
            bar.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        end
        if ( bar.vct ) then
            bar.vct:SetWidth( bar:GetWidth() / 16)
            bar.vct:Show()
        end
        if ( bar.bar2 ) then
            bar.bar2:Hide()
        end
        
        local txt=""
        if ( barSettings.show_mypip ) then
            txt = txt.."* "
        end

        if ( barSettings.show_text ) then
            if "" ~= barSettings.show_text_user then
                txt = barSettings.show_text_user
            else
                txt = txt .. NeedToKnow.PrettyName(barSettings)
            end

            if ( barSettings.append_cd
                 and (barSettings.BuffOrDebuff == "CASTCD"
                   or barSettings.BuffOrDebuff == "BUFFCD"
                   or barSettings.BuffOrDebuff == "EQUIPSLOT" ) )
            then
                txt = txt .. " CD"
            elseif ( barSettings.append_usable
                 and barSettings.BuffOrDebuff == "USABLE" )
            then
                txt = txt .. " Usable"
            end
            if ( barSettings.bDetectExtends == true ) then
                txt = txt .. " + 3s"
            end
        end
        bar.text:SetText(txt)

        if ( barSettings.Enabled ) then
            bar:SetAlpha(1)
        else
            bar:SetAlpha(0.4)
        end
    end
end


function NeedToKnow.CheckCombatLogRegistration(bar, force)
    if UnitExists(bar.unit) then
        bar:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    else
        bar:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end


function NeedToKnow.SetScripts(bar)
    bar:SetScript("OnEvent", NeedToKnow.Bar_OnEvent)
    bar:SetScript("OnUpdate", NeedToKnow.Bar_OnUpdate)
    if ( "TOTEM" == bar.settings.BuffOrDebuff ) then
        bar:RegisterEvent("PLAYER_TOTEM_UPDATE")
    elseif ( "CASTCD" == bar.settings.BuffOrDebuff ) then
        if ( bar.settings.bAutoShot ) then
            bar:RegisterEvent("START_AUTOREPEAT_SPELL")
            bar:RegisterEvent("STOP_AUTOREPEAT_SPELL")
        end
        bar:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
        bar:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    elseif ( "EQUIPSLOT" == bar.settings.BuffOrDebuff ) then
        bar:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    elseif ( "USABLE" == bar.settings.BuffOrDebuff ) then
        bar:RegisterEvent("SPELL_UPDATE_USABLE")
    elseif ( "mhand" == bar.settings.Unit or "ohand" == bar.settings.Unit ) then
        bar:RegisterEvent("UNIT_INVENTORY_CHANGED")
    elseif ( bar.unit == "targettarget" ) then
        -- WORKAROUND: PLAYER_TARGET_CHANGED happens immediately, UNIT_TARGET every couple seconds
        bar:RegisterEvent("PLAYER_TARGET_CHANGED")
        bar:RegisterEvent("UNIT_TARGET")
        -- WORKAROUND: Don't get UNIT_AURA for targettarget
        NeedToKnow.CheckCombatLogRegistration(bar)
    else
        bar:RegisterEvent("UNIT_AURA")
        if ( bar.unit == "focus" ) then
            bar:RegisterEvent("PLAYER_FOCUS_CHANGED")
        elseif ( bar.unit == "target" ) then
            bar:RegisterEvent("PLAYER_TARGET_CHANGED")
        elseif ( bar.unit == "pet" ) then
            bar:RegisterEvent("UNIT_PET")
        end
    end
    
    if bar.settings.bDetectExtends then
        bar:RegisterEvent("UNIT_SPELLCAST_SENT")
    end
    if bar.settings.blink_enabled and bar.settings.blink_boss then
        if not NeedToKnow.BossStateBars then
            NeedToKnow.BossStateBars = {}
        end
        NeedToKnow.BossStateBars[bar] = 1;
    end
end

function NeedToKnow.ClearScripts(bar)
    bar:SetScript("OnEvent", nil)
    bar:SetScript("OnUpdate", nil)
    bar:UnregisterEvent("PLAYER_TARGET_CHANGED")
    bar:UnregisterEvent("PLAYER_FOCUS_CHANGED")
    bar:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    bar:UnregisterEvent("PLAYER_TOTEM_UPDATE")
    bar:UnregisterEvent("UNIT_AURA")
    bar:UnregisterEvent("UNIT_INVENTORY_CHANGED")
    bar:UnregisterEvent("UNIT_TARGET")
    bar:UnregisterEvent("UNIT_SPELLCAST_SENT")
    bar:UnregisterEvent("START_AUTOREPEAT_SPELL")
    bar:UnregisterEvent("STOP_AUTOREPEAT_SPELL")
    bar:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    if NeedToKnow.BossStateBars then
        NeedToKnow.BossStateBars[bar] = nil;
    end
end

function NeedToKnow.Bar_OnMouseUp(self, button)
    if ( button == "RightButton" ) then
        PlaySound("UChatScrollButton");
        NeedToKnowRMB.ShowMenu(self);
     end
end

function NeedToKnow.Bar_OnSizeChanged(self)
    if (self.bar1.cur_value) then SetStatusBarValue(self, self.bar1, self.bar1.cur_value) end
    if (self.bar2 and self.bar2.cur_value) then SetStatusBarValue(self, self.bar2, self.bar2.cur_value, self.bar1.cur_value) end
end

function NeedToKnow.Bar_OnEvent(self, event, unit, ...)
    if ( event == "COMBAT_LOG_EVENT_UNFILTERED") then
        local combatEvent = select(1, ...)

        if ( NEEDTOKNOW.AURAEVENTS[combatEvent] ) then
            local guidTarget = select(7, ...)
            if ( guidTarget == UnitGUID(self.unit) ) then
                local idSpell, nameSpell = select(11, ...)
                if (self.auraName:find(idSpell) or
                     self.auraName:find(nameSpell)) 
                then 
                    NeedToKnow.Bar_AuraCheck(self)
                end
            end
        elseif ( combatEvent == "UNIT_DIED" ) then
            local guidDeceased = select(7, ...) 
            if ( guidDeceased == UnitGUID(self.unit) ) then
                NeedToKnow.Bar_AuraCheck(self)
            end
        end 
    elseif ( event == "PLAYER_TOTEM_UPDATE"  ) or
           ( event == "ACTIONBAR_UPDATE_COOLDOWN" ) or
           ( event == "SPELL_UPDATE_COOLDOWN" ) or
           ( event == "SPELL_UPDATE_USABLE" )  
    then
        NeedToKnow.Bar_AuraCheck(self)
    elseif ( event == "UNIT_AURA" ) and ( unit == self.unit ) then
        NeedToKnow.Bar_AuraCheck(self)
    elseif ( event == "UNIT_INVENTORY_CHANGED" and unit == "player" ) then
        NeedToKnow.UpdateWeaponEnchants()
        NeedToKnow.Bar_AuraCheck(self)
    elseif ( event == "PLAYER_TARGET_CHANGED" ) or ( event == "PLAYER_FOCUS_CHANGED" ) then
        if self.unit == "targettarget" then
            NeedToKnow.CheckCombatLogRegistration(self)
        end
        NeedToKnow.Bar_AuraCheck(self)
    elseif ( event == "UNIT_TARGET" and unit == "target" ) then 
        if self.unit == "targettarget" then
            NeedToKnow.CheckCombatLogRegistration(self)
        end
        NeedToKnow.Bar_AuraCheck(self)
    elseif ( event == "UNIT_PET" and unit == "player" ) then
        NeedToKnow.Bar_AuraCheck(self)
    elseif ( event == "UNIT_SPELLCAST_SENT" ) then
        local spell = select(1, ...)
        if ( self.settings.bDetectExtends ) then
            -- FIXME: This really does not belong on the individual bar
            if unit == "player" then --and self.buffName == spell then
                local r = NeedToKnow.last_cast[spell]
                if ( r and r.state == 0 ) then
                    r.state = 1
                    NeedToKnow.nSent = NeedToKnow.nSent + 1
                    NeedToKnow_ExecutiveFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
                end
            end
        end
    elseif ( event == "START_AUTOREPEAT_SPELL" ) then
        self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    elseif ( event == "STOP_AUTOREPEAT_SPELL" ) then
        self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    elseif ( event == "UNIT_SPELLCAST_SUCCEEDED" ) then
        local spell = select(1,...)
        if ( self.settings.bAutoShot and unit == "player" and spell == NEEDTOKNOW.AUTO_SHOT ) then
            local interval = UnitRangedDamage("player")
            self.tAutoShotCD = interval
            self.tAutoShotStart = GetTime()
            NeedToKnow.Bar_AuraCheck(self)
        end
    end
end



-- AuraCheck calls on this to compute the "text" of the bar
-- It is separated out like this in part to be hooked by other addons
function NeedToKnow.ComputeBarText(buffName, count, extended)
    local text
    if ( count > 1 ) then
        text = buffName.."  ["..count.."]"
    else
        text = buffName
    end
    if ( extended and extended > 1 ) then
        text = text .. string.format(" + %.0fs", extended)
    end
    return text
end

-- Called by NeedToKnow.UpdateVCT, which is called from AuraCheck and possibly 
-- by Bar_Update depending on vct_refresh. In addition to refactoring out some 
-- code from the long AuraCheck, this also provides a convenient hook for other addons
function NeedToKnow.ComputeVCTDuration(bar)
    local vct_duration = 0
    
    local spellToTime = bar.settings.vct_spell
    if ( nil == spellToTime or "" == spellToTime ) then
        spellToTime = bar.buffName
    end
    local _, _, _, _, _, _, castTime = GetSpellInfo(spellToTime)

    if ( castTime ) then
        vct_duration = castTime / 1000
        bar.vct_refresh = true
    else
        bar.vct_refresh = false
    end
    
    if ( bar.settings.vct_extra ) then
        vct_duration =  vct_duration + bar.settings.vct_extra
    end
    return vct_duration
end

function NeedToKnow.UpdateVCT(bar)
    local vct_duration = NeedToKnow.ComputeVCTDuration(bar)

    local dur = bar.fixedDuration or bar.duration
    if ( dur ) then
        vct_width =  (vct_duration * bar:GetWidth()) / dur
        if (vct_width > bar:GetWidth()) then
            vct_width = bar:GetWidth() 
        end
    else
        vct_width = 0
    end

    if ( vct_width > 1 ) then
        bar.vct:SetWidth(vct_width)
        bar.vct:Show()
    else
        bar.vct:Hide()
    end
end

function NeedToKnow.SizeBackground(bar, i_show_icon)
    local background = _G[bar:GetName() .. "Background"]
    local bgWidth = bar:GetWidth() + 2*NeedToKnow.ProfileSettings["BarPadding"]
    local y = NeedToKnow.ProfileSettings["BarPadding"]
    local x = -y
    background:ClearAllPoints()

    if ( i_show_icon ) then
        local iconExtra = bar:GetHeight() + NeedToKnow.ProfileSettings["BarPadding"]
        bgWidth = bgWidth + iconExtra
        x = x - iconExtra
    end
    background:SetWidth(bgWidth)
    background:SetPoint("TOPLEFT", bar, "TOPLEFT", x, y)
end

function NeedToKnow.CreateBar2(bar)
    if ( not bar.bar2 ) then
        local n = bar:GetName() .. "Bar2"
        bar.bar2 = bar:CreateTexture(n, "BORDER")
        bar.bar2:SetPoint("TOPLEFT", bar.bar1, "TOPRIGHT")
        bar.bar2:SetPoint("BOTTOM", bar, "BOTTOM")
        bar.bar2:SetWidth(bar:GetWidth())
    end
end

function NeedToKnow.PrettyName(barSettings)
    if ( barSettings.BuffOrDebuff == "EQUIPSLOT" ) then
        return NEEDTOKNOW.ITEM_NAMES[tonumber(barSettings.AuraName)]
    else
        return barSettings.AuraName
    end
end

function NeedToKnow.ConfigureVisibleBar(bar, count, extended)
    local text = ""
    if ( bar.settings.show_icon and bar.iconPath and bar.icon ) then
        bar.icon:SetTexture(bar.iconPath)
        bar.icon:Show()
        NeedToKnow.SizeBackground(bar, true)
    elseif bar.icon then
        bar.icon:Hide()
        NeedToKnow.SizeBackground(bar, false)
    end

    bar.bar1:SetVertexColor(bar.settings.BarColor.r, bar.settings.BarColor.g, bar.settings.BarColor.b)
    bar.bar1:SetAlpha(bar.settings.BarColor.a)
    if ( bar.max_expirationTime and bar.max_expirationTime ~= bar.expirationTime ) then 
        NeedToKnow.CreateBar2(bar)
        bar.bar2:SetTexture(bar.bar1:GetTexture())
        bar.bar2:SetVertexColor(bar.settings.BarColor.r, bar.settings.BarColor.g, bar.settings.BarColor.b)
        bar.bar2:SetAlpha(bar.settings.BarColor.a * 0.5)
        bar.bar2:Show()
    elseif (bar.bar2) then
        bar.bar2:Hide()
    end
    
    local txt = ""
    if ( bar.settings.show_mypip ) then
        txt = txt .. "* "
    end

    if ( bar.settings.show_text ) then
        local n = bar.buffName
        if "" ~= bar.settings.show_text_user then
            local idx=bar.idxName
            if idx > #bar.spell_names then idx = #bar.spell_names end
            n = bar.spell_names[idx]
        end
        local c = count
        if not bar.settings.show_count then
            c = 1
        end
        txt = txt .. NeedToKnow.ComputeBarText(n, c, extended)
    end
    if ( bar.settings.append_cd 
         and (bar.settings.BuffOrDebuff == "CASTCD" 
           or bar.settings.BuffOrDebuff == "BUFFCD"
           or bar.settings.BuffOrDebuff == "EQUIPSLOT" ) ) 
    then
        txt = txt .. " CD"
    elseif (bar.settings.append_usable and bar.settings.BuffOrDebuff == "USABLE" ) then
        txt = txt .. " Usable"
    end
    bar.text:SetText(txt)
        
    -- Is this an aura with a finite duration?
    local vct_width = 0
    if ( bar.duration > 0 ) then
        -- Configure the main status bar
        local duration = bar.fixedDuration or bar.duration
        bar.max_value = duration

        -- Determine the size of the visual cast bar
        if ( bar.settings.vct_enabled ) then
            NeedToKnow.UpdateVCT(bar)
        end
        
        -- Force an update to get all the bars to the current position (sharing code)
        -- This will call UpdateVCT again, but that seems ok
        bar.nextUpdate = -NEEDTOKNOW.UPDATE_INTERVAL
        if bar.expirationTime > GetTime() then
            NeedToKnow.Bar_OnUpdate(bar, 0)
        end

        bar.time:Show()
    else
        -- Hide the time text and spark for auras with "infinite" duration
        bar.max_value = 1
        SetStatusBarValue(bar,bar.bar1,1)
        if bar.bar2 then SetStatusBarValue(bar,bar.bar2,1) end

        bar.time:Hide()
        bar.spark:Hide()

        if ( bar.vct ) then
            bar.vct:Hide()
        end
    end
end

function NeedToKnow.ConfigureBlinkingBar(bar)
    local settings = bar.settings
    if ( not bar.blink ) then
        bar.blink=true
        bar.blink_phase=1
        bar.bar1:SetVertexColor(settings.MissingBlink.r, settings.MissingBlink.g, settings.MissingBlink.b)
        bar.bar1:SetAlpha(settings.MissingBlink.a)
    end
    bar.text:SetText(settings.blink_label)
    bar.time:Hide()
    bar.spark:Hide()
    bar.max_value = 1
    SetStatusBarValue(bar,bar.bar1,1)
    
    if ( bar.icon ) then
        bar.icon:Hide()
        NeedToKnow.SizeBackground(bar, false)
    end
    if ( bar.bar2 ) then
        bar.bar2:Hide()
    end
end

function NeedToKnow.GetUtilityTooltips()
    if ( not NeedToKnow_Tooltip1 ) then
        for idxTip = 1,2 do
            local ttname = "NeedToKnow_Tooltip"..idxTip
            local tt = CreateFrame("GameTooltip", ttname)
            tt:SetOwner(UIParent, "ANCHOR_NONE")
            tt.left = {}
            tt.right = {}
            -- Most of the tooltip lines share the same text widget,
            -- But we need to query the third one for cooldown info
            for i = 1, 30 do
                tt.left[i] = tt:CreateFontString()
                tt.left[i]:SetFontObject(GameFontNormal)
                if i < 5 then
                    tt.right[i] = tt:CreateFontString()
                    tt.right[i]:SetFontObject(GameFontNormal)
                    tt:AddFontStrings(tt.left[i], tt.right[i])
                else
                    tt:AddFontStrings(tt.left[i], tt.right[4])
                end
            end 
         end
    end
    local tt1,tt2 = NeedToKnow_Tooltip1, NeedToKnow_Tooltip2
    
    tt1:ClearLines()
    tt2:ClearLines()
    return tt1,tt2
end

function NeedToKnow.DetermineTempEnchantFromTooltip(i_invID)
    local tt1,tt2 = NeedToKnow.GetUtilityTooltips()
    
    tt1:SetInventoryItem("player", i_invID)
    local n,h = tt1:GetItem()

    tt2:SetHyperlink(h)
    
    -- Look for green lines present in tt1 that are missing from tt2
    local nLines1, nLines2 = tt1:NumLines(), tt2:NumLines()
    local i1, i2 = 1,1
    while ( i1 <= nLines1 ) do
        local txt1 = tt1.left[i1]
        if ( txt1:GetTextColor() ~= 0 ) then
            i1 = i1 + 1
        elseif ( i2 <= nLines2 ) then
            local txt2 = tt2.left[i2]
            if ( txt2:GetTextColor() ~= 0 ) then
                i2 = i2 + 1
            elseif (txt1:GetText() == txt2:GetText()) then
                i1 = i1 + 1
                i2 = i2 + 1
            else
                break
            end
        else
            break
        end
    end
    if ( i1 <= nLines1 ) then
        local line = tt1.left[i1]:GetText()
        local paren = line:find("[(]")
        if ( paren ) then
            line = line:sub(1,paren-2)
        end
        return line
    end    
end



-- Looks at the tooltip for the given spell to see if a cooldown 
-- is listed with a duration in seconds.  Longer cooldowns don't
-- need this logic, so we don't need to do unit conversion
function NeedToKnow.DetermineShortCooldownFromTooltip(spell)
    if not NeedToKnow.short_cds then
        NeedToKnow.short_cds = {}
    end
    if not NeedToKnow.short_cds[spell] then
        -- Figure out what a cooldown in seconds should look like
        local ref = SecondsToTime(10):lower()
        local unit_ref = ref:match("10 (.+)")

        -- Get the number and unit of the cooldown from the tooltip
        local tt1 = NeedToKnow.GetUtilityTooltips()
        local lnk = GetSpellLink(spell)
        local cd, n_cd, unit_cd
        if lnk and lnk ~= "" then
            tt1:SetHyperlink( lnk )
            
            for iTT=3,2,-1 do
                cd = tt1.right[iTT]:GetText()
                if cd then 
                    cd = cd:lower()
                    n_cd, unit_cd = cd:match("(%d+) (.+) ")
                end
                if n_cd then break end
            end
        end

        -- unit_ref will be "|4sec:sec;" in english, so do a find rather than a ==
        if not n_cd then 
            -- If we couldn't parse the tooltip, assume there's no cd
            NeedToKnow.short_cds[spell] = 0
        elseif unit_ref:find(unit_cd) then
            NeedToKnow.short_cds[spell] = tonumber(n_cd)
        else
            -- Not a short cooldown.  Record it as a minute
            NeedToKnow.short_cds[spell] = 60
        end
    end

    return NeedToKnow.short_cds[spell]
end


-- Search the player's spellbook for a spell that matches 
-- todo: cache this result?
function NeedToKnow.TryToFindSpellWithCD(barSpell)
    if NeedToKnow.DetermineShortCooldownFromTooltip(barSpell) > 0 then return barSpell end
    
    for iBook = 1, GetNumSpellTabs() do
        local sBook,_,iFirst,nSpells = GetSpellTabInfo(iBook)
        for iSpell=iFirst+1, iFirst+nSpells do
            local sName = GetSpellInfo(iSpell, sBook)
            if sName == barSpell then
                local sLink = GetSpellLink(iSpell, sBook)
                local sID = sLink:match("spell:(%d+)")
                local start = GetSpellCooldown(sID)
                if start then
                    local ttcd = NeedToKnow.DetermineShortCooldownFromTooltip(sID)
                    if ttcd and ttcd>0 then
                        return sID
                    end
                end
            end
        end
    end
end


function NeedToKnow.GetItemIDString(id_or_name)
    local _, link = GetItemInfo(id_or_name)
    if link then
        local idstring = link:match("item:(%d+):")
        if idstring then
            return idstring
        end
    end
end


-- Helper for NeedToKnow.AuraCheck_CASTCD which gets the autoshot cooldown
function NeedToKnow.GetAutoShotCooldown(bar)
    local tNow = GetTime()
    if ( bar.tAutoShotStart and bar.tAutoShotStart + bar.tAutoShotCD > tNow ) then
        local n, icon = GetSpellInfo(75)
        return bar.tAutoShotStart, bar.tAutoShotCD, 1, NEEDTOKNOW.AUTO_SHOT, icon
    else
        bar.tAutoShotStart = nil
    end
end


-- Helper for NeedToKnow.AuraCheck_CASTCD for names we haven't figured out yet
function NeedToKnow.GetUnresolvedCooldown(bar, barSpell, idxName)
    NeedToKnow.SetupSpellCooldown(bar, idxName, barSpell)
    local fn = bar.cd_functions[idxName]
    if NeedToKnow.GetUnresolvedCooldown ~= fn then
        -- Have to re-evaluate barSpell since SetupSpellCooldown may have changed bar.spells
        return fn(bar, bar.spells[idxName], idxName)
    end
end


-- Wrapper around GetSpellCooldown with extra sauce
-- Expected to return start, cd_len, enable, buffName, iconpath
function NeedToKnow.GetSpellCooldown(bar, barSpell)
    local start, cd_len, enable = GetSpellCooldown(barSpell)
    if start and start > 0 then
        local spellName, spellRank, spellIconPath, _, _, spellPower = GetSpellInfo(barSpell)
        if not spellName then 
            if not NeedToKnow.GSIBroken then 
                NeedToKnow.GSIBroken = {} 
            end
            if  not NeedToKnow.GSIBroken[barSpell] then
                print("NeedToKnow: Warning! Unable to get spell info for "..barSpell..".  Try using Spell ID instead.")
                NeedToKnow.GSIBroken[barSpell] = true;
            end
            spellName = barSpell
        end

        if 0 == enable then 
            -- Filter out conditions like Stealth while stealthed
            start = nil
        elseif spellPower == 5 then -- Rune
            -- Filter out rune cooldown artificially extending the cd
            if cd_len <= 10 then
                local tNow = GetTime()
                if bar.expirationTime and tNow < bar.expirationTime then
                    -- We've already seen the correct CD for this; keep using it
                    start = bar.expirationTime - bar.duration
                    cd_len = bar.duration
                elseif NeedToKnow.last_sent and NeedToKnow.last_sent[barSpell] and NeedToKnow.last_sent[barSpell] > (tNow - 1.5) then
                    -- We think the spell was just cast, and a CD just started but it's short.
                    -- Look at the tooltip to tell what the correct CD should be. If it's supposed
                    -- to be short (Ghoul Frenzy, Howling Blast), then start a CD bar
                    cd_len = NeedToKnow.DetermineShortCooldownFromTooltip(barSpell)
                    if cd_len == 0 or cd_len > 10 then
                        start = nil
                    end
                else
                    start = nil
                end
            end
        end
        
        if start then
            return start, cd_len, enable, spellName, spellIconPath
        end
    end
end



-- Wrapper around GetItemCooldown
-- Expected to return start, cd_len, enable, buffName, iconpath
function NeedToKnow.GetItemCooldown(bar, item_id, idx)
    local start, cd_len, enable = GetItemCooldown(item_id)
    if start then
        local name, _, _, _, _, _, _, _, icon = GetItemInfo(item_id)
        return start, cd_len, enable, name, icon
    end
end


-- Scrapes the current tooltips for the player's weapons to tease out
-- the name of the current weapon imbue (and not just the name of the 
-- weapon, like you get from the Blizzard API.)  This info gets cached
-- on the bar so we don't have to compute it every Bar_AuraCheck
function NeedToKnow.UpdateWeaponEnchants()
    local mdata = NeedToKnow.weapon_enchants.mhand
    local odata = NeedToKnow.weapon_enchants.ohand

    mdata.present, mdata.expiration, mdata.charges, 
      odata.present, odata.expiration, odata.charges 
      = GetWeaponEnchantInfo()
      
    if ( mdata.present ) then
       local oldname = mdata.name
       mdata.name = NeedToKnow.DetermineTempEnchantFromTooltip(16)
       if not mdata.name then
           mdata.name = "Unknown"
           print("Warning: NTK couldn't figure out what enchant is on the main hand weapon")
       end
       mdata.expiration = GetTime() + mdata.expiration/1000
       if oldname ~= mdata.name then
         _,_,mdata.icon = GetSpellInfo(mdata.name)
       end
    else
        mdata.name=nil
    end

    if ( odata.present ) then
       local oldname = odata.name
       odata.name = NeedToKnow.DetermineTempEnchantFromTooltip(17)
       if not odata.name then
           odata.name = "Unknown"
           print("Warning: NTK couldn't figure out what enchant is on the off-hand weapon")
       end
       odata.expiration = GetTime() + odata.expiration/1000
       if oldname ~= odata.name then
         _,_,odata.icon = GetSpellInfo(odata.name)
       end
    else
        odata.name = nil
    end
end


local function AddInstanceToStacks(all_stacks, bar_entry, duration, name, count, expirationTime, iconPath, caster)
    if duration then
        if (not count or count < 1) then count = 1 end
        if ( 0 == all_stacks.total or all_stacks.min.expirationTime > expirationTime ) then
            all_stacks.min.idxName = bar_entry.idxName
            all_stacks.min.buffName = name
            all_stacks.min.caster = caster
            all_stacks.min.duration = duration
            all_stacks.min.expirationTime = expirationTime
            all_stacks.min.iconPath = iconPath
        end
        if ( 0 == all_stacks.total or all_stacks.max.expirationTime < expirationTime ) then
            all_stacks.max.duration = duration
            all_stacks.max.expirationTime = expirationTime
        end 
        all_stacks.total = all_stacks.total + count
    end
end


-- Bar_AuraCheck helper for Totem bars, this returns data if
-- a totem matching barSpell is currently out. 
function NeedToKnow.AuraCheck_TOTEM(bar, bar_entry, all_stacks)
    local idxName, barSpell, isSpellID = bar_entry.idxName, bar_entry.barSpell, bar_entry.isSpellID
    local spellName, spellRank, spellIconPath
    if ( isSpellID ) then
        spellName, spellRank, spellIconPath = GetSpellInfo(barSpell)
    end
    for iSlot=1, 4 do
        local haveTotem, totemName, startTime, totemDuration, totemIcon = GetTotemInfo(iSlot)
        local sComp = barSpell
        if isSpellID then sComp = spellName end
        if ( totemName and totemName:find(sComp) ) then
            -- WORKAROUND: The startTime reported here is both cast to an int and off by 
            -- a latency meaning it can be significantly low.  So we cache the GetTime 
            -- that the totem actually appeared, so long as GetTime is reasonably close to 
            -- startTime (since the totems may have been out for awhile before this runs.)
            if ( not NeedToKnow.totem_drops[iSlot] or 
                 NeedToKnow.totem_drops[iSlot] < startTime ) 
            then
                local precise = GetTime()
                if ( precise - startTime > 1 ) then
                    precise = startTime + 1
                end
                NeedToKnow.totem_drops[iSlot] = precise
            end

            AddInstanceToStacks(all_stacks, bar_entry, 
                   totemDuration,                              -- duration
                   totemName,                                  -- name
                   1,                                          -- count
                   NeedToKnow.totem_drops[iSlot] + totemDuration, -- expiration time
                   totemIcon,                                  -- icon path
                   "player" )                                  -- caster
        end
    end
end




-- Bar_AuraCheck helper for tracking usable gear based on the slot its in
-- rather than the equipment name
function NeedToKnow.AuraCheck_EQUIPSLOT(bar, bar_entry, all_stacks)
    local idxName, barSpell, isSpellID = bar_entry.idxName, bar_entry.barSpell, bar_entry.isSpellID
    local spellName, spellRank, spellIconPath
    if ( isSpellID ) then
        local slot = tonumber(bar_entry.barSpell)
        local id = GetInventoryItemID("player",slot)
        if id then
            local start, cd_len, enable, name, icon = NeedToKnow.GetItemCooldown(bar, id, idx)

            if ( start and start > 0 ) then
                AddInstanceToStacks(all_stacks, bar_entry, 
                       cd_len,                                     -- duration
                       name,                                       -- name
                       1,                                          -- count
                       start + cd_len,                             -- expiration time
                       icon,                                       -- icon path
                       "player" )                                  -- caster
            end
        end
    end
end



-- Bar_AuraCheck helper that checks the bar.weapon_enchants 
-- (computed by UpdateWeaponEnchants) for the given spell.
-- FIXME: this is the only bar type that does not work with spell ids.
function NeedToKnow.AuraCheck_Weapon(bar, bar_entry, all_stacks)
    local idxName, barSpell, isSpellID = bar_entry.idxName, bar_entry.barSpell, bar_entry.isSpellID;
    local data = NeedToKnow.weapon_enchants[bar.settings.Unit]
    if ( data.present and data.name and data.name:find(barSpell) ) then
        AddInstanceToStacks( all_stacks, bar_entry,
               1800,                                       -- duration TODO: Get real duration?
               data.name,                                  -- name
               data.charges,                               -- count
               data.expiration,                            -- expiration time
               data.icon,                                  -- icon path
               "player" )                                  -- caster
    end
end


-- Bar_AuraCheck helper that checks for spell/item use cooldowns
-- Relies on NeedToKnow.GetAutoShotCooldown, NeedToKnow.GetSpellCooldown 
-- and NeedToKnow.GetItemCooldown. Bar_Update will have already pre-processed 
-- this list so that bar.cd_functions[idxName] can do something with barSpell
function NeedToKnow.AuraCheck_CASTCD(bar, bar_entry, all_stacks)
    local idxName, barSpell, isSpellID = bar_entry.idxName, bar_entry.barSpell, bar_entry.isSpellID;
    local func = bar.cd_functions[idxName]
    local start, cd_len, should_cooldown, buffName, iconPath = func(bar, barSpell, idxName)

    -- filter out the GCD, we only care about actual spell CDs
    if start and cd_len <= 1.5 and func ~= NeedToKnow.GetAutoShotCooldown then
        if bar.expirationTime and bar.expirationTime <= (start + cd_len) then
            start = bar.expirationTime - bar.duration
            cd_len = bar.duration
        else
            start = nil
        end
    end

    if start and cd_len then
        local tNow = GetTime()
        local tEnd = start + cd_len
        if ( tEnd > tNow + 0.1 ) then
            AddInstanceToStacks( all_stacks, bar_entry,
                   cd_len,                                     -- duration
                   buffName,                                   -- name
                   1,                                          -- count
                   tEnd,                                       -- expiration time
                   iconPath,                                   -- icon path
                   "player" )                                  -- caster
        end
    end
end


-- Bar_AuraCheck helper for watching "Is Usable", which means that the action
-- bar button for the spell lights up.  This is mostly useful for Victory Rush
function NeedToKnow.AuraCheck_USABLE(bar, bar_entry, all_stacks)
    local idxName, barSpell, isSpellID = bar_entry.idxName, bar_entry.barSpell, bar_entry.isSpellID;
    local key
    local settings = bar.settings
    if ( isSpellID ) then key = tonumber(barSpell) else key = barSpell end
    if ( not key ) then key = "" end
    local spellName, _, iconPath = GetSpellInfo(key)
    if ( spellName ) then
        local isUsable, notEnoughMana = IsUsableSpell(spellName)
        if (isUsable or notEnoughMana) then
            local duration = settings.usable_duration
            local expirationTime
            local tNow = GetTime()
            if ( not bar.expirationTime or 
                 (bar.expirationTime > 0 and bar.expirationTime < tNow - 0.01) ) 
            then
                duration = settings.usable_duration
                expirationTime = tNow + duration
            else
                duration = bar.duration
                expirationTime = bar.expirationTime
            end

            AddInstanceToStacks( all_stacks, bar_entry,
                   duration,                                   -- duration
                   spellName,                                  -- name
                   1,                                          -- count
                   expirationTime,                             -- expiration time
                   iconPath,                                   -- icon path
                   "player" )                                  -- caster
        end
    end
end


-- Bar_AuraCheck helper for watching "internal cooldowns", which is like a spell
-- cooldown for spells cast automatically (procs).  The "reset on buff" logic
-- is still handled by 
function NeedToKnow.AuraCheck_BUFFCD(bar, bar_entry, all_stacks)
    local idxName, barSpell, isSpellID = bar_entry.idxName, bar_entry.barSpell, bar_entry.isSpellID;
    local buff_stacks = NeedToKnow.scratch.buff_stacks
    buff_stacks.total = 0
    NeedToKnow.AuraCheck_Single(bar, bar_entry, buff_stacks)
    local tNow = GetTime()
    if ( buff_stacks.total > 0 ) then
        if buff_stacks.max.expirationTime == 0 then
            -- TODO: This really doesn't work very well as a substitute for telling when the aura was applied
            if not bar.expirationTime then
                local nDur = tonumber(bar.settings.buffcd_duration)
                AddInstanceToStacks( all_stacks, bar_entry,
                    nDur, buff_stacks.min.buffName, 1, nDur+tNow, buff_stacks.min.iconPath, buff_stacks.min.caster )
            else
                AddInstanceToStacks( all_stacks, bar_entry,
                       bar.duration,                               -- duration
                       bar.buffName,                               -- name
                       1,                                          -- count
                       bar.expirationTime,                         -- expiration time
                       bar.iconPath,                               -- icon path
                       "player" )                                  -- caster
            end
            return
        end
        local tStart = buff_stacks.max.expirationTime - buff_stacks.max.duration
        local duration = tonumber(bar.settings.buffcd_duration)
        local expiration = tStart + duration
        if ( expiration > tNow ) then
            AddInstanceToStacks( all_stacks, bar_entry,
                   duration,                                   -- duration
                   buff_stacks.min.buffName,                                   -- name
                   -- Seeing the charges on the CD bar violated least surprise for me
                   1,                                          -- count
                   expiration,                                 -- expiration time
                   buff_stacks.min.iconPath,                   -- icon path
                   buff_stacks.min.caster )                    -- caster
        end
    elseif ( bar.expirationTime and bar.expirationTime > tNow + 0.1 ) then
        AddInstanceToStacks( all_stacks, bar_entry,
               bar.duration,                               -- duration
               bar.buffName,                               -- name
               1,                                          -- count
               bar.expirationTime,                         -- expiration time
               bar.iconPath,                               -- icon path
               "player" )                                  -- caster
    end
end


-- Bar_AuraCheck helper that looks for the first instance of a buff
-- Uses the UnitAura filters exclusively if it can
function NeedToKnow.AuraCheck_Single(bar, bar_entry, all_stacks)
    local idxName, barSpell, isSpellID = bar_entry.idxName, bar_entry.barSpell, bar_entry.isSpellID;
    local settings = bar.settings
    local filter = settings.BuffOrDebuff
    if settings.OnlyMine then
        filter = filter .. "|PLAYER"
    end

    if isSpellID then
        -- WORKAROUND: The second parameter to UnitAura can't be a spellid, so I have 
        --             to walk them all
        local barID = tonumber(barSpell)
        local j = 1
        while true do
            local buffName, _, iconPath, count, _, duration, expirationTime, caster, _, _, spellID 
              = UnitAura(bar.unit, j, filter)
            if (not buffName) then
                break
            end

            if (spellID == barID) then 
                AddInstanceToStacks( all_stacks, bar_entry,
                       duration,                               -- duration
                       buffName,                               -- name
                       count,                                  -- count
                       expirationTime,                         -- expiration time
                       iconPath,                               -- icon path
                       caster )                                -- caster
                return;
            end
            j=j+1
        end
    else
        local buffName, _ , iconPath, count, _, duration, expirationTime, caster 
          = UnitAura(bar.unit, barSpell, nil, filter)

          AddInstanceToStacks( all_stacks, bar_entry,
               duration,                               -- duration
               buffName,                               -- name
               count,                                  -- count
               expirationTime,                         -- expiration time
               iconPath,                               -- icon path
               caster )                                -- caster
    end
end


-- Bar_AuraCheck helper that updates bar.all_stacks (but returns nil)
-- by scanning all the auras on the unit
function NeedToKnow.AuraCheck_AllStacks(bar, bar_entry, all_stacks)
    local idxName, barSpell, isSpellID = bar_entry.idxName, bar_entry.barSpell, bar_entry.isSpellID;
    local j = 1
    local matchID 
    if isSpellID then matchID = tonumber(barSpell) end
    local settings = bar.settings
    local filter = settings.BuffOrDebuff
    
    while true do
        local buffName, _, iconPath, count, _, duration, expirationTime, caster, _, _, spellID 
          = UnitAura(bar.unit, j, filter)
        if (not buffName) then
            break
        end
        
        if (isSpellID and spellID == matchID) or (not isSpellID and barSpell == buffName) then
        AddInstanceToStacks(all_stacks, bar_entry, 
            duration,
            buffName,
            count,
            expirationTime,
            iconPath,
            caster )
        end

        j = j+1
    end
end


-- Called whenever the state of auras on the bar's unit may have changed
function NeedToKnow.Bar_AuraCheck(bar)
    local settings = bar.settings
    local bUnitExists, isWeapon
    if "mhand" == settings.Unit or
       "ohand" == settings.Unit then
        isWeapon = true
        bUnitExists = true
    elseif "player" == settings.Unit then
        bUnitExists = true
    else
        bUnitExists = UnitExists(settings.Unit)
    end
    
    -- Determine if the bar should be showing anything
    local all_stacks       
    local idxName, duration, buffName, count, expirationTime, iconPath, caster
    if ( bUnitExists ) then         
        all_stacks = NeedToKnow.scratch.all_stacks
        all_stacks.total = 0
        local bar_entry = NeedToKnow.scratch.bar_entry

        -- Call the helper function for each of the spells in the list
        for idx, barSpell in ipairs(bar.spells) do
            local _, nDigits = barSpell:find("^%d+")
            bar_entry.idxName = idx
            bar_entry.barSpell = barSpell
            bar_entry.isSpellID = ( nDigits == barSpell:len() )

            bar.fnCheck(bar, bar_entry, all_stacks);
            
            if all_stacks.total > 0 and not settings.show_all_stacks then
                idxName = idx
                break 
            end
        end
    end
    
    if ( all_stacks and all_stacks.total > 0 ) then
        idxName = all_stacks.min.idxName
        buffName = all_stacks.min.buffName
        caster = all_stacks.min.caster
        duration = all_stacks.max.duration
        expirationTime = all_stacks.min.expirationTime
        iconPath = all_stacks.min.iconPath
        count = all_stacks.total
    end

    -- Cancel the work done above if a reset spell is encountered
    -- (reset_spells will only be set for BUFFCD)
    if ( bar.reset_spells ) then
        local maxStart = 0
        local tNow = GetTime()
        local buff_stacks = NeedToKnow.scratch.buff_stacks
        buff_stacks.total = 0
        -- Keep track of when the reset auras were last applied to the player
        for idx, resetSpell in ipairs(bar.reset_spells) do
            local _, nDigits = resetSpell:find("^%d+")
            local bar_entry = NeedToKnow.scratch.bar_entry
            bar_entry.idxName = idx
            bar_entry.barSpell = resetSpell
            bar_entry.isSpellID = ( nDigits == resetSpell:len() )

            -- Note this relies on BUFFCD setting the target to player, and that the onlyMine will work either way
            local resetDuration, _, _, resetExpiration
              = NeedToKnow.AuraCheck_Single(bar, bar_entry, buff_stacks)
            local tStart
            if buff_stacks.total > 0 then
               if 0 == buff_stacks.max.duration then 
                   tStart = bar.reset_start[idx]
                   if 0 == tStart then
                       tStart = tNow
                   end
               else
                   tStart = buff_stacks.max.expirationTime - buff_stacks.max.duration
               end
               bar.reset_start[idx] = tStart
               
               if tStart > maxStart then maxStart = tStart end
            else
               bar.reset_start[idx] = 0
            end
        end
        if duration and maxStart > expirationTime-duration then
            duration = nil
        end
    end
    
    -- There is an aura this bar is watching! Set it up
    if ( duration ) then
        duration = tonumber(duration)
        -- Handle duration increases
        local extended
        if (settings.bDetectExtends) then
            local curStart = expirationTime - duration
            local guidTarget = UnitGUID(bar.unit)
            if ( not NeedToKnow.last_cast[buffName] ) then
                NeedToKnow.last_cast[buffName] = { state=0 }
            end
            local r = NeedToKnow.last_cast[buffName] 
            
            if ( not r[guidTarget] ) then
                r[guidTarget] = { time=curStart, dur=duration }
            elseif ( r[guidTarget].dur == 0 ) then
                r[guidTarget].dur = duration
            else
                local rStart = r[guidTarget]
                extended = expirationTime - rStart.time - rStart.dur
                if ( extended > 1 ) then
                    duration = rStart.dur 
                end
            end
        end

        --bar.duration = tonumber(bar.fixedDuration) or duration
        bar.duration = duration

        bar.expirationTime = expirationTime
        bar.idxName = idxName
        bar.buffName = buffName
        bar.iconPath = iconPath
        if ( all_stacks and all_stacks.max.expirationTime ~= expirationTime ) then
            bar.max_expirationTime = all_stacks.max.expirationTime
        else
            bar.max_expirationTime = nil
        end

        -- Mark the bar as not blinking before calling ConfigureVisibleBar, 
        -- since it calls OnUpdate which checks bar.blink
        bar.blink=false
        NeedToKnow.ConfigureVisibleBar(bar, count, extended)
        bar:Show()
    else
        if (settings.bDetectExtends and bar.buffName) then
            if ( NeedToKnow.last_cast[bar.buffName] ) then
                local guidTarget = UnitGUID(bar.unit)
                if guidTarget then
                    local r = NeedToKnow.last_cast[bar.buffName]
                    r[guidTarget] = nil
                end
            end
        end
        bar.buffName = nil
        bar.duration = nil
        bar.expirationTime = nil
        
        local bBlink = false
        if settings.blink_enabled and settings.MissingBlink.a > 0 then
            if isWeapon then
                bBlink = true
            else
                bBlink = bUnitExists and not UnitIsDead(bar.unit)
            end
        end
        if ( bBlink and not settings.blink_ooc ) then
            if not UnitAffectingCombat("player") then
                bBlink = false
            end
        end
        if ( bBlink and settings.blink_boss ) then
            if UnitIsFriend(bar.unit, "player") then
                bBlink = NeedToKnow.bCombatWithBoss
            else
                bBlink = (UnitLevel(bar.unit) == -1)
            end
        end
        if ( bBlink ) then
            NeedToKnow.ConfigureBlinkingBar(bar)
            bar:Show()
        else    
            bar.blink=false
            bar:Hide()
        end
    end
end


function NeedToKnow.Fmt_SingleUnit(i_fSeconds)
    return string.format(SecondsToTimeAbbrev(i_fSeconds))
end


function NeedToKnow.Fmt_TwoUnits(i_fSeconds)
  if ( i_fSeconds < 6040 ) then
      local nMinutes, nSeconds
      nMinutes = floor(i_fSeconds / 60)
      nSeconds = floor(i_fSeconds - nMinutes*60)
      return string.format("%02d:%02d", nMinutes, nSeconds)
  else
      string.format(SecondsToTimeAbbrev(i_fSeconds))
  end
end

function NeedToKnow.Fmt_Float(i_fSeconds)
  return string.format("%0.1f", i_fSeconds)
end

function NeedToKnow.Bar_OnUpdate(self, elapsed)
    local now = GetTime()
    if ( now > self.nextUpdate ) then
        self.nextUpdate = now + NEEDTOKNOW.UPDATE_INTERVAL

        if ( self.blink ) then
            self.blink_phase = self.blink_phase + NEEDTOKNOW.UPDATE_INTERVAL
            if ( self.blink_phase >= 2 ) then
                self.blink_phase = 0
            end
            local a = self.blink_phase
            if ( a > 1 ) then
                a = 2 - a
            end

            self.bar1:SetVertexColor(self.settings.MissingBlink.r, self.settings.MissingBlink.g, self.settings.MissingBlink.b)
            self.bar1:SetAlpha(self.settings.MissingBlink.a * a)
            return
        end
        
        -- WORKAROUND: Although the existence of the enchant is correct at UNIT_INVENTORY_CHANGED
        -- the expiry time is not yet correct.  So we update the expiration every update :(
        local origUnit = self.settings.Unit
        if ( origUnit == "mhand" ) then
            -- The expiry time doesn't update right away, so we have to poll it
            local mhEnchant, mhExpire = GetWeaponEnchantInfo()
            if ( mhExpire ) then
                self.expirationTime = GetTime() + mhExpire/1000
            end
        elseif ( origUnit == "ohand" ) then
            local _, _, _, ohEnchant, ohExpire = GetWeaponEnchantInfo()
            if ( ohExpire ) then
                self.expirationTime = GetTime() + ohExpire/1000
            end
        end
        
        -- WORKAROUND: Some of these (like item cooldowns) don't fire an event when the CD expires.
        --   others fire the event too soon.  So we have to keep checking.
        if ( self.duration and self.duration > 0 ) then
            local duration = self.fixedDuration or self.duration
            local bar1_timeLeft = self.expirationTime - GetTime()
            if ( bar1_timeLeft < 0 ) then
                if ( self.settings.BuffOrDebuff == "CASTCD" or
                     self.settings.BuffOrDebuff == "BUFFCD" or
                     self.settings.BuffOrDebuff == "EQUIPSLOT" )
                then
                    NeedToKnow.Bar_AuraCheck(self)
                    return
                end
                bar1_timeLeft = 0
            end
            SetStatusBarValue(self, self.bar1, bar1_timeLeft);
            if ( self.settings.show_time ) then
                local fn = NeedToKnow[self.settings.TimeFormat]
                local oldText = self.time:GetText()
                local newText
                if ( fn ) then
                    newText = fn(bar1_timeLeft)
                else 
                    newText = string.format(SecondsToTimeAbbrev(bar1_timeLeft))
                end
                
                if ( newText ~= oldText ) then
                    self.time:SetText(newText)
                end
            else
                self.time:SetText("")
            end
            
            if ( self.settings.show_spark and bar1_timeLeft <= duration ) then
                self.spark:SetPoint("CENTER", self, "LEFT", self:GetWidth()*bar1_timeLeft/duration, 0)
                self.spark:Show()
            else
                self.spark:Hide()
            end
            
            if ( self.max_expirationTime ) then
                local bar2_timeLeft = self.max_expirationTime - GetTime()
                SetStatusBarValue(self, self.bar2, bar2_timeLeft, bar1_timeLeft)
            end
            
            if ( self.vct_refresh ) then
                NeedToKnow.UpdateVCT(self)
            end
        end
    end
end 
