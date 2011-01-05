if not TukuiCF["actionbar"].enable == true then return end

---------------------------------------------------------------------------
-- Setup Shapeshift Bar
---------------------------------------------------------------------------

-- used for anchor totembar or shapeshiftbar
local TukuiShift = CreateFrame("Frame","TukuiShiftBar",UIParent)
TukuiShift:SetSize(TukuiDB.buttonsize, TukuiDB.buttonsize)
TukuiShift:SetPoint("BOTTOM", TukuiActionBarBackground, "TOP", 0, -TukuiDB.Scale(20))

-- hide it if not needed and stop executing code
if TukuiCF.actionbar.hideshapeshift then TukuiShift:Hide() return end

-- create the shapeshift bar if we enabled it
local bar = CreateFrame("Frame", "TukuiShapeShift", TukuiShift, "SecureHandlerStateTemplate")
bar:ClearAllPoints()
bar:SetAllPoints(TukuiShift)

local States = {
	["DRUID"] = "show",
	["WARRIOR"] = "show",
	["PALADIN"] = "show",
	["DEATHKNIGHT"] = "show",
	["ROGUE"] = "show,",
	["PRIEST"] = "show,",
	["HUNTER"] = "show,",
	["WARLOCK"] = "show,",
}

bar:RegisterEvent("PLAYER_LOGIN")
bar:RegisterEvent("PLAYER_ENTERING_WORLD")
bar:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
bar:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")
bar:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN")
bar:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
bar:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
bar:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		local button
    local activeButtons = 0
		for i = 1, NUM_SHAPESHIFT_SLOTS do
			button = _G["ShapeshiftButton"..i]
			button:ClearAllPoints()
			button:SetParent(self)
			if i == 1 then
				button:SetPoint("BOTTOMLEFT", TukuiShift, 0, TukuiDB.Scale(29))
			else
				local previous = _G["ShapeshiftButton"..i-1]
				button:SetPoint("LEFT", previous, "RIGHT", TukuiDB.Scale(4), 0)
			end
			local _, name = GetShapeshiftFormInfo(i)
			if name then
				button:Show()
        activeButtons = activeButtons + 1
			end
		end

    -- If we have one or more active buttons, resize the action bar
    -- background panel to nudge unit frames and other depending frames up
    if activeButtons > 0 then
      local currentBackgroundHeight = _G["InvTukuiActionBarBackground"]:GetHeight()
      _G["InvTukuiActionBarBackground"]:SetHeight(currentBackgroundHeight + TukuiShift:GetHeight() + TukuiDB.Scale(13))
    end
    
    TukuiDB.TukuiShiftBarResize()
		RegisterStateDriver(self, "visibility", States[TukuiDB.myclass] or "hide")
	elseif event == "UPDATE_SHAPESHIFT_FORMS" then
		-- Update Shapeshift Bar Button Visibility
		-- I seriously don't know if it's the best way to do it on spec changes or when we learn a new stance.
		if InCombatLockdown() then return end -- > just to be safe ;p
		local button
		for i = 1, NUM_SHAPESHIFT_SLOTS do
			button = _G["ShapeshiftButton"..i]
			local _, name = GetShapeshiftFormInfo(i)
			if name then
				button:Show()
			else
				button:Hide()
			end
		end
    TukuiDB.TukuiShiftBarResize()
		TukuiDB.TukuiShiftBarUpdate()

	elseif event == "PLAYER_ENTERING_WORLD" then
		TukuiDB.StyleShift()
	else
		TukuiDB.TukuiShiftBarUpdate()
	end
end)
