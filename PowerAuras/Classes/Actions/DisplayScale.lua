-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Changes display size.
local DisplayScale = PowerAuras:RegisterActionClass("DisplayScale", {
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
function DisplayScale:New(id, parameters, display, displayID, displayClass)
	-- Store the default target scale.
	local def = displayClass:GetActionDefaults("DisplayScale", display);
	-- Allow the display to override the action.
	if(display.OnScale) then
		return display.OnScale;
	else
		-- Return activator.
		return function(seqID, oldID, scale)
			-- Do nothing if we have no targets/sequence changes.
			if(seqID == oldID) then return; end
			if(not seqID) then
				displayClass:ApplyAction("DisplayScale", display, unpack(def));
			else
				-- The scale action is supplied the original width and height.
				-- Not very clear, I admit.
				local w, h = unpack(def);
				w, h = w * scale, h * scale;
				displayClass:ApplyAction("DisplayScale", display, w, h);
			end
		end;
	end
end

--- Constructs the sequence editor for an action.
-- @param frame The frame to apply widgets to.
-- @param ...   The ID's to pass to Get/SetParameter calls.
function DisplayScale:CreateSequenceEditor(frame, ...)
	-- I need a numbah! I need a numbah till the end of the ni-ight!
	local numbah = PowerAuras:Create("P_Slider", frame);
	numbah:SetUserTooltip("Scale");
	numbah:SetMinMaxValues(0.05, 10);
	numbah:SetValueStep(0.05);
	numbah:LinkParameter("Sequence", 1, ...);
	numbah:SetRelativeWidth(0.4);
	numbah:SetPadding(4, 0, 2, 0);
	numbah:SetTitle(L["Scale"]);
	frame:AddWidget(numbah);
end

--- Returns the target for this action. A target is what the action needs
--  to be applied to in order to work as intended.
function DisplayScale:GetTarget()
	return "Display";
end

--- Upgrades an action from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function DisplayScale:Upgrade(version, params)
end