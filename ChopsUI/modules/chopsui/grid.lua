local T, C, L = unpack(Tukui)
ChopsUI.RegisterModule("grid", Grid)

-- Anchor Grid to the action bar background.
local GridLayout = Grid:GetModule("GridLayout")
GridLayout.RestorePosition = function()
  local f = GridLayout.frame
  f:ClearAllPoints()
  f:SetPoint("BOTTOM", InvTukuiActionBarBackground, "TOP", 0, 85)
end

-- Configure Grid indicators
function ChopsUI.modules.grid.ConfigureIndicators()

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
  -- TODO - this is disabled for now, GridStatusShield is having some issues.
  -- GridFrame.db.profile["statusmap"]["cornertextbottomright"]["unitShieldLeft"] = true

  --
  -- Class/Spec specific configurations
  --

  if T.myclass == "DRUID" then

    if T.Spec == "RESTORATION" then

      GridFrame.db.profile["statusmap"]["iconTLcornerleft"]["buff_Rejuvenation"] = true
      GridFrame.db.profile["statusmap"]["iconTRcornerright"]["buff_Regrowth"] = true
      GridFrame.db.profile["statusmap"]["iconBLcornerleft"]["buff_Lifebloom"] = true
      GridFrame.db.profile["statusmap"]["iconBLcornerright"]["buff_WildGrowth"] = true
      GridFrame.db.profile["statusmap"]["iconBRcornerleft"]["buff_LivingSeed"] = true
      
    end

  elseif T.myclass == "PALADIN" then

    GridFrame.db.profile["statusmap"]["iconTLcornerleft"] = {
      ["buff_HandofSalvation"] = true,
      ["buff_HandofFreedom"] = true,
      ["buff_HandofProtection"] = true,
      ["buff_HandofSacrifice"] = true,
    }

    if T.Spec == "HOLY" then
      GridFrame.db.profile["statusmap"]["iconTRcornerright"]["buff_BeaconofLight"] = true
      GridFrame.db.profile["statusmap"]["iconleft"]["buff_GiftoftheNaaru"] = true
    end

  elseif T.myclass == "PRIEST" then

    if T.Spec == "DISCIPLINE" or T.spec == "HOLY" then
      GridFrame.db.profile["statusmap"]["iconTLcornerleft"]["buff_Renew"] = true
      GridFrame.db.profile["statusmap"]["iconTLcornerright"]["buff_PrayerofMending"] = true
      GridFrame.db.profile["statusmap"]["iconBLcornerleft"] = {
        ["buff_Inspiration"] = true,
        ["buff_AncestralFortitude"] = true
      }
      GridFrame.db.profile["statusmap"]["iconBLcornerright"]["debuff_WeakenedSoul"] = true
      GridFrame.db.profile["statusmap"]["iconleft"]["buff_GiftoftheNaaru"] = true
    end

    if T.Spec == "DISCIPLINE" then
      GridFrame.db.profile["statusmap"]["iconTRcornerright"]["buff_Grace"] = true
    end

  elseif T.myclass == "SHAMAN" then

    if T.Spec == "RESTORATION" then
      GridFrame.db.profile["statusmap"]["iconTLcornerleft"]["buff_Riptide"] = true
      GridFrame.db.profile["statusmap"]["iconTLcornerright"]["buff_Earthliving"] = true
      GridFrame.db.profile["statusmap"]["iconTRcornerright"]["buff_EarthShield"] = true
      GridFrame.db.profile["statusmap"]["iconleft"]["buff_GiftoftheNaaru"] = true
      GridFrame.db.profile["statusmap"]["iconBLcornerleft"] = {
        ["buff_Inspiration"] = true,
        ["buff_AncestralFortitude"] = true
      }
    end

  elseif T.myclass == "WARLOCK" then

    GridFrame.db.profile["statusmap"]["iconleft"]["buff_DarkIntent"] = true

  elseif T.myclass == "WARRIOR" then

    GridFrame.db.profile["statusmap"]["iconleft"]["buff_Vigilance"] = true

  end

