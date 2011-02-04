function ChopsuiReset()
  ChopsuiSkadaReset()
  ChopsuiAuditorReset()
  ChopsuiGridReset()
  ChopsuiNeedToKnowReset()
  ChopsuiBigWigsReset()
  ChopsuiMSBTReset()
end

-- Set up the ChopsUI related addons
local f = CreateFrame("FRAME")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, _, name)

  if name ~= "Tukui" then return end

  print("Welcome to |cffC495DDChopsUI|r, using role " .. TukuiDB.myrole)

  -- Configure the ChopsUI specific addons
  ChopsuiSkadaConfigure()
  ChopsuiAuditorConfigure()
  ChopsuiGridConfigure()
  ChopsuiNeedToKnowConfigure()
  ChopsuiBigWigsConfigure()
  ChopsuiMSBTConfigure()

  f:UnregisterEvent("ADDON_LOADED")
  f:SetScript("OnEvent", nil)

end)
