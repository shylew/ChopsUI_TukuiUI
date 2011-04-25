local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
assert(Grid, "ChopsUI Grid extension failed to load, make sure Grid is enabled")

-- Anchor Grid to our action bar background
local GridLayout = Grid:GetModule("GridLayout")
GridLayout.RestorePosition = function()

  local f = GridLayout.frame

  f:ClearAllPoints()
  f:SetPoint("BOTTOM", InvTukuiActionBarBackground, "TOP", 0, 85)

end

-- Configure Grid indicators
function ChopsuiConfigureGridIndicators()

  local GridFrame = Grid:GetModule("GridFrame")

  --
  -- DISPEL INDICATOR
  --
  dispellableTypes = { ["poison"] = false, ["curse"] = false, ["disease"] = false, ["magic"] = false }

  -- Poison dispelling
  if T.myclass == "DRUID" or T.myclass == "PALADIN" then
    dispellableTypes["poison"] = true
  end

  -- Curse dispelling
  if T.myclass == "DRUID" or T.myclass == "SHAMAN" or T.myclass == "MAGE" then
    dispellableTypes["curse"] = true
  end

  -- Disease dispelling
  if T.myclass == "PRIEST" or T.myclass == "PALADIN" then
    dispellableTypes["disease"] = true
  end

  -- Magic dispelling
  if T.myclass == "PRIEST" or (T.myclass == "DRUID" and T.Spec == "RESTORATION") or (T.myclass == "PALADIN" and T.Spec == "HOLY") or (T.myclass == "SHAMAN" and T.Spec == "RESTORATION") then
    dispellableTypes["magic"] = true
  end

  for dispelType, value in pairs(dispellableTypes) do
    if value == true then
      GridFrame.db.profile["statusmap"]["iconTRcornerleft"]["debuff_" .. dispelType] = true
    end
  end

  --
  -- Absorbs
  --
  GridFrame.db.profile["statusmap"]["cornertextbottomright"]["unitAbsorbsLeft"] = true

  --
  -- Class/Spec specific configurations
  --

  if T.myclass == "PALADIN" then

    GridFrame.db.profile["statusmap"]["iconTLcornerleft"] = {
      ["buff_HandofSalvation"] = true,
      ["buff_HandofFreedom"] = true,
      ["buff_HandofProtection"] = true,
      ["buff_HandofSacrifice"] = true,
    }

    if T.Spec == "HOLY" then
      GridFrame.db.profile["statusmap"]["corner1"]["alert_beacon"] = true
      GridFrame.db.profile["statusmap"]["iconBLcornerleft"]["buff_GiftoftheNaaru"] = true
    end

  elseif T.myclass == "PRIEST" then

    if T.Spec == "DISCIPLINE" or T.spec == "HOLY" then
      GridFrame.db.profile["statusmap"]["iconTRcornerright"]["debuff_WeakenedSoul"] = true
      GridFrame.db.profile["statusmap"]["iconTLcornerleft"]["alert_renew"] = true
      GridFrame.db.profile["statusmap"]["iconTLcornerright"]["alert_pom"] = true
      GridFrame.db.profile["statusmap"]["iconBLcornerleft"]["buff_GiftoftheNaaru"] = true
    end

    if T.Spec == "DISCIPLINE" then
      GridFrame.db.profile["statusmap"]["iconBLcornerleft"]["alert_gracestack"] = true
    end

  elseif T.myclass == "SHAMAN" then

    if T.Spec == "RESTORATION" then
      GridFrame.db.profile["statusmap"]["iconTLcornerleft"]["buff_Riptide"] = true
      GridFrame.db.profile["statusmap"]["iconTLcornerright"]["buff_Earthliving"] = true
      GridFrame.db.profile["statusmap"]["iconTRcornerright"]["buff_AncestralFortitude"] = true
      GridFrame.db.profile["statusmap"]["iconBLcornerleft"]["buff_GiftoftheNaaru"] = true
      GridFrame.db.profile["statusmap"]["cornertextbottomleft"]["alert_earthshield"] = true
    end

  elseif T.myclass == "WARRIOR" then

    if T.Spec == "PROTECTION" then
      GridFrame.db.profile["statusmap"]["iconTLcornerright"]["buff_Vigilance"] = true
    end

  end

end
ChopsuiConfigureGridIndicators()