end
ChopsUI.modules.grid.ConfigureIndicators()

-- Add a buff to Grid
function ChopsUI.modules.grid.AddBuff(GridStatusAuras, auraName, onlyMine, color, priority)
  ChopsUI.modules.grid.AddAura(GridStatusAuras, "buff", auraName, onlyMine, color, priority)
end

-- Add a debuff to Grid
function ChopsUI.modules.grid.AddDebuff(GridStatusAuras, auraName, onlyMine, color, priority)
  ChopsUI.modules.grid.AddAura(GridStatusAuras, "debuff", auraName, onlyMine, color, priority)
end

-- Returns the key to use in the profile map for the specified aura
function ChopsUI.modules.grid.AuraKey(auraName)
  return auraName:gsub("%s+", "")
end

-- Add an aura to Grid
function ChopsUI.modules.grid.AddAura(GridStatusAuras, buffOrDebuff, auraName, onlyMine, color, priority)

  if onlyMine == nil then
    onlyMine = false
  end
  if color == nil then
    color = { ["r"] = 1, ["g"] = 1, ["b"] = 1 }
  end
  if priority == nil then
    priority = 90
  end

  color["a"] = 1
  local auraKey = ChopsUI.modules.grid.AuraKey(auraName)

  GridStatusAuras.db.profile[buffOrDebuff .. "_" .. auraKey] = {
    ["missing"] = false,
    ["priority"] = priority,
    ["text"] = auraName,
    ["enable"] = true,
    ["color"] = color,
    ["duration"] = true,
    ["range"] = false,
    ["desc"] = buffOrDebuff:gsub("^%l", string.upper) .. ": " .. auraName,
    ["mine"] = onlyMine    
  }

end

