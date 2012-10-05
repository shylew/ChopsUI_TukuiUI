-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Display action definition.
local DisplayRotation = PowerAuras:RegisterActionClass("DisplayRotation", {
	Parameters = {
		[1] = 0,
	},
});

--- Constructor function for the action. Generates and returns an activator.
-- @param id        The ID of the action.
-- @param params    Parameters for constructing the action.
-- @param display   The display to create the action for.
-- @param displayID The ID of the display.
-- @param cls       The class of the display.
function DisplayRotation:New(id, parameters, display, displayID, cls)
	-- Store the default target values.
	local def = cls:GetActionDefaults("DisplayRotation", display);
	-- Allow the display to override the action.
	if(display.OnRotation) then
		return display.OnRotation;
	else
		-- Return activator.
		return function(seqID, oldID, angle)
			-- Do nothing if we have no targets/sequence changes.
			if(seqID == oldID) then return; end
			if(not seqID) then
				cls:ApplyAction("DisplayRotation", display, 0, unpack(def));
			else
				cls:ApplyAction("DisplayRotation", display, angle, unpack(def));
			end
		end;
	end
end

--- Constructs the sequence editor for an action.
-- @param frame The frame to apply widgets to.
-- @param ...   The ID's to pass to Get/SetParameter calls.
function DisplayRotation:CreateSequenceEditor(frame, ...)
	-- Rotation slider.
	local rotate = PowerAuras:Create("P_Slider", frame);
	rotate:SetUserTooltip("DTexture_Rotation");
	rotate:SetMinMaxValues(0, 270);
	rotate:SetValueStep(90);
	rotate:LinkParameter("Sequence", 1, ...);
	rotate:SetRelativeWidth(0.35);
	rotate:SetPadding(4, 0, 2, 0);
	rotate:SetMinMaxLabels("%d°", "%d°");
	rotate:SetTitle(L["Rotation"]);
	frame:AddWidget(rotate);
end

--- Returns the target for this action. A target is what the action needs
--  to be applied to in order to work as intended.
function DisplayRotation:GetTarget()
	return "Display";
end

--- Upgrades an action from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function DisplayRotation:Upgrade(version, params)
end