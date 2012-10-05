-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Display action definition.
local DisplaySaturation = PowerAuras:RegisterActionClass("DisplaySaturation", {
	Parameters = {
		[1] = true,
	},
});

--- Constructor function for the action. Generates and returns an activator.
-- @param id        The ID of the action.
-- @param params    Parameters for constructing the action.
-- @param display   The display to create the action for.
-- @param displayID The ID of the display.
-- @param cls       The class of the display.
function DisplaySaturation:New(id, parameters, display, displayID, cls)
	-- Store the default target values.
	local def = cls:GetActionDefaults("DisplaySaturation", display);
	-- Allow the display to override the action.
	if(display.OnSaturation) then
		return display.OnSaturation;
	else
		-- Return activator.
		return function(seqID, oldID, state)
			-- Do nothing if we have no targets/sequence changes.
			if(seqID == oldID) then return; end
			if(not seqID) then
				cls:ApplyAction("DisplaySaturation", display, unpack(def));
			else
				cls:ApplyAction("DisplaySaturation", display, state);
			end
		end;
	end
end

--- Constructs the sequence editor for an action.
-- @param frame The frame to apply widgets to.
-- @param ...   The ID's to pass to Get/SetParameter calls.
function DisplaySaturation:CreateSequenceEditor(frame, ...)
	-- Desaturation.
	local desat = PowerAuras:Create("P_Checkbox", frame);
	desat:SetUserTooltip("DTexture_Desaturate");
	desat:LinkParameter("Sequence", 1, ...);
	desat:SetRelativeWidth(0.35);
	desat:SetPadding(4, 0, 2, 0);
	desat:SetText(L["Desaturate"]);
	frame:AddWidget(desat);
end

--- Returns the target for this action. A target is what the action needs
--  to be applied to in order to work as intended.
function DisplaySaturation:GetTarget()
	return "Display";
end

--- Upgrades an action from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function DisplaySaturation:Upgrade(version, params)
end