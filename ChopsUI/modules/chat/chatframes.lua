local T, C, L = unpack(Tukui)

-- Move the chat frame to the left dock.
local moveLootFrameCallback = function(frame)
  if frame then
    local id = frame:GetID()
    if id == 4 then
      frame:ClearAllPoints()
      frame:SetJustifyH("LEFT")
      FCF_DockFrame(ChatFrame4)
    end
  end
end
hooksecurefunc("FCF_RestorePositionAndDimensions", moveLootFrameCallback)

-- Show the chat tabs.
local ChopsUIChat = CreateFrame("Frame", "ChopsUIChat")
local overrideChatTabCallback = function(frame)
  for i = 1, NUM_CHAT_WINDOWS do
    local chat = "ChatFrame" .. i
    local tab = _G[chat .. "Tab"]
    local text = _G[chat .. "TabText"]

    text:Show()
    tab:HookScript("OnEnter", function() text:Show() end)
    tab:HookScript("OnLeave", function() text:Show() end)
  end
end
ChopsUIChat:RegisterEvent("ADDON_LOADED")
ChopsUIChat:SetScript("OnEvent", function(self, event, addon)
  if addon == "Blizzard_CombatLog" then
    self:UnregisterEvent("ADDON_LOADED")
    overrideChatTabCallback()
  end
end)
