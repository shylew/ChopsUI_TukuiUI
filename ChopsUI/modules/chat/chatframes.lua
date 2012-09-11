local T, C, L = unpack(Tukui)

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event)

  -- Move the loot frame to the left.
  FCF_UnDockFrame(ChatFrame4)
  ChatFrame4:ClearAllPoints()
  ChatFrame4:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
  ChatFrame4:SetJustifyH("LEFT")
  FCF_DockFrame(ChatFrame4)

  -- Increase the height of the chat frames.
  for i = 1, NUM_CHAT_WINDOWS do
    local chat = _G["ChatFrame" .. i]
    chat:SetHeight(141)
  end

  -- Always show the chat tabs.
  for i = 1, NUM_CHAT_WINDOWS do
    local chat = "ChatFrame" .. i
    local tab = _G[chat .. "Tab"]
    local text = _G[chat .. "TabText"]
    text:Show()
    tab:HookScript("OnEnter", function() text:Show() end)
    tab:HookScript("OnLeave", function() text:Show() end)
  end

end)
