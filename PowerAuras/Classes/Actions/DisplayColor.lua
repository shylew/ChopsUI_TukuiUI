-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Changes display color.
local DisplayColor = PowerAuras:RegisterActionClass("DisplayColor", {
	Parameters = {
		[1] = 1.0,
		[2] = 1.0,
		[3] = 1.0,
	},
});

--- Constructor function for the action. Generates and returns an activator.
-- @param id           The ID of the action.
-- @param params       Parameters for constructing the action.
-- @param display      The display to create the action for.
-- @param displayID    The ID of the display.
-- @param displayClass The class of the display.
function DisplayColor:New(id, parameters, display, displayID, displayClass)
	-- Store the default target colours.
	local def = displayClass:GetActionDefaults("DisplayColor", display);
	-- Allow the display to override the action.
	if(display.OnColor) then
		return display.OnColor;
	else
		-- Return activator.
		return function(seqID, oldID, r, g, b)
			-- Do nothing if we have no targets/sequence changes.
			if(seqID == oldID) then return; end
			if(not seqID) then
				displayClass:ApplyAction("DisplayColor", display, unpack(def));
			else
				displayClass:ApplyAction("DisplayColor", display, r, g, b);
			end
		end;
	end
end

--- Constructs the sequence editor for an action.
-- @param frame The frame to apply widgets to.
-- @param ...   The ID's to pass to Get/SetParameter calls.
function DisplayColor:CreateSequenceEditor(frame, ...)
	-- Add a color picker.
	local picker = PowerAuras:Create("ColorPicker", frame);
	picker:SetUserTooltip("Color");
	local r = PowerAuras:GetParameter("Sequence", 1, ...);
	local g = PowerAuras:GetParameter("Sequence", 2, ...);
	local b = PowerAuras:GetParameter("Sequence", 3, ...);
	picker:SetPadding(4, 0, 2, 0);
	picker:SetRelativeWidth(1.0);
	picker:SetText(L["Color"]);
	picker:SetColor(r, g, b, 1);
	picker:HasOpacity(false);
	picker:ConnectParameter(PowerAuras:Loadstring(PowerAuras:FormatString([[
		local self, value, type, key, id1, id2 = ...;
		if(type == "Sequence" and id1 == ${1:d} and id2 == ${2:d}) then
			local r = PowerAuras:GetParameter("Sequence", 1, id1, id2);
			local g = PowerAuras:GetParameter("Sequence", 2, id1, id2);
			local b = PowerAuras:GetParameter("Sequence", 3, id1, id2);
			r = (key == 1 and value or r);
			g = (key == 2 and value or g);
			b = (key == 3 and value or b);
			self:SetColor(r, g, b, 1);
		end
	]], ...)));
	picker.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, r, g, b = ...;
		PowerAuras:SetParameter("Sequence", 1, r, ${1:d}, ${2:d});
		PowerAuras:SetParameter("Sequence", 2, g, ${1:d}, ${2:d});
		PowerAuras:SetParameter("Sequence", 3, b, ${1:d}, ${2:d});
	]], ...));
	-- Add widgets to frame.
	frame:AddWidget(picker);
end

--- Returns the target for this action. A target is what the action needs
--  to be applied to in order to work as intended.
function DisplayColor:GetTarget()
	return "Display";
end

--- Upgrades an action from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function DisplayColor:Upgrade(version, params)
end