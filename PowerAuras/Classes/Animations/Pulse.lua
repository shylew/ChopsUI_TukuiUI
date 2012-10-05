-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Animation class definition.
local Pulse = PowerAuras:RegisterAnimationClass("Pulse", {
	--- Default parameters table.
	Parameters = {
		Speed = 1.0,
		Scale = 1.08,
		Pulses = 1,
	},
	--- Supported animation types.
	Types = {
		Single = true,
		Repeat = true,
	},
});

--- Constructor function for the animation.
-- @param parameters Parameters for constructing the animation.
-- @param display    The display to create the animation for.
-- @param animtype   The type of animation to construct.
function Pulse:New(parameters, display, animtype)
	-- Create the animation.
	local group = display:CreateAnimationGroup();
	-- Simple pulse animation, copied from blizz kthx.
	local o = 1;
	for i = 1, parameters["Pulses"] do
		-- Create both scale anims.
		local scale = group:CreateAnimation("Scale");
		scale:SetOrder(o);
		scale:SetDuration(1* (1 / parameters["Speed"]));
		scale:SetScale(parameters["Scale"], parameters["Scale"]);
		scale:SetSmoothing("IN_OUT");
		local scale = group:CreateAnimation("Scale");
		scale:SetOrder(o + 1);
		scale:SetDuration(1 * (1 / parameters["Speed"]));
		scale:SetScale(1 / parameters["Scale"], 1 / parameters["Scale"]);
		scale:SetSmoothing("IN_OUT");
		-- Increment order.
		o = o + 2;
	end
	-- Loop?
	if(animtype == "Repeat") then
		group:SetLooping("REPEAT");
	end
	-- Done.
	return group;
end

--- Create the animation editor frame.
-- @param frame The frame to assign widgets to.
-- @param ...   ID's to use for Get/SetParameter calls.
function Pulse:CreateAnimationEditor(frame, ...)
	-- Construct sliders.
	local speed = PowerAuras:Create("P_SpeedBox", frame, 1.0);
	speed:LinkParameter("Animation", "Speed", 0, ...);
	speed:SetRelativeWidth(1 / 3);
	speed:SetPadding(4, 0, 2, 0);

	local scale = PowerAuras:Create("P_Slider", frame);
	scale:SetUserTooltip("AnimScale");
	scale:SetTitle(L["Scale"]);
	scale:SetMinMaxValues(0.5, 2.0);
	scale:SetMinMaxLabels("%.2f", "%.2f");
	scale:SetValueStep(0.01);
	scale:LinkParameter("Animation", "Scale", ...);
	scale:SetRelativeWidth(1 / 3);
	scale:SetPadding(2, 0, 2, 0);

	local pulses = PowerAuras:Create("P_NumberBox", frame);
	pulses:SetUserTooltip("APulse_Pulses");
	pulses:SetTitle(L["Pulses"]);
	pulses:SetMinMaxValues(1, 20);
	pulses:SetValueStep(1);
	pulses:LinkParameter("Animation", "Pulses", 0, ...);
	pulses:SetRelativeWidth(1 / 3);
	pulses:SetPadding(2, 0, 4, 0);

	-- Add widgets to frame.
	frame:AddWidget(speed);
	frame:AddWidget(scale);
	frame:AddWidget(pulses);
end

--- Upgrades an animation from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function Pulse:Upgrade(version, params)
	
end