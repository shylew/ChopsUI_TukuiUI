local T, C, L = unpack(Tukui)
ChopsUI.RegisterModule("skada", Skada)

-- Position the Skada frame when logging in.
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self)
  local window = Skada:GetWindows()[1]
  if window then
    window.bargroup:ClearAllPoints()
    window.bargroup:Point("TOPRIGHT", TukuiMinimap, "TOPLEFT", -8, -17)
  end
  self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)

-- Reset Skada
function ChopsUI.modules.skada.Reset()

  -- Switch the Skada profile to a character specific profile
  local skadaProfile = UnitName("player") .. " - " .. GetRealmName()
  Skada.db:SetProfile(skadaProfile)

  -- Reset Skada windows
  Skada.db.profile.windows = {}

  -- Set some general Skada options
  Skada.db.profile.icon.hide = true
  Skada.db.profile.hidesolo = false

  -- Calculate the width of the skada window.
  local remainingWidth = TukuiInfoRight:GetWidth() - TukuiMinimap:GetWidth() - 10

  -- Create and configure the Skada window
  Skada:CreateWindow("Skada")
  Skada.db.profile.windows[1].set = "current"
  Skada.db.profile.windows[1].barwidth = remainingWidth
  Skada.db.profile.windows[1].barheight = 14
  Skada.db.profile.windows[1].background.height = 146
  Skada.db.profile.windows[1].barslocked = true

end
