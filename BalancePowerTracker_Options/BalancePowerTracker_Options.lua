--[[
## Interface: 40200
## Title: BalancePowerTracker_Options
## Version: 1.0.1
## Author: Kurohoshi (EU-Minahonda)
## Notes: BPT's Options were moved into a new AddOn.

--CHANGELOG
v1.0.1: Width step changed from 5 to 1 pixel
		Move freely fixed
v1.0.0: Release
--]]
if BPT_OPT_STATUS then 
	BPT_OPT_STATUS = "ARDY"
	print("|c00a080ffBalancePowerTracker OPTIONS|r: ERROR: NOT LOADED")
	return 
elseif (select(2,UnitClass("player"))~="DRUID") then 
	BPT_OPT_STATUS = "!DRU" 
	print("|c00a080ffBalancePowerTracker OPTIONS|r: ERROR: NOT LOADED")
	return
end
BPT_OPT_STATUS = "INIT"

local function CreateOptions(self) 
	local buttonFacadeOptions = nil
	if not self.vars.lbfdisabled then
		buttonFacadeOptions = {
			type	= 'toggle',
			name	= "Use LBF",
			desc	= "Use ButtonFacade.",
			disabled = function() return self.vars.lbfdisabled or self.options.originalEclipseIcons end,
			get		= function () return self.options.lbf end,
			set		= function () self.options.lbf= not self.options.lbf self:CreateInterface() end,
			order	= 7,
		}
	end
	
	local propagateMSBT = nil
	local msbtOptions = nil
	if not self.vars.msbtdisabled then
		propagateMSBT = {
			type	= 'toggle',
			name	= "MSBT",
			desc	= "Fire warnings through Mik's Scrolling Battle Text.",
			disabled = function() return MikSBT.IsModDisabled() end,
			get		= function () return self.warnings.msbt.enabled and not MikSBT.IsModDisabled() end,
			set		= function () self.warnings.msbt.enabled = not self.warnings.msbt.enabled self:CreateInterface() end,
			order	= 14,
		}
		msbtOptions= {
			name	= "MSBT options",
			type	= 'group',
			order	= 99,
			disabled = function() return MikSBT.IsModDisabled() or not self.warnings.msbt.enabled end,
			args	= {
				sticky = {
					type	= 'toggle',
					name	= "Sticky",
					desc	= "Display warning as sticky",
					get		= function () return self.warnings.msbt.sticky end,
					set		= function () self.warnings.msbt.sticky= not self.warnings.msbt.sticky end,
					order	= 1,
				},
				fontSize	= {
					type	= 'range',
					name	= "Font Size",
					desc 	= nil,
					min		= 4,
					max		= 38,
					step    = 1,
					get		= function () return self.warnings.msbt.fontSize end,
					set		= function (info, new) self.warnings.msbt.fontSize = new; end,
					order	= 2,
				},
				ScrollArea	= {
					type	= 'select',
					name	= "Scroll Area",
					get		= function () return self.warnings.msbt.scrollArea; end,
					set		= function(info,new) self.warnings.msbt.scrollArea=new end,
					values	= function () 
								local temp ={}
								for scrollAreaKey, scrollAreaName in MikSBT.IterateScrollAreas() do
									temp[scrollAreaKey]= scrollAreaName
								end
								return temp 
							end,
					order	= 3,
				},
			},
		}
	end
	
	local options = { 
		name	= "BalancePowerTracker v"..self.vars.version,
		handler	= BalancePowerTracker,
		type	= 'group',
		args	= {
			reset	= {
				type	= 'execute',
				name	= "Reset",
				desc	= "Reset to defaults",
				func	= function () self:ResetOptions();self:CreateInterface();self:ReCheck(); self:RegisterCallback(); self:RegisterProbEclipseCallback(); print("|c00a080ffBalancePowerTracker|r: Reset done.") end,
				order	= 4,
			},
			enabled	= {
				type	= 'toggle',
				name	= "Enabled",
				desc	= "Enable/Disable the addon (stops working)",
				get		= function () return self.options.enabled end,
				set		= function () self.options.enabled = not self.options.enabled; 	BalancePowerTracker_SharedInfo.enabled = self.options.enabled; self:ReCheck() end,
				order	= 5,
			},
			Warning = {
			    type	= 'group',
				name	= "Warnings",
				order	= 10,
				args ={
					spellEffect = {
						type	= 'toggle',
						name	= "Virtual spell effects",
						desc	= "Use virtual info to show/hide Eclipse spell effects.",
						get		= function () return self.options.virtualSpellEffects end,
						set		= function ()self.options.virtualSpellEffects = not self.options.virtualSpellEffects; end,
						order	= 4,
					},
					header = {
						type	= 'header',
						name    ="Toogle ON/OFF each warning:",
						order = 5,
					},
					LEwarning = {
						type	= 'toggle',
						name	= "Lunar Eclipse Warning",
						desc	= "Enable/Disable Lunar Eclipse warnings.",
						get		= function () return self.warnings.options.warnLunar end,
						set		= function ()self.warnings.options.warnLunar = not self.warnings.options.warnLunar; end,
						order	= 6,
					},
					SEwarning = {
						type	= 'toggle',
						name	= "Solar Eclipse Warning",
						desc	= "Enable/Disable Solar Eclipse warnings.",
						get		= function () return self.warnings.options.warnSolar end,
						set		= function ()self.warnings.options.warnSolar = not self.warnings.options.warnSolar; end,
						order	= 7,
					},
					vLEwarning = {
						type	= 'toggle',
						name	= "Virtual Lunar Warning",
						desc	= "Enable/Disable virtual Lunar Eclipse warnings (Uses virtual energy).",
						get		= function () return self.warnings.options.warnVLunar end,
						set		= function ()self.warnings.options.warnVLunar = not self.warnings.options.warnVLunar; end,
						order	= 8,
					},
					vSEwarning = {
						type	= 'toggle',
						name	= "Virtual Solar Warning",
						desc	= "Enable/Disable virtual Solar Eclipse warnings (Uses virtual energy).",
						get		= function () return self.warnings.options.warnVSolar end,
						set		= function ()self.warnings.options.warnVSolar = not self.warnings.options.warnVSolar; end,
						order	= 9,
					},
					vFailedwarning = {
						type	= 'toggle',
						name	= "Failed Virtual Eclipse Warning",
						desc	= "Enable/Disable virtual failed Lunar/Solar Eclipse warnings (Uses virtual energy).",
						get		= function () return self.warnings.options.warnVFailed end,
						set		= function ()self.warnings.options.warnVFailed = not self.warnings.options.warnVFailed; end,
						order	= 10,
					},
					header2 = {
						type	= 'header',
						name    ="Toogle ON/OFF each warning type:",
						order = 11,
					},
					alert = {
						type	= 'toggle',
						name	= "Alert Warning",
						desc	= "Enable/Disable alert warnings.",
						get		= function () return self.warnings.alert.enabled end,
						set		= function ()self.warnings.alert.enabled = not self.warnings.alert.enabled end,
						order	= 12,
					},
					flash = {
						type	= 'toggle',
						name	= "Screen Flash Warning",
						desc	= "Enable/Disable screen flash warnings.",
						get		= function () return self.warnings.flasher.enabled end,
						set		= function ()self.warnings.flasher.enabled = not self.warnings.flasher.enabled; end,
						order	= 13,
					},
					sound_effects = {
						type	= 'toggle',
						name	= "Sound Effects",
						desc	= "Enable/Disable sound effects (Independent from the selected above).",
						get		= function () return self.warnings.options.sound end,
						set		= function ()self.warnings.options.sound = not self.warnings.options.sound end,
						order	= 14,
					},
					msbt = propagateMSBT,
					masbt_options = msbtOptions,
					Alert_options = {
						name	= "Alert options",
						type	= 'group',
						order	= 97,
						disabled = function() return not self.warnings.alert.enabled end,
						args	= {
								move = {
									type	= 'toggle',
									name	= "Move",
									desc	= "Move Warning Frame",
									get		= function () return self.warnings.options.move end,
									set		= function () self.warnings:Move() end,
									order	= 1,
								},
								warningFontSize	= {
									type	= 'range',
									name	= "Font Size",
									desc 	= nil,
									min		= 18,
									max		= 40,
									step    = 1,
									get		= function () return self.warnings.options.fontSize end,
									set		= function (info, new) self.warnings.options.fontSize = new; self:CreateInterface() end,
									order	= 2,
								},
						},
					},
					sounds_effects = {
						name	= "Sound Effects",
						type	= 'group',
						order	= 98,
						disabled = function() return not self.warnings.options.sound end,
						args	= {
								lunar	= {
									type	= 'select',
									name	= "Lunar Eclipse",
									get		= function () return self.warnings.options.sounds.warnLunar; end,
									set		= function(info,new) self.warnings.options.sounds.warnLunar=new; PlaySoundFile(new) end,
									values	= function () return self.media.sound end,
									order	= 1,
								},
								solar	= {
									type	= 'select',
									name	= "Solar Eclipse",
									get		= function () return self.warnings.options.sounds.warnSolar; end,
									set		= function(info,new) self.warnings.options.sounds.warnSolar=new; PlaySoundFile(new) end,
									values	= function () return self.media.sound end,
									order	= 2,
								},
								vlunar	= {
									type	= 'select',
									name	= "Virtual Lunar Eclipse",
									get		= function () return self.warnings.options.sounds.warnVLunar; end,
									set		= function(info,new) self.warnings.options.sounds.warnVLunar=new; PlaySoundFile(new) end,
									values	= function () return self.media.sound end,
									order	= 3,
								},
								vsolar	= {
									type	= 'select',
									name	= "Virtual Solar Eclipse",
									get		= function () return self.warnings.options.sounds.warnVSolar; end,
									set		= function(info,new) self.warnings.options.sounds.warnVSolar=new; PlaySoundFile(new) end,
									values	= function () return self.media.sound end,
									order	= 4
								},
								vfailed	= {
									type	= 'select',
									name	= "Failed Virtual Eclipse ",
									get		= function () return self.warnings.options.sounds.warnVFailed; end,
									set		= function(info,new) self.warnings.options.sounds.warnVFailed=new; PlaySoundFile(new) end,
									values	= function () return self.media.sound end,
									order	= 5,
								},
						},
					},
					FullScreen_Flash_options = {
						name	= "Screen Flash otions",
						type	= 'group',
						order	= 99,
						disabled = function() return not self.warnings.flasher.enabled end,
						args	= {
								alpha	= {
									type	= 'range',
									name	= "Alpha",
									desc	= nil,
									min		= 0,
									max		= 1,
									step    = 0.05,
									get		= function () return self.warnings.flasher.alpha end,
									set		= function (info, new) self.warnings.flasher.alpha = new; self:CreateInterface() end,
									order	= 4,
								},
						},
					},
				},
			},
			Arrow = {
			    type	= 'group',
				name	= "Arrow",
				order	= 14,
				args ={
					arrow = {
						type	= 'toggle',
						name	= "Use Arrow",
						desc	= "Use arrow or spark.",
						get		= function () return self.options.usearrow end,
						set		= function () self.options.usearrow = not self.options.usearrow; self:CreateInterface() end,
						order	=1
					},
					vInfo = {
						type	= 'toggle',
						name	= "Use Virtual Info",
						desc	= "Use Virtual energy/direction.",
						get		= function () return self.options.showVirtualOnSpark end,
						set		= function () self.options.showVirtualOnSpark = not self.options.showVirtualOnSpark; self:RecalcEnergy(LibBalancePowerTracker:GetEclipseEnergyInfo())    end,
						order	= 8,
					},
					arrowScale	= {
						type	= 'range',
						name	= "Arrow scale",
						desc 	= "Scale of arrow",
						min		= .5,
						max		= 4,
						step    = 0.1,
						get		= function () return self.options.arrowScale end,
						set		= function (info, new) self.options.arrowScale = new; self:CreateInterface() end,
						order	= 15,
					},
				},
			},
			Icons = {
			    type	= 'group',
				name	= "Icon",
				order	= 15,
				args ={
					vInfo = {
						type	= 'toggle',
						name	= "Use Virtual Info",
						disabled = function () return self.options.hideIcon end,
						desc	= "Use Virtual eclipse/direction.",
						get		= function () return self.options.showVirtualOnIcon end,
						set		= function () self.options.showVirtualOnIcon = not self.options.showVirtualOnIcon; self:RecalcEnergy(LibBalancePowerTracker:GetEclipseEnergyInfo())    end,
						order	= 2,
					},
					highlightIcons	= {
						type	= 'select',
						disabled = function () return self.options.hideIcon or self.options.originalEclipseIcons end,
						name	= "Highlight type",
						get		= function ()	if  self.options.dynamicGlow then return 3;
												elseif self.options.highlightIcons then return 2;
												else return 1;
												end
								end,
						set		= 	function(info,new)	self.options.highlightIcons = new ~= 1
														self.options.dynamicGlow = new == 3
														self:UpdateEclipse()
									end,
						values	= function () return {[1]="None",[2]="Glow",[3]="Sparkle"} end,
						order	= 7,
					},
					bigIcon = {
						type	= 'toggle',
						name	= "Big icons",
						disabled = function () return self.options.hideIcon end,
						desc	= "Enlarge Eclipse icon you should aim to",
						get		= function () return self.options.bigIcons end,
						set		= function () self.options.bigIcons= not self.options.bigIcons self:CreateInterface() end,
						order	= 5,
					},
					hideIcon = {
						type	= 'toggle',
						name	= "Hide icons",
						desc	= "Hide Eclipse icons.",
						get		= function () return self.options.hideIcon end,
						set		= function () self.options.hideIcon= not self.options.hideIcon self:CreateInterface() end,
						order	= 1,
					},
					bigIconsScale	= {
						type	= 'range',
						name	= "Big icons Scale",
						disabled = function () return (not self.options.bigIcons) or self.options.hideIcon end,
						desc 	= "Scale of enlarged icons",
						min		= 1,
						max		= 4,
						step    = 0.1,
						get		= function () return self.options.bigIconScale end,
						set		= function (info, new) self.options.bigIconScale = new; self:CreateInterface() end,
						order	= 6,
					},
					IconsScale	= {
						type	= 'range',
						name	= "Icon base Scale",
						desc 	= "Scale of icons",
						disabled = function () return self.options.hideIcon end,
						min		= 0,
						max		= 3,
						step    = 0.1,
						get		= function () return self.options.normalIconScale end,
						set		= function (info, new) self.options.normalIconScale = new; self:CreateInterface() end,
						order	= 4,
					},
					originalEclipseIcons = {
						type	= 'toggle',
						name	= "Original Icon",
						disabled = function() return self.options.lbf end,
						desc	= "Use original Eclipse icons.",
						get		= function () return self.options.originalEclipseIcons end,
						set		= function () self.options.originalEclipseIcons= not self.options.originalEclipseIcons self:CreateInterface() end,
						order	= 7,
					},
					offset	= {
						type	= 'range',
						name	= "Offset",
						disabled = function () return self.options.hideIcon end,
						min		= -30,
						max		= 30,
						step    = 1,
						get		= function () return self.options.iconOffset end,
						set		= function (info, new) self.options.iconOffset = new; self:CreateInterface() end,
						order	= 3,
					},
					lbf = buttonFacadeOptions,
				},
			},
			Bars = {
			    type	= 'group',
				name	= "Bar",
				order	= 13,
				args ={
					addForeseenEnergyToBar 	= {
						type	= 'toggle',
						name	= "Show vEnergy",
						desc	= "Shows virtual energy as a middle bar.",
						get		= function () return self.options.addForeseenEnergyToBar   end,
						set		= function () self.options.addForeseenEnergyToBar  = not self.options.addForeseenEnergyToBar	self:RecalcEnergy(LibBalancePowerTracker:GetEclipseEnergyInfo())   self.frames.background.benergy:Hide() end,
						order	= 2,
					},
					moveSparkOnly	= {
						type	= 'toggle',
						name	= "Grow bars",
						desc	= "Bars grow & shrink with energy",
						get		= function () return not self.options.moveSparkOnly end,
						set		= function () self.options.moveSparkOnly = not self.options.moveSparkOnly; self:CreateInterface(); end,
						order	= 1,
					},
					colorBarDirection	= {
						type	= 'toggle',
						name	= "Color entire bar",
						desc	= "Entire bar gets colored based on direction.",
						get		= function () return self.options.colorBarDirection end,
						set		= function () self.options.colorBarDirection = not self.options.colorBarDirection; self:CreateInterface(); end,
						order	= 3,
					},
					showVirtualOnColoredBar	= {
						type	= 'toggle',
						name	= "Use vDirection",
						disabled = function () return not self.options.colorBarDirection end,
						desc	= "Use vDirection to color the entire bar.",
						get		= function () return self.options.showVirtualOnColoredBar end,
						set		= function () self.options.showVirtualOnColoredBar = not self.options.showVirtualOnColoredBar; self:RecalcEnergy(LibBalancePowerTracker:GetEclipseEnergyInfo()) ; end,
						order	= 4,
					},
					orientation	= {
						type	= 'select',
						name	= "Orientation",
						get		= function () 	if  self.options.vertical then return "Vertical" else return "Horizontal" end
								end,
						set		= 	function(info,new) 	self.options.vertical = new == "Vertical"
														self:CreateInterface(); 
									end,
						values	= function () local temp = {Vertical="Vertical",Horizontal="Horizontal"} return temp end,
						order	= 5,
					},
				},
			},
			Visibility = {
			    type	= 'group',
				name	= "Visibility",
				order	= 9,
				args ={
					alpha	= {
						type	= 'range',
						name	= "Alpha",
						desc	= nil,
						min		= 0,
						max		= 1,
						step    = 0.05,
						get		= function () return self.options.alpha end,
						set		= function (info, new) self.options.alpha = new; self:CreateInterface() end,
						order	= 4,
					},
					alphaOOC	= {
						type	= 'range',
						name	= "Alpha OOC",
						desc	= nil,
						min		= 0,
						max		= 1,
						step    = 0.05,
						get		= function () return self.options.alphaOOC end,
						set		= function (info, new) self.options.alphaOOC = new; self:CreateInterface() end,
						order	= 5,
					},
					visible	= {
						type	= 'toggle',
						name	= "Visible",
						desc	= "Hide/Show the addon (still working)",
						get		= function () return self.options.visible end,
						set		= function ()	self.options.visible = not self.options.visible;
												if self.options.visible then	
													if not UnitAffectingCombat("player") then 
														self.frames.background:SetAlpha(self.options.alphaOOC) 
													else 
														self.frames.background:SetAlpha(self.options.alpha)
													end
												else 
													self.frames.background:SetAlpha(0);
												end
												self:RecalcEnergy(LibBalancePowerTracker:GetEclipseEnergyInfo())   
								end,
						order	= 7,
					},
					showOptions	= {
						type	= 'select',
						disabled = function () return not self.options.visible; end,
						name	= "Show in form options",
						get		= function ()	if  self.options.showOOF then return 3;
												elseif self.options.showOIM then return 1;
												elseif self.options.showCustom then return 4;
												else return 2;
												end
								end,
						set		= 	function(info,new)	self.options.showOIM = new == 1;
														self.options.showOOF = new == 3;
														self.options.showCustom = new == 4;
														self:CheckHiddenStatus() self:RecalcEnergy(LibBalancePowerTracker:GetEclipseEnergyInfo())
									end,
						values	= function () return {[1]="Only in Moonkin",[2]="Moonkin and Caster",[3]="Every form",[4]="Customize"} end,
						order	= 8,
					},
					showCustomize	= {
						type	= 'multiselect',
						disabled = function () return (not self.options.showCustom) or (not self.options.visible); end,
						name	= "Customizable show in form",
						get		=	function(_,keyname)	return self.options.showCustomTable[keyname]; end,
						set		= 	function(_,keyname, state)
										self.options.showCustomTable[keyname] = state;
										self:CheckHiddenStatus() self:RecalcEnergy(LibBalancePowerTracker:GetEclipseEnergyInfo())
									end,
						values	= function () return {["1"]="Cat",["5"]="Bear",["31"]="Moonkin",["27"]="Flight",["3"]="Travel",["4"]="Aquatic",["nil"]="No Form"} end,
						order	= 9,
					},
				},
			},
			Text = {
			    type	= 'group',
				name	= "Text",
				order	= 16,
				args ={
					showText = {
						type	= 'toggle',
						name	= "Show Text",
						desc	= "Show/Hide energy text",
						get		= function () return self.options.showText end,
						set		= function () self.options.showText = not self.options.showText self:CreateInterface() end,
						order	= 1,
					},
					moveText = {
						type	= 'toggle',
						name	= "Move Text",
						disabled = function() return not self.options.showText end,
						desc	= "Take text out of the way, so you can see the arrow.",
						get		= function () return self.options.moveText end,
						set		= function () self.options.moveText = not self.options.moveText self:CreateInterface() end,
						order	= 4,
					},
					vInfo = {
						type	= 'toggle',
						name	= "Use Virtual Info",
						disabled = function() return not self.options.showText end ,
						desc	= "Display virtual energy.",
						get		= function () return self.options.showVirtualOnText end,
						set		= function () self.options.showVirtualOnText = not self.options.showVirtualOnText self:RecalcEnergy(LibBalancePowerTracker:GetEclipseEnergyInfo())    end,
						order	= 3,
					},
					autoFontSize = {
						type	= 'toggle',
						name	= "Auto size text",
						disabled = function() return not self.options.showText end ,
						desc	= "Display virtual energy.",
						get		= function () return self.options.autoFontSizeText end,
						set		= function () self.options.autoFontSizeText = not self.options.autoFontSizeText self:CreateInterface()    end,
						order	= 4,
					},
					fontSize	= {
						type	= 'range',
						name	= "Font size",
						disabled = function() return (not self.options.showText) or (self.options.autoFontSizeText) end ,
						desc	= nil,
						min		= 10,
						max		= 40,
						step    = 1,
						get		= function () return self.options.fontSizeText end,
						set		= function (info, new) self.options.fontSizeText = new; self:CreateInterface() end,
						order	= 5,
					},
					absolute = {
						type	= 'toggle',
						name	= "Absolute Value",
						disabled = function() return not self.options.showText end ,
						desc	= "Display absolute value of energy.",
						get		= function () return self.options.absoluteText end,
						set		= function () self.options.absoluteText = not self.options.absoluteText; self:RecalcEnergy(LibBalancePowerTracker:GetEclipseEnergyInfo()); end,
						order	= 6,
					},
				},
			},
			General = {
			    type	= 'group',
				name	= "General",
				order	= 6,
				args ={
					hideBlizzards = {
						type	= 'toggle',
						name	= "Hide Blizz",
						desc	= "Hide Blizz energy tracker",
						get		= function () return self.options.hideBlizzards end,
						set		= function () self.options.hideBlizzards = not self.options.hideBlizzards; self:CheckBlizzardFrameStatus() end,
						order	= 1,
					},
					header = {
						type	= 'header',
						name    ="Foresee Energy:",
						order = 4,
					},
					info = {
						type	= 'description',
						name	= "Foresee Energy is a feature the addon uses to analize the spells you have cast and/or you are casting but are yet to land and computes the energy sum of them. This allows the addon to distinguish between two kinds of each variable: One real, the one you have at the moment and other virtual, the one you'll have when all flying spells and the spell you are casting land.",
						order = 5,
					},
					info2 = {
						type	= 'description',
						name	= "Foresee Energy works assuming the following: \n       -You're hit capped.\n       -You're not going to proc Euphoria (2x energy gain).",
						order = 6,
					},
					info3 = {
						type	= 'description',
						name	= "All the features with the 'virtual' tag (virtual Energy, virtual Eclipse ...) rely on Foresee Energy.",
						order = 7,
					},
					foreseeEnergy 	= {
						type	= 'toggle',
						name	= "Foresee Energy",
						desc	= "Enable/Disable foresee energy.",
						get		= function () return self.options.foreseeEnergy   end,
						set		= function () self.options.foreseeEnergy  = not self.options.foreseeEnergy ;  self:RegisterCallback()   end,
						order	= 8,
					},
					info4 = {
						type	= 'description',
						name	= function() return "In this version, Foresee energy feature and energy track is provided by LibBalancePowerTracker v"..select(1,LibBalancePowerTracker:GetVersion()).."."..select(2,LibBalancePowerTracker:GetVersion()) end,
						order = 10,
					},
				},
			},
			Position = {
			    type	= 'group',
				name	= "Position",
				order	= 8,
				args ={
					move	= {
						type	= 'toggle',
						name	= 'Move freely',
						desc	= "Move the addon dragging it",
						get		= function () return self.vars.move end,
						set		= function () self:Move() end,
						order	= 4,
					},
					x	= {
						type	= 'range',
						name	= "X",
						desc	= nil,
						min		= -600,
						max		= 600,
						step    = 1,
						get		= function () return self.options.x end,
						set		= function (info, new) self.options.x = new; self:CreateInterface() end,
						order	= 1,
					},
					y	= {
						type = 'range',
						name = "Y",
						desc = nil,
						min	= -400,
						max	= 400,
						step = 1,
						get	= function () return self.options.y end,
						set	= function (info, new) self.options.y = new; self:CreateInterface() end,
						order = 2,
					},
					strata	= {
						type	= 'select',
						name	= "Strata",
						get		= function () 	for k,v in pairs(self.strataTable) do 
													if self.options.strata == v then 
														return k;
													end 
												end 
								end,
						set		= 	function(info,new) 	for k,v in pairs(self.strataTable) do 
															if new == k then 
																self.options.strata=v
															end 
														end 
														self:CreateInterface(); 
									end,
						values	= function () return self.strataTable end,
						order	= 5,
					},
					point	= {
						type	= 'select',
						name	= "Relative point",
						get		= function () 	return self.options.point	end,
						set		= function(info,new) 	self.options.point = new self:CreateInterface(); end,
						values	= function () return {TOPLEFT="TOPLEFT",TOPRIGHT="TOPRIGHT",BOTTOMLEFT="BOTTOMLEFT",BOTTOMRIGHT="BOTTOMRIGHT",TOP="TOP",BOTTOM="BOTTOM",LEFT="LEFT",RIGHT="RIGHT",CENTER="CENTER" }end,
						order	= 4,
					},
				},
			},
			Size = {
			    type	= 'group',
				name	= "Size",
				order	= 7,
				args ={
					height	= {
						type	= 'range',
						name	= "Bar Height",
						desc	= nil,
						min		= 8,
						max		= 24,
						step    = 1,
						get		= function () return self.options.height end,
						set		= function (info, new) self.options.height = new; self:CreateInterface() end,
						order	= 1,
					},
					width	= {
						type	= 'range',
						name	= "Bar Width",
						desc	= nil,
						min		= 50,
						max		= 400,
						step    = 1,
						get		= function () return self.options.width end,
						set		= function (info, new) self.options.width = new; self:CreateInterface() end,
						order	= 2,
					},
					scale	= {
						type	= 'range',
						name	= "Scale",
						desc	= nil,
						min		= 0.5,
						max		= 4.0,
						step    = 0.1,
						get		= function () return self.options.scale end,
						set		= function (info, new) self.options.scale = new; self:CreateInterface() end,
						order	= 3,
					},
				},
			},
			Colors = {
			    type	= 'group',
				name	= "Colors",
				order	= 12,
				args ={
					solarColor	= {
						type = 'color',
						name = "Solar Color",
						hasAlpha = true,
						desc = nil,
						get	= function ()local color = self.barColor.solarEnergyBar;return color.r, color.g, color.b, color.a end,
						set	= function (info, r, g, b, a)local color = self.barColor.solarEnergyBar;color.r=r color.g=g color.b=b color.a=a self:CreateInterface()end,
						order	= 1,
					},			
					lunarColor	= {
						type = 'color',
						name = "Lunar Color",
						hasAlpha = true,
						desc = nil,
						get	= function ()local color = self.barColor.lunarEnergyBar;return color.r, color.g, color.b, color.a end,
						set	= function (info, r, g, b, a)local color = self.barColor.lunarEnergyBar;color.r=r color.g=g color.b=b color.a=a self:CreateInterface()end,
						order	= 2,
					},			
					vsolarColor	= {
						type = 'color',
						name = "Virtual Solar/Solar soon Color",
						hasAlpha = true,
						desc = nil,
						get	= function ()local color = self.barColor.virtualSolarEnergyBar;return color.r, color.g, color.b, color.a end,
						set	= function (info, r, g, b, a)local color = self.barColor.virtualSolarEnergyBar;color.r=r color.g=g color.b=b color.a=a self:CreateInterface()end,
						order	= 3,
					},			
					vlunarColor	= {
						type = 'color',
						name = "Virtual Lunar/Lunar soon Color",
						hasAlpha = true,
						desc = nil,
						get	= function ()local color = self.barColor.virtualLunarEnergyBar;return color.r, color.g, color.b, color.a end,
						set	= function (info, r, g, b, a)local color = self.barColor.virtualLunarEnergyBar;color.r=r color.g=g color.b=b color.a=a self:CreateInterface()end,
						order	= 4,
					},
					background	= {
						type = 'color',
						name = "Background",
						hasAlpha = true,
						desc = nil,
						get	= function ()local color = self.barColor.background;return color.r, color.g, color.b, color.a end,
						set	= function (info, r, g, b, a)local color = self.barColor.background;color.r=r color.g=g color.b=b color.a=a self:CreateInterface()end,
						order	= 5,
					},
					border	= {
						type = 'color',
						name = "Border",
						hasAlpha = true,
						desc = nil,
						get	= function ()local color = self.barColor.border;return color.r, color.g, color.b, color.a end,
						set	= function (info, r, g, b, a)local color = self.barColor.border;color.r=r color.g=g color.b=b color.a=a self:CreateInterface()end,
						order	= 6,
					},
					text	= {
						type = 'color',
						name = "Text",
						hasAlpha = true,
						desc = nil,
						get	= function ()local color = self.barColor.text;return color.r, color.g, color.b, color.a end,
						set	= function (info, r, g, b, a)local color = self.barColor.text;color.r=r color.g=g color.b=b color.a=a self:CreateInterface()end,
						order	= 7,
					},
					--[[spark	= {
						type = 'color',
						name = "Spark",
						hasAlpha = true,
						desc = nil,
						get	= function ()local color = self.barColor.spark;return color.r, color.g, color.b, color.a end,
						set	= function (info, r, g, b, a)local color = self.barColor.spark;color.r=r color.g=g color.b=b color.a=a self:CreateInterface()end,
						order	= 8,
					},--]]
				},
			},
			Info = {
			    type	= 'group',
				name	= "Info",
				order	= 99,
				args ={
					info = {
						type	= 'description',
						name	= "Created & maintained by Kurohoshi (EU - Minahonda)",
						order = 1,
					},
					info1 = {
						type	= 'description',
						name	= "Download site: http://www.wowinterface.com/downloads/info18000-self.html",
						order = 2,
					},
					info2 = {
						type	= 'description',
						name	= "I can be found as Kuro on www.themoonkinrepository.com",
						order = 3,
					},
					info3 = {
						type	= 'description',
						name	= "Also I can be found as Copialinex on www.elitistjerks.com",
						order = 4,
					},
				},
			},
			Advanced = {
			    type	= 'group',
				name	= "Advanced",
				order	= 75,
				args ={
					info = {
						type	= 'description',
						name	= "Advanced functions. Increase CPU usage slightly each",
						order = 1,
					},
					header = {
						type	= 'header',
						name    ="Eclipse Chance:",
						order = 2,
					},
					info2 = {
						type	= 'description',
						name	= "Eclipse Chance displays a number over the Eclipse Icon that represents the % chance of getting Eclipse with the flying/casting spells at every moment, this number takes into consideration both Euphoria and miss chance.",
						order = 3,
					},
					eclipseProb = {
						type	= 'toggle',
						name	= "Eclipse Chance",
						desc	= "Enable/Disable Eclipse Chance",
						get		= function () return self.options.probEclipse end,
						set		= function () self.options.probEclipse = not self.options.probEclipse  self:RegisterProbEclipseCallback() end,
						order	= 4,
					},
					header3 = {
						type	= 'header',
						name    = "Statistically Energy calculation:",
						order = 5,
					},
					info3 = {
						type	= 'description',
						name	= "Statistically Energy calculation is a feature that allows the display of the least energy you'll have taking into consideration both Euphoria and miss chance with a confidence degree. For example: You are hitcapped against your target, you have 20 solar energy and are casting a Starfire, so you have 24% chance of having 60 energy and 76% of having 40, with required confidence at 10% it will display 60 and with confidence at 30% it will display 40.",
						order = 6,
					},
					confidence	= {
						type	= 'range',
						name	= "Required confidence %",
						desc	= nil,
						disabled = function()  return not self.options.statEclipse end,
						min		= 0,
						max		= 100,
						step    = 1,
						get		= function () return self.options.confidence*100 end,
						set		= function (info, new) self.options.confidence = new*0.01; end,
						order	= 8,
					},
					statEnergy 	= {
						type	= 'toggle',
						name	= "Stat Energy",
						desc	= "Enable/Disable statistically Energy calculation:.",
						get		= function () return self.options.statEclipse   end,
						set		= function () self.options.statEclipse  = not self.options.statEclipse;  self:RegisterCallback()   end,
						order	= 7,
					},
				},					
			},
			Style = {
			    type	= 'group',
				name	= "Style",
				order	= 11,
				args ={
					style = {
						type	= 'select',
						name	= "Style",
						values	= function ()	local temp ={} 
												for k, v in pairs(BalancePowerTracker_SharedInfo.style) do temp[k]=v.name; end 
												for k, v in pairs(self.style) do	temp[k]=v.name;end 
												return temp;
								end,
						set		= function(info,new)	if self.options.extMod then BalancePowerTracker_SharedInfo.style[self.options.extMod].Unload() end
														if self.style[new] then
															self.options.styleName = new
															self.options.extMod = false
															self:CreateInterface();
														elseif BalancePowerTracker_SharedInfo.style[new] then
															self.options.extMod = new
															self:CreateInterface();
														end 
								end,
						get		= function()  return self.options.extMod or self.options.styleName; end,
						order	= 1,
					},
					header = {
						type	= 'header',
						name    ="INFO",
						order = 2,
					},
					info = {
						type	= 'description',
						name	= function() 	if self.options.extMod then
													if BalancePowerTracker_SharedInfo.style[self.options.extMod].info~=nil then
														return BalancePowerTracker_SharedInfo.style[self.options.extMod].info
													else 
														return "            -NO INFO-"
													end 
												else
													if self.style[self.options.styleName].info ~= nil then
														return self.style[self.options.styleName].info
													else
														return "            -NO INFO-"
													end 
												end
								end,
						order = 3,
					},
					free_style = {
						name	= "Media",
						type	= 'group',
						order	= 4,
						disabled = function() 	if self.options.extMod then 
													return not BalancePowerTracker_SharedInfo.style[self.options.extMod].usesMedia 
												else 
													return not self.style[self.options.styleName].usesMedia 
												end end,
						args	= {
							inset	= {
								type	= 'range',
								name	= "inset",
								desc	= nil,
								min		= 0,
								max		= 8,
								step    = 1,
								get		= function () return self.style.free.inset end,
								set		= function (info, new) self.style.free.inset = new;self:CreateInterface() end,
								order	= 5,
							},
							texture	= {
								type	= 'select',
								name	= "Bar texture",
								get		= function () return self.style.free.bar end,
								set		= function(info,new) self.style.free.bar=new;self:CreateInterface() end,
								values	= function () return self.media.textures end,
								order	= 1,
							},
							background	= {
								type	= 'select',
								name	= "Background texture",
								get		= function () return self.style.free.background end,
								set		= function(info,new)self.style.free.background=new;self:CreateInterface() end,
								values	= function () return self.media.textures end,
								order	= 2,
							},
							edge	= {
								type	= 'select',
								name	= "Border Texture",
								get		= function () return self.style.free.edge end,
								set		= function(info,new) self.style.free.edge=new;self:CreateInterface() end,
								values	= function () return self.media.borders end,
								order	= 3,
							},
							font	= {
								type	= 'select',
								name	= "Font",
								get		= function () return self.style.free.font end,
								set		= function(info,new) self.style.free.font=new;self:CreateInterface() end,
								values	= function () return self.media.fonts end,
								order	= 4,
							},
							header = {
								type	= 'header',
								name    ="Icon texture",
								order = 6,
							},
							solarIconTexture	= {
								type	= 'input',
								name	= "Sun",
								get		= function () return self.style.free.iconSolar end,
								set		= function(info,new) 
											if tonumber(new) then self.style.free.iconSolar = select(3,GetSpellInfo(tonumber(new)))
											elseif GetSpellInfo(new) then self.style.free.iconSolar = select(3,GetSpellInfo(new))
											else self.style.free.iconSolar=new;
											end
											self:CreateInterface()
										end,
								order	= 8,
								desc 	= "Works with spell ID, spell name and relative texture path",
							},
							lunarIconTexture	= {
								type	= 'input',
								name	= "Moon",
								get		= function () return self.style.free.iconLunar end,
								set		= function(info,new) 
											if tonumber(new) then self.style.free.iconLunar = select(3,GetSpellInfo(tonumber(new)))
											elseif GetSpellInfo(new) then self.style.free.iconLunar = select(3,GetSpellInfo(new))
											else self.style.free.iconLunar=new;
											end
											self:CreateInterface() 
										end,
								order	= 7,
								desc 	= "Works with spell ID, spell name and relative texture path",
							},
						},
					},
				},
			},
		}, 
	} 

	LibStub("AceConfig-3.0"):RegisterOptionsTable("BalancePowerTracker", options,nil)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("BalancePowerTracker","BalancePowerTracker")
	BPT_OPT_STATUS = "WORK"
end

if not BalancePowerTracker_SharedInfo then BPT_OPT_STATUS = "MISS" print("|c00a080ffBalancePowerTracker Options|r: ERROR: BalancePowerTracker not found") return end
BPT_OPT_STATUS = "LOAD"
BalancePowerTracker_SharedInfo:CreateOptions(CreateOptions)
