-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Animation class definition.
local ZoomSpin = PowerAuras:RegisterAnimationClass("ZoomSpin", {
	--- Default parameters table.
	Parameters = {
		Speed = 1.0,
		Spins = 2,
		Scale = 1.5,
		Direction = 1,
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
function ZoomSpin:New(parameters, display, animtype)
	-- Create the animation.
	local group = display:CreateAnimationGroup();
	if(animtype == "Show") then
		-- Go to scale, then zoom towards inverse of target.
		local scale = group:CreateAnimation("Scale");
		scale:SetOrder(1);
		scale:SetDuration(0);
		scale:SetScale(parameters["Scale"], parameters["Scale"]);
		local scale = group:CreateAnimation("Scale");
		scale:SetOrder(2);
		scale:SetDuration(1 * (1 / parameters["Speed"]));
		scale:SetScale(1 / parameters["Scale"], 1 / parameters["Scale"]);
		-- Throw in the spinny winny.
		local rotation = group:CreateAnimation("Rotation");
		rotation:SetOrder(2);
		rotation:SetDuration(1 * (1 / parameters["Speed"]));
		rotation:SetDegrees(
			parameters["Direction"] * (360 * parameters["Spins"])
		);
		-- Standard fade for show/hide anims.
		ApplyEntryFade(display, group, parameters["Speed"]);
	elseif(animtype == "Hide") then
		-- Animate from current scale to target. Unlike the Show variant,
		-- the target is not the inverse (1 / scale).
		local scale = group:CreateAnimation("Scale");
		scale:SetOrder(1);
		scale:SetDuration(1 * (1 / parameters["Speed"]));
		scale:SetScale(parameters["Scale"], parameters["Scale"]);
		-- Throw in the spinny winny.
		local rotation = group:CreateAnimation("Rotation");
		rotation:SetOrder(1);
		rotation:SetDuration(1 * (1 / parameters["Speed"]));
		rotation:SetDegrees(
			parameters["Direction"] * (360 * parameters["Spins"])
		);
		-- Standard fade for show/hide anims.
		ApplyExitFade(display, group, parameters["Speed"]);
	elseif(animtype == "Single" or animtype == "Repeat") then
		-- Animate towards target.
		local scale = group:CreateAnimation("Scale");
		scale:SetOrder(1);
		scale:SetDuration(1 * (1 / parameters["Speed"]));
		scale:SetScale(parameters["Scale"], parameters["Scale"]);
		scale:SetSmoothing("IN_OUT");
		-- Fade out while scaling.
		local alpha = group:CreateAnimation("Alpha");
		alpha:SetOrder(1);
		alpha:SetDuration(1 * (1 / parameters["Speed"]));
		alpha:SetChange(-1);
		alpha:SetSmoothing("IN_OUT");
		-- Throw in the spinny winny.
		local rotation = group:CreateAnimation("Rotation");
		rotation:SetOrder(1);
		rotation:SetDuration(1 * (1 / parameters["Speed"]));
		rotation:SetDegrees(
			parameters["Direction"] * (360 * parameters["Spins"])
		);
		-- Loop?
		if(animtype == "Repeat") then
			group:SetLooping("REPEAT");
		end
	else
		error(L("ErrorAnimTypeInvalid", "ZoomSpin", animtype));
	end
	return group;
end

--- Create the animation editor frame.
-- @param frame The frame to assign widgets to.
-- @param ...   ID's to use for Get/SetParameter calls.
function ZoomSpin:CreateAnimationEditor(frame, ...)
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
	frame:AddWidget(scale);
	frame:AddWidget(spins);
	frame:AddWidget(dir);
end

--- Upgrades an animation from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function ZoomSpin:Upgrade(version, params)
	-- 5.0.0.A -> 5.0.0.O
	if(version < PowerAuras.Version("5.0.0.O")) then
		-- Added Direction.
		params.Direction = 1;
	end
end