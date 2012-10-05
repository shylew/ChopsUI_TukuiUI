-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

local CurrentAnimType, CurrentCategory = nil, nil;
local CurrentPreviewAnim = nil;

function PowerAuras:RequiresAdvancedAnimEditor(id)
	-- Get the display data.
	if(not PowerAuras:HasAuraDisplay(id)) then
		return false;
	end
	local vars = PowerAuras:GetAuraDisplay(id);
	-- Rules: Can only have one channel (or zero).
	local triggered = vars.Animations.Triggered;
	if(not triggered) then
		vars.Animations.Triggered = { Single = {}, Repeat = {} };
		vars.Animations.Static = (vars.Animations.Static or {});
		triggered = vars.Animations.Triggered;
	end
	-- So, no triggered channels?
	triggered = triggered.Repeat;
	if(#(triggered) == 0) then
		return false;
	end
	-- More than 1?
	if(#(triggered) > 1) then
		return true;
	end
	-- Okay, rule #2: one animation.
	if(#(triggered[1].Animations) ~= 1) then
		return true;
	end
	-- Rule #3: action must be simple.
	local aVars = PowerAuras:GetAuraAction(triggered[1].Action);
	if(#(aVars.Triggers) ~= 1 or #(aVars.Sequences) ~= 1) then
		return true;
	end
	-- Rule 4: Only trigger must be a display state with specific params.
	local tri = aVars.Triggers[1];
	local params = tri.Parameters;
	if(tri.Type ~= "DisplayState" or params["ID"] ~= id
		or params["State"] ~= "Show") then
		return true;
	end
	-- Rule 5: Sequence must point to our only animation, and be simple.
	local seq = aVars.Sequences[1];
	if(seq.Operators ~= "1" or seq.Parameters[1] ~= 1) then
		return true;
	end
	-- Getting here should give you a damn achievement.
	return false;
end

local function OnPreviewSimpleAnim(self)
	-- Stop existing previews.
	if(CurrentPreviewAnim) then
		CurrentPreviewAnim:Stop();
		CurrentPreviewAnim = nil;
	end

	-- Create a new one.
	local vars = PowerAuras:GetAuraDisplay(
		self:GetParent():GetParent():GetParent():GetID()
	);
	local key = self:GetID();
	if(key == 1 and vars.Animations.Static.Show
		or key == 2 and vars.Animations.Static.Hide) then
		-- Get the animation data and class.
		local aType = (key == 1 and "Show" or "Hide");
		local anim = vars.Animations.Static[aType];
		local class = PowerAuras:GetAnimationClass(anim.Type);

		-- Construct a new instance upon our editor's preview frame.
		local target = PowerAuras.Editor.Displays.Preview;
		if(target and target.ActiveChild) then
			CurrentPreviewAnim = class:New(anim.Parameters, target, aType);
		end
	elseif(key == 3 and vars.Animations.Triggered.Repeat[1]) then
		-- Similar to static anims, kind of.
		local anim = vars.Animations.Triggered.Repeat[1].Animations[1];
		local class = PowerAuras:GetAnimationClass(anim.Type);

		-- Construct a new instance upon our editor's preview frame.
		local target = PowerAuras.Editor.Displays.Preview;
		if(target and target.ActiveChild) then
			CurrentPreviewAnim = class:New(anim.Parameters, target, "Single");
		end
	end

	-- Now play it.
	if(CurrentPreviewAnim) then
		CurrentPreviewAnim:Play();
	end
end

local function OnSimpleAnimTypeChanged(menu, key)
	-- Create the animation if not setting to none.
	local id = menu:GetID();
	local cType = (CurrentAnimType == 1 and "Show" or "Hide");
	if(CurrentAnimType ~= 3) then
		if(key ~= -1) then
			PowerAuras:CreateStaticAnimation(id, cType, key);
		else
			PowerAuras:DeleteStaticAnimation(id, cType);
		end
	else
		-- Store the node, 'cause this is screwy.
		local node = PowerAuras.Editor.Displays:GetCurrentNode();
		-- Repeat animation.
		cType = "Repeat";
		-- Does the animation exist, and are we not deleting it?
		local done = false;
		if(key ~= -1) then
			local vars = PowerAuras:GetAuraDisplay(id);
			if(vars.Animations.Triggered.Repeat[1]
				and vars.Animations.Triggered.Repeat[1].Animations[1]) then
				-- Yeah, it does.
				PowerAuras:CreateTriggeredAnimation(id, cType, 1, key, 1);
				done = true;
			end
		end
		-- Otherwise...
		if(not done) then
			-- Delete the channel.
			PowerAuras:DeleteAnimationChannel(id, cType, 1);
			-- Now re-create it if told to.
			if(key ~= -1) then
				-- Create the triggered animation + channel.
				local _, _, aID = PowerAuras:CreateAnimationChannel(id, cType);
				if(not _) then
					return;
				end
				-- Configure the action.
				PowerAuras:CreateAuraActionTrigger(aID, "DisplayState", 1);
				PowerAuras:SetParameter("Trigger", "ID", id, aID, 1);
				PowerAuras:SetParameter("Trigger", "State", "Show", aID, 1);
				PowerAuras:SetParameter("SequenceOp", "", "1", aID, 1);
				PowerAuras:SetParameter("Sequence", 1, 1, aID, 1);
				-- Add the animation.
				local _, tID = PowerAuras:CreateTriggeredAnimation(
					id, cType, 1, key, 1
				);
				if(not tID) then
					return;
				end
			end
		end
		-- Restore the node.
		CurrentAnimType = 3;
		PowerAuras.Editor.Displays:RefreshHost(node);
	end
end

local function OnSimpleContentRefreshed(frame, pane, key)
	-- Get the display and animation data.
	CurrentAnimType = key;
	local id = frame:GetID();
	local aType, cType, cID, aID;
	local vars = PowerAuras:GetAuraDisplay(id);
	local animData;
	if(key == 3 and not PowerAuras:RequiresAdvancedAnimEditor(id)) then
		-- Triggered repeat anim at index #1.
		aType = "Triggered";
		cType = "Repeat";
		cID = 1;
		aID = 1;
		animData = vars.Animations.Triggered.Repeat[1];
		animData = (animData and animData.Animations[1] or nil);
	elseif(key == 1 or key == 2) then
		-- Show/hide animations.
		aType = "Static";
		if(key == 1) then
			cType = "Show";
			animData = vars.Animations.Static.Show;
		else
			cType = "Hide";
			animData = vars.Animations.Static.Hide;
		end
	end

	-- Type switching dropdown.
	local animType = PowerAuras:Create("SimpleDropdown", pane);
	animType:SetUserTooltip("Animation_Type");
	animType:SetPadding(4, 0, 2, 0);
	animType:SetRelativeWidth(0.45);
	animType:SetTitle(L["AnimType"]);
	animType:AddCheckItem(-1, L["None"], not animData);
	animType:SetID(id);
	animType.OnValueUpdated:Connect(OnSimpleAnimTypeChanged);
	for i, k, name in PowerAuras:IterAnimationClasses() do
		local class = PowerAuras:GetAnimationClass(k);
		if(class:IsTypeSupported(cType)) then
			animType:AddCheckItem(k, name, animData and animData.Type == k);
		end
	end
	-- Set the text of the dropdown.
	if(animData and animType:HasItem(animData.Type)) then
		animType:SetText(animData.Type);
	else
		animType:SetText(-1);
	end
	-- Add dropdown to pane.
	pane:AddWidget(animType);
	pane:AddRow(4);

	-- And now do the configuring controls of configuration.
	if(animData and PowerAuras:HasAnimationClass(animData.Type)) then
		local class = PowerAuras:GetAnimationClass(animData.Type);
		class:CreateAnimationEditor(pane, id, aType, cType, cID, aID);
	end
end

local function OnSimpleTasksRefreshed(frame, pane, key)
	-- Add our preview button.
	local prev = PowerAuras:Create("IconButton", pane);
	prev:SetUserTooltip("Anim_Preview");
	prev:SetIcon([[Interface\OptionsFrame\VoiceChat-Play]]);
	prev:SetID(key);
	prev.OnClicked:Connect(OnPreviewSimpleAnim);
	pane:AddWidget(prev);

	-- Update pane width.
	pane:SetWidth(prev:GetFixedWidth() + 1);
end

function PowerAuras:CreateAnimationEditor(frame, node)
	-- Basic or advanced?
	local _, id, f1, _, _, s2 = self:SplitNodeID(node);
	if(f1 == 0) then
		-- List inlay for each category.
		local list = PowerAuras:Create("ListInlay", frame);
		list:SetRelativeSize(1.0, 1.0);
		list:SetPadding(-3, -6, -6, -8);
		list:PauseLayout();
		list:AddItem(1, L["OnShow"]);
		list:AddItem(2, L["OnHide"]);
		if(not self:RequiresAdvancedAnimEditor(id)) then
			list:AddItem(3, L["Repeat"]);
		end
		CurrentAnimType = (CurrentAnimType or 1);
		if(not list:HasItem(CurrentAnimType)) then
			CurrentAnimType = 1;
		end
		list:SetCurrentItem(CurrentAnimType);
		list.OnContentRefreshed:Connect(OnSimpleContentRefreshed);
		list.OnTasksRefreshed:Connect(OnSimpleTasksRefreshed);
		list:SetID(id);
		list:ResumeLayout();
		frame:AddWidget(list);
	else
		-- Advanced [NYI]
	end
end