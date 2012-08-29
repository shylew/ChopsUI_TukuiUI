-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Collection of reusable frames for displays.
local DisplayFrameStore = {};

--- Dictionary of display ID's to the actual display frame.
local DisplayMap = {};

--- Creates a throttled OnUpdate handler for a display.
-- @param display  The display to modify.
-- @param func     The function to run.
local function CreateOnUpdateHandler(display, func)
	-- Kill any existing throttlers.
	display:SetScript("OnUpdate", nil);
	if(display.UpdateThrottle) then
		display.UpdateThrottle:Stop();
	end

	-- There's a function...Right?
	if(not func) then
		return;
	end

	-- Use an appropriate throttle method.
	local perFrame = PowerAuras.GlobalSettings["OnUpdateThrottle"];
	if(perFrame == 0) then
		-- OnUpdate directly.
		display:SetScript("OnUpdate", func);
	else
		-- Animation method.
		if(not display.UpdateThrottle) then
			local ag = display:CreateAnimationGroup();
			ag.Loop = ag:CreateAnimation();
			ag:SetLooping("REPEAT");
			display.UpdateThrottle = ag;
		end

		-- Apply script.
		display.UpdateThrottle:SetScript("OnLoop", function()
			func(display);
		end);
		display.UpdateThrottle.Loop:SetDuration(1 / perFrame);
		display.UpdateThrottle:Play();
	end
end

--- Returns the loaded display frame for the passed display ID.
-- @param id The ID of the loaded display.
function PowerAuras:GetLoadedDisplay(id)
	return DisplayMap[id] or error(L("ErrorDisplayNotLoaded", id));
end

--- Returns the dictionary of loaded displays.
function PowerAuras:GetLoadedDisplays()
	return DisplayMap;
end


--- Checks if the passed display ID has been loaded successfully.
-- @param id The display ID to check the state of.
function PowerAuras:IsDisplayLoaded(id)
	return not not DisplayMap[id];
end

--- Loads the requested display from its saved variables data.
-- @param id The display ID to load.
-- @return True if the load was a success, or if the display was already
--         loaded prior to the call. False if loading failed, as well as
--         the flags that were set.
function PowerAuras:LoadDisplay(id)
	-- Make sure ID is valid.
	if(not self:HasAuraDisplay(id)) then
		self:LogResourceMessage(1, "Display", id, "MissingResource");
		return false;
	end
	-- Do nothing if it's already loaded.
	if(self:IsDisplayLoaded(id)) then
		return true;
	end
	-- Get the saved variable data.
	local data = self:GetAuraDisplay(id);
	-- Validate class exists.
	if(not self:HasDisplayClass(data["Type"])) then
		self:LogResourceMessage(1, "Display", id, "MissingClass", data["Type"]);
		return false;
	end
	-- Get the display class.
	local class = self:GetDisplayClass(data["Type"]);
	-- Validate actions.
	for type, id in pairs(data["Actions"]) do
		-- Check it's not loaded and that the class exists.
		if(self:IsActionLoaded(id)) then
			self:LogResourceMessage(1, "Display", id, "DependencyLoaded",
				"Action", id);
			return false;
		elseif(not self:HasActionClass(type)) then
			self:LogResourceMessage(1, "Display", id, "MissingClass", type);
			return false;
		elseif(not class:IsActionSupported(type)) then
			self:LogResourceMessage(1, "Display", id, "UnsupportedClass", type);
			return false;
		end
		-- Validate the action class.
		local actionClass = self:GetActionClass(type);
		if(actionClass:GetTarget() ~= "Display") then
			self:LogResourceMessage(1, "Display", id, "InvalidTarget",
				actionClass:GetTarget());
			return false;
		end
	end
	-- Validate the layout.
	if(not PowerAuras:HasLayout(data["Layout"]["ID"])) then
		self:LogResourceMessage(1, "Display", id, "MissingLayout",
			data["Layout"]["ID"]);
		return false;
	elseif(not PowerAuras:IsLayoutLoaded(data["Layout"]["ID"])) then
		self:LogResourceMessage(1, "Display", id, "DependencyFailed",
			"Layout", data["Layout"]["ID"]);
		return false;
	end
	-- Validate data provider.
	local provider = nil;
	if(next(class:GetRequiredServices() or {}) or 
		(data["Provider"] and next(class:GetOptionalServices() or {}))) then
		-- Validate the provider has been loaded.
		local pid = data["Provider"];
		if(not self:HasAuraProvider(pid)) then
			self:LogResourceMessage(1, "Display", id, "MissingProvider", pid);
			return false;
		elseif(not self:IsProviderLoaded(pid)) then
			-- Try to load the provider.
			if(not self:LoadProvider(pid)) then
				self:LogResourceMessage(1, "Display", id, "DependencyFailed",
					"Provider", pid);
				return false;
			end
		end
		-- Store the provider ID.
		provider = pid;
		-- Verify the provider has the services we need.
		for int, _ in pairs(class:GetRequiredServices()) do
			if(not self:GetAuraProvider(pid)[int]) then
				self:LogResourceMessage(1, "Display", id, "MissingInterface",
					int);
				return false;
			end
		end
	end
	-- Attempt to reuse or create a frame.
	DisplayFrameStore[data["Type"]] = DisplayFrameStore[data["Type"]]
		or setmetatable({}, { __mode = "kv" });
	local store = DisplayFrameStore[data["Type"]];
	local frame = store[#(store)] or CreateFrame("Frame", nil, UIParent);
	-- Attach the display ID to the frame itself.
	frame:SetID(id);
	frame.Provider = (provider and self:GetLoadedProvider(provider));
	frame.Layout = self:GetLoadedLayout(data["Layout"]["ID"]);
	-- Connect the OnShow/OnHide scripts to our layout.
	frame:HookScript("OnShow", function(self)
		self.Layout:ActivateDisplay(self)
	end);
	frame:HookScript("OnHide", function(self)
		self.Layout:DeactivateDisplay(self)
	end);
	-- Construct display. Wrap this in a pcall to prevent errors occuring.
	local state, code = pcall(class.New, class, frame, id, data["Parameters"]);
	-- If this failed, then we errored out.
	if(not state) then
		frame:SetParent(UIParent);
		frame:ClearAllPoints();
		frame:Hide();
		self:LogResourceMessage(1, "Display", id, "Error", code);
		return false;
	end
	-- Set the OnUpdate script directly.
	CreateOnUpdateHandler(frame, frame.OnUpdate);
	-- Does the display support animations?
	if(class:SupportsAnimation()) then
		local state, res = self:LoadAnimations(id, data["Animations"], frame);
		if(not state) then
			-- Failed to load animations.
			frame:SetParent(UIParent);
			frame:ClearAllPoints();
			frame:SetScript("OnUpdate", nil);
			frame:Hide();
			self:LogResourceMessage(1, "Display", id, "Error",
				"Animations failed to load.");
			return false;
		end
	end
	-- Construct actions.
	for type, action in pairs(data["Actions"]) do
		if(not self:LoadAction(action, frame, id, class)) then
			self:LogResourceMessage(2, "Display", id, "DependencyFailed",
				"Action", action);
		end
	end
	-- Set our display as loaded.
	DisplayMap[id] = frame;
	-- Set state as loaded, we're done!
	tremove(store, #(store));
	self:LogResourceMessage(3, "Display", id, "Loaded");
	return true;
end

--- Unloads the specified display.
-- @param id     The ID of the display to unload.
function PowerAuras:UnloadDisplay(id)
	-- If not loaded, don't even bother.
	if(not self:IsDisplayLoaded(id)) then
		return;
	end
	-- Get the display.
	local display = DisplayMap[id];
	local data;
	if(self:HasAuraDisplay(id)) then
		data = self:GetAuraDisplay(id);
	end
	-- Fully hide the display.
	display:SetParent(UIParent);
	display:Hide();
	display:ClearAllPoints();
	display:SetScript("OnUpdate", nil);
	if(data) then
		tinsert(DisplayFrameStore[data["Type"]], display);
	end
	-- Unloading is as simple as removing from the map and changing the state.
	DisplayMap[id] = nil;
	display.Provider = nil;
	display.Layout = nil;
	local key = next(display);
	while(key) do
		if(type(display[key]) == "function") then
			display[key] = nil;
		end
		key = next(display, key);
	end
	self:LogResourceMessage(3, "Display", id, "Unloaded");
end