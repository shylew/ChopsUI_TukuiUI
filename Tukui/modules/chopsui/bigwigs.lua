local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
assert(BigWigs_LoadAndEnableCore, "ChopsUI BigWigs extension failed to load, make sure BigWigs is enabled")

-- Reposition BigWigs. This is called from a small hack inside at the following locations:
--  - BigWigs_Plugins/Bars.lua, inside createAnchor()
--  - BigWigs_Plugins/Messages.lua, inside createAnchor()
function ChopsuiBigWigsReposition(frameName)
  DEFAULT_CHAT_FRAME:AddMessage("REPOSITION: " .. frameName)
  if frameName == "BigWigsAnchor" then
    ChopsuiBigWigsRepositionAnchor()
  elseif frameName == "BigWigsEmphasizeAnchor" then
    ChopsuiBigWigsRepositionEmphasisAnchor()
  elseif frameName == "BWMessageAnchor" then
    ChopsuiBigWigsRepositionMessageAnchor()
  end
end

-- Reposition the normal BigWigs anchor
function ChopsuiBigWigsRepositionAnchor()

  frame = _G["BigWigsAnchor"]
  frame:ClearAllPoints()
  frame:SetPoint("LEFT", UIParent, "LEFT", 10, 0)

end

-- Reposition the BigWigs emphasis anchor
function ChopsuiBigWigsRepositionEmphasisAnchor()

  frame = _G["BigWigsEmphasizeAnchor"]
  frame:ClearAllPoints()
  frame:SetPoint("BOTTOM", InvTukuiActionBarBackground, "TOP", 0, 200)

end

-- Reposition the BigWigs message anchor
function ChopsuiBigWigsRepositionMessageAnchor()

  frame = _G["BWMessageAnchor"]
  frame:ClearAllPoints()
  frame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)

end

-- Reset BigWigs
function ChopsuiBigWigsReset()

  if not BigWigs then
    BigWigs_LoadAndEnableCore()
  end

  local barProfile = BigWigs.db:GetNamespace("BigWigs_Plugins_Bars")
  local messageProfile = BigWigs.db:GetNamespace("BigWigs_Plugins_Messages")
  local proximityProfile = BigWigs.db:GetNamespace("BigWigs_Plugins_Proximity")

  -- Switch the BigWigs profile to a character specific profile
  local bigwigsProfile = UnitName("player") .. " - " .. GetRealmName()
  BigWigs.db:SetProfile(bigwigsProfile)

  -- Set some BigWigs default settings
  barProfile.profile["texture"] = "TukuiNormalTexture"
  barProfile.profile["barStyle"] = "TukUI"
  barProfile.profile["font"] = "TukuiNormalFont"
  barProfile.profile["scale"] = 1.1
  barProfile.profile["emphasizeScale"] = 1.2
  barProfile.profile["emphasizeGrowup"] = true
  messageProfile.profile["font"] = "TukuiNormalFont"
  messageProfile.profile["fontSize"] = 15
  proximityProfile.profile["fontSize"] = 15
  proximityProfile.profile["font"] = "TukuiNormalFont"

  -- Set the size of the bars
  barProfile.profile["BigWigsAnchor_width"] = 200
  barProfile.profile["BigWigsEmphasizeAnchor_width"] = 400

  -- Hide the minimap icon
  BigWigs3IconDB["hide"] = true

end
