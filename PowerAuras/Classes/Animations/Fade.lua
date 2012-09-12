-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Applies an entry fade effect, for use by all Show animations.
-- @param display The display to apply the effect to.
-- @param group   The animation group to use.
-- @param speed   Animation speed.
function ApplyEntryFade(display, group, speed)
	-- Bit of a hackery-doo, force alpha to zero before playing.
	local alpha = group:CreateAnimation("Alpha");
	alpha:SetOrder(1);
	alpha:SetDuration(0);
	alpha:SetChange(-1);
	-- Simple fade in.
	local alpha = group:CreateAnimation("Alpha");
	alpha:SetOrder(2);
	alpha:SetDuration(1 * (1 / speed));
	alpha:SetChange(display:GetAlpha());
end

function ApplyExitFade(display, group, speed)
	-- Simple fade out.
	local alpha = group:CreateAnimation("Alpha");
	alpha:SetOrder(1);
	alpha:SetDuration(1 * (1 / speed));
	alpha:SetChange(-display:GetAlpha());
end

--- Animation class definition.
local Fade = PowerAuras:RegisterAnimationClass("Fade", {
	--- Default parameters table.
	Parameters = {
		Speed = 1.0,
	},
	--- Supported animation types.
	Types = {
		Show = true,
		Hide = true,
	},
});

--- Constructor function for the animation.
-- @param parameters Parameters for constructing the animation.
-- @param display    The display to create the animation for.
-- @param animtype   The type of animation to construct.
function Fade:New(parameters, display, animtype)
	-- Create the animation.
	local group = display:CreateAnimationGroup();
	-- Apply the fade effect.
	if(animtype == "Show") then
		-- Standard fade for show/hide anims.
		ApplyEntryFade(display, group, parameters["Speed"]);
	elseif(animtype == "Hide") then
		-- Standard fade for show/hide anims.
		ApplyExitFade(display, group, parameters["Speed"]);
	else
		error(L("ErrorAnimTypeInvalid", "Fade", animtype));
	end
	-- Done.
	return group;
end

--- Create the animation editor frame.
-- @param frame The frame to assign widgets to.
-- @param ...   ID's to use for Get/SetParameter calls.
function Fade:CreateAnimationEditor(frame, ...)
	-- Construct sliders.
	local speed = PowerAuras:Create("P_SpeedBox", frame, 1.0);
	speed:LinkParameter("Animation", "Speed", 0, ...);
	speed:SetRelativeWidth(1 / 3);
	speed:SetPadding(4, 0, 2, 0);

	-- Add widgets to frame.
	frame:AddWidget(speed);
end

--- Upgrades an animation from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function Fade:Upgrade(version, params)
	
end