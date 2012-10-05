-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Animation class definition.
local Bounce = PowerAuras:RegisterAnimationClass("Bounce", {
	--- Default parameters table.
	Parameters = {
		Speed = 1.0,
		Decay = 0.65,
		Height = 400,
	},
	--- Supported animation types.
	Types = {
		Show = true,
	},
});

--- Constructor function for the animation.
-- @param parameters Parameters for constructing the animation.
-- @param display    The display to create the animation for.
-- @param animtype   The type of animation to construct.
function Bounce:New(parameters, display, animtype)
	-- Create the animation.
	local group = display:CreateAnimationGroup();
	if(animtype == "Show") then
		-- Inital height and path offsets.
		local height = parameters["Height"];
		local baseSeconds, order = 4, 2;
		-- Set initial offset.
		local translation = group:CreateAnimation("Translation");
		translation:SetOrder(1);
		translation:SetDuration(0);
		translation:SetOffset(0, height);
		-- We don't bounce a fixed number of times, rather we let you control
		-- the decay, which in turn controls the bounces.
		repeat
			-- Create path animation for this bounce.
			local path = group:CreateAnimation("Path");
			local down, up = nil, nil;
			path:SetOrder(order);
			path:SetCurve("SMOOTH");
			path:SetSmoothing("IN_OUT");
			-- Start by moving down.
			down = path:CreateControlPoint();
			down:SetOffset(0, -height);
			down:SetOrder(1);
			-- Get the decayed position.
			local decayedHeight = height * parameters["Decay"];
			-- If we're not moving much, quit.
			if(math.abs(height - decayedHeight) <= 2) then
				-- Change the smoothing mode of the drop, this prevents it
				-- from looking weird.
				path:SetSmoothing("IN");
				break;
			else
				-- Otherwise, up we go!
				up = path:CreateControlPoint();
				up:SetOffset(0, (decayedHeight - height));
				height = decayedHeight;
			end
			-- Set orders on points. This prevents a client crash.
			down:SetOrder(1);
			up:SetOrder(2);
			order = order + 1;
		until(order > 100);
		-- Adjust the order down 1. This will represent our total path count.
		order = order - 1;
		-- Total available time to animate.
		local duration = (baseSeconds * (1 / parameters["Speed"]));
		local firstPathDuration = 0;
		-- Adjust the duration of each path (bounce).
		local a = 0;
		for i = 1, select("#", group:GetAnimations()) do
			-- If the order of this animation is 1, skip.
			local anim = select(i, group:GetAnimations());
			if(anim:GetOrder() > 1) then
				-- The time allocated per segment starts off higher, and 
				-- decreases linearly over time.
				local base = (duration / order);
				local x = 2 - (((anim:GetOrder() - 1) * 2) / order) 
					+ (base * (parameters["Speed"] / baseSeconds));
				anim:SetDuration(x * base);
				a = a + (x * base);
				-- Is this the first path?
				if(anim:GetOrder() == 2) then
					firstPathDuration = (x * base);
				end
			end
		end
		-- Apply the fade animation at order 2.
		local alpha = group:CreateAnimation("Alpha");
		alpha:SetOrder(1);
		alpha:SetDuration(0);
		alpha:SetChange(-1);
		local alpha = group:CreateAnimation("Alpha");
		alpha:SetOrder(2);
		alpha:SetDuration(firstPathDuration);
		alpha:SetChange(display:GetAlpha());
	else
		error(L("ErrorAnimTypeInvalid", "Bounce", animtype));
	end
	-- Done.
	return group;
end

--- Create the animation editor frame.
-- @param frame The frame to assign widgets to.
-- @param ...   ID's to use for Get/SetParameter calls.
function Bounce:CreateAnimationEditor(frame, ...)
	-- Construct sliders.
	local speed = PowerAuras:Create("P_Slider", frame);
	speed:SetUserTooltip("ABounce_Speed");
	speed:SetTitle(L["Speed"]);
	speed:SetMinMaxValues(0.05, 5.0);
	speed:SetMinMaxLabels("%.2f", "%.2f");
	speed:SetValueStep(0.05);
	speed:LinkParameter("Animation", "Speed", ...);
	speed:SetRelativeWidth(1 / 3);
	speed:SetPadding(4, 0, 2, 0);

	local decay = PowerAuras:Create("P_Slider", frame);
	decay:SetUserTooltip("ABounce_Decay");
	decay:SetTitle(L["Decay"]);
	decay:SetMinMaxValues(0.05, 0.9);
	decay:SetMinMaxLabels("%.2f", "%.2f");
	decay:SetValueStep(0.05);
	decay:LinkParameter("Animation", "Decay", ...);
	decay:SetRelativeWidth(1 / 3);
	decay:SetPadding(2, 0, 2, 0);

	local height = PowerAuras:Create("P_Slider", frame);
	height:SetUserTooltip("ABounce_Height");
	height:SetTitle(L["Height"]);
	height:SetMinMaxValues(0, 1000);
	height:SetValueStep(50);
	height:LinkParameter("Animation", "Height", ...);
	height:SetRelativeWidth(1 / 3);
	height:SetPadding(4, 0, 4, 0);

	-- Add widgets to frame.
	frame:AddWidget(speed);
	frame:AddWidget(decay);
	frame:AddWidget(height);
end

--- Upgrades an animation from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function Bounce:Upgrade(version, params)
	
end