-- Reset Grid
function ChopsUI.modules.grid.Reset()

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
  local GridIndicatorSideIcons = GridFrame:GetModule("GridIndicatorSideIcons")
  local GridIndicatorCornerText = GridFrame:GetModule("GridIndicatorCornerText")
  local GridStatusAuras = GridStatus:GetModule("GridStatusAuras")
  -- TODO - this is disabled for now, GridStatusShield is having some issues.
  --local GridStatusShield = GridStatus:GetModule("GridStatusShield")

  local gridProfile = UnitName("player") .. " - " .. GetRealmName()
  Grid.db:SetProfile(gridProfile)
  Grid.db:ResetProfile()

  -- Set some general Grid options
  Grid.db.profile["minimap"] = { ["hide"] = true }
  GridFrame.db.profile["enableBarColor"] = true
  GridLayout.db.profile["layout"] = "None"
  GridLayout.db.profile["groupAnchor"] = "BOTTOMLEFT"
  GridLayout.db.profile["horizontal"] = true
  GridLayout.db.profile["layouts"] = { ["solo"] = "None" }

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
	GridFrame.db.profile["invertBarColor"] = true
  GridFrame.db.profile["iconSize"] = 22
  GridFrame.db.profile["cornerSize"] = 16

  -- Scale the frames
  GridFrame.db.profile["frameWidth"] = 100
  GridFrame.db.profile["frameHeight"] = 45

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
      ["buff_SpiritLinkTotem"] = true,

      -- Magic damage reductions
      ["buff_CloakofShadows"] = true,
      ["buff_Anti-MagicShell"] = true,
      ["buff_Anti-MagicZone"] = true,
      
      -- Healer support
      ["buff_LastStand"] = true,
      ["buff_VampiricBlood"] = true,
      ["buff_GuardianSpirit"] = true,
      ["buff_RallyingCry"] = true

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
  GridIndicatorCornerIcons.db.profile["iconSizeTopLeftCorner"] = 18
  GridIndicatorCornerIcons.db.profile["iconSizeTopRightCorner"] = 18
  GridIndicatorCornerIcons.db.profile["iconSizeBottomLeftCorner"] = 18
  GridIndicatorCornerIcons.db.profile["iconSizeBottomRightCorner"] = 18
  GridIndicatorCornerIcons.db.profile["enableIconCooldown"] = true
  GridIndicatorCornerIcons.db.profile["enableIconStackText"] = true
  GridIndicatorCornerIcons.db.profile["xoffset"] = 2
  GridIndicatorCornerIcons.db.profile["yoffset"] = -1

  -- Set up side icons
  GridIndicatorSideIcons.db.profile["iconSizeTop"] = 18
	GridIndicatorSideIcons.db.profile["enableIconStackText"] = true
	GridIndicatorSideIcons.db.profile["yoffsetLR"] = 0
	GridIndicatorSideIcons.db.profile["iconSizeLeft"] = 18
	GridIndicatorSideIcons.db.profile["iconBorderSize"] = 1
	GridIndicatorSideIcons.db.profile["iconSizeBottom"] = 18
	GridIndicatorSideIcons.db.profile["iconSizeRight"] = 18
	GridIndicatorSideIcons.db.profile["xoffsetLR"] = -2
	GridIndicatorSideIcons.db.profile["enableIconCooldown"] = true
	GridIndicatorSideIcons.db.profile["yoffsetTB"] = -2
  
  -- Set up shield tracker
  -- TODO - this is disabled for now, GridStatusShield is having some issues.
	--GridStatusShield.db.profile["unitShieldLeft"] = { [ "useCombatLog"] = true }

  -- Configure the mana bars
  GridManaBarFrame.db.profile["side"] = "Bottom"
  GridManaBarFrame.db.profile["size"] = 0.1
  GridManaBarStatus.db.profile["hiderage"] = true

  -- Configure corner texts
  GridIndicatorCornerText.db.profile["CornerTextFontSize"] = 12
  GridIndicatorCornerText.db.profile["CornerTextFont"] = "TukuiNormalFont"

  --
  -- Set up some custom auras
  --
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Gift of the Naaru", true)

  -- Druid auras
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Rejuvenation", true)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Regrowth", true)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Lifebloom", true)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Wild Growth", true)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Living Seed", true)
  
  -- Paladin auras
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Hand of Salvation")
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Hand of Freedom")
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Hand of Protection")
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Hand of Sacrifice")
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Beacon of Light", true)
  
  -- Priest auras
  ChopsUI.modules.grid.AddDebuff(GridStatusAuras, "Weakened Soul")
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Inspiration")
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Prayer of Mending", true)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Renew", true)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Grace", true)

  -- Shaman auras
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Ancestral Fortitude")
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Earthliving", true)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Riptide", true)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Earth Shield", true)

  -- Warlock auras
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Dark Intent", true)

  -- Warrior auras
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Vigilance", true)

  -- Immunities
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Iceblock", false, gridColorImmunity, 98)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Divine Shield", false, gridColorImmunity, 98)

  -- Strong damage reductions
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Power Word: Barrier", false, gridColorStringDR, 97)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Pain Suppression", false, gridColorStringDR, 97)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Shield Wall", false, gridColorStringDR, 97)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Icebound Fortitude", false, gridColorStringDR, 97)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Survival Instincts", false, gridColorStringDR, 97)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Divine Protection", false, gridColorStringDR, 97)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Ancient Guardian", false, gridColorStringDR, 97)

  -- Light damage reduction
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Bone Shield", false, gridColorLightDR, 96)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Barkskin", false, gridColorLightDR, 96)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Shield Block", false, gridColorLightDR, 96)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Will of the Necropolis", false, gridColorLightDR, 96)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Divine Guardian", false, gridColorLightDR, 96)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Spirit Link Totem", false, gridColorLightDR, 96)

  -- Magic damage reductions
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Cloak of Shadows", false, gridColorMagicDR, 95)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Anti-Magic Zone", false, gridColorMagicDR, 95)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Anti-Magic Shell", false, gridColorMagicDR, 95)

  -- Healer support
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Last Stand", false, gridColorHealerSupport, 94)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Vampiric Blood", false, gridColorHealerSupport, 94)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Guardian Spirit", false, gridColorHealerSupport, 94)
  ChopsUI.modules.grid.AddBuff(GridStatusAuras, "Rallying Cry", false, gridColorHealerSupport, 94)

end
