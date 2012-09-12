-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Animation class definition.
local Flashing = PowerAuras:RegisterAnimationClass("Flashing", {
	--- Default parameters table.
	Parameters = {
		Speed = 1.0,
		Flashes = 1,
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
function Flashing:New(parameters, display, animtype)
	-- Create the animation.
	local group = display:CreateAnimationGroup();
	local order = 1;
	for i = 1, parameters["Flashes"] do
		-- Fade out...
		local alpha = group:CreateAnimation("Alpha");
		alpha:SetOrder(order);
		alpha:SetDuration(0.5 * (1 / parameters["Speed"]));
		alpha:SetChange(-(display:GetAlpha() * 0.5));
		alpha:SetSmoothing("IN_OUT");
		-- And in!
		local alpha = group:CreateAnimation("Alpha");
		alpha:SetOrder(order + 1);
		alpha:SetDuration(0.5 * (1 / parameters["Speed"]));
		alpha:SetChange((display:GetAlpha() * 0.5));
		alpha:SetSmoothing("IN_OUT");
		-- Increment order.
		order = order + 2;
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
function Flashing:CreateAnimationEditor(frame, ...)
	-- Construct sliders.
	local speed = PowerAuras:Create("P_SpeedBox", frame, 1.0);
	speed:LinkParameter("Animation", "Speed", 0, ...);
	speed:SetRelativeWidth(1 / 3);
	speed:SetPadding(4, 0, 2, 0);

	local flashes = PowerAuras:Create("P_NumberBox", frame);
	flashes:SetUserTooltip("AFlashing_Flashes");
	flashes:SetTitle(L["Flashes"]);
	flashes:SetMinMaxValues(1, 20);
	flashes:SetValueStep(1);
	flashes:LinkParameter("Animation", "Flashes", 0, ...);
	flashes:SetRelativeWidth(1 / 3);
	flashes:SetPadding(2, 0, 2, 0);

	-- Add widgets to frame.
	frame:AddWidget(speed);
	frame:AddWidget(flashes);
end

--- Upgrades an animation from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function Flashing:Upgrade(version, params)
	
end