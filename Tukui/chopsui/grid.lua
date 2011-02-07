------------------------------------------------------------------------------
-- CONFIGURE GRID
------------------------------------------------------------------------------
function ChopsuiGridConfigure()

  local GridFrame = Grid:GetModule("GridFrame")

  --------------------------------------------------------------------------
  -- GRID INDICATOR SETUP
  --------------------------------------------------------------------------
  if TukuiDB.myclass == "PALADIN" then

    if TukuiDB.myspec == "HOLY" then
      GridFrame.db.profile["statusmap"]["icon"]["debuff_curse"] = false
      GridFrame.db.profile["statusmap"]["corner1"]["alert_beacon"] = true
    end

  elseif TukuiDB.myclass == "PRIEST" then

    -- Common stuff between Discipline and Holy
    if TukuiDB.myspec == "DISCIPLINE" or TukuiDB.myspec == "HOLY" then
      GridFrame.db.profile["statusmap"]["text2"]["unitShieldLeft"] = true
      GridFrame.db.profile["statusmap"]["corner1"]["debuff_WeakenedSoul"] = true
      GridFrame.db.profile["statusmap"]["corner2"]["alert_pom"] = true
      GridFrame.db.profile["statusmap"]["corner4"]["alert_renew"] = true
      GridFrame.db.profile["statusmap"]["icon"]["debuff_curse"] = false
      GridFrame.db.profile["statusmap"]["icon"]["debuff_poison"] = false
    end

    if TukuiDB.myspec == "DISCIPLINE" then
      GridFrame.db.profile["statusmap"]["corner3"]["alert_gracestack"] = true
    end

  elseif TukuiDB.myclass == "SHAMAN" then

    if TukuiDB.myspec == "RESTORATION" then
      GridFrame.db.profile["statusmap"]["icon"]["debuff_poison"] = false
      GridFrame.db.profile["statusmap"]["icon"]["debuff_disease"] = false
      GridFrame.db.profile["statusmap"]["corner1"]["alert_earthshield"] = true
      GridFrame.db.profile["statusmap"]["corner2"]["alert_earthliving"] = true
      GridFrame.db.profile["statusmap"]["corner3"]["buff_AncestralFortitude"] = true
      GridFrame.db.profile["statusmap"]["corner4"]["alert_riptide"] = true
    end

  elseif TukuiDB.myclass == "WARRIOR" then
    if TukuiDB.myspec == "PROTECTION" then
      GridFrame.db.profile["statusmap"]["iconBRcornerright"] = { ["buff_Vigilance"] = true }
    end
  end
  
end

------------------------------------------------------------------------------
-- RESET GRID
------------------------------------------------------------------------------
function ChopsuiGridReset()

  local GridLayout = Grid:GetModule("GridLayout")
  local GridStatus = Grid:GetModule("GridStatus")
  local GridFrame = Grid:GetModule("GridFrame")
  local GridIndicatorCornerIcons = GridFrame:GetModule("GridIndicatorCornerIcons")
  local GridStatusAuras = GridStatus:GetModule("GridStatusAuras")
  local GridStatusAurasExt = GridStatus:GetModule("GridStatusAurasExt")
  local GridStatusHots = GridStatus:GetModule("GridStatusHots")

  local GridStatusChimaeron = GridStatus:GetModule("GridStatusChimaeron")
  local GridStatusTankCooldown = GridStatus:GetModule("GridStatusTankCooldown")

  -- Disabled for now, doesn't work properly
  --local buffAuras = {
  --  ["stats"] = {
  --    ["1126"] = true,    -- Mark of the Wild
  --    ["90363"] = true,   -- Embrace of the Shale Spider
  --    ["20217"] = true,   -- Blessing of Kings
  --  },
  --  ["stamina"] = {
  --    ["21562"] = true,   -- Power Word: Fortitude
  --    ["469"] = true,     -- Commanding Shout
  --    ["6307"] = true,    -- Blood Pact
  --  },
  --  ["mana"] = {
  --    ["1459"] = true,    -- Arcane Brilliance
  --    ["61316"] = true,   -- Dalaran Brilliance
  --    ["54424"] = true,   -- Fel Intelligence
  --  },
  --  ["str_agi"] = {
  --    ["67330"] = true,   -- Horn of Winter
  --    ["93435"] = true,   -- Roar of Courage
  --    ["8075"] = true,    -- Strength of Earth Totem
  --    ["6673"] = true,    -- Battle Shout
  --  }
  --}

  -- Switch the Grid profile to a character specific profile
  local gridProfile = UnitName("player") .. " - " .. GetRealmName()
  Grid.db:SetProfile(gridProfile)
  Grid.db:ResetProfile()

  -- Set some general Grid options
  Grid.db.profile["minimap"] = {
    ["hide"] = true
  }
  GridLayout.db.profile["layouts"] = {
    ["solo"] = "None"
  }
  GridLayout.db.profile["layout"] = "None"
  GridFrame.db.profile["enableBarColor"] = true

  -- Anchor the groups to the bottom left
  GridLayout.db.profile["groupAnchor"] = "BOTTOMLEFT"

  -- Horizontal groups
  GridLayout.db.profile["horizontal"] = true

  -- Position the frame
  if TukuiDB.myrole == "healer" then

    -- Anchor the frames to the bottom center edge
    GridLayout.db.profile["anchorRel"] = "BOTTOM"
    GridLayout.db.profile["anchor"] = "BOTTOM"
    GridLayout.db.profile["groupAnchor"] = "BOTTOMLEFT"

    -- Set the appropriate width and height for the frames
    local totalWidth = TukuiDB.Scale(470)
    local frameWidth = math.floor(totalWidth / 5)
    GridFrame.db.profile["frameWidth"] = frameWidth
    GridFrame.db.profile["frameHeight"] = TukuiDB.Scale(50)

    -- Style the frame
    GridFrame.db.profile["cornerSize"] = 16

    -- Position the frame
    local gridYOffset = TukuiDB.Scale(120)
    if TukuiCF["actionbar"].bottomrows < 2 then
      gridYOffset = TukuiDB.Scale(94)
    end
    GridLayout.db.profile["PosX"] = 0
    GridLayout.db.profile["PosY"] = gridYOffset

  else

    -- Anchor the frames to the bottom left corner
    GridLayout.db.profile["anchorRel"] = "BOTTOMLEFT"
    GridLayout.db.profile["anchor"] = "BOTTOMLEFT"
    GridLayout.db.profile["groupAnchor"] = "BOTTOMLEFT"

    -- Set the appropriate width and height for the frames
    local totalWidth = ChopsuiChatBackgroundLeft:GetWidth() + TukuiDB.Scale(8)
    local frameWidth = math.floor(totalWidth / 5)
    GridFrame.db.profile["frameWidth"] = frameWidth
    GridFrame.db.profile["frameHeight"] = TukuiDB.Scale(42)

    -- Style the frame
    GridFrame.db.profile["cornerSize"] = 14

    -- Position the frame
    GridLayout.db.profile["PosX"] = TukuiDB.Scale(7)
    GridLayout.db.profile["PosY"] = TukuiDB.Scale(119)
    
  end

  -- Lock the frame
  GridLayout.db.profile["hideTab"] = true
  GridLayout.db.profile["FrameLock"] = true

  -- Style the layout
  GridLayout.db.profile["Padding"] = 0
  GridLayout.db.profile["Spacing"] = 0
  GridLayout.db.profile["borderTexture"] = "None"
  GridLayout.db.profile["BackgroundA"] = 0
  GridLayout.db.profile["BackgroundR"] = 0
  GridLayout.db.profile["BackgroundG"] = 0
  GridLayout.db.profile["BackgroundB"] = 0

  -- Style the frame
  GridFrame.db.profile["font"] = "TelUI Font"
  GridFrame.db.profile["fontSize"] = 12
  GridFrame.db.profile["textlength"] = 12
  GridFrame.db.profile["texture"] = "TelUI Statusbar"
  GridFrame.db.profile["enableText2"] = true
  GridFrame.db.profile["orientation"] = "HORIZONTAL"
  GridFrame.db.profile["enableMouseoverHighlight"] = false
  GridFrame.db.profile["iconSize"] = 22

  -- Set up some frame defaults
  GridFrame.db.profile["statusmap"] = {
    ["border"] = {},
    ["corner1"] = {},
    ["corner2"] = {},
    ["corner3"] = {},
    ["corner4"] = {},
    ["icon"] = {},
    ["iconBRcornerright"] = {},
    ["text"] = {},
    ["text2"] = {},
    ["barcolor"] = {},
  }
  GridFrame.db.profile["statusmap"]["border"]["alert_lowMana"] = false
  GridFrame.db.profile["statusmap"]["border"]["alert_lowHealth"] = false
  GridFrame.db.profile["statusmap"]["border"]["alert_aggro"] = true
  GridFrame.db.profile["statusmap"]["border"]["debuff_curse"] = true
  GridFrame.db.profile["statusmap"]["border"]["debuff_magic"] = true
  GridFrame.db.profile["statusmap"]["border"]["debuff_disease"] = true
  GridFrame.db.profile["statusmap"]["border"]["debuff_poison"] = true
  GridFrame.db.profile["statusmap"]["corner1"]["alert_heals"] = false
  GridFrame.db.profile["statusmap"]["corner3"]["debuff_curse"] = false
  GridFrame.db.profile["statusmap"]["corner3"]["debuff_poison"] = false
  GridFrame.db.profile["statusmap"]["corner3"]["debuff_disease"] = false
  GridFrame.db.profile["statusmap"]["corner3"]["debuff_magic"] = false
  GridFrame.db.profile["statusmap"]["corner4"]["alert_aggro"] = false
  GridFrame.db.profile["statusmap"]["icon"]["alert_RaidDebuff"] = false
  GridFrame.db.profile["statusmap"]["iconBRcornerright"]["alert_RaidDebuff"] = true
  GridFrame.db.profile["statusmap"]["text"]["alert_offline"] = false
  GridFrame.db.profile["statusmap"]["text"]["unit_healthDeficit"] = false
  GridFrame.db.profile["statusmap"]["text"]["debuff_Ghost"] = false
  GridFrame.db.profile["statusmap"]["text"]["alert_heals"] = false
  GridFrame.db.profile["statusmap"]["text"]["alert_death"] = false
  GridFrame.db.profile["statusmap"]["text"]["alert_feignDeath"] = false
  GridFrame.db.profile["statusmap"]["barcolor"]["unitChimaeron"] = true
  GridFrame.db.profile["statusmap"]["barcolor"]["alert_tankcd"] = true

  -- Set up corner icons
  GridIndicatorCornerIcons.db.profile["iconSizeTopLeftCorner"] = 16
  GridIndicatorCornerIcons.db.profile["iconSizeTopRightCorner"] = 16
  GridIndicatorCornerIcons.db.profile["iconSizeBottomLeftCorner"] = 16
  GridIndicatorCornerIcons.db.profile["iconSizeBottomRightCorner"] = 16
  GridIndicatorCornerIcons.db.profile["xoffset"] = 2
  GridIndicatorCornerIcons.db.profile["yoffset"] = -1

  -- Set up the Chimaeron addon
  GridStatusChimaeron.db.profile["unitChimaeron"] = {
    ["threshold"] = 10000
  }
  
  -- Set up the Tank Cooldown addon
  GridStatusTankCooldown.db.profile["alert_tankcd"] = {
    ["color"] = {
      ["g"] = 0,
      ["b"] = 0.95
    },
    ["active_spellids"] = {
      nil,
      nil,
      nil,
      48792,
      33206,
      871,
      61336,
      498,
      12975,
      55233,
      49222,
      48707,
      22812,
    },
    ["inactive_spellids"] = {
      [6940] = 4
    },
    ["showtextas"] = "spell"
  }

  -- Disabled for now, doesn't work properly
  ---- Remove any old aura groups
  --for name, _ in pairs(GridStatusAurasExt.db.profile.auraGroups) do
  --  GridStatusAurasExt:RemoveAuraGroup(name)
  --end
  --GridStatusAurasExt.db.profile.auraGroups = {}

  ---- Re-initialize the aura extension to avoid a LUA error
  --GridStatusAurasExt:OnInitialize()

  ---- Set up new aura groups for the current class
  --if TukuiDB.myclass == "DRUID" or TukuiDB.myclass == "PALADIN" then
  --  GridStatusAurasExt:NewAuraGroup("Missing Buff Group: Stats", "missing buffs")
  --  GridStatusAurasExt.db.profile["status_Missing Buff Group: Stats"].ids = buffAuras["stats"]
  --  GridFrame.db.profile["statusmap"]["iconBRcornerright"]["status_Missing Buff Group: Stats"] = true
  --end
  --if TukuiDB.myclass == "PRIEST" or TukuiDB.myclass == "WARLOCK" or TukuiDB.myclass == "WARRIOR" then
  --  GridStatusAurasExt:NewAuraGroup("Missing Buff Group: Stamina", "missing buffs")
  --  GridStatusAurasExt.db.profile["status_Missing Buff Group: Stamina"].ids = buffAuras["stamina"]
  --  GridFrame.db.profile["statusmap"]["iconBRcornerright"]["status_Missing Buff Group: Stamina"] = true
  --end
  --if TukuiDB.myclass == "MAGE" or TukuiDB.myclass == "WARLOCK" then
  --  GridStatusAurasExt:NewAuraGroup("Missing Buff Group: Mana", "missing buffs")
  --  GridStatusAurasExt.db.profile["status_Missing Buff Group: Mana"].ids = buffAuras["mana"]
  --  GridFrame.db.profile["statusmap"]["iconBRcornerright"]["status_Missing Buff Group: Mana"] = true
  --end
  --if TukuiDB.myclass == "DEATHKNIGHT" or TukuiDB.myclass == "SHAMAN" or TukuiDB.myclass == "WARRIOR" then
  --  GridStatusAurasExt:NewAuraGroup("Missing Buff Group: Agility/Strength", "missing buffs")
  --  GridStatusAurasExt.db.profile["status_Missing Buff Group: Agility/Strength"].ids = buffAuras["str_agi"]
  --  GridFrame.db.profile["statusmap"]["iconBRcornerright"]["status_Missing Buff Group: Agility/Strength"] = true
  --end

  --------------------------------------------------------------------------
  -- GRID AURA SETUP
  --------------------------------------------------------------------------
  if TukuiDB.myclass == "PRIEST" then

    GridStatusAuras.db.profile["debuff_WeakenedSoul"] = {
      ["color"] = {
        ["b"] = 0,
        ["g"] = 0.4470588235294117,
        ["r"] = 0.8470588235294118
      }
    }

  elseif TukuiDB.myclass == "SHAMAN" then

    if TukuiDB.myspec == "RESTORATION" then

      GridStatusHots.db.profile["alert_earthliving"] = {
        ["color"] = { ["r"] = 1, ["g"] = 0.99 },
        ["color2"] = { ["g"] = 0.78 }
      }
      GridStatusHots.db.profile["alert_riptide"] = {
        ["color"] = { ["b"] = 1 }
      }

      GridStatusAuras.db.profile["buff_AncestralFortitude"] = {
        ["missing"] = false,
        ["priority"] = 90,
        ["text"] = "Ancestral Fortitude",
        ["enable"] = true,
        ["color"] = { ["r"] = 0.75, ["g"] = 0.06, ["b"] = 0.56, ["a"] = 1 },
        ["duration"] = false,
        ["range"] = false,
        ["desc"] = "Buff: Ancestral Fortitude"
      }
      
    end

  elseif TukuiDB.myclass == "WARRIOR" then

    if TukuiDB.myspec == "PROTECTION" then

      GridStatusAuras.db.profile["buff_Vigilance"] = {
        ["missing"] = false,
        ["priority"] = 90,
        ["text"] = "Vigilance",
        ["enable"] = true,
        ["color"] = { ["r"] = 1, ["g"] = 0.73, ["b"] = 0.03, ["a"] = 1 },
        ["duration"] = false,
        ["range"] = false,
        ["desc"] = "Buff: Vigilance"
      }

    end

  end
  
end
