-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Animation class definition.
local Wiggle = PowerAuras:RegisterAnimationClass("Wiggle", {
	--- Default parameters table.
	Parameters = {
		Speed = 1.0,
		Angle = 20,
	},
	--- Supported animation types.
	Types = {
		Show   = true,
		Hide   = true,
		Single = true,
		Repeat = true,
	},
});

--- Constructor function for the animation.
-- @param parameters Parameters for constructing the animation.
-- @param display    The display to create the animation for.
-- @param animtype   The type of animation to construct.
function Wiggle:New(parameters, display, animtype)
	-- Create the animation.
	local group = display:CreateAnimationGroup();
	-- Wiggle to the left.
	local rotation = group:CreateAnimation("Rotation");
	rotation:SetOrder(1);
	rotation:SetDuration(0.25 * (1 / parameters["Speed"]));
	rotation:SetDegrees((parameters["Angle"] / 2));
	-- Wiggle to the right.
	local rotation = group:CreateAnimation("Rotation");
	rotation:SetOrder(2);
	rotation:SetDuration(0.50 * (1 / parameters["Speed"]));
	rotation:SetDegrees(-parameters["Angle"]);
	-- Back to the center.
	local rotation = group:CreateAnimation("Rotation");
	rotation:SetOrder(3);
	rotation:SetDuration(0.25 * (1 / parameters["Speed"]));
	rotation:SetDegrees(parameters["Angle"] / 2);
	-- Apply fading/repeating as needed.
	if(animtype == "Show" or animtype == "Hide") then
		-- If show, jump to 0 alpha.
		if(animtype == "Show") then
			local alpha = group:CreateAnimation("Alpha");
			alpha:SetOrder(0);
			alpha:SetDuration(0);
			alpha:SetChange(-1);
		end
		-- Set our target.
		local target = (animtype == "Show" and display:GetAlpha()
				or -display:GetAlpha());
		-- Split the fade across all of the segments of our animation.
		local alpha = group:CreateAnimation("Alpha");
		alpha:SetOrder(1);
		alpha:SetDuration(0.25 * (1 / parameters["Speed"]));
		alpha:SetChange(target / 4);
		-- Segment #2.
		local alpha = group:CreateAnimation("Alpha");
		alpha:SetOrder(2);
		alpha:SetDuration(0.50 * (1 / parameters["Speed"]));
		alpha:SetChange(target / 2);
		-- Segment #3.
		local alpha = group:CreateAnimation("Alpha");
		alpha:SetOrder(3);
		alpha:SetDuration(0.25 * (1 / parameters["Speed"]));
		alpha:SetChange(target / 4);
	elseif(animtype == "Repeat") then
		group:SetLooping("REPEAT");
	end
	-- Done.
	return group;
end

--- Create the animation editor frame.
-- @param frame The frame to assign widgets to.
-- @param ...   ID's to use for Get/SetParameter calls.
function Wiggle:CreateAnimationEditor(frame, ...)
	-- Construct sliders.
	local speed = PowerAuras:Create("P_SpeedBox", frame, 1.0);
	speed:LinkParameter("Animation", "Speed", 0, ...);
	speed:SetRelativeWidth(1 / 3);
	speed:SetPadding(4, 0, 2, 0);

	local angle = PowerAuras:Create("P_Slider", frame);
	angle:SetUserTooltip("AWiggle_Angle");
	angle:SetTitle(L["Angle"]);
	angle:SetMinMaxValues(5, 355);
	angle:SetValueStep(5);
	angle:LinkParameter("Animation", "Angle", ...);
	angle:SetRelativeWidth(1 / 3);
	angle:SetPadding(2, 0, 2, 0);

	-- Add widgets to frame.
	frame:AddWidget(speed);
	frame:AddWidget(angle);
end

--- Upgrades an animation from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function Wiggle:Upgrade(version, params)
	
end