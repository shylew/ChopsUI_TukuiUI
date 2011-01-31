------------------------------------------------------------------------------
-- CONFIGURE BIGWIGS
------------------------------------------------------------------------------
function ChopsuiBigWigsConfigure()
end

------------------------------------------------------------------------------
-- RESET BIGWIGS
------------------------------------------------------------------------------
function ChopsuiBigWigsReset()

  if not BigWigs then
    BigWigs_LoadAndEnableCore()
  end

  -- Switch the BigWigs profile to a character specific profile
  local bigwigsProfile = UnitName("player") .. " - " .. GetRealmName()
  BigWigs.db:SetProfile(bigwigsProfile)
  --BigWigs.db:ResetProfile()

  local barProfile = BigWigs.db:GetNamespace("BigWigs_Plugins_Bars")
  local messageProfile = BigWigs.db:GetNamespace("BigWigs_Plugins_Messages")
  local proximityProfile = BigWigs.db:GetNamespace("BigWigs_Plugins_Proximity")

  barProfile:ResetProfile()
  messageProfile:ResetProfile()
  proximityProfile:ResetProfile()

  -- Set some BigWigs default settings
  barProfile.profile["texture"] = "TelUI Statusbar"
  barProfile.profile["barStyle"] = "TukUI"
  barProfile.profile["font"] = "TelUI Font"
  barProfile.profile["emphasizeScale"] = 1.2
  barProfile.profile["emphasizeGrowup"] = true
  messageProfile.profile["font"] = "TelUI Font"
  messageProfile.profile["fontSize"] = 15
  proximityProfile.profile["fontSize"] = 15
  proximityProfile.profile["font"] = "TelUI Font"

  -- Set the size of the bars
  barProfile.profile["BigWigsAnchor_width"] = 200
  barProfile.profile["BigWigsEmphasizeAnchor_width"] = 250

  -- Position the normal bar anchor
  barProfile.profile["BigWigsAnchor_x"] = 10
  barProfile.profile["BigWigsAnchor_y"] = math.floor(TukuiDB.getscreenheight / 2) - TukuiDB.Scale(100)

  -- Position the emphasis bar anchor
  local emphasisYOffset = oUF_Tukz_target:GetTop() + TukuiDB.Scale(50)
  local emphasisXOffset = math.floor(TukuiDB.getscreenwidth / 2) - (250 * 1.4) + 35
  barProfile.profile["BigWigsEmphasizeAnchor_x"] = emphasisXOffset
  barProfile.profile["BigWigsEmphasizeAnchor_y"] = emphasisYOffset

  -- Position the message anchor
  local messageXOffset = math.floor(TukuiDB.getscreenwidth / 2) - 295
  local messageYOffset = TukuiDB.getscreenheight - TukuiDB.Scale(400)
  messageProfile.profile["BWMessageAnchor_x"] = messageXOffset
  messageProfile.profile["BWMessageAnchor_y"] = messageYOffset

  -- Position the emphasis message anchor
  local emphasisMessageYOffset = math.floor(TukuiDB.getscreenheight / 2) - TukuiDB.Scale(200)
  messageProfile.profile["BWEmphasizeMessageAnchor_x"] = messageXOffset
  messageProfile.profile["BWEmphasizeMessageAnchor_y"] = emphasisMessageYOffset

  -- Hide the minimap icon
  BigWigs3IconDB["hide"] = true

end
