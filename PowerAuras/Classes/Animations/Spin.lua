-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Animation class definition.
local Spin = PowerAuras:RegisterAnimationClass("Spin", {
	--- Default parameters table.
	Parameters = {
		Speed = 1.0,
		Direction = 1,
		Spins = 1,
	},
	--- Supported animation types.
	Types = {
		Show = true,
		Hide = true,
		Single = true,
		Repeat = true,
	},
});

--- Constructor function for the animation.
-- @param parameters Parameters for constructing the animation.
-- @param display    The display to create the animation for.
-- @param animtype   The type of animation to construct.
function Spin:New(parameters, display, animtype)
	-- Create the animation.
	local group = display:CreateAnimationGroup();
	-- Simple spin animation with configurable spin counter.
	local rotation = group:CreateAnimation("Rotation");
	rotation:SetOrder(((animtype == "Show") and 2 or 1));
	rotation:SetDuration(1 * (1 / parameters["Speed"]));
	rotation:SetDegrees(parameters["Direction"] * (360 * parameters["Spins"]));
	-- Add a fade if it's a begin/end animation.
	if(animtype == "Show") then
		ApplyEntryFade(display, group, parameters["Speed"]);
	elseif(animtype == "Hide") then
		ApplyExitFade(display, group, parameters["Speed"]);
	elseif(animtype == "Repeat") then
		-- Loop if repeat.
		group:SetLooping("REPEAT");
	end
	-- Done.
	return group;
end

--- Create the animation editor frame.
-- @param frame The frame to assign widgets to.
-- @param ...   ID's to use for Get/SetParameter calls.
function Spin:CreateAnimationEditor(frame, ...)
	-- Construct sliders.
	local speed = PowerAuras:Create("P_SpeedBox", frame, 1.0);
	speed:LinkParameter("Animation", "Speed", 0, ...);
	speed:SetRelativeWidth(1 / 3);
	speed:SetPadding(4, 0, 2, 0);

	local spins = PowerAuras:Create("P_NumberBox", frame);
	spins:SetUserTooltip("ASpin_Spins");
	spins:SetTitle(L["Spins"]);
	spins:SetMinMaxValues(1, 20);
	spins:SetValueStep(1);
	spins:LinkParameter("Animation", "Spins", 0, ...);
	spins:SetRelativeWidth(1 / 3);
	spins:SetPadding(2, 0, 2, 0);

	local dir = PowerAuras:Create("P_Dropdown", frame);
	dir:SetUserTooltip("ASpin_Direction");
	dir:SetRelativeWidth(1 / 3);
	dir:SetPadding(2, 0, 4, 0);
	dir:SetTitle(L["ASpin_Direction"]);
	dir:AddCheckItem(-1, L["ASpin_CW"]);
	dir:AddCheckItem(1, L["ASpin_CCW"]);
	dir:LinkParameter("Animation", "Direction", ...);

	-- Add widgets to frame.
	frame:AddWidget(speed);
	frame:AddWidget(spins);
	frame:AddWidget(dir);
end

--- Upgrades an animation from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function Spin:Upgrade(version, params)
	-- 5.0.0.A -> 5.0.0.O
	if(version < PowerAuras.Version("5.0.0.O")) then
		-- Added Direction.
		params.Direction = 1;
	end
end