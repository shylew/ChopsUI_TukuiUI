-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Animate action, runs a single animation upon a display when certain
--  criteria are met.
local Animate = PowerAuras:RegisterActionClass("Animate", {
	Parameters = {
		[1] = 1,
	},
});

--- Constructor function for the action. Generates and returns an activator.
-- @param id      The ID of the action.
-- @param params  Parameters for constructing the action.
-- @param display The display to attach the action to.
-- @param channel The channel this animation action is allowed to manage
--                animations on.
function Animate:New(id, parameters, display, channel)
	-- Generate the activator.
	return function(seqID, oldSeqID, animation)
		if(seqID and seqID ~= oldSeqID) then
			display:QueueAnimation(animation, false, channel);
		end
	end;
end

--- Constructs the sequence editor for an action.
-- @param frame The frame to apply widgets to.
-- @param ...   The ID's to pass to Get/SetParameter calls.
function Animate:CreateSequenceEditor(frame, ...)
	-- Construct widgets.
	local edit = PowerAuras:Create("NumberBox", frame);
	edit:SetRelativeWidth(0.5);
	edit:SetTitle("[UL] Animation ID");
	edit:SetMinMaxValues(-1, PowerAuras.MAX_ANIMATIONS_PER_CHANNEL);
	edit:SetValue(tostring(PowerAuras:GetParameter("Sequence", 1, ...)));
	edit:ConnectParameter("Sequence", 1, edit.SetValue, ...);
	edit.OnValueUpdated:Connect(PowerAuras:Loadstring(([[
		local self, value = ...;
		PowerAuras:SetParameter("Sequence", 1, value, %s, %s);
	]]):format(tostringall(...))));
	frame:AddWidget(edit);
end

--- Returns a dictionary of parameter names that are ID numbers to other
--  resources.
-- @param params The parameters of the resource.
-- @param out    The table to fill.
function Animate:GetIDParameters(params, out)
	out[1] = "Animation";
end

--- Returns the target for this action. A target is what the action needs
--  to be applied to in order to work as intended.
function Animate:GetTarget()
	return "Animation";
end

--- Upgrades an action from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function Animate:Upgrade(version, params)
	
end