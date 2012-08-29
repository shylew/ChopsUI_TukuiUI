-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Animation class definition.
local Zoom = PowerAuras:RegisterAnimationClass("Zoom", {
	--- Default parameters table.
	Parameters = {
		Speed = 1.0,
		Scale = 1.5,
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
function Zoom:New(parameters, display, animtype)
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
		-- Standard fade for show/hide anims.
		ApplyEntryFade(display, group, parameters["Speed"]);
	elseif(animtype == "Hide") then
		-- Animate from current scale to target. Unlike the Show variant,
		-- the target is not the inverse (1 / scale).
		local scale = group:CreateAnimation("Scale");
		scale:SetOrder(1);
		scale:SetDuration(1 * (1 / parameters["Speed"]));
		scale:SetScale(parameters["Scale"], parameters["Scale"]);
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
		-- Loop?
		if(animtype == "Repeat") then
			group:SetLooping("REPEAT");
		end
	else
		error(L("ErrorAnimTypeInvalid", "Zoom", animtype));
	end
	-- Done.
	return group;
end

--- Create the animation editor frame.
-- @param frame The frame to assign widgets to.
-- @param ...   ID's to use for Get/SetParameter calls.
function Zoom:CreateAnimationEditor(frame, ...)
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

	-- Add widgets to frame.
	frame:AddWidget(speed);
	frame:AddWidget(scale);
end

--- Upgrades an animation from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function Zoom:Upgrade(version, params)
	
end