-- Reset Grid
function ChopsuiGridReset()

  local gridColorImmunity = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }
  local gridColorStrongDR = { ["r"] = 0, ["g"] = 0.2, ["b"] = 1, ["a"] = 1 } 
  local gridColorLightDR = { ["r"] = 1, ["g"] = 0, ["b"] = 0.77, ["a"] = 1 } 
  local gridColorMagicDR = { ["r"] = 0, ["g"] = 1, ["b"] = 0, ["a"] = 1 } 
  local gridColorHealerSupport = { ["r"] = 0, ["g"] = 0.85, ["b"] = 1, ["a"] = 1 } 

  local GridLayout = Grid:GetModule("GridLayout")
  local GridStatus = Grid:GetModule("GridStatus")
  local GridFrame = Grid:GetModule("GridFrame")
  local GridManaBarFrame = GridFrame:GetModule("GridMBFrame")
  local GridManaBarStatus = GridStatus:GetModule("GridMBStatus")
  local GridIndicatorCornerIcons = GridFrame:GetModule("GridIndicatorCornerIcons")
  local GridIndicatorCornerText = GridFrame:GetModule("GridIndicatorCornerText")
  local GridStatusAuras = GridStatus:GetModule("GridStatusAuras")
  local GridStatusHots = GridStatus:GetModule("GridStatusHots")

  local gridProfile = UnitName("player") .. " - " .. GetRealmName()
  Grid.db:SetProfile(gridProfile)
  Grid.db:ResetProfile()

  -- Set some general Grid options
  Grid.db.profile["minimap"] = { ["hide"] = true }
  GridFrame.db.profile["enableBarColor"] = true
  GridLayout.db.profile["layout"] = "None"
  GridLayout.db.profile["groupAnchor"] = "BOTTOMLEFT"
  GridLayout.db.profile["horizontal"] = true

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
  GridFrame.db.profile["font"] = "TukuiNormalFont"
  GridFrame.db.profile["fontSize"] = 12
  GridFrame.db.profile["textlength"] = 12
  GridFrame.db.profile["texture"] = "TukuiNormalTexture"
  GridFrame.db.profile["enableText2"] = true
  GridFrame.db.profile["orientation"] = "HORIZONTAL"
  GridFrame.db.profile["enableMouseoverHighlight"] = false
  GridFrame.db.profile["iconSize"] = 22
  GridFrame.db.profile["cornerSize"] = 16

  -- Scale the frames
  GridFrame.db.profile["frameWidth"] = 90
  GridFrame.db.profile["frameHeight"] = 50

  -- Set up some frame defaults
  GridFrame.db.profile["statusmap"] = {
    ["border"] = {},
    ["corner1"] = {},
    ["corner2"] = {},
    ["corner3"] = {},
    ["corner4"] = {},
    ["icon"] = {},
    ["iconTLcornerleft"] = {},
    ["iconTLcornerright"] = {},
    ["iconTRcornerleft"] = {},
    ["iconTRcornerright"] = {},
    ["iconBLcornerleft"] = {},
    ["iconBLcornerright"] = {},
    ["iconBRcornerleft"] = {},
    ["iconBRcornerright"] = {},
    ["cornertexttopleft"] = {},
    ["cornertexttopright"] = {},
    ["cornertextbottomleft"] = {},
    ["cornertextbottomright"] = {},
    ["text"] = {},
    ["text2"] = {},
    ["barcolor"] = {

      -- Immunities
      ["buff_IceBlock"] = true,
      ["buff_DivineShield"] = true,

      -- Strong damage reductions
      ["buff_PowerWord:Barrier"] = true,
      ["buff_PainSuppression"] = true,
      ["buff_ShieldWall"] = true,
      ["buff_IceboundFortitude"] = true,
      ["buff_SurvivalInstincts"] = true,
      ["buff_DivineProtection"] = true,
      ["buff_AncientGuardian"] = true,

      -- Light damage reductions
      ["buff_BoneShield"] = true,
      ["buff_Barkskin"] = true,
      ["buff_ShieldBlock"] = true,
      ["buff_WilloftheNecropolis"] = true,
      ["buff_DivineGuardian"] = true,

      -- Magic damage reductions
      ["buff_CloakofShadows"] = true,
      ["buff_Anti-MagicShell"] = true,
      ["buff_Anti-MagicZone"] = true,
      
      -- Healer support
      ["buff_LastStand"] = true,
      ["buff_VampiricBlood"] = true,
      ["buff_GuardianSpirit"] = true

    },
    ["manabar"] = { ["unit_mana"] = true }
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
  GridFrame.db.profile["statusmap"]["icon"]["alert_RaidDebuff"] = true
  GridFrame.db.profile["statusmap"]["icon"]["debuff_curse"] = false
  GridFrame.db.profile["statusmap"]["icon"]["debuff_poison"] = false
  GridFrame.db.profile["statusmap"]["icon"]["debuff_disease"] = false
  GridFrame.db.profile["statusmap"]["icon"]["debuff_magic"] = false
  GridFrame.db.profile["statusmap"]["text"]["alert_offline"] = false
  GridFrame.db.profile["statusmap"]["text"]["unit_healthDeficit"] = false
  GridFrame.db.profile["statusmap"]["text"]["debuff_Ghost"] = false
  GridFrame.db.profile["statusmap"]["text"]["alert_heals"] = false
  GridFrame.db.profile["statusmap"]["text"]["alert_death"] = false
  GridFrame.db.profile["statusmap"]["text"]["alert_feignDeath"] = false
  GridFrame.db.profile["statusmap"]["text2"]["unit_healthDeficit"] = true

  -- Set up corner icons
  GridIndicatorCornerIcons.db.profile["iconSizeTopLeftCorner"] = 16
  GridIndicatorCornerIcons.db.profile["iconSizeTopRightCorner"] = 16
  GridIndicatorCornerIcons.db.profile["iconSizeBottomLeftCorner"] = 16
  GridIndicatorCornerIcons.db.profile["iconSizeBottomRightCorner"] = 16
  GridIndicatorCornerIcons.db.profile["xoffset"] = 2
  GridIndicatorCornerIcons.db.profile["yoffset"] = -1

  -- Configure the mana bars
  GridManaBarFrame.db.profile["side"] = "Bottom"
  GridManaBarFrame.db.profile["size"] = 0.1
  GridManaBarStatus.db.profile["hiderage"] = true

  -- Set up some custom auras
  GridStatusAuras.db.profile["debuff_WeakenedSoul"] = {
    ["color"] = {
      ["b"] = 0,
      ["g"] = 0.4470588235294117,
      ["r"] = 0.8470588235294118
    }
  }
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
  GridStatusAuras.db.profile["buff_HandofSalvation"] = {
    ["missing"] = false,
    ["priority"] = 90,
    ["text"] = "Hand of Salvation",
    ["enable"] = true,
    ["color"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 },
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Hand of Salvation"
  }
  GridStatusAuras.db.profile["buff_HandofFreedom"] = {
    ["missing"] = false,
    ["priority"] = 90,
    ["text"] = "Hand of Freedom",
    ["enable"] = true,
    ["color"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 },
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Hand of Freedom"
  }
  GridStatusAuras.db.profile["buff_HandofProtection"] = {
    ["missing"] = false,
    ["priority"] = 90,
    ["text"] = "Hand of Protection",
    ["enable"] = true,
    ["color"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 },
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Hand of Protection"
  }
  GridStatusAuras.db.profile["buff_HandofSacrifice"] = {
    ["missing"] = false,
    ["priority"] = 90,
    ["text"] = "Hand of Sacrifice",
    ["enable"] = true,
    ["color"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 },
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Hand of Sacrifice"
  }
  GridStatusAuras.db.profile["buff_Riptide"] = {
    ["missing"] = false,
    ["priority"] = 90,
    ["text"] = "Riptide",
    ["enable"] = true,
    ["color"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 },
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Riptide"
  }
  GridStatusAuras.db.profile["buff_Earthliving"] = {
    ["missing"] = false,
    ["priority"] = 90,
    ["text"] = "Earthliving",
    ["enable"] = true,
    ["color"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 },
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Earthliving"
  }
  GridStatusAuras.db.profile["buff_GiftoftheNaaru"] = {
    ["missing"] = false,
    ["priority"] = 90,
    ["text"] = "Gift of the Naaru",
    ["enable"] = true,
    ["color"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 },
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Gift of the Naaru",
    ["mine"] = true
  }

  -- Immunities
  GridStatusAuras.db.profile["buff_IceBlock"] = {
    ["missing"] = false,
    ["priority"] = 98,
    ["text"] = "Ice Block",
    ["enable"] = true,
    ["color"] = gridColorImmunity,
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Ice Block"
  }
  GridStatusAuras.db.profile["buff_DivineShield"] = {
    ["missing"] = false,
    ["priority"] = 98,
    ["text"] = "Divine Shield",
    ["enable"] = true,
    ["color"] = gridColorImmunity,
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Divine Shield"
  }

  -- Strong damage reductions
  GridStatusAuras.db.profile["buff_PowerWord:Barrier"] = {
    ["missing"] = false,
    ["priority"] = 97,
    ["text"] = "Power Word: Barrier",
    ["enable"] = true,
    ["color"] = gridColorStrongDR,
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Power Word: Barrier"
  }
  GridStatusAuras.db.profile["buff_PainSuppression"] = {
    ["missing"] = false,
    ["priority"] = 97,
    ["text"] = "Pain Suppression",
    ["enable"] = true,
    ["color"] = gridColorStrongDR,
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Pain Suppression"
  }
  GridStatusAuras.db.profile["buff_ShieldWall"] = {
    ["missing"] = false,
    ["priority"] = 97,
    ["text"] = "Shield Wall",
    ["enable"] = true,
    ["color"] = gridColorStrongDR,
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Shield Wall"
  }
  GridStatusAuras.db.profile["buff_IceboundFortitude"] = {
    ["missing"] = false,
    ["priority"] = 97,
    ["text"] = "Icebound Fortitude",
    ["enable"] = true,
    ["color"] = gridColorStrongDR,
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Icebound Fortitude"
  }
  GridStatusAuras.db.profile["buff_SurvivalInstincts"] = {
    ["missing"] = false,
    ["priority"] = 97,
    ["text"] = "Survival Instincts",
    ["enable"] = true,
    ["color"] = gridColorStrongDR,
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Survival Instincts"
  }
  GridStatusAuras.db.profile["buff_DivineProtection"] = {
    ["missing"] = false,
    ["priority"] = 97,
    ["text"] = "Divine Protection",
    ["enable"] = true,
    ["color"] = gridColorStrongDR,
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Divine Protection"
  }
  GridStatusAuras.db.profile["buff_AncientGuardian"] = {
    ["missing"] = false,
    ["priority"] = 97,
    ["text"] = "Ancient Guardian",
    ["enable"] = true,
    ["color"] = gridColorStrongDR,
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Ancient Guardian"
  }

  -- Light damage reduction
  GridStatusAuras.db.profile["buff_BoneShield"] = {
    ["missing"] = false,
    ["priority"] = 96,
    ["text"] = "Bone Shield",
    ["enable"] = true,
    ["color"] = gridColorLightDR,
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Bone Shield"
  }
  GridStatusAuras.db.profile["buff_Barkskin"] = {
    ["missing"] = false,
    ["priority"] = 96,
    ["text"] = "Barkskin",
    ["enable"] = true,
    ["color"] = gridColorLightDR,
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Barkskin"
  }
  GridStatusAuras.db.profile["buff_ShieldBlock"] = {
    ["missing"] = false,
    ["priority"] = 96,
    ["text"] = "Shield Block",
    ["enable"] = true,
    ["color"] = gridColorLightDR,
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Shield Block"
  }
  GridStatusAuras.db.profile["buff_WilloftheNecropolis"] = {
    ["missing"] = false,
    ["priority"] = 96,
    ["text"] = "Will of the Necropolis",
    ["enable"] = true,
    ["color"] = gridColorLightDR,
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Will of the Necropolis"
  }
  GridStatusAuras.db.profile["buff_DivineGuardian"] = {
    ["missing"] = false,
    ["priority"] = 96,
    ["text"] = "Divine Guardian",
    ["enable"] = true,
    ["color"] = gridColorLightDR,
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Divine Guardian"
  }

  -- Magic damage reductions
  GridStatusAuras.db.profile["buff_CloakofShadows"] = {
    ["missing"] = false,
    ["priority"] = 95,
    ["text"] = "Cloak of Shadows",
    ["enable"] = true,
    ["color"] = gridColorMagicDR,
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Cloak of Shadows"
  }
  GridStatusAuras.db.profile["buff_Anti-MagicShell"] = {
    ["missing"] = false,
    ["priority"] = 95,
    ["text"] = "Anti-Magic Shell",
    ["enable"] = true,
    ["color"] = gridColorMagicDR,
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Anti-Magic Shell"
  }
  GridStatusAuras.db.profile["buff_Anti-MagicZone"] = {
    ["missing"] = false,
    ["priority"] = 95,
    ["text"] = "Anti-Magic Zone",
    ["enable"] = true,
    ["color"] = gridColorMagicDR,
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Anti-Magic Zone"
  }

  -- Healer support
  GridStatusAuras.db.profile["buff_LastStand"] = {
    ["missing"] = false,
    ["priority"] = 94,
    ["text"] = "Last Stand",
    ["enable"] = true,
    ["color"] = gridColorHealerSupport,
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Last Stand"
  }
  GridStatusAuras.db.profile["buff_VampiricBlood"] = {
    ["missing"] = false,
    ["priority"] = 94,
    ["text"] = "Vampiric Blood",
    ["enable"] = true,
    ["color"] = gridColorHealerSupport,
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Vampiric Blood"
  }
  GridStatusAuras.db.profile["buff_GuardianSpirit"] = {
    ["missing"] = false,
    ["priority"] = 94,
    ["text"] = "Guardian Spirit",
    ["enable"] = true,
    ["color"] = gridColorHealerSupport,
    ["duration"] = false,
    ["range"] = false,
    ["desc"] = "Buff: Guardian Spirit"
  }

  -- Configure corner texts
  GridIndicatorCornerText.db.profile["CornerTextFontSize"] = 12
  GridIndicatorCornerText.db.profile["CornerTextFont"] = "TukuiNormalFont"

end
