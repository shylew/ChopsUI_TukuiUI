-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Dictionary of layout ID's to their instances.
local LayoutMap = {};

--- Returns the loaded layout frame for the passed layout ID.
-- @param id The ID of the loaded layout.
function PowerAuras:GetLoadedLayout(id)
	return LayoutMap[id] or error(L("ErrorLayoutNotLoaded", id));
end

--- Returns the dictionary of loaded layouts.
function PowerAuras:GetLoadedLayouts()
	return LayoutMap;
end

--- Checks if the passed layout ID has been loaded successfully.
-- @param id The layout ID to check the state of.
function PowerAuras:IsLayoutLoaded(id)
	return not not LayoutMap[id];
end

do
	--- Cache of metatables for each layout class.
	local classMTs = {};

	--- Attempts to load the layout with the specified ID.
	-- @param id The ID of the layout to load.
	-- @return True if the load was a success, or if the layout was already
	--         loaded prior to the call. False if loading failed, as well as
	--         the flags that were set.
	function PowerAuras:LoadLayout(id)
		-- Make sure ID is valid.
		if(not self:HasLayout(id)) then
			self:LogResourceMessage(1, "Layout", id, "MissingResource");
			return false;
		end
		-- Do nothing if it's already loaded.
		if(self:IsLayoutLoaded(id)) then
			return true;
		end
		-- Get the saved variable data.
		local data = self:GetLayout(id);
		-- Validate class exists.
		if(not self:HasLayoutClass(data["Type"])) then
			self:LogResourceMessage(1, "Layout", id, "MissingClass",
				data["Type"]);
			return false;
		end
		-- Get the layout class.
		local class = self:GetLayoutClass(data["Type"]);
		-- Construct the layout instance.
		local state, result = pcall(class.New, class, id, data["Parameters"]);
		if(not state) then
			-- Failed to load the layout.
			self:LogResourceMessage(1, "Layout", id, "Error", result);
			return false;
		end
		-- Flag as loaded.
		classMTs[class] = classMTs[class] or { __index = class };
		LayoutMap[id] = setmetatable(result, classMTs[class]);
		self:LogResourceMessage(3, "Layout", id, "Loaded");
		return true;
	end
end

--- Loads all of the layouts in the current active profile.
function PowerAuras:LoadLayouts()
	-- Now actually do the loading. 
	local loadFails = 0;
	-- Load displays.
	for id, _ in self:GetAllLayouts() do
		self:LoadLayout(id);
	end
end

--- Unloads the specified layout.
-- @param id     The ID of the layout to unload.
function PowerAuras:UnloadLayout(id)
	-- If not loaded, don't even bother.
	if(not self:IsLayoutLoaded(id)) then
		return;
	end
	-- Detatch all displays from the layout.
	local layout = LayoutMap[id];
	for id, display in pairs(self:GetLoadedDisplays()) do
		layout:UnregisterDisplay(display);
	end
	-- Remove from the map and change our load state.
	self:LogResourceMessage(3, "Layout", id, "Unloaded");
	LayoutMap[id] = nil;
end

--- Completely unloads all of our layouts.
function PowerAuras:UnloadLayouts()
	-- Clear GUI selections.
	if(PowerAuras.SetCurrentLayout) then
		PowerAuras:SetCurrentLayout(nil);
	end
	-- Unload all layouts.
	local map = self:GetLoadedLayouts();
	local id = next(map);
	while(id) do
		self:UnloadLayout(id);
		id = next(map, id);
	end
end

--- Upgrades all of the layouts in the active profile.
-- @param version The version to upgrade from.
function PowerAuras:UpgradeLayouts(version)
	-- Iterate over all layouts.
	for id, layout in self:GetAllLayouts() do
		-- Get the class of this layout.
		if(self:HasLayoutClass(layout["Type"])) then
			local class = self:GetLayoutClass(layout["Type"]);
			class:UpgradeLayout(version, layout["Parameters"]);
		end
	end
	-- Iterate over all displays.
	for id, display in self:GetAllDisplays() do
		-- Get the class that owns the layout.
		local layout = self:GetLayout(display["Layout"]["ID"]);
		if(self:HasLayoutClass(layout["Type"])) then
			local class = self:GetLayoutClass(layout["Type"]);
			class:UpgradeDisplay(version, display["Layout"]["Parameters"]);
		end
	end
end