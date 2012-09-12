-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Creates and returns a profile with the given ID. If the profile already
--  exists, then it is not overwritten.
--  If the profile being created is the current profile, then a reload of the
--  auras will occur.
-- @param id    The ID of the profile to create and return.
-- @param reset If set to true, any existing profile will be reset.
function PowerAuras:CreateProfile(id, reset)
	if(reset or not self:HasProfile(id)) then
		GlobalDB["Profiles"][id] = {
			Auras = {},
			Layouts = {},
			Version = tostring(PowerAuras.CurrentVersion),
		};
	end
	-- If this was our current profile, reload.
	if(self:GetCurrentProfileID() == id) then
		self:UnloadProfile();
		self:LoadProfile(id);
	end
	-- Notify the UI.
	self.OnOptionsEvent("PROFILE_CREATED", id);
end

--- Destroys the requested profile. Does nothing if the profile doesn't exist.
--  If the destroyed profile is the current active one, then the current
--  profile ID will reset to the default, which may result in the profile
--  being recreated.
-- @param id The ID of the profile to destroy.
function PowerAuras:DeleteProfile(id)
	-- Destroy existing.
	if(self:HasProfile(id)) then
		GlobalDB["Profiles"][id] = nil;
		-- Notify the UI.
		self.OnOptionsEvent("PROFILE_DELETED", id);
		-- Was this ID the same as our current?
		if(id == self:GetCurrentProfileID()) then
			-- Load default.
			self:UnloadProfile();
			self:LoadProfile(self:GetDefaultProfileID());
		end
	end
end

--- Exports the profile with the given ID.
-- @param id The ID of the profile to export.
-- @return A string containing the exported profile, or nil if export failed.
function PowerAuras:ExportProfile(id)
	-- Validate profile exists.
	if(not self:HasProfile(id)) then
		return;
	end
	-- Get profile.
	return self:ExportTable(self:GetProfile(id));
end

--- Returns a table containing all defined profiles, with names as the keys
--  and the profiles themselves as values.
function PowerAuras:GetAllProfiles()
	return GlobalDB["Profiles"];
end

--- Returns the profile ID string of the current character based upon their
--  character realm and name.
function PowerAuras:GetDefaultProfileID()
	return string.format("%s - %s", UnitName("player"), GetRealmName());
end

--- Returns a profile with the specified ID.
-- @param id The ID of the profile to find.
function PowerAuras:GetProfile(id)
	assert(self:HasProfile(id), L("ErrorProfileIDInvalid", id));
	return GlobalDB["Profiles"][id];
end

--- Returns the total number of profiles.
function PowerAuras:GetProfileCount()
	return self:CountPairs(GlobalDB["Profiles"]);
end

--- Checks if the requested profile exists.
-- @param id The ID of the profile to find.
function PowerAuras:HasProfile(id)
	return not not (id and GlobalDB["Profiles"][id]);
end

--- Imports a profile string and assigns it the given ID.
-- @param id  The ID of the profile to create and import.
-- @param str The profile string to process.
-- @return True on success, false if an error occured.
function PowerAuras:ImportProfile(id, str)
	-- Load in the profile string.
	local loader, msg = loadstring(("return %s"):format(str));
	if(not loader) then
		self:PrintError(L("ErrorProfileImport", msg));
		return false;
	end
	-- Get the created table.
	local profile = loader();
	-- Does the profile we're making exist?
	local isCurrent = (self:GetCurrentProfileID() == id);
	if(self:HasProfile(id)) then
		-- Unload if we're replacing our current one.
		if(isCurrent) then
			self:UnloadProfile();
		end
		-- Delete current profile.
		self:DeleteProfile(id);
	end
	-- Recreate profile.
	GlobalDB["Profiles"][id] = profile;
	-- Load profile if we unloaded the current one.
	if(isCurrent) then
		self:LoadProfile(id);
	end
	return true;
end

--- Renames an existing profile, optionally making it a copy or a simple move
--  operation. If the renamed profile is the current active one, then the
--  current profile will be unloaded and reloaded with the new name, but only
--  if copy is false/nil.
-- @param id   The existing profile to rename.
-- @param name The new name of the profile.
-- @param copy If set to true, the original profile is left intact.
-- @return True on success, false if there was an issue.
function PowerAuras:RenameProfile(id, name, copy)
	-- Ensure profile with this ID exists.
	if(not self:HasProfile(id)) then
		return false;
	end
	-- Ensure no profile with the new name exists.
	if(self:HasProfile(name)) then
		return false;
	end
	-- Copy the profile.
	GlobalDB["Profiles"][name] = PowerAuras:CopyTable(self:GetProfile(id));
	-- Remove existing?
	if(not copy) then
		GlobalDB["Profiles"][id] = nil;
	end
	-- Notify the UI.
	self.OnOptionsEvent("PROFILE_RENAMED", id, name, copy);
	-- Did we just kill our own profile?
	if(id == self:GetCurrentProfileID() and not copy) then
		-- Unload/reload.
		self:UnloadProfile();
		self:LoadProfile(name);
	end
	return true;
end

--- Resets the requested profile. Does nothing if the profile does not exist.
--  If the profile being reset is the current profile, then a reload of the
--  auras will occur.
-- @param id     The ID of the profile to reset.
-- @param create If set to true, the profile will also be created if it doesn't
--               exist.
function PowerAuras:ResetProfile(id, create)
	-- Call create with the reset parameter set to true.
	if(create or self:HasProfile(id)) then
		self:CreateProfile(id, true);
	end
end