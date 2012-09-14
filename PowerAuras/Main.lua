-- Lock down local environment.
PowerAuras = select(2, ...);
local PowerAuras = PowerAuras;
-- Set a metatable on the PowerAuras table allowing it to access globals.
setfenv(1, setmetatable(PowerAuras, { __index = _G }));

--- Callback object. Allows functions to be connected to it and will call
--  them all with the specified parameters as needed.
Callback = setmetatable({
	__index = {
		--- Connects a new callback function to the object.
		-- @param func The function to connect.
		Connect = function(self, func)
			-- Skip if there's no function.
			if(not func) then
				return;
			end
			-- Auto loadstring() the function if a string.
			if(type(func) == "string") then
				func = PowerAuras:Loadstring(func);
			end
			-- If it's already connected, don't add it.
			for i = #(self), 1, -1 do
				if(self[i] == func) then
					return;
				end
			end
			-- Add.
			tinsert(self, func);
		end,
		Debug = function(error)
			PowerAuras:PrintDebug("Callback Error: %s", error);
			return error;
		end,
		--- Disconnects a function from the object.
		-- @param func The function to disconnect.
		Disconnect = function(self, func)
			for i = #(self), 1, -1 do
				if(self[i] == func) then
					tremove(self, i);
					break;
				end
			end
		end,
		--- Pauses the firing of callbacks. This function is re-entrant.
		Pause = function(self)
			self.Paused = self.Paused + 1;
		end,
		--- Removes all callbacks. Does not reset the pause counter.
		Reset = function(self)
			for i = #(self), 1, -1 do
				self[i] = nil;
			end
		end,
		--- Resumes the firing of callbacks. This function is re-entrant.
		Resume = function(self)
			self.Paused = self.Paused - 1;
		end,
	},
	--- Called when a callback object is called. Runs all callbacks.
	-- @param ... Arguments to pass to callbacks.
	__call = function(self, ...)
		-- Do nothing if paused.
		if(self.Paused > 0) then return; end
		-- Transfer functions into a temporary table. This means our callbacks
		-- can safely modify the callback concurrently. As callbacks can 
		-- be recursively invoked, we track multiple states each time.
		local index = self.States.Current + 1;
		self.States.Current = self.States.Current + 1;

		-- Get table.
		local temp = wipe(self.States[index] or {});
		self.States[index] = {};
		for i = 1, #(self) do
			temp[i] = self[i];
		end

		-- Call all functions.
		self:Pause();
		for i = 1, #(temp) do
			-- Call the function.
			local state, err;
			if(not PowerAuras.DebugCallbacks) then
				state, err = pcall(temp[i], ...);
			else
				local args = { ... };
				state, err = xpcall(function()
					return temp[i](unpack(args));
				end, self.Debug);
			end

			-- Successful?
			if(not state) then
				PowerAuras:PrintError("Error: %s", err);
				PowerAuras:PrintDebug("Error: %s", err);
			end
		end
		self:Resume();

		-- Decrement current index count.
		self.States.Current = self.States.Current - 1;
	end,
}, {
	--- Constructor/call metamethod. Calling the Callback class will construct
	--  a new instance of the class.
	__call = function(self)
		return setmetatable({
			["Paused"] = 0,      -- Current pause counter.
			["States"] = {       -- Call state collection.
				["Current"] = 0  -- Current number of active states.
			},
			["Arguments"] = {},
		}, self);
	end,
});

--- Current addon version. Initialised during ADDON_LOADED.
CurrentVersion = nil;

--- Debug flag. Can test this if, for some reason, we need debug specific
--  things.
Debug = true;

--- If set to true, callbacks will use xpcall instead of pcall.
DebugCallbacks = false;

--- Default per-character settings table.
DefaultCharacterSettings = {};

--- Default global settings table.
DefaultGlobalSettings = {
	--- Maximum number of actions to process per frame.
	["ActionsPerFrame"]   = 1024,
	--- 4.x settings backups.
	["Backup"]            = {},
	--- Last version used. Defaults to 1.0.0.A.
	["LastVersion"]       = { 1, 0, 0, "A" },
	--- Maximum number of providers to process per frame.
	["ProvidersPerFrame"] = 1024,
	--- Throttle for per-display OnUpdate.
	["OnUpdateThrottle"]  = 0,
	--- Custom user-defined trigger types. AWW-YEAH.
	["Triggers"]          = {},
	--- Tutorial progress.
	["Tutorials"]         = {},
};

