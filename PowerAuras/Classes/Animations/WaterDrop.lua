-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Animation class definition.
local WaterDrop = PowerAuras:RegisterAnimationClass("WaterDrop", {
	--- Default parameters table.
	Parameters = {
		Speed = 1.0,
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
function WaterDrop:New(parameters, display, animtype)
	-- Create the animation.
	local group = display:CreateAnimationGroup();
	-- Scale high instantly.
	local scale = group:CreateAnimation("Scale");
	scale:SetOrder(1);
	scale:SetDuration(0);
	scale:SetScale(1.76, 1.76);
	-- Translate randomly.
	local translation = group:CreateAnimation("Translation");
	translation:SetOrder(1);
	translation:SetDuration(0);
	translation:SetOffset(0, 0);
	translation:SetScript("OnPlay", function(self)
		self:SetOffset(
			math.random(-display:GetWidth(), display:GetWidth()),
			math.random(-display:GetHeight(), display:GetHeight())
		);
	end);
	-- Scale downwards.
	local scale = group:CreateAnimation("Scale");
	scale:SetOrder(2);
	scale:SetDuration((1 / 5) * (1 / parameters["Speed"]));
	scale:SetScale(0.45 / 1.76, 0.45 / 1.76);
	scale:SetSmoothing("IN");
	-- Scale back out.
	local scale = group:CreateAnimation("Scale");
	scale:SetOrder(3);
	scale:SetDuration((4 / 5) * (1 / parameters["Speed"]));
	scale:SetScale(1.76 / 0.45, 1.76 / 0.45);
	scale:SetSmoothing("OUT");
	-- Also fade out.
	local alpha = group:CreateAnimation("Alpha");
	alpha:SetOrder(3);
	alpha:SetDuration((4 / 5) * (1 / parameters["Speed"]));
	alpha:SetChange(-1);
	alpha:SetSmoothing("OUT");
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
function WaterDrop:CreateAnimationEditor(frame, ...)
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
function WaterDrop:Upgrade(version, params)
	
end