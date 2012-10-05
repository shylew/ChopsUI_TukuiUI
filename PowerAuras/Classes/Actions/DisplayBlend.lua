-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Display action definition.
local DisplayBlend = PowerAuras:RegisterActionClass("DisplayBlend", {
	Parameters = {
		[1] = "ADD",
	},
});

--- Constructor function for the action. Generates and returns an activator.
-- @param id        The ID of the action.
-- @param params    Parameters for constructing the action.
-- @param display   The display to create the action for.
-- @param displayID The ID of the display.
-- @param cls       The class of the display.
function DisplayBlend:New(id, parameters, display, displayID, cls)
	-- Store the default target values.
	local def = cls:GetActionDefaults("DisplayBlend", display);
	-- Allow the display to override the action.
	if(display.OnBlend) then
		return display.OnBlend;
	else
		-- Return activator.
		return function(seqID, oldID, mode)
			-- Do nothing if we have no targets/sequence changes.
			if(seqID == oldID) then return; end
			if(not seqID) then
				cls:ApplyAction("DisplayBlend", display, unpack(def));
			else
				cls:ApplyAction("DisplayBlend", display, mode);
			end
		end;
	end
end

--- Constructs the sequence editor for an action.
-- @param frame The frame to apply widgets to.
-- @param ...   The ID's to pass to Get/SetParameter calls.
function DisplayBlend:CreateSequenceEditor(frame, ...)
	-- Blend mode.
	local blend = PowerAuras:Create("P_BlendDropdown", frame);
	blend:SetUserTooltip("Blend");
	blend:LinkParameter("Sequence", 1, ...);
	blend:SetRelativeWidth(0.3);
	blend:SetPadding(4, 0, 2, 0);
	frame:AddWidget(blend);
end

--- Returns the target for this action. A target is what the action needs
--  to be applied to in order to work as intended.
function DisplayBlend:GetTarget()
	return "Display";
end

--- Upgrades an action from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function DisplayBlend:Upgrade(version, params)
end