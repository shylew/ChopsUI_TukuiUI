local T, C, L = unpack(Tukui)
ChopsUI.RegisterModule("bigwigs", BigWigs_LoadAndEnableCore)

-- Reposition BigWigs. This is called from a small hack inside at the following locations:
--  - BigWigs_Plugins/Bars.lua, inside createAnchor()
--  - BigWigs_Plugins/Messages.lua, inside createAnchor()
function ChopsUI.modules.bigwigs.RepositionFrame(frameName)
  if frameName == "BigWigsAnchor" then
    ChopsUI.modules.bigwigs.RepositionAnchor()
  elseif frameName == "BigWigsEmphasizeAnchor" then
    ChopsUI.modules.bigwigs.RepositionEmphasisAnchor()
  elseif frameName == "BWMessageAnchor" then
    ChopsUI.modules.bigwigs.RepositionMessageAnchor()
  end
end

-- Reposition the normal BigWigs anchor
function ChopsUI.modules.bigwigs.RepositionAnchor()

  frame = _G["BigWigsAnchor"]
  frame:ClearAllPoints()
  frame:SetPoint("LEFT", UIParent, "LEFT", 40, 0)

end

-- Reposition the BigWigs emphasis anchor
function ChopsUI.modules.bigwigs.RepositionEmphasisAnchor()

  frame = _G["BigWigsEmphasizeAnchor"]
  frame:ClearAllPoints()
  frame:SetPoint("BOTTOM", InvTukuiActionBarBackground, "TOP", 0, 290)

end

-- Reposition the BigWigs message anchor
function ChopsUI.modules.bigwigs.RepositionMessageAnchor()

  frame = _G["BWMessageAnchor"]
  frame:ClearAllPoints()
  frame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)

end

-- Reset BigWigs
function ChopsUI.modules.bigwigs.Reset()

  if not BigWigs then
    BigWigs_LoadAndEnableCore()
  end

  local barProfile = BigWigs.db:GetNamespace("BigWigs_Plugins_Bars")
  local messageProfile = BigWigs.db:GetNamespace("BigWigs_Plugins_Messages")
  local proximityProfile = BigWigs.db:GetNamespace("BigWigs_Plugins_Proximity")
  local tipOfTheRaidProfile = BigWigs.db:GetNamespace("BigWigs_Plugins_Tip of the Raid")

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
  tipOfTheRaidProfile.profile["show"] = false

  -- Set the size of the bars
  barProfile.profile["BigWigsAnchor_width"] = 200
  barProfile.profile["BigWigsEmphasizeAnchor_width"] = 400

  -- Hide the minimap icon
  BigWigs3IconDB["hide"] = true

end
