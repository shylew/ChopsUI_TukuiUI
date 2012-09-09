local T, C, L = unpack(Tukui)
if C.unitframes.enable ~= true then return end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self)

  local unitFrame = TukuiTarget

  -- Reposition the target unitFrame.
  unitFrame:ClearAllPoints()
  unitFrame:SetPoint("BOTTOM", ChopsUIInvViewportBackground, "TOP", 130, 25)

  -- Remove debuffs from the target unitFrame.
  unitFrame.Debuffs:Kill()

  -- Move the buff unitFrame to the right of the target unitFrame instead of at the top.
  unitFrame.Buffs:ClearAllPoints()
  unitFrame.Buffs:SetPoint('LEFT', unitFrame, 'RIGHT', 6, -28)
  unitFrame.Buffs:SetWidth(54)
  unitFrame.Buffs:SetHeight(54)
  unitFrame.Buffs.size = 26
  unitFrame.Buffs.num = 4
  unitFrame.Buffs.spacing = 2
  unitFrame.Buffs.InitialAnchor = 'TOPLEFT'

  -- Stub out the anchoring methods of the buff unitFrame to prevent OnUpdate events
  -- from moving them.
  unitFrame.Buffs.ClearAllPoints = T.dummy
  unitFrame.Buffs.SetPoint = T.dummy
  unitFrame.Buffs.Point = T.dummy

end)
