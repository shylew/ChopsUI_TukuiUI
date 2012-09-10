local T, C, L, G = unpack(Tukui)

-- Add support for more data text containers.
local DataTextPosition = function(p, obj)

  local left = ChopsUIDataTextLeft
  local right = ChopsUIDataTextRight

  -- 10 and above are used for the ChopsUI data text containers.
  if p == 10 then
    obj:SetParent(left)
    obj:SetHeight(left:GetHeight())
    obj:SetPoint("LEFT", left, 15, 0)
    obj:SetPoint("TOP", left)
    obj:SetPoint("BOTTOM", left)
  elseif p == 11 then
    obj:SetParent(left)
    obj:SetPoint("RIGHT", left, -15, 0)
    obj:SetPoint("TOP", left)
    obj:SetPoint("BOTTOM", left)
  elseif p == 12 then
    obj:SetParent(right)
    obj:SetHeight(right:GetHeight())
    obj:SetPoint("LEFT", right, 15, 0)
    obj:SetPoint("TOP", right)
    obj:SetPoint("BOTTOM", right)
  elseif p == 13 then
    obj:SetParent(right)
    obj:SetPoint("RIGHT", right, -15, 0)
    obj:SetPoint("TOP", right)
    obj:SetPoint("BOTTOM", right)
  end

end

for dataTextName, dataTextFrame in pairs(G.DataText) do
  if dataTextFrame and dataTextFrame.Option then
    DEFAULT_CHAT_FRAME:AddMessage("Working on " .. dataTextName)
    DataTextPosition(dataTextFrame.Option, G.DataText[dataTextName].Text)
  end
end
