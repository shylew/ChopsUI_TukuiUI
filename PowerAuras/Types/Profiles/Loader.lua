-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

-- Load modules.
local Coroutines, Metadata = PowerAuras:GetModules("Coroutines", "Metadata");

--- Current active profile ID as a string.
local ActiveProfileID = nil;

--- Current active profile table.
local ActiveProfile = nil;

--- Pending states for reloading.
local PendingLoad, PendingUnload = false, false;

--- Listen to OnOptionsEvent to not break due to coroutines.
PowerAuras.OnOptionsEvent:Connect(function(event)
	if(event == "COROUTINE_QUEUE_END") then
		-- Process pending stuff.
		if(PendingUnload) then
			PowerAuras:PrintInfo(L["ProfileUnloadDeferredGo"]);
			PowerAuras:UnloadProfile();
			PendingUnload = false;
		end

		if(PendingLoad) then
			PowerAuras:PrintInfo(L("ProfileLoadDeferredGo", PendingLoad));
			PowerAuras:LoadProfile(PendingLoad);
			PendingLoad = false;
		end
	end
end);

--- Returns the current active profile tahle.
function PowerAuras:GetCurrentProfile()
	return ActiveProfile;
end

--- Returns the current active profile ID string.
function PowerAuras:GetCurrentProfileID()
	return ActiveProfileID;
end

--- Checks if a profile has been loaded.
function PowerAuras:IsProfileLoaded()
	return (ActiveProfileID ~= nil);
end

--- Loads the requested profile, creating it if it doesn't already exist.
-- @param id The ID of the profile to load.
function PowerAuras:LoadProfile(id)
	-- Cancel if pending.
	if(Coroutines:Count() > 0) then
		PowerAuras:PrintInfo(L("ProfileLoadDeferred", id));
		PendingLoad = id;
		return;
	end
	-- Time loading in debug mode.
	local start;
	if(self.Debug) then
		start = debugprofilestop();
	end
	-- Is there a currently loaded profile?
	if(self:IsProfileLoaded()) then
		self:UnloadProfile();
	end
	-- Create if it doesn't exist.
	if(not self:HasProfile(id)) then
		self:CreateProfile(id);
	end
	-- Set as active profile.
	ActiveProfileID = id;
	ActiveProfile = self:GetProfile(id);
	-- Store as active profile in character vars.
	CharacterDB["Profile"] = id;
	-- We require at least one layout, so create it.
	if(self:GetLayoutCount() == 0) then
		self:CreateLayout("Fixed");
	end
	-- Check the profile version.
	local version = self.Version(ActiveProfile["Version"]);
	if(version < self.CurrentVersion) then
		-- Begin profile upgrade.
		self:PrintInfo("Upgrading profile from %s to %s...", version,
			self.CurrentVersion);
		self:UpgradeLayouts(version);
		self:UpgradeAuras(version);
		self:UpgradeProfile(version);
		-- Getting here indicates success.
		ActiveProfile["Version"] = tostring(self.CurrentVersion);
		self:PrintSuccess("Upgrade successful!");
	elseif(version > self.CurrentVersion) then
		self:PrintError("Profile version is from the future. Aborting...");
		ActiveProfileID = nil;
		ActiveProfile = nil;
		return;
	end
	-- Load layouts and auras.
	if(not self:GetEditMode()) then
		self:LoadLayouts();
		self:LoadAuras();
		self:LoadDispatcher();
	end
	-- Notify the UI.
	self.OnOptionsEvent("PROFILE_LOADED", id);
	-- Force a GC cycle. It's a bit messy, but it's nice.
	if(not UnitAffectingCombat("player")) then
		collectgarbage("collect");
	end
	-- Dump the loading time.
	if(start) then
		PrintDebug("Load time: %.2fms", debugprofilestop() - start);
	end
end

--- Unloads the currently existing profile, unloading all of its resources too.
-- @remarks Despite the name, the profile isn't deactivated. It's still 
--          considered the 'currently active' profile, but all of the resources
--          it owns are unloaded.
function PowerAuras:UnloadProfile()
	-- No need to unload if we're already unloaded.
	if(not self:IsProfileLoaded()) then
		PowerAuras:PrintInfo(L["ProfileUnloadDeferred"]);
		return;
	end
	-- Defer unloading if we're processing stuff.
	if(Coroutines:Count() > 0) then
		PendingUnload = true;
		return;
	end
	-- Deregister all existing auras.
	self:UnloadDispatcher();
	self:UnloadLayouts();
	self:UnloadAuras();
	-- Unset the active profile ID.
	self.OnOptionsEvent("PROFILE_UNLOADED", ActiveProfileID);
end

--- Upgrades a profile from an old version to the current one. This function
--  is intended for upgrades which can't be handled by normal means in the
--  class Upgrade functions.
-- @param version The version to upgrade from.
function PowerAuras:UpgradeProfile(version)
end