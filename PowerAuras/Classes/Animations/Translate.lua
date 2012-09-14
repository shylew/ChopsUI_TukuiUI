-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Animation class definition.
local Translate = PowerAuras:RegisterAnimationClass("Translate", {
	--- Default parameters table.
	Parameters = {
		Speed = 1.0,
		Position = {
			[1] = -100,
			[2] = 0,
		},
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
function Translate:New(parameters, display, animtype)
	-- Create the animation.
	local group = display:CreateAnimationGroup();
	if(animtype == "Show") then
		-- Jump to target.
		local translation = group:CreateAnimation("Translation");
		translation:SetOrder(1);
		translation:SetDuration(0);
		translation:SetOffset(unpack(parameters["Position"]));
		-- Now go back to center.
		local translation = group:CreateAnimation("Translation");
		translation:SetOrder(2);
		translation:SetDuration(1 * (1 / parameters["Speed"]));
		translation:SetOffset(
			-parameters["Position"][1],
			-parameters["Position"][2]
		);
		-- Standard fade for show/hide anims.
		ApplyEntryFade(display, group, parameters["Speed"]);
	elseif(animtype == "Hide") then
		-- Animate towards target.
		local translation = group:CreateAnimation("Translation");
		translation:SetOrder(1);
		translation:SetDuration(1 * (1 / parameters["Speed"]));
		translation:SetOffset(unpack(parameters["Position"]));
		-- Standard fade for show/hide anims.
		ApplyExitFade(display, group, parameters["Speed"]);
	else
		error(L("ErrorAnimTypeInvalid", "Translate", animtype));
	end
	-- Done.
	return group;
end

--- Create the animation editor frame.
-- @param frame The frame to assign widgets to.
-- @param ...   ID's to use for Get/SetParameter calls.
function Translate:CreateAnimationEditor(frame, ...)
	-- Construct sliders.
	local speed = PowerAuras:Create("P_SpeedBox", frame, 1.0);
	speed:LinkParameter("Animation", "Speed", 0, ...);
	speed:SetRelativeWidth(1 / 3);
	speed:SetPadding(4, 0, 2, 0);

	local x = PowerAuras:Create("P_NumberBox", frame);
	x:SetUserTooltip("ATranslate_X");
	x:SetTitle(L["X"]);
	x:SetMinMaxValues(-65535, 65535);
	x:SetValueStep(10);
	x:LinkParameter("Animation", "Position", 1, ...);
	x:SetRelativeWidth(1 / 3);
	x:SetPadding(4, 0, 2, 0);

	local y = PowerAuras:Create("P_NumberBox", frame);
	y:SetUserTooltip("ATranslate_Y");
	y:SetTitle(L["Y"]);
	y:SetMinMaxValues(-65535, 65535);
	y:SetValueStep(10);
	y:LinkParameter("Animation", "Position", 2, ...);
	y:SetRelativeWidth(1 / 3);
	y:SetPadding(2, 0, 4, 0);

	-- Add widgets to frame.
	frame:AddWidget(speed);
	frame:AddWidget(x);
	frame:AddWidget(y);
end

--- Upgrades an animation from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function Translate:Upgrade(version, params)
	
end