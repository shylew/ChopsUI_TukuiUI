print("Welcome to |cffC495DDChopsUI|r, using role " .. TukuiDB.myrole)

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

  -- Assign role and spec from the DB
  if ChopsUI then
    TukuiDB.myrole = ChopsUI.role
    TukuiDB.myspec = ChopsUI.spec
  end

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
