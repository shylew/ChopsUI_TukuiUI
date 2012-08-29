-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

-- Modules.
local Metadata = PowerAuras:GetModules("Metadata");

--- Current style editor category.
local CurrentStyle = nil;

--- Current selected service (custom).
local CurrentService = nil;

--- Called when the service type dropdown is updated.
-- @param menu The menu frame.
-- @param key  The selected key.
local function OnManualServiceUpdated(menu, key)
	-- Update and refresh.
	CurrentService = key;
	menu:GetParent():GetParent():UpdatePage();
end

--- Called when the service class dropdown is updated.
-- @param menu The menu frame.
-- @param key  The selected key.
local function OnManualTypeUpdated(menu, key)
	-- Delete any existing interfaces of the current type on the provider.
	local pID = menu:GetID();
	PowerAuras:DeleteAuraProviderService(pID, CurrentService);
	-- Now create the new one and refresh.
	if(key ~= -1) then
		PowerAuras:CreateAuraProviderService(pID, CurrentService, key);
	end
end

--- Called when an optional source checkbox is toggled.
-- @param check The checkbox frame.
-- @param state The checked state.
local function OnOptSourceToggled(check, state)
	-- Get the current source flags.
	local optFlag = check:GetID();
	local _, id = PowerAuras:GetCurrentDisplay();
	local vars = PowerAuras:GetAuraDisplay(id);
	local optFlags = bit.band(vars["Flags"], Metadata.DISPLAY_OPTMASK);
	-- Are we enabling or disabling?
	if(state) then
		Metadata:SetDisplayFlags(id, bit.bor(optFlags, optFlag), "Opt");
	else
		Metadata:SetDisplayFlags(
			id,
			bit.band(optFlags, bit.bnot(optFlag)),
			"Opt"
		);
	end
	-- Update frame.
	check:GetParent():GetParent():UpdatePage();
end

--- Called when the source configuration mode is changed.
-- @param menu The menu frame.
-- @param key  The selected key.
local function OnSourceConfigModeChanged(menu, key)
	-- Close all menus.
	menu:CloseMenu();
	-- Update the mode and the pane.
	Metadata:SetDisplayFlags(menu:GetID(), key, "Source");
	menu:GetParent():GetParent():GetParent():UpdatePage();
end

--- Called when the chosen trigger ID has changed.
-- @param edit  The editbox widget.
-- @param value The selected value.
local function OnSourceTriggerChanged(edit, value)
	-- Update.
	local flags = PowerAuras:GetAuraDisplay(edit:GetID())["Flags"];
	Metadata:SetDisplayFlags(
		edit:GetID(),
		Metadata:SetFlagID(flags, value, "Trigger")
	);
	edit:GetParent():GetParent():UpdatePage();
end

--- Callback for when the active style category changes.
-- @param frame The list frame.
-- @param pane  The content frame.
-- @param key   The selected category key.
local function OnStyleContentRefreshed(frame, pane, key)
	-- Store key.
	CurrentStyle = key;
	local _, id = PowerAuras:GetCurrentDisplay();
	if(not key or not PowerAuras:HasAuraDisplay(id)) then
		return;
	end
	-- Population: Frames.
	local vars = PowerAuras:GetAuraDisplay(id);
	if(key == 0) then
		-- Style.
		local class = PowerAuras:GetDisplayClass(vars["Type"]);
		class:CreateStyleEditor(pane, id);
	elseif(key == 1) then
		-- Layout.
		local lVars = PowerAuras:GetLayout(vars["Layout"]["ID"]);
		local lClass = PowerAuras:GetLayoutClass(lVars["Type"]);
		lClass:CreateDisplayEditor(pane, id);
	elseif(key == 2) then
		-- Super-advanced display options.
		local class = PowerAuras:GetDisplayClass(vars["Type"]);
		if(class.CreateAdvancedStyleEditor) then
			class:CreateAdvancedStyleEditor(pane, id);
		end
		-- Source options. These vary based upon the metadata flags.
		local flags = vars["Flags"];
		local sFlags = bit.band(flags, Metadata.DISPLAY_SOURCEMASK);
		if(sFlags == Metadata.DISPLAY_SOURCE_AUTO
			or sFlags == Metadata.DISPLAY_SOURCE_TRIGGER) then

			-- Extract trigger ID.
			local fTri = Metadata:GetFlagID(flags, "Trigger");
			local aID = vars.Actions["DisplayActivate"];
			local aVars = PowerAuras:GetAuraAction(aID);
			local tri = aVars["Triggers"][fTri];

			-- Get services used by the display.
			local class = PowerAuras:GetDisplayClass(vars["Type"]);
			local services = class:GetAllServices();

			-- Allow picking a trigger ID in Trigger mode.
			local labelPl, labelMt = 4, 0;
			if(sFlags == Metadata.DISPLAY_SOURCE_TRIGGER) then
				-- Add numberbox for this.
				local box = PowerAuras:Create("NumberBox", pane);
				box:SetPadding(4, 0, 2, 0);
				box:SetRelativeWidth(0.25);
				box:SetTitle(L["Trigger"]);
				box:SetMinMaxValues(0, PowerAuras.MAX_TRIGGERS_PER_ACTION);
				box:SetValueStep(1);
				box:SetValue(fTri);
				box:SetID(id);
				box.OnValueUpdated:Connect(OnSourceTriggerChanged);
				-- Add widget to frame.
				pane:AddWidget(box);
				labelPl = 2;
				labelMt = 20;
			end

			-- Add label to tell the user what trigger is being used.
			local lab = PowerAuras:Create("Label", pane);
			lab:SetRelativeWidth(0.75);
			lab:SetFixedHeight(24);
			lab:SetPadding(labelPl, 0, 4, 0);
			lab:SetMargins(0, labelMt, 0, 0);
			lab:SetFontObject(GameFontHighlight);
			lab:SetJustifyH("LEFT");
			lab:SetJustifyV("MIDDLE");
			lab:SetText(L("UsingTrigger",
				fTri,
				tri and L["TriggerClasses"][tri["Type"]]["Name"]
					or _G.NONE
			));
			pane:AddWidget(lab);
			pane:AddRow(4);

			-- Add checkboxes for source types.
			local invalidTrigger = (not tri);
			if(tri) then
				-- Determine the supported conversions from this trigger.
				local tClass = PowerAuras:GetTriggerClass(tri["Type"]);
				for int, req in pairs(services) do
					local name = tClass:SupportsServiceConversion(int);
					if(name) then
						-- Add a checkbox for it.
						local check = PowerAuras:Create("Checkbox", pane);
						check:SetRelativeWidth(1.0);
						check:SetPadding(4, 0, 4, 0);
						check:SetText(L["ServiceClasses"][name][int]);
						-- Disable if required.
						check:SetEnabled(not req);
						-- Check the box if needed.
						local opt = Metadata["DISPLAY_OPT_" .. int:upper()];
						check:SetChecked((bit.band(vars["Flags"], opt) > 0));
						-- Callback handling.
						check:SetID(opt);
						check.OnValueUpdated:Connect(OnOptSourceToggled);
						-- Add to frame.
						pane:AddWidget(check);
					elseif(not name and req) then
						-- If this occurs, we've selected an invalid trigger.
						invalidTrigger = true;
						break;
					end
				end
			end

			-- Add a warning message if this is an invalid trigger.
			if(invalidTrigger) then
				-- Add pretty image.
				local warnImg = PowerAuras:Create("Texture", pane);
				warnImg:SetFixedSize(16, 16);
				warnImg:SetMargins(4, 0, 2, 0);
				warnImg:SetTexture(
					[[Interface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon]]
				);
				-- And the warninng label.
				local warnText = PowerAuras:Create("Label", pane);
				warnText:SetFontObject(GameFontHighlight);
				warnText:SetJustifyH("LEFT");
				warnText:SetJustifyV("TOP");
				warnText:SetRelativeWidth(1.0);
				warnText:SetMargins(-28, 0, 0, 0);
				warnText:SetPadding(28, 0, 4, 0);
				warnText:SetFixedHeight(128);
				warnText:SetText(L["InvalidAutoTrigger"]);

				-- Add frames to pane.
				pane:AddWidget(warnImg);
				pane:AddWidget(warnText);
			end
		else
			-- Manual config.
			local vars = PowerAuras:GetAuraDisplay(id);
			local class = PowerAuras:GetDisplayClass(vars["Type"]);
			local services = class:GetAllServices();
			local pID = vars["Provider"];
			if(PowerAuras:HasAuraProvider(pID)) then
				-- Get provider data.
				local pVars = PowerAuras:GetAuraProvider(pID);
				-- Attempt to fix the current type, but don't try too hard.
				if(not CurrentService or services[CurrentService] == nil) then
					CurrentService = next(class:GetRequiredServices());
					if(not CurrentService) then
						CurrentService = next(services);
					end
				end

				-- Double dropdowns man, what does it mean?
				local int = PowerAuras:Create("SimpleDropdown", pane);
				int:SetTitle(L["Service"]);
				int:SetPadding(4, 0, 2, 0);
				int:SetRelativeWidth(0.45);
				int:SetRawText(_G.NONE);
				-- Populate interfaces list.
				for _, key, name in PowerAuras:IterServiceInterfaces() do
					-- Only add if it can make use of it.
					if(services[key] ~= nil) then
						int:AddCheckItem(key, name, key == CurrentService);
						if(key == CurrentService) then
							int:SetText(key);
						end
					end
				end
				-- Callbacks.
				int.OnValueUpdated:Connect(OnManualServiceUpdated);
				pane:AddWidget(int);
				pane:AddStretcher();

				-- Bail now if we don't have a selected service.
				if(not CurrentService) then
					return;
				end
				
				-- Add types dropdown.
				local svc = PowerAuras:Create("SimpleDropdown", pane);
				svc:SetTitle(L["Type"]);
				svc:SetPadding(2, 0, 4, 0);
				svc:SetRelativeWidth(0.45);
				svc:SetID(pID);
				-- Allow selection of "None" (analogous to saying 'no thx').
				svc:SetRawText(_G.NONE);
				svc:AddCheckItem(-1, _G.NONE, true);
				-- Allow selection of types (omfg!).
				for _, key, name in PowerAuras:IterServiceClasses() do
					-- Implemented it?
					local hasImpl = PowerAuras:HasServiceClassImplemented(
						key, CurrentService
					);
					if(hasImpl) then
						-- Damn straight!
						svc:AddCheckItem(key, name, false);
						svc:SetItemTooltip(
							key,
							L["ServiceClasses"][key]["Tooltip"]
						);
					end
				end
				-- Callbacks.
				svc.OnValueUpdated:Connect(OnManualTypeUpdated);
				pane:AddWidget(svc);
				pane:AddRow(4);

				-- Now add the configuration for the current type.
				if(pVars[CurrentService]) then
					-- Get the service data.
					local sVars = pVars[CurrentService];
					local class = PowerAuras:GetServiceClassImplementation(
						sVars["Type"], CurrentService
					);
					-- Create the editor.
					class:CreateEditor(pane, pID, CurrentService);
					-- Also, update our service dropdown.
					if(svc:HasItem(sVars["Type"])) then
						svc:SetItemChecked(sVars["Type"], true);
						svc:SetItemChecked(-1, false);
						svc:SetText(sVars["Type"]);
					end
				end
			else
				-- TODO: Notify user that manual mode won't do jack shit.
			end
		end
	end
end

--- Callback for when the tasks list of the selected category is refreshed.
-- @param frame The list frame.
-- @param pane  The content frame.
-- @param key   The category key.
local function OnStyleTasksRefreshed(frame, pane, key)
	-- Process based upon the key.
	if(key == 2) then
		-- -- Source options. Get current display metadata.
		-- local _, id = PowerAuras:GetCurrentDisplay();
		-- local vars = PowerAuras:GetAuraDisplay(id);
		-- local c = bit.band(vars["Flags"], Metadata.DISPLAY_SOURCEMASK);
		-- -- Add a button for changing the source mode.
		-- local mode = PowerAuras:Create("SimpleDropdownIcon", pane);
		-- mode:SetID(id);
		-- mode:SetMargins(0, 0, 2, 0);
		-- mode:SetIcon([[Interface\WorldMap\Gear_64Grey]]);
		-- mode:SetIconTexCoord(0.2, 0.8, 0.2, 0.8);
		-- -- Add options.
		-- for k, v in pairs(Metadata) do
		-- 	if(k:sub(1, 15) == "DISPLAY_SOURCE_") then
		-- 		mode:AddCheckItem(v, L[k], v == c);
		-- 	end
		-- end
		-- -- Callback.
		-- mode.OnValueUpdated:Connect(OnSourceConfigModeChanged);
		-- -- Add button to pane.
		-- pane:AddWidget(mode);
		-- pane:SetWidth(mode:GetFixedWidth() + 3);
	end
end

--- Creates the style and layout editor pane.
-- @param frame The frame to apply widgets to.
-- @param node  The currently selected node.
function PowerAuras:CreateStyleEditor(frame, node)
	-- Get the display.
	local _, id = self:SplitNodeID(node);
	local vars = self:GetAuraDisplay(id);
	-- Construct the sections list.
	local list = PowerAuras:Create("ListInlay", frame);
	list:SetRelativeSize(1.0, 1.0);
	list:SetPadding(-3, -6, -6, -8);
	list:PauseLayout();
	-- Add subcategories.
	list:AddItem(0, L["Style"]);
	list:AddItem(1, L["LayoutPositioning"]);
	list:AddItem(2, L["DisplayClasses"][vars["Type"]]["Sources"]);
	-- Default to the style section unless told otherwise.
	list:SetCurrentItem(CurrentStyle or 0);
	-- Connect to callbacks.
	list.OnContentRefreshed:Connect(OnStyleContentRefreshed);
	list.OnTasksRefreshed:Connect(OnStyleTasksRefreshed);
	list:ResumeLayout();
	frame:AddWidget(list);
end