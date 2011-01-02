print("Welcome to |cffC495DDChopsUI|r, using role " .. TukuiDB.myrole)

function ChopsuiReset()
  ChopsuiSkadaReset()
  ChopsuiAuditorReset()
  ChopsuiGridReset()
  ChopsuiNeedToKnowReset()
  ChopsuiBigWigsReset()
  ChopsuiMSBTReset()
end

-- Configure the ChopsUI specific parts of the UI
ChopsuiSkadaConfigure()
ChopsuiAuditorConfigure()
ChopsuiGridConfigure()
ChopsuiNeedToKnowConfigure()
ChopsuiBigWigsConfigure()
ChopsuiMSBTConfigure()
