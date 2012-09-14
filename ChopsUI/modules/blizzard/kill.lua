local T, C, L = unpack(Tukui)

-- Disable the Blizzard party & raid frames.
-- This code is copied directly from TukUI, but since ChopsUI doesn't run with
-- the Tukui_Raid/Tukui_Raid_Healing extensions, the code there doesn't fire.

InterfaceOptionsFrameCategoriesButton11:SetScale(0.00001)
InterfaceOptionsFrameCategoriesButton11:SetAlpha(0)

local function KillRaidFrame()
  CompactRaidFrameManager:UnregisterAllEvents()
  if not InCombatLockdown() then CompactRaidFrameManager:Hide() end

  local shown = CompactRaidFrameManager_GetSetting("IsShown")
  if shown and shown ~= "0" then
    CompactRaidFrameManager_SetSetting("IsShown", "0")
  end
end

hooksecurefunc("CompactRaidFrameManager_UpdateShown", function()
  KillRaidFrame()
end)

KillRaidFrame()

-- kill party 1 to 5
local function KillPartyFrame()
  CompactPartyFrame:Kill()

  for i=1, MEMBERS_PER_RAID_GROUP do
    local name = "CompactPartyFrameMember" .. i
    local frame = _G[name]
    frame:UnregisterAllEvents()
  end                     
end
for i=1, MAX_PARTY_MEMBERS do
  local name = "PartyMemberFrame" .. i
  local frame = _G[name]

  frame:Kill()

  _G[name .. "HealthBar"]:UnregisterAllEvents()
  _G[name .. "ManaBar"]:UnregisterAllEvents()
end

if CompactPartyFrame then
  KillPartyFrame()
elseif CompactPartyFrame_Generate then -- 4.1
  hooksecurefunc("CompactPartyFrame_Generate", KillPartyFrame)
end             
