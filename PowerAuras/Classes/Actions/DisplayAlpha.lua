-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Changes display alpha.
local DisplayAlpha = PowerAuras:RegisterActionClass("DisplayAlpha", {
	Parameters = {
		[1] = 1.0,
	},
});

--- Constructor function for the action. Generates and returns an activator.
-- @param id           The ID of the action.
-- @param params       Parameters for constructing the action.
-- @param display      The display to create the action for.
-- @param displayID    The ID of the display.
-- @param displayClass The class of the display.
function DisplayAlpha:New(id, parameters, display, displayID, displayClass)
	-- Store the default target alpha.
	local def = displayClass:GetActionDefaults("DisplayAlpha", display);
	-- Allow the display to override the action.
	if(display.OnAlpha) then
		return display.OnAlpha;
	else
		-- Return activator.
		return function(seqID, oldID, alpha)
			-- Do nothing if we have no targets/sequence changes.
			if(seqID == oldID) then return; end
			if(not seqID) then
				displayClass:ApplyAction("DisplayAlpha", display, unpack(def));
			else
				displayClass:ApplyAction("DisplayAlpha", display, alpha);
			end
		end;
	end
end

--- Constructs the sequence editor for an action.
-- @param frame The frame to apply widgets to.
-- @param ...   The ID's to pass to Get/SetParameter calls.
function DisplayAlpha:CreateSequenceEditor(frame, ...)
	-- Alpha box.
	local numbah = PowerAuras:Create("P_Slider", frame);
	numbah:SetUserTooltip("Opacity");
	numbah:SetMinMaxValues(0, 1);
	numbah:SetValueStep(0.05);
	numbah:LinkParameter("Sequence", 1, ...);
	numbah:SetRelativeWidth(0.4);
	numbah:SetPadding(4, 0, 2, 0);
	numbah:SetTitle(L["Alpha"]);
	frame:AddWidget(numbah);
end

--- Returns the target for this action. A target is what the action needs
--  to be applied to in order to work as intended.
function DisplayAlpha:GetTarget()
	return "Display";
end

--- Upgrades an action from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function DisplayAlpha:Upgrade(version, params)
end