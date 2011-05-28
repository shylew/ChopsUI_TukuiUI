local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

function ChopsuiReset()
  ChopsuiGridReset()
  ChopsuiNeedToKnowReset()
  ChopsuiBigWigsReset()
  ChopsuiMsbtReset()
  ChopsuiSkadaReset()
  ChopsuiPostalReset()
  ChopsuiEllipsisReset()
  ChopsuiChatReset()
end

function ChopsuiChatReset()
  ChangeChatColor("OFFICER", 0.79, 0.57, 0)
end
