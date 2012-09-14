local T, C, L = unpack(Tukui)
ChopsUI.RegisterModule("skinning", UISkinOptions)

-- Remove skin options from the game menu and move the log out button back into
-- place.
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self)
  SkinOptionsButton:Hide()
  GameMenuButtonLogout:Point("TOP", GameMenuButtonMacros, "BOTTOM", 0, -19)
  self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)

function ChopsUI.modules.skinning.Reset()

  -- Disable all skins except Skada.
  for skinName, value in pairs(UISkinOptions) do
    if skinName == "SkadaBackdrop" or skinName == "SkadaSkin" then
      UISkinOptions[skinName] = "Enabled"
    else
      UISkinOptions[skinName] = "Disabled"
    end
  end

end