--- References to the global/character saved var tables.
GlobalDB, CharacterDB = nil, nil;

--- Per-character settings table. Initialised during LoadSavedVariables.
CharacterSettings = DefaultCharacterSettings;

--- Global settings table. Initialised during LoadSavedVariables.
GlobalSettings = DefaultGlobalSettings;

--- Frame used for processing ingame events.
Frame = CreateFrame("Frame");

--- Automagical lookup table for converting item names to ID's.
ItemIDLookup = setmetatable({}, {
	__index = function(self, item)
		-- Verify type.
		if(type(item) ~= "string") then
			return tonumber(item) or 0;
		end
		-- Get the link to the item.
		local _, link = GetItemInfo(item);
		-- Split the link to find the ID.
		local match = link and link:match("|Hitem:(%d+)");
		match = tonumber(match) or 0;
		-- Verify the name of the match is the same as our input.
		if(match > 0 and item ~= GetItemInfo(match)) then
			match = 0;
		end
		-- Store and return.
		self[item] = match;
		return match;
	end,
});

--- Localisation dictionary. Key represents a localization token, value is
--  the localised equivalent. See the Localisation folder for supported
--  translations.
L = setmetatable({}, {
	--- Called when the table is called as a function. Automatically runs
	--  string.format on the passed localization key with the specified
	--  parameters.
	-- @param key The localization key to retrieve.
	-- @param ... The parameters to pass to string.format.
	__call = function(self, key, ...)
		return self[key]:format(tostringall(...));
	end,

	--- Called when a non-existant localization key is accessed. Returns the
	--  key directly.
	-- @param key The key to find.
	__index = function(self, key)
		if(type(key) ~= "table" and not _G[key]) then
			self[key] = ("[UL] %s"):format(key);
			PowerAuras:PrintDebug("Missing localization key: %s", key);
			return self[key];
		else
			return _G[key];
		end
	end,
});

--- Last version used by the user. Only relevant to the GUI.
LastVersion = nil;

--- Submodules, because we have too many damn functions.
Modules = {};

--- Callback for when the ADDON_LOADED event fires for the main addon.
OnAddOnLoaded = PowerAuras:Callback();

--- Callback for handling certain events often relating to saved variables
--  in some way.
OnOptionsEvent = PowerAuras:Callback();

--- Callback for when the options addon has been loaded. Connect functions
--  to this and they will be called automatically. If you connect a function
--  to this callback after the addon has been loaded, then the function will
--  be called immediately.
OnOptionsLoaded = PowerAuras:Callback();
PowerAuras.OnOptionsLoaded:Connect(function()
	-- If it's our first run since a new version, pop up the changelog.
	if(PowerAuras.LastVersion < PowerAuras.CurrentVersion) then
		-- The changelog will make the workspace when we're done.
		PowerAuras:Create("Changelog");
	else
		PowerAuras["Workspace"] = PowerAuras:Create("Workspace");
	end
end);

--- Storage for all parameter callback functions.
OnParameterChanged = PowerAuras:Callback();

--- Global logging storage for the loading of resources. Acts as a sort of
--  debug log, but doesn't need the debugging flag to be enabled.
ResourceLoadLog = {};

--- Tooltip that can be used for scanning things. Cannot be used at a checkout.
ScanTooltip = CreateFrame("GameTooltip","PowerAurasTooltip",
	UIParent, "GameTooltipTemplate");

--- Automagical lookup table for converting spell names to ID's.
--  Only works if the spell is currently learned.
SpellIDLookup = setmetatable({}, {
	__index = function(self, spell)
		-- Verify type.
		if(type(spell) ~= "string") then
			return tonumber(spell) or 0;
		end
		-- Get the link to the spell.
		local link = GetSpellLink(spell);
		-- Split the link to find the ID.
		local match = link and link:match("|Hspell:(%d+)|h");
		match = tonumber(match) or 0;
		-- Verify the name of the match is the same as our input.
		if(match > 0 and spell ~= GetSpellInfo(match)) then
			match = 0;
		end
		-- Store and return.
		self[spell] = match;
		return match;
	end,
});

--- Current time. Used for profiling, represents the time the addon begun to
--  load (approximately).
StartTime = GetTime();

--- Simple frame that obeys the user's OnUpdateThrottle setting for limiting
--  updates.
Throttle = setmetatable({
	--- OnLoop script handler. Calls the necessary function.
	OnLoop = function(self)
		-- Update the animation duration and call the function.
		local dur = PowerAuras.GlobalSettings["OnUpdateThrottle"];
		if(dur == 0) then
			dur = 120;
		end
		-- Get the frame.
		local frame = self:GetParent();
		self.Anim:SetDuration(1 / dur);
		-- Get the time and pass the difference between now and then.
		local time = GetTime();
		frame:Callback(time - frame.LastUpdate);
		frame.LastUpdate = time;
	end,
}, {
	--- __call metamethod. Creates a new throttled update frame.
	__call = function(self, func)
		-- Create the throttled frame.
		local frame = CreateFrame("Frame");
		frame.Callback = func;
		frame.LastUpdate = GetTime();
		local dur = PowerAuras.GlobalSettings["OnUpdateThrottle"];
		if(dur == 0) then
			dur = 120;
		end

		-- Create the animation for handling the update.
		frame.Update = frame:CreateAnimationGroup();
		frame.Update:SetLooping("REPEAT");
		frame.Update.Anim = frame.Update:CreateAnimation();
		frame.Update.Anim:SetDuration(1 / dur);
		frame.Update:SetScript("OnLoop", self.OnLoop);
		return frame;
	end,
});

--- Version object. Represents an addon version based on passed string data.
Version = setmetatable({
	--- Metamethod handler for creating new table entries.
	__newindex = function(self)
		error("Attempted to insert a new key in to a Version object.");
	end,
	--- Metamethod handler for prettyprinting a version.
	__tostring = function(self)
		return ("%d.%d.%d.%s"):format(unpack(self));
	end,
	--- Metamethod handler for EQ (==).
	__eq = function(self, other)
		return self <= other and other <= self;
	end,
	--- Metamethod handler for LT (<).
	__lt = function(self, other)
		return self <= other and not (other <= self);
	end,
	--- Metamethod handler for LE (<=).
	__le = function(self, other)
		-- Compare versions, like a boss.
		for i = 1, #(self) do
			if(self[i] < other[i]) then
				return true;
			elseif(self[i] > other[i]) then
				return false;
			end
		end
		-- Getting this far means we're equal.
		return true;
	end,
}, {
	--- Constructs a new version table with comparison metatable.
	__call = function(self, version)
		-- Split version string up.
		local major, minor, build, rev;
		if(type(version) == "string") then
			major, minor, build, rev = 
				tostring(version):match("(%d+)\.(%d+)\.?(%d*)\.?(%a*)");
		elseif(type(version) == "table") then
			major, minor, build, rev = unpack(version);
		end
		-- Set.
		return setmetatable({
			[1] = (major ~= "" and tonumber(major) or 1),
			[2] = (minor ~= "" and tonumber(minor) or 0),
			[3] = (build ~= "" and tonumber(build) or 0),
			[4] = (rev ~= "" and rev or "A"),
		}, self);
	end,
});

--- Returns all modules in an unpacked list, in registration order.
-- @param ... If arguments are passed, only the named modules are returned,
--            and in the specified order.
function PowerAuras:GetModules(...)
	if(select("#", ...) == 0) then
		return unpack(self.Modules);
	else
		local t = {};
		for i = 1, select("#", ...) do
			for j = 1, #(self.Modules) do
				if(select(i, ...) == self.Modules[j].Name) then
					t[i] = self.Modules[j];
					break;
				end
			end
		end
		return unpack(t);
	end
end

--- Gets the resource load log table.
function PowerAuras:GetResourceLog()
	return self.ResourceLoadLog;
end

--- Loads the options addon if not already loaded.
-- @return True if the addon has been loaded, false and an error message if
--         not.
function PowerAuras:LoadOptionsAddOn()
	-- Check if enabled.
	local _, _, _, enabled, _, reason = GetAddOnInfo("PowerAurasOptions");
	if(not enabled) then
		return false, L("ErrorOptionsNotEnabled",
			_G[("ADDON_%s"):format(reason)]:lower());
	end
	-- Load the addon if needed.
	local loaded, reason = IsAddOnLoaded("PowerAurasOptions"), nil;
	if(not loaded) then
		loaded, reason = LoadAddOn("PowerAurasOptions");
		if(not loaded) then
			return false, L("ErrorOptionsNotEnabled",
				_G[("ADDON_%s"):format(reason)]:lower());
		else
			return true, "";
		end
	else
		return true, "";
	end
end

--- Initialises the saved variables tables, correcting any issues that are
--  found and loading the current character profile.
function PowerAuras:LoadSavedVariables()
	-- Initial setup, ensure the saved variable tables exist.
	if(not _G["PowerAurasCharacterDB"]) then
		_G["PowerAurasCharacterDB"] = {};
	end
	if(not _G["PowerAurasGlobalDB"]) then
		_G["PowerAurasGlobalDB"] = {};
	end

	-- Get the variables tables.
	local charVars = _G["PowerAurasCharacterDB"];
	local globVars = _G["PowerAurasGlobalDB"];
	GlobalDB, CharacterDB = globVars, charVars;

	-- Validate the per-char variables.
	charVars["Settings"] = (charVars["Settings"] or {});
	for key, value in pairs(DefaultCharacterSettings) do
		-- Use existing or overwrite.
		if(type(charVars["Settings"][key]) ~= type(value)) then
			charVars["Settings"][key] = value;
		end
	end

	-- Validate the global variables.
	globVars["Profiles"] = (globVars["Profiles"] or {});
	globVars["Settings"] = (globVars["Settings"] or {});

	-- Validate the global settings.
	for key, value in pairs(DefaultGlobalSettings) do
		-- Use existing or overwrite.
		if(type(globVars["Settings"][key]) ~= type(value)) then
			globVars["Settings"][key] = value;
		end
	end

	-- Validate the profile name in the per-char settings.
	if(not self:HasProfile(charVars["Profile"])) then
		-- If the profile name wasn't nil, then the profile is gone. Notify.
		if(charVars["Profile"] ~= nil) then
			self:PrintInfo(L("InfoProfileNotFound", charVars["Profile"],
				self:GetDefaultProfileID()));
		end
		-- Use default ID.
		charVars["Profile"] = self:GetDefaultProfileID();
	end

	-- Store table references.
	GlobalSettings = globVars["Settings"];
	CharacterSettings = charVars["Settings"];

	-- Load custom trigger types.
	self:LoadCustomTriggers();

	-- Load main profile.
	self:LoadProfile(charVars["Profile"]);
end

--- Logs a resource load message.
-- @param level The level of the message. Numeric, use a value between
--              1 and 3 where 1 is an error, 2 is a warning and 3 is just
--              general information.
-- @param type  The type of resource.
-- @param id    The ID of the resource.
-- @param msg   The message type of the resource. This should be a string
--              value from the ResourceLoadMessageTypes table.
-- @param ...   Additional arguments based upon the message type. No nil
--              values should be included.
function PowerAuras:LogResourceMessage(level, type, id, msg, ...)
	-- Check the current logging level and compare to the passed level.
	if(self.ResourceLoadLogLevel < level) then
		return;
	end
	-- Ensure the subtable for the type exists.
	local typeTable = self.ResourceLoadLog[type];
	if(not typeTable) then
		self.ResourceLoadLog[type] = {};
		typeTable = self.ResourceLoadLog[type];
	end
	-- Same for the ID of the resource.
	local idTable = typeTable[id];
	if(not idTable) then
		typeTable[id] = {};
		idTable = typeTable[id];
	end
	-- Store the message and the data.
	tinsert(idTable, { msg, type, id, ... });
	self:PrintDebug(
		self:FormatString(L["ResourceLogMsg" .. msg], type, id, ...)
	);
end

if(PowerAuras.Debug) then
	--- Debug log contents.
	local log = {};

	--- Debug filter dictionary.
	local filters = {};

	--- Callback for when the debug function logs a line.
	PowerAuras.OnDebugLogUpdated = PowerAuras:Callback();

	--- Prints a debug info message to the chat frame.
	-- @param message The base message to print. This can be a localization key.
	-- @param ...     Arguments to format into the message.
	-- @remarks Unlike other Print* functions, this one can be called
	--          directly (like PrintDebug()), without the PowerAuras prefix.
	function PowerAuras:PrintDebug(message, ...)
		-- Skip if filtered.
		if(filters[(self ~= PowerAuras and self or message)]) then
			return;
		end
		-- Recycle or create a table for our line data.
		local line = #(log) >= 1024 and tremove(log, 1) or {};
		wipe(line);
		-- Place the message into the line.
		local subOfs = 1;
		if(self ~= PowerAuras) then
			line[1], line[2] = self, message;
			subOfs = 2;
		else
			line[1] = message;
		end
		-- Insert format arguments. Don't format the string in advance.
		for i = 1, select("#", ...) do
			line[subOfs + i] = select(i, ...);
		end
		-- Include timestamp.
		line["Time"] = time();
		line["TimeMs"] = GetTime();
		-- Include the debug stack and locals.
		line["Stack"] = debugstack(2);
		line["Locals"] = debuglocals(2);
		-- Insert line.
		tinsert(log, line);
		PowerAuras.OnDebugLogUpdated();
	end

	--- Returns all of the lines in the debug log.
	function PowerAuras:GetDebugLog()
		return log;
	end

	--- Registers a debugging filter.
	-- @param format The message string to filter by.
	function PowerAuras:RegisterDebugFilter(format)
		-- Add to dictionary.
		filters[format] = true;
		-- Remove existing lines which meet this filter.
		for i = #(log), 1, -1 do
			if(log[i][1] == format) then
				tremove(log, i);
			end
		end
		-- Fire callback.
		PowerAuras.OnDebugLogUpdated();
	end

	do
		--- Temporary variable for copying.
		local copyText = "";
		
		--- Popup dialog for copying messages.
		StaticPopupDialogs["POWERAURAS_COPY_MESSAGE"] = {
			text = "Message:",
			button1 = "Affirmative",
			OnShow = function(self)
				self.editBox:SetText(copyText);
				self.editBox:HighlightText(0, -1);
			end,
			hideOnEscape = 1,
			timeout = 0,
			exclusive = 1,
			hasEditBox = true,
			enterClicksFirstButton = true,
			showAlert = true,
		};

		--- Opens the copy message dialog for the specified message ID.
		-- @param id The index of the line.
		function PowerAuras:CopyDebugMessage(id)
			-- Get the line data.
			local line = log[id];
			if(not line) then
				return;
			end
			-- Set the string.
			copyText = ("[%s]: %s\n\nStack Trace:\n%s\n\nLocals:\n%s"):format(
				date("%X", line["Time"]),
				tostring(line[1]):format(tostringall(unpack(line, 2))),
				line["Stack"] or _G["NONE"],
				line["Locals"] or _G["NONE"]
			);
			-- Show the dialog.
			StaticPopup_Show("POWERAURAS_COPY_MESSAGE");
		end
	end
else
	--- Stub equivalent of PrintDebug for when the Debug flag is not set.
	function PowerAuras:PrintDebug()
	end
end

--- Registers a submodule.
-- @param name   The name of the module.
-- @param module The module table. Optional.
function PowerAuras:RegisterModule(name, module)
	-- Add to list and return.
	module = module or {};
	module.Name = name;
	tinsert(self.Modules, module);
	return module;
end

--- Validates all registered resource classes.
function PowerAuras:ValidateResourceClasses()
	-- Run over all resource types.
	for i = 1, #(self.ResourceTypes) do
		local rtype = self.ResourceTypes[i];
		-- Resolve function names.
		local colName = ("Get%sClasses"):format(rtype);
		local valName = ("Validate%sClass"):format(rtype);
		-- Verify functions exist.
		if(not self[colName] or not self[valName]) then
			self:PrintError(
				"Resource type '%s' is missing function '%s'.",
				rtype,
				not self[colName] and colName or valName
			);
		else
			-- Get the registered classes and run over them all.
			local classes = self[colName](self);
			local name = next(classes);
			while(name) do
				local result, err = self[valName](self, name);
				if(not result) then
					self:PrintError(err);
				end
				name = next(classes, name);
			end
		end
	end
end

--- Slash command handler for /powa.
SlashCmdList["POWERAURAS"] = function(command)
	-- Split the command up.
	local iterator = command:gmatch("[^%s]+");
	local cmd = iterator();
	cmd = (cmd and cmd:lower());
	-- Handle commands.
	if(not cmd or cmd == "") then
		-- Toggle display.
		local loaded, msg = PowerAuras:LoadOptionsAddOn();
		if(loaded and PowerAuras.Workspace) then
			PowerAuras["Workspace"]:Toggle();
		elseif(not loaded) then
			PowerAuras:PrintError(msg);
		end
	elseif(cmd == "reset") then
		StaticPopup_Show("POWERAURAS_RESET_SV");
	elseif(cmd == "current") then
		local profile = PowerAuras:GetCurrentProfileID();
		PowerAuras:PrintInfo(L("InfoProfile", profile));
	elseif(cmd == "debug") then
		local loaded, msg = PowerAuras:LoadOptionsAddOn();
		if(loaded) then
			-- Create the window if needed.
			if(not PowerAuras["Debugger"]) then
				PowerAuras["Debugger"] = PowerAuras:Create(
					"DebugWindow", UIParent
				);
			end
			-- Toggle display.
			PowerAuras["Debugger"]:Toggle();
		elseif(not loaded) then
			PowerAuras:PrintError(msg);
		end
	elseif(cmd == "list") then
		PowerAuras:PrintInfo(L["InfoProfileList"]);
		for profile, _ in pairs(PowerAuras:GetAllProfiles()) do
			if(profile == PowerAuras:GetCurrentProfileID()) then
				PowerAuras:PrintInfo(L("InfoProfileMatch", profile));
			else
				PowerAuras:PrintInfo(profile);
			end
		end
	elseif(cmd == "disco") then
		DoEmote("dance", "player", false);
		UIErrorsFrame:AddMessage(L["DiscoModeEngage"]);
		print(L["DiscoModeEngage"]);
		PlaySoundFile([[Interface\AddOns\PowerAuras\Sounds\easter.ogg]],
			"MASTER");
	else
		-- Print help messages.
		PowerAuras:PrintInfo(L["InfoHelpCmdUsage"]);
		PowerAuras:PrintInfo(
			L("InfoHelpCmd", "current", L["InfoHelpCmdCurrent"])
		);
		PowerAuras:PrintInfo(
			L("InfoHelpCmd", "debug", L["InfoHelpCmdDebug"])
		);
		PowerAuras:PrintInfo(
			L("InfoHelpCmd", "list", L["InfoHelpCmdList"])
		);
		PowerAuras:PrintInfo(
			L("InfoHelpCmd", "reset", L["InfoHelpCmdReset"])
		);
	end
end;

-- Register our slash command handler.
_G["SLASH_POWERAURAS1"] = "/powa";

-- Dialogs.
PowerAuras.OnAddOnLoaded:Connect(function()
	StaticPopupDialogs["POWERAURAS_RESET_SV"] = {
		text = PowerAuras.L["DialogResetProfile"],
		button1 = PowerAuras.L["Yes"],
		button2 = PowerAuras.L["No"],
		OnAccept = function(self)
			PowerAuras:ResetProfile(PowerAuras:GetCurrentProfileID());
		end,
		hideOnEscape = 1,
		timeout = 0,
		exclusive = 1,
		showAlert = true,
	};

	StaticPopupDialogs["POWERAURAS_CREATE_PROFILE"] = {
		text = PowerAuras.L["DialogCreateProfile"],
		button1 = PowerAuras.L["Accept"],
		button2 = PowerAuras.L["Cancel"],
		OnAccept = function(self)
			local text = self.editBox:GetText();
			PowerAuras:CreateProfile(text);
		end,
		hideOnEscape = 1,
		timeout = 0,
		exclusive = 1,
		hasEditBox = true,
		enterClicksFirstButton = true,
		showAlert = true,
	};

	StaticPopupDialogs["POWERAURAS_DELETE_PROFILE"] = {
		text = PowerAuras.L["DialogDeleteProfile"],
		button1 = PowerAuras.L["Accept"],
		button2 = PowerAuras.L["Cancel"],
		OnAccept = function(self, profile)
			PowerAuras:DeleteProfile(profile);
		end,
		hideOnEscape = 1,
		timeout = 0,
		exclusive = 1,
		hasEditBox = false,
		enterClicksFirstButton = true,
		showAlert = true,
	};

	StaticPopupDialogs["POWERAURAS_RENAME_PROFILE"] = {
		text = PowerAuras.L["DialogRenameProfile"],
		button1 = PowerAuras.L["Accept"],
		button2 = PowerAuras.L["Cancel"],
		OnAccept = function(self, profile)
			local text = self.editBox:GetText();
			PowerAuras:RenameProfile(profile, text);
		end,
		hideOnEscape = 1,
		timeout = 0,
		exclusive = 1,
		hasEditBox = true,
		enterClicksFirstButton = true,
		showAlert = true,
	};
end);