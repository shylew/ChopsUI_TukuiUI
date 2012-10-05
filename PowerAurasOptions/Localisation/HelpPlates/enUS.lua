-- Lock down local environment. Set function environment to the localization
-- table.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras.L);

-- Ensure current locale matches one on file.
-- if(GetLocale() != "enUS") then return; end

-- Browser/Editor tooltips.
Browser_NewAura = "New Aura";
Browser_NewAuraText = "Creates a new aura with a default Texture display.";

Browser_NewProfile = "New Profile";
Browser_NewProfileText = "Creates a new profile.";

Editor_MainTrigger = "Main Trigger";
Editor_MainTriggerText = "The trigger to use for activating this display.";

Editor_Invert = "Invert";
Editor_InvertText = "Inverts the trigger, making it match the opposite of the configured effect.";

Editor_EnableSupport = "Enable";
Editor_EnableSupportText = "Enables this support trigger, adding it to the list of checks to perform.";

Action_DA_Delay = "Delay";
Action_DA_DelayText = "The amount of seconds to delay showing this aura by.";

Action_DA_DelayModes = {
	[0] = { Text = "No Change", Tooltip = "The progress through the delay remains unchanged." },
	[1] = { Text = "Reset", Tooltip = "The progress through the delay is reset." },
	[2] = { Text = "Rolling", Tooltip = "The delay is extended by the chosen amount of seconds." },	
};

Action_DA_Duration = "Duration";
Action_DA_DurationText = "The length of time to show this display for. If set to 0, this will keep the display active for as long as the triggers remain active.";

Action_DA_DurationModes = {
	[0] = { Text = "No Change", Tooltip = "The progress through the duration remains unchanged." },
	[1] = { Text = "Reset", Tooltip = "The progress through the duration is reset." },
	[2] = { Text = "Rolling", Tooltip = "The duration is extended by the chosen amount of seconds." },	
};

Action_DA_RollingDelay = "Delay Mode";
Action_DA_RollingDelayText = "Controls what happens to the delay if the display deactivates, but then re-activates shortly after.";

Action_DA_RollingDuration = "Duration Mode";
Action_DA_RollingDurationText = "Controls what happens to the duration if the display deactivates, but then re-activates shortly after.";

Action_DA_Override = "Override";
Action_DA_OverrideText = "If checked, the delay/duration under this sequence take priority over the previous sequence.\n\n|cFFFFD000This is an advanced option, and has no effect inside of the basic editor.|r";

Action_DA_OverrideModes = {
	[0] = { Text = "No Change", Tooltip = "The progress through the delay/duration remains unchanged." },
	[1] = { Text = "Reset", Tooltip = "The progress through the delay/duration is reset." },
	[2] = { Text = "Rolling", Tooltip = "The delay/duration is extended by the chosen amount of seconds." },	
};

Action_DA_Immortal = "Immortal";
Action_DA_ImmortalText = "Controls what happens when the delay expires if the display is no longer active. If checked, the display will show anyway for the specified duration. If not checked, the display won't show at all.";

Action_DA_RollingOverride = "Override Mode";
Action_DA_RollingOverrideText = "Controls what happens to the existing delay/duration if the Override checkbox is checked.";

Aggro_MatchType     = "Match Type";
Aggro_MatchTypeText = "Changes the type of aggro matching used. Basic will check to see if any enemies are attacking you, whereas detailed can be customised for checking specific units.";

Aggro_ThreatSit     = "Threat Situation";
Aggro_ThreatSitText = "The threat situations to detect. The trigger will activate if the current situation is any of the checked options.";

Aggro_Track     = "Track";
Aggro_TrackText = "The type of information to be tracked.";

Aggro_Enemy     = "Enemy";
Aggro_EnemyText = "The hostile unit to check.";

Aggro_ThreatLevel = "Threat Level";
Aggro_ThreatLevelText = "The level of threat to use as a threshold.";

ComboPoints = "Combo Points";
ComboPointsText = "The amount of combo points to match.";

ComboPoints_Vehicle = "Vehicle Combo Points";
ComboPoints_VehicleText = "If checked, this will track the number of combo points your current vehicle has on the target.";

Dependency_AID = "Action";
Dependency_AIDText = "The ID of the action to depend upon. This is an advanced trigger type, if you want to make a display depend upon another display use Display State instead.";

Display_ID = "Display";
Display_IDText = "The ID of the display to depend upon. Click the button in the textbox to open the display selection dialog.";

Display_State = "State";
Display_StateText = "The states to match. The trigger will activate whenever the display is in any of the chosen states.";

GTFO_Type = "Type";
GTFO_TypeText = "The alert type to match.";

GTFO_Duration = "Duration";
GTFO_DurationText = "The amount of time to keep the trigger active for.";

GTFO_LowDamage = "Low Damage";
GTFO_HighDamage = "High Damage";
GTFO_Fail = "Fail Alert";
GTFO_FriendlyFire = "Friendly Fire";

ItemOffCooldown_Match = "Item/Slot Name";
ItemOffCooldown_MatchText = "Type in either the name/ID of a specific item to track, of the name of an inventory slot to track and press enter.\n\nItem names must be spelled correctly, with proper casing, otherwise they won't work.\n\nInventory slots must be prefixed with 'Slot:' (eg. 'Slot:Trinket1') to work.\n\n|cFFFFD000Slots|r\nHead, Neck, Shoulder, Chest, Waist, Hand, Finger1, Finger2, Trinket1, Trinket2, Back, MainHand, OffHand, Tabard.";

Pet_Stance = "Stance";
Pet_StanceText = "The stances to match. The trigger will activate whenever the current stance matches any of the selected ones.";

Runes_Type = "Match Type";
Runes_TypeText = "Changes the basic matching behaviour of the trigger.";

SpellCharges_Match = "Spell Name/ID";
SpellCharges_MatchText = "The spell name (or ID) to match. Enter it here, and press enter to save it.";

SpellCharges_Charges = "Charges";
SpellCharges_ChargesText = "The number of charges to be matched.";

SpellCharges_StacksInvert = "Stacks: Invert";
SpellCharges_StacksInvertText = "Inverts the number of reported stacks, so that Stacks displays will show the missing number of charges.";

SpellCharges_TimeOverall = "Timer: Show Overall Time";
SpellCharges_TimeOverallText = "Reports the total time it will take to replenish all charges for this spell.\n\nUnchecking this will make timers show the amount of time until a single charge is restored.";

SpellCharges_CustomMax = "Custom Maximum";
SpellCharges_CustomMaxText = "Applies a custom number of maximum charges to the effect.\n\nThis can be used in conjunction with the |cFFFFD000Stacks: Invert|r and |cFFFFD000Timer: Show Overall Time|r settings to alter the reported numbers.";

SpellOffCooldown_Match = "Spell Name/ID";
SpellOffCooldown_MatchText = "The spell name (or ID) to match. Enter it here, and press enter to save it.";

SpellOffCooldown_Usable = "Usable";
SpellOffCooldown_UsableText = "Checks to see if the spell is also usable.\n\nThis only checks to see if you have the required resources (eg. Mana) to cast the ability, and does not perform range checks.\n\n|cFFFFD000Note: |rThis should be unchecked if you invert the trigger, otherwise the behaviour may not be what you expect.";

SpellOffCooldown_IgnoreGCD = "Ignore GCD";
SpellOffCooldown_IgnoreGCDText = "Ignores the cooldown of the spell if the cooldown matches that of the global cooldown.";

SpellOffCooldown_IgnoreGCDEnd = "Ignore GCD End";
SpellOffCooldown_IgnoreGCDEndText = "If checked, then the trigger will activate if the spell will come off cooldown once any current active global cooldown is over.";

SpellOffCooldown_Known = "Known";
SpellOffCooldown_KnownText = "Checks to see if the spell is known to you, or your pet.\n\n|cFFFFD000Note: |rThis will cause issues with spells that replace other spells (Mage Bombs, Symbiosis, etc). Only check this option if you're sure you need it.";

Stance_Match = "Stance";
Stance_MatchText = "The stance to match. Select a stance from the dropdown.";

Totems_Totem = "Totem";
Totems_TotemText = "The totem to match in this slot. Select the totems to check for in this slot by using the dropdown.";

UnitAura_MatchDlg = "Buff/Debuff Matches";
UnitAura_MatchDlgText = "The buffs and debuffs to match.\n\nClicking this will open a dialog for configuring the effects that should cause this trigger to activate.";

UnitAura_MatchType = "Type";
UnitAura_MatchTypeText = "The type of effect to match.";

UnitAura_Unit = "Units";
UnitAura_UnitText = "The units to check for the matches on. You can either use a unit ID or name, or click the button in the textbox to select multiple unit types.";

UnitAura_Match = "Buff/Debuff Name";
UnitAura_MatchText = "The name or ID of the effect to be matched.";

UnitAura_Exact = "Exact";
UnitAura_ExactText = "If checked, this will check to see if any buffs/debuffs have the exact same name as entered above.";

UnitAura_Ignore = "Ignore Case";
UnitAura_IgnoreText = "If checked, any matching will be done without case-sensitivity.";

UnitAura_Pattern = "Use as Pattern";
UnitAura_PatternText = "Uses the match text as a Lua string pattern. Advanced option. If you want to match any effect, check this option and enter '.+' into the |cFFFFD000Buff/Debuff Name|r textbox.";

UnitAura_MatchTooltip = "Match Tooltip";
UnitAura_MatchTooltipText = "If checked, an optional check will also be performed on the tooltip of any effects. This check is done separately from the |cFFFFD000Buff/Debuff Name|r option.";

UnitAura_Tooltip = "Match Tooltip";
UnitAura_TooltipText = "The tooltip text to find.";

UnitAura_IsMine = "Is Mine";
UnitAura_IsMineText = "If checked, the matched effect must have been applied by your character.";

UnitAura_StealPurge = "Can Steal/Purge";
UnitAura_StealPurgeText = "If checked, the matched effect must either be stealable (via Spellsteal) or purgeable.";

UnitAura_Count = "Count";
UnitAura_CountText = "The number of stacks this effect must have.";

UnitAura_Source = "Source";
UnitAura_SourceText = "The stack count to use. This is an advanced option, but may be required for tracking the strength of certain effects such as Vengeance.";

UnitAuraType_Match = "Aura Types";
UnitAuraType_MatchText = "The effect types to match. The trigger will activate if any of these are present.";

UnitAuraType_MatchType = "Type";
UnitAuraType_MatchTypeText = "The types of effects to look at.";

UnitAuraType_Unit = "Units";
UnitAuraType_UnitText = "The units to check for the matches on. You can either use a unit ID or name, or click the button in the textbox to select multiple unit types.";

UnitAuraType_IsMine = "Is Mine";
UnitAuraType_IsMineText = "If checked, the matched effect must have been applied by your character.";

UnitAuraType_StealPurge = "Can Steal/Purge";
UnitAuraType_StealPurgeText = "If checked, the matched effect must either be stealable (via Spellsteal) or purgeable.";

UnitStats_Unit = "Unit";
UnitStats_UnitText = "The units to check. Enter either the name of a unit and press enter, or click the button in the textbox to open a dialog for selecting multiple units.";

UnitStats_Abs = "Absolute Values";
UnitStats_AbsText = "If not checked, this will perform a check based upon the percentage of the value (from 0-100).";

UnitStats_Value = "Value";
UnitStats_ValueText = "The value to match. The trigger will activate based upon this threshold.";

UnitPower_Resource = "Resource";
UnitPower_ResourceText = "The type of resource to check.";

WeaponEnchant_MainHand = "Main Hand";
WeaponEnchant_MainHandText = "The effect to match in the main hand weapon slot. Click the widget to open the match dialog.";

WeaponEnchant_OffHand = "Off Hand";
WeaponEnchant_OffHandText = "The effect to match in the off hand weapon slot. Click the widget to open the match dialog.";

WeaponEnchant_Count = "Count";
WeaponEnchant_CountText = "The time remaining that this effect must have.";

WeaponEnchant_CheckOff = "Check Offhand";
WeaponEnchant_CheckOffText = "Enables checking of the off hand weapon.";

WeaponEnchant_CheckMain = "Check Mainhand";
WeaponEnchant_CheckMainText = "Enables checking of the main hand weapon.";

DTexture_Path = "Texture";
DTexture_PathText = "The path to a texture to use. Click the button inside of the textbox to open the texture picking dialog.";

DTexture_Width = "Width";
DTexture_WidthText = "The width of the texture.";

DTexture_Height = "Height";
DTexture_HeightText = "The height of the texture.";

DTexture_Flip = "Flip";
DTexture_FlipText = "Flips the texture, either horizontally or vertically.";

DTexture_Rotation = "Rotation";
DTexture_RotationText = "Rotates the texture on the display.";

DTexture_Desaturate = "Desaturate";
DTexture_DesaturateText = "If checked, desaturates the texture.";

DTimer_Texture = "Texture";
DTimer_TextureText = "The texture to use for the timer display. Click the button inside of the textbox to open the texture picker dialog.";

DTimer_Secs99 = "Seconds at 99";
DTimer_Secs99Text = "If checked, the timer will count in seconds once there are 99 seconds remaining."

DTimer_ShowTenths = "Show Tenths";
DTimer_ShowTenthsText = "If checked, the timer will show tenths of seconds.";

DTimer_ShowHundredths = "Show Hundredths";
DTimer_ShowHundredthsText = "If checked, the timer will show hundredths of seconds.";

DTimer_ShowTimeActive = "Show Time Active";
DTimer_ShowTimeActiveText = "If checked, the timer will count upwards from activation.";

DTimer_HideLeading = "Hide Leading Zeroes";
DTimer_HideLeadingText = "If checked, the timer will not display leading zeroes.";

DTimer_TenthsBelow = "Tenths Below";
DTimer_TenthsBelowText = "If set to a value higher than 0, tenths of seconds will only display when the timer is at less than this value.";

DTimer_HundredthsBelow = "Hundredths Below";
DTimer_HundredthsBelowText = "If set to a value higher than 0, hundredths of seconds will only display when the timer is at less than this value.";

DTimerBar_Template = "Template";
DTimerBar_TemplateText = "The template to use for the bar. Click the button inside of the textbox to open the template picker dialog.";

DTimerBar_Invert = "Invert";
DTimerBar_InvertText = "Inverts the timer bar progress, so that it starts off full and gradually depletes.";

DStacks_Texture = "Texture";
DStacks_TextureText = "The texture to use for the stacks display. Click the button inside of the textbox to open the texture picker dialog.";

DStacks_WideDigits = "Wide Digits";
DStacks_WideDigitsText = "If checked, the digits will be doubled in width.";

DText_Font = "Font";
DText_FontText = "The font to use. Click the button inside of the textbox to open the font picker dialog.";

DText_Text = "Text";
DText_TextText = "[[TEMP]] The text to display. [[TODO: SUBSTITUTIONS LIST]] [[TODO:EXAMPLES]]";

DText_Outline = "Outline";
DText_OutlineText = "The outline to apply to the text.";

DText_Monochrome = "Monochrome";
DText_MonochromeText = "If checked, removes anti-aliasing from the text.";

DText_FontSize = "Font Size";
DText_FontSizeText = "Controls the size of the font.";

LFixed_Parent = "Parent Display";
LFixed_ParentText = "Anchors this display to another, making the position of this one relative to the linked one.\n\nLeave this empty if you don't want to attach this display to another.";

LFixed_X = "X";
LFixed_XText = "An X co-ordinate offset for the positioning.";

LFixed_Y = "Y";
LFixed_YText = "A Y co-ordinate offset for the positioning.";

LFixed_Anchor = "Anchor Point";
LFixed_AnchorText = "The main anchor point of the display.";

LFixed_Relative = "Relative Point";
LFixed_RelativeText = "The point to anchor to on the parent display.";

Opacity = "Opacity";
OpacityText = "Changes the opacity of the display.";

Layer = "Layer";
LayerText = "The layer that the display is placed on.";

Blend = "Blend";
BlendText = "Changes the alpha blending of the display.";

Scale = "Scale";
ScaleText = "Changes the scale of the display.";

Color = "Color";
ColorText = "Opens a color picker for selecting a color";

Operator = "Operator";
OperatorText = "The operator to use for the match.";

Unit     = "Unit";
UnitText = "The unit to be checked.";

AnimSpeed = "Duration";
AnimSpeedText = "The amount of seconds to play the animation for.";

Sound_Enable = "Enable Sound";
Sound_EnableText = "If checked, enables this sound.";

Sound_Path = "Sound";
Sound_PathText = "The path to the sound to play. Click the button inside of the textbox to open the sound picker dialog.";

Sound_Channel = "Channel";
Sound_ChannelText = "The channel to play the sound on.";

Animation_Type = "Animation Type";
Animation_TypeText = "The type of animation to use.";

ABounce_Speed = "Speed";
ABounce_SpeedText = "The speed to bound at. Higher values are faster.";

ABounce_Decay = "Decay";
ABounce_DecayText = "The rate to decay bounces at. Lower values will make the animation shorter in duration.";

ABounce_Height = "Height";
ABounce_HeightText = "The bounce height to start from.";

AFlashing_Flashes = "Flashes";
AFlashing_FlashesText = "The number of flashes.";

APulse_Pulses = "Pulses";
APulse_PulsesText = "The number of pulses.";

ASpin_Spins = "Spins";
ASpin_SpinsText = "The number of times to spin."

ASpin_Direction = "Direction";
ASpin_DirectionText = "The direction for the spin.";

ASpin_CW = "Clockwise";
ASpin_CCW = "Counter-Clockwise";

ATranslate_X = "X";
ATranslate_XText = "The X co-ordinate to move from, relative to the position of the display.";

ATranslate_Y = "Y";
ATranslate_YText = "The Y co-ordinate to move from, relative to the position of the display.";

AWiggle_Angle = "Angle";
AWiggle_AngleText = "The angle of the wiggle animation.";

AnimScale = "Scale";
AnimScaleText = "The scale of the animation.";

GActionUpdate = "Action Update Speed";
GActionUpdateText = "Controls the speed at which actions update.\n\nHigher values will ensure that the updates aren't split across multiple frames, lower values will slow down response times but reduce processing load.";

GSourceUpdate = "Source Update Speed";
GSourceUpdateText = "Controls the speed at which sources update.\n\nHigher values will ensure that the updates aren't split across multiple frames, lower values will slow down response times but reduce processing load.";

GUpdate = "Update Speed";
GUpdateText = "Controls the speed at which displays refresh.\n\nHigher values will appear to have less jumps/skips, lower ones will reduce processing load.\n\nLeaving this at 0 will make it run as fast as possible.";

CT_Timed = "Timed";
CT_TimedText = "If checked, the trigger will be rechecked every frame.";

CT_ToggleTimed = "Toggle Timed";
CT_ToggleTimedText = "If checked, the trigger will be allowed to toggle its timed check state.\n\nTo do so, call the following method within your trigger:\nPowerAuras:SetTriggerTimed(action, self, <state>);";

CT_Lazy = "Lazy";
CT_LazyText = "If checked, the trigger will support lazy rechecks. Lazy rechecks will make the trigger only be checked if it has been explicitly flagged.\n\nThis setting is ignored if the trigger is timed, or has dependencies.";

CT_Events = "Events";
CT_EventsText = "A dropdown containing the list of events this trigger is listening to. Click the New Event entry to add a new event.";

CT_DeleteEvent = "Delete Event";
CT_DeleteEventText = "Deletes the current event.";

CT_AutoEvent = "Automatic";
CT_AutoEventText = "If checked, this event is processed automatically and the trigger is flagged.";

CT_EventName = "Event Name";
CT_EventNameText = "The name of the API event to listen to.";

Anim_Preview = "Preview Animation";
Anim_PreviewText = "Previews the configured animation in this category.";

SupportTriggersHelp1 = "|cFFFFD000Showing trigger: |r%s |TInterface\\Common\\help-i:16:16:4:0:64:64:16:48:16:48:255:255:255|t";
SupportTriggersHelp2 = "You can cycle through other support triggers by using the arrow buttons inside of the header.";

WhereIsAbilityIcon = "Ability Icon"
WhereIsAbilityIconText = "The 'Use Ability Icon' setting is available in the 'Advanced Options' category, check the 'Use for Texture' checkbox.";

LinkedDisplayHelp = "This display is currently linked to a parent, and as such automatically inherits its activation criteria.";

LinkedDisplayInvert = "Invert";
LinkedDisplayInvertText = "Inverts the criteria, effectively making this display show whenever the parent is not showing.";

-- Browser/Editor help plate definitions.