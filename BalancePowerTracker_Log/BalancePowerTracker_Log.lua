--[[
## Interface: 40200
## Title: BalancePowerTracker_Log
## Version: 1.0.0
## Author: Kurohoshi (EU-Minahonda)
## Notes: Log feature for BalancePowerTracker

--CHANGELOG
v1.0.0: Release
--]]
if BPT_LOG_STATUS then 
	BPT_LOG_STATUS = "ARDY"
	print("|c00a080ffBalancePowerTracker LOG|r: ERROR: NOT LOADED")
	return 
elseif (select(2,UnitClass("player"))~="DRUID") then 
	BPT_LOG_STATUS = "!DRU" 
	print("|c00a080ffBalancePowerTracker LOG|r: ERROR: NOT LOADED")
	return
end

local version = {1,0,0};

if (LogBalancePowerTracker and LogBalancePowerTracker:CompareVersion(version)) then return; end;
BPT_LOG_STATUS = "INIT"

--Initialize Global Lib
LogBalancePowerTracker = {};
function LogBalancePowerTracker:CompareVersion(versionTable) 
	for i,v in ipairs(versionTable) do
		if version[i] < v then
			return false;
		end;
	end;
	return true;
end;

--Main table
local LogBPT={
	direction="none",
	selected=false,
	infoTable={},
	logs = {},
	frames = {},
}
--General info
local data ={
	WR  = {name = GetSpellInfo(5176) ,energy = 13,spellId=5176 }, -- name & energy Wrath
	SF  = {name = GetSpellInfo(2912) ,energy = 20,spellId=2912 }, -- name & energy Starfire
	SS  = {name = GetSpellInfo(78674),energy = 15,spellId=78674}, -- name StarSurge
	EE  = {spellId = 89265}, -- Eclipse Energy spell
	SSE = {spellId = 86605}, --Starsurge Energy spell
	SuddenEclipse = {spellId = 95746}, --PvP energy proc
}
local spellsUsed = {
	[data.WR.name] = tonumber(data.WR.spellId),
	[data.SS.name] = tonumber(data.SS.spellId),
	[data.SF.name] = tonumber(data.SF.spellId),
	[data.WR.spellId] = tostring(data.WR.name),
	[data.SS.spellId] = tostring(data.SS.name),
	[data.SF.spellId] = tostring(data.SF.name),
}
local notEnergy = {
	[data.SF.spellId] = "moon",
	[data.WR.spellId] = "sun"
}
--Extract useful info from events functions
local unfilteredCombatLogTable = {
	SPELL_ENERGIZE 	= function(id,amount,tipo) if tipo == 8 			then return "ENERGIZE",id,amount end end,
	SPELL_MISSED 	= function(id)	if spellsUsed[id] 					then return "MISS",id end end,
	SPELL_DAMAGE 	= function(id)	if notEnergy[id] ==LogBPT.direction then return "DAMAGE",id end end,
	SPELL_AURA_APPLIED = function(id) if (id == 48518) or (id == 48517) then return "ECLIPSE_ON",id end end,
	SPELL_AURA_REMOVED = function(id) if (id == 48518) or (id == 48517) then return "ECLIPSE_OFF",id end end,
	SPELL_CAST_FAILED = function(id,msg) if spellsUsed[id] and msg == SPELL_FAILED_INTERRUPTED then return "CAST_FAILED",id end end
}
local translate = {
	TIMER							= function(id) return "TIMER",id end,
	--DISPLAY_CHANGED					= function(en,dir,ven,vdir) vars.direction=dir return "DISPLAY_CHANGED",transform(en,dir,ven,vdir,true)	end,
	UNIT_SPELLCAST_START			= function(unit,_,_,_,id) if unit == "player" and spellsUsed[id] then return "START",id end end,
	UNIT_SPELLCAST_SUCCEEDED		= function(unit,_,_,_,id) if unit == "player" and spellsUsed[id] then return "SUCCEES",id end end,
	PLAYER_DEAD						= function() return "DEAD"  end,
	PLAYER_ALIVE					= function() return "ALIVE" end,
	ECLIPSE_DIRECTION_CHANGE		= function(dir) if dir=="none" then return "ECLIPSE_RESET" end end,
	PLAYER_ENTERING_WORLD			= function() return "LOADING_SCREEN" end,
	COMBAT_LOG_EVENT_UNFILTERED 	= function(_,event,_,gUIDor,_,_,_,destGUID,_,_,_,spellId,_,_,amountEnergy,typeEnergy)
										local playerGUID=UnitGUID("player");
										if (gUIDor == playerGUID) then 
											event = unfilteredCombatLogTable[event] 
											if event then return event(spellId,amountEnergy,typeEnergy) end
										elseif (destGUID == playerGUID) and event=="SPELL_INTERRUPT" then
											if spellsUsed[amountEnergy] then return "INTERRUPT",amountEnergy end
										end
									end,
	TIER_CHANGE						= function(tiersId) return "TIER_BONUS",tiersId end,
	ACTIVE_TALENT_GROUP_CHANGED		= function() return "TALENTS_CHANGED" end, 
	CHARACTER_POINTS_CHANGED		= function() return "TALENTS_CHANGED" end,
}

--==============================================--
--===========zip/unzip info functions===========--
--==============================================--
local eventtoint = {
	[0]  =	"DISPLAY_CHANGED",
	[1]  =	"START",
	[2]  =	"SUCCEES",
	[3]  =	"ENERGIZE",
	[4]  =	"CAST_FAILED",
	[5]  =	"ECLIPSE_ON",
	[6]  =	"ECLIPSE_OFF",
	[7]  =	"DAMAGE",
	[8]  =	"MISS",
	[9]  =	"TIMER",
	[10] =	"DEAD",
	[11] =	"ALIVE",
	[12] =	"ECLIPSE_RESET",
	[13] =	"LOADING_SCREEN",
	[14] =	"INTERRUPT",
	[15] =	"TIER_BONUS",
	[16] =	"TALENTS_CHANGED",
	[17] =  "HIATUS",
	DISPLAY_CHANGED	= 0,
	START	= 1,
	SUCCEES	= 2,
	ENERGIZE	= 3,
	CAST_FAILED = 4,
	ECLIPSE_ON 	= 5,
	ECLIPSE_OFF = 6,
	DAMAGE 	= 7,
	MISS 	= 8,
	TIMER	= 9,
	DEAD	= 10,
	ALIVE	= 11,
	ECLIPSE_RESET	= 12,
	LOADING_SCREEN	= 13,
	INTERRUPT		= 14,
	TIER_BONUS		= 15,
	TALENTS_CHANGED	= 16,
	HIATUS			= 17,
}
local function transformar(tiempo,queueNumber,comprimidoEn,comprimidoDir,evento,id,cantidad,dicionarioId,dicIdReversed,diccionarioCantidad,dicCantReversed)
	--tiempo [0,79] ds desde el evento anterior
	--queueNumber [0,1455]
	--evento [0,17] -> se guardan en cantidad, salvo en el caso de energize, que es especial
	--id [0,99999]->dicionario[0-19]
	--cantidad [0,200]->dicionario[0,29]
	--comprimidoEn [0,40400]
	--comprimidoDir [0,8]
	--tiene que devolver un número [0,50823811584000-1]
	
	if evento == "ENERGIZE" then
		--es el evento que más información ha de guardar, se por lo que su identificación ha de ser la más sencilla
		-- se descubre porque mod2=0 
		-- info [0,181803]
		-- return ((info*2)*1456 + estado)*2+1
		
		local nid = dicionarioId[id] --[0,19]
		if not nid then
			nid = dicionarioId.last
			dicIdReversed[nid] = id
			dicionarioId[id] = nid
			dicionarioId.last = nid+1
		end
		
		local ncant = diccionarioCantidad[cantidad] --[0,29]
		if not ncant then
			ncant = diccionarioCantidad.last
			dicCantReversed[ncant] = cantidad
			diccionarioCantidad[cantidad] = ncant
			diccionarioCantidad.last = ncant+1
		end
		
		if ncant>29 or nid>19 then return false end
		tiempo = min(79,math.floor((GetTime()-tiempo)*10+.5)) --[0.79]

		local info = (comprimidoEn*9 + comprimidoDir) --[0,363608]
		info=(info*80+tiempo) --[0,80*363608-1]
		info=(info*30+ncant)
		info=(info*20+nid)
		info=(info*1456+queueNumber)
		
		return info*2
	else 
		--el resto de eventos, no afecta cantidad

		local nid
		if not id then 
			nid = 0
		else
			nid = dicionarioId[id]
			if not nid then
				nid = dicionarioId.last
				dicIdReversed[nid] = id
				dicionarioId[id] = nid
				dicionarioId.last = nid+1
			end
		end
		
		if evento == "HIATUS" then
			tiempo = floor(GetTime()-tiempo+.5)
			local s = tiempo%60
			local m = min(19,(tiempo-s)/60)
			tiempo = s
			nid    = m
		else
			tiempo = min(79,math.floor((GetTime()-tiempo)*10+.5)) --[0.79]
		end
		
		local ncant = eventtoint[evento]
		if ncant>29 or nid>19 then return false end
		
		local info = (comprimidoEn*9 + comprimidoDir) --[0,363608]
		info=(info*80+tiempo) --[0,80*363608-1]
		info=(info*30+ncant)
		info=(info*20+nid)
		info=(info*1456+queueNumber)
		
		return info*2+1
	end
end
local function decodificar (codificado,dicIdReversed,dicCantReversed)
	if codificado % 2 == 0 then
		codificado=codificado/2
		
		local estado = codificado % 1456
		codificado = (codificado-estado)/1456
		
		local id = codificado % 20
		codificado = (codificado-id)/20
		
		local cant = codificado % 30
		codificado = (codificado-cant)/30
		
		local tiempo = codificado % 80
		codificado = (codificado-tiempo)/80
		
		local comprimidoDir = codificado % 9
		codificado = (codificado-comprimidoDir)/9
		
		return tiempo,estado,codificado,comprimidoDir,"ENERGIZE",dicIdReversed[id],dicCantReversed[cant]
	else
		codificado=(codificado-1)/2
		
		local estado = codificado % 1456
		codificado = (codificado-estado)/1456
		
		local id = codificado % 20
		codificado = (codificado-id)/20
		
		local cant = codificado % 30
		codificado = (codificado-cant)/30
		
		local tiempo = codificado % 80
		codificado = (codificado-tiempo)/80
		
		local comprimidoDir = codificado % 9
		codificado = (codificado-comprimidoDir)/9
		
		if cant == 17 then 
			return tiempo*10+id*600,estado,codificado,comprimidoDir,eventtoint[cant]
		end
		return tiempo,estado,codificado,comprimidoDir,eventtoint[cant],dicIdReversed[id]
	end
end

local dirtoint={
	[0]="sun",
	[1]="moon",
	[2]="none",
	sun=0,
	moon=1,
	none=2,
}
local function transform(en,dir,ven,vdir,to)
	--en, vene están entre -100 y 100, ambos incluídos,dir y vdir están entre 0-2, total = 201*201*2*3 posibilidades
	if to then
		return (en+100)+(ven+100)*201,dirtoint[dir]+dirtoint[vdir]*3;
	else
		to = en % 201
		ven = (en-to)/201-100
		en = to-100
		
		to = dir % 3
		vdir = dirtoint[(dir-to)/3]
		dir=dirtoint[to]
		
		if dir~=vdir then 	if vdir =="sun" then to=-100
							else to=100
							end
		else to = false
		end
		
		return en,dir,ven,vdir,to
	end
end

local troublechars = {
 ['\\'] =' ',
 ["$"] ='!',
 ["|"] = '"',
}
local troublecharsReverse = {
 [' '] ='\\',
 ['!'] ='$',
 ['"'] ='|',
}
local function deEnteroAString(e)
	--e[0,91^7-1]
	local s =""
	for i=0,6 do
		local rem = e%91;
		e=(e-rem)/91;
		local char = troublechars[string.char(rem+36)]
		if not char then char = string.char(rem+36) end
		s=s..char
	end
	return s
end
local function deStringAEntero(s)
	local e = 0
	for i=1,7 do
		local char = troublecharsReverse[string.sub(s,i,i)]
		if char then
			e=e+ (string.byte(char) -36)*91^(i-1)
		else
			e=e+ (string.byte(s,i) -36)*91^(i-1)
		end
	end
	return e
end
--==============================================--
--=======finish zip/unzip info functions========--
--==============================================--

function LogBPT.CreateLog()
	local registro = {}
	local first,last = 1,1
	registro.logging = false
	registro.playing = false

	registro.dicionarioId={
		last=4,
		[0] = 0;
		[data.WR.spellId] = 1,
		[data.SS.spellId] = 2,
		[data.SF.spellId] = 3,
	}
	registro.dicIdReversed={
		[0] = 0,
		[1] = data.WR.spellId,
		[2] = data.SS.spellId,
		[3] = data.SF.spellId,
	}
	registro.diccionarioCantidad={last=0}
	registro.dicCantReversed={}

	local temp = {}
	registro.add = function(sth,show)
		registro[last]=sth
		if show  then registro.print(last) end
		last=last+1
	end
	registro.print = function(index)
		if (not registro[index]) or (not LogBPT.frames.main) then return end
		local tiempo,estado,comprimidoEn,comprimidoDir,evento,id,cant = decodificar(deStringAEntero(registro[index]),registro.dicIdReversed,registro.dicCantReversed)
		LogBPT.actualizarvalores(comprimidoEn,comprimidoDir) 
		local func = LogBPT.infoTable.queueNumberToTable
		if func then func(estado,temp) LogBPT.dibujarcola(temp) end
		
		if evento ~= "HIATUS" then
			LogBPT.annadirLinea(evento,id,cant,tiempo)
		elseif tiempo == 0 then
			LogBPT.annadirLinea("LOG_BREAK")
		else
			LogBPT.annadirLinea(evento,(tiempo/10).."s")
		end
	end
	registro.getLast = function() return last,first end
	
	registro.export = function(init,fin)
		if not init then init=first end
		if not fin 	then fin = last-1 end
		
		local temp = ""
		
		for _,v in ipairs(registro.dicIdReversed) do
			temp=temp..v..'#'
		end
		temp=temp.."$"
		for i=0,registro.diccionarioCantidad.last-1 do
			temp=temp..registro.dicCantReversed[i]..'#'
		end
		temp=temp.."$"
		for i=init,fin do
			if i~=fin or registro[i] ~= "+D}C>hP" then 
				temp=temp..registro[i]..'#'
			end
		end
		temp=temp.."$"
		return temp
	end
	registro.import = function(sth)
		local a,b,c =sth:match("^(.-)%$(.-)%$(.-)%$$")
		if not (a and b and c) then return false end
		
		registro.dicionarioId={
			last=1,
			[0] = 0;
		}
		registro.dicIdReversed={
			[0] = 0,
		}
		local first
		while a ~= "" do
			first,a=a:match('^(.-)%#(.-)$')
			if tonumber(first) == nil then return false end
			registro.dicIdReversed[registro.dicionarioId.last]=tonumber(first)
			registro.dicionarioId[tonumber(first)]=registro.dicionarioId.last
			registro.dicionarioId.last = registro.dicionarioId.last +1
		end
		
		registro.diccionarioCantidad={last=0}
		registro.dicCantReversed={}
		while b ~= "" do
			first,b=b:match('^(.-)%#(.-)$')
			if tonumber(first) == nil then return false end
			registro.dicCantReversed[registro.diccionarioCantidad.last]=tonumber(first)
			registro.diccionarioCantidad[tonumber(first)]=registro.diccionarioCantidad.last
			registro.diccionarioCantidad.last = registro.diccionarioCantidad.last +1
		end
		
		last = 1
		while c ~= "" do
			first,c=c:match('^(.-)%#(.-)$')
			if select(5,decodificar(deStringAEntero(first),registro.dicIdReversed,registro.dicCantReversed)) then registro[last]=first else return false end
			last =last +1
		end
		if last~=1 then registro[last]="+D}C>hP" last=last+1 end
		registro[last]=nil
		return true
	end
	registro.clear = function()
		first,last = 1,1
		--registro.logging =false
		--registro.playing = false
	end
	return registro
end

function LogBPT.enableLog(i,selectIt)
	if not  LogBPT.infoTable.logFunction then print("|c00a080ffBalancePowerTracker LOG|r: ERROR: Missing function") return end

	local registro = LogBPT.logs[i]
	if not registro then
		 LogBPT.logs[i]=LogBPT.CreateLog()
		 registro = LogBPT.logs[i]
	end
	registro.logging = true
	if selectIt and LogBPT.frames.main then LogBPT.selectLog(i) end
	
	local tiempo 
	local initEnergy,initDirection,initVirtualEnergy,initVDirection,initQueueNumber = LogBPT.infoTable.logFunction(	function(event,en,dir,ven,vdir,queueNumber,...) 
										local func = translate[event]
										if func then 
											LogBPT.direction = dir;
											local comprimidoEn,comprimidoDir = transform(en,dir,ven,vdir,true)
											local evento,id,cantidad=func(...)
											if evento then 
												if not tiempo then  tiempo=GetTime() 
												elseif GetTime()-tiempo>7.9 then
													registro.add(deEnteroAString(transformar(tiempo,queueNumber,comprimidoEn,comprimidoDir,"HIATUS",0,0,registro.dicionarioId,registro.dicIdReversed,registro.diccionarioCantidad,registro.dicCantReversed)),LogBPT.selected == i)
													tiempo = GetTime()
												end
												registro.add(deEnteroAString(transformar(tiempo,queueNumber,comprimidoEn,comprimidoDir,evento,id,cantidad,registro.dicionarioId,registro.dicIdReversed,registro.diccionarioCantidad,registro.dicCantReversed)),LogBPT.selected == i)
												tiempo=GetTime()
											end
										end
									end );
									
	if LogBPT.selected == i and LogBPT.frames.main then
		local t = {}
		LogBPT.infoTable.queueNumberToTable(initQueueNumber,t)
		LogBPT.dibujarcola(t)
		LogBPT.actualizarvalores(transform(initEnergy,initDirection,initVirtualEnergy,initVDirection,true))
	end
end
function LogBPT.disableLog(i)
	local registro = LogBPT.logs[i]
	if not registro then return end
	registro.logging = false
	local last = registro.getLast()
	if last~=1 and registro[last-1] ~= "+D}C>hP" then registro.add("+D}C>hP",LogBPT.selected == i) end
	LogBPT.infoTable.logFunction(false)
end

function LogBalancePowerTracker.Register(spellQ,logFunction,playFunction,customFunction)
	LogBPT.infoTable={
		queueNumberToTable=spellQ,
		logFunction = logFunction,
		playFunction = playFunction,
		customFunction = customFunction,
	}
	LogBPT.logs[1]=LogBPT.CreateLog()
	LogBPT.selected = 1
	if LogBPT.frames.main then LogBPT.checkAllButtons() end
end
function LogBalancePowerTracker.Show() LogBPT.CreateInterface() LogBPT.frames.main:Show() end
function LogBalancePowerTracker.Hide() LogBPT.frames.main:Hide() end

--Interface
function LogBPT.CreateInterface()
	if LogBPT.frames.main then return end
	local backdrop={
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",  
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = {left = 11,right = 12,top = 12,bottom = 11}
	}
	LogBPT.frames.timer = CreateFrame("Frame","LogBPTTimerFrame",UIParent)
	LogBPT.frames.timer:Hide()
	
	--ventana principal
	LogBPT.frames.main = CreateFrame("Frame","LogBPTGUI",UIParent)
	local main = LogBPT.frames.main
	main:SetHeight(430)
	main:SetWidth(240)
	main:SetClampedToScreen(true)
	main:SetMovable(true)
	main:EnableMouse(true)
	main:SetPoint("CENTER")
	main:SetScript("OnMouseDown", function(self) self:StartMoving() end)
	main:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
	main:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	main:SetBackdrop(backdrop)
	
	--titulo
	local title = main:CreateFontString("LogBPTTitle","OVERLAY","GameFontNormal")
	title:SetPoint("TOP",main,"TOP",0,-15)
	title:SetText("BalancePowerTracker LOG")
	title:SetTextColor(.5, .5, 1, 1)

	--close button
	local closeButton = CreateFrame("Button","LogBPTGUICloseButton",main, "UIPanelCloseButton" )
	closeButton:SetPoint("TOPRIGHT",main,"TOPRIGHT",-5,-5)

	--export window
	LogBPT.frames.exportFrame = CreateFrame("Frame","LogBPTExportFrame",UIParent)
	local export = LogBPT.frames.exportFrame
	export.exportText="TESTING"
	export:SetHeight(80)
	export:SetWidth(220)
	export:SetFrameStrata("DIALOG")
	export:SetClampedToScreen(true)
	export:SetMovable(true)
	export:EnableMouse(true)
	export:SetPoint("CENTER")
	export:SetScript("OnMouseDown", function(self) self:StartMoving() end)
	export:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
	export:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	export:SetBackdrop(backdrop)
	local exportBox=CreateFrame("EditBox","LogBPTExportBox",export, "InputBoxTemplate" )
	exportBox:SetHeight(30)
	exportBox:SetWidth(160)
	exportBox:ClearAllPoints()
	exportBox:SetPoint("TOPLEFT",export,"TOPLEFT",20,-10)
	exportBox:SetAutoFocus(false)
	exportBox:SetFocus()	
	exportBox:SetText("TEST")
	exportBox:SetScript( "OnChar", function (self,char) self:SetText(export.exportText); end )
	exportBox:SetScript( "OnEnterPressed", function() export:Hide() end)
	exportBox:SetScript( "OnEscapePressed",function() export:Hide() end)
	exportBox:HighlightText()
	local exportBoxButton = CreateFrame("Button","LogBPTExportFrameCloseButton",export, "UIPanelCloseButton" )
	exportBoxButton:SetPoint("TOPRIGHT",export,"TOPRIGHT",-10,-10)
	export:Hide()
	--advertencia
	local advertencia1 = export:CreateFontString("LogBPTExportWarning1","OVERLAY","GameFontNormal")
	advertencia1:SetPoint("BOTTOM",export,"BOTTOM",0,30)
	advertencia1:SetText("Any understandable part of")
	advertencia1:SetTextColor(1, 1, 1, 1)
	local advertencia2 = export:CreateFontString("LogBPTExportWarning2","OVERLAY","GameFontNormal")
	advertencia2:SetPoint("BOTTOM",export,"BOTTOM",0,15)
	advertencia2:SetText("the text is just a concidence.")
	advertencia2:SetTextColor(1, 1, 1, 1)
	--texto seleccion lineas
	local exportlinestext = export:CreateFontString("LogBPTExportLinesText","OVERLAY","GameFontNormal")
	exportlinestext:SetPoint("TOPLEFT",export,"TOPLEFT",15,-20)
	exportlinestext:SetText("  From line:\n\nTo line:")
	exportlinestext:SetTextColor(1, 1, 1, 1)
	
	--de linea
	local exportBoxFrom=CreateFrame("EditBox","LogBPTExportBoxFrom",export, "InputBoxTemplate" )
	exportBoxFrom:SetHeight(25)
	exportBoxFrom:SetWidth(45)
	exportBoxFrom:ClearAllPoints()
	exportBoxFrom:SetPoint("TOPLEFT",exportlinestext,"TOPRIGHT",8,6)
	exportBoxFrom:SetAutoFocus(false)
	exportBoxFrom:SetNumeric(true) 
	exportBoxFrom:SetNumber(1)
	exportBoxFrom:SetScript( "OnChar", function (self,char) local line = tonumber(exportBoxFrom:GetNumber()); if line and line>0 then exportBoxFrom.line = line end  self:SetNumber(exportBoxFrom.line) end )
	
	--a linea
	local exportBoxTo=CreateFrame("EditBox","LogBPTExportBoxTo",export, "InputBoxTemplate" )
	exportBoxTo:SetHeight(25)
	exportBoxTo:SetWidth(45)
	exportBoxTo:ClearAllPoints()
	exportBoxTo:SetPoint("TOPRIGHT",exportBoxFrom,"BOTTOMRIGHT",0,1)
	exportBoxTo:SetAutoFocus(false)
	exportBoxTo:SetNumeric(true) 
	exportBoxTo:SetNumber(1)
	exportBoxTo:SetScript( "OnChar", function (self,char) local line = tonumber(exportBoxTo:GetNumber()); if line and line>0 then exportBoxTo.line = line end  self:SetNumber(exportBoxTo.line) end )
	
	--boton exportar
	local exportBoxExportButton = CreateFrame("Button","LogBPTExportFrameExportButton",export, "UIPanelButtonTemplate" )
	exportBoxExportButton:SetPoint("BOTTOMRIGHT",export,"BOTTOMRIGHT",-15,20)
	exportBoxExportButton:SetHeight(20)
	exportBoxExportButton:SetWidth(60)
	exportBoxExportButton:SetText("Export")
	exportBoxExportButton:SetScript("OnClick", function() 
													local registro = LogBPT.logs[LogBPT.selected]
													local last,first = registro.getLast()
													if exportBoxFrom.line<exportBoxTo.line and first<=exportBoxFrom.line and last>exportBoxTo.line then
														exportBox:Show()  advertencia1:Show()  advertencia2:Show()  exportBoxExportButton:Hide() exportlinestext:Hide() exportBoxFrom:Hide() exportBoxTo:Hide()
														export.exportText=LogBPT.logs[LogBPT.selected].export(exportBoxFrom.line,exportBoxTo.line) 
														exportBox:SetText(export.exportText)
														exportBox:SetFocus()
													end
												end)
	
	export:SetScript("OnShow",function() 
								exportBox:Hide() 
								advertencia1:Hide() 
								advertencia2:Hide() 
								exportBoxExportButton:Show() 
								exportlinestext:Show() 
								exportBoxFrom:Show() 
								exportBoxTo:Show() 
								local registro = LogBPT.logs[LogBPT.selected]
								local last,first = registro.getLast()
								exportBoxFrom.line=first
								exportBoxTo.line=last-1
								exportBoxFrom:SetNumber(min(exportBoxFrom.line,exportBoxTo.line))
								exportBoxTo:SetNumber(exportBoxTo.line)
							end)
	
	--import window
	LogBPT.frames.importFrame = CreateFrame("Frame","LogBPTImportFrame",UIParent)
	local import = LogBPT.frames.importFrame
	import:SetHeight(50)
	import:SetWidth(220)
	import:SetFrameStrata("DIALOG")
	import:SetClampedToScreen(true)
	import:SetMovable(true)
	import:EnableMouse(true)
	import:SetPoint("CENTER")
	import:SetScript("OnMouseDown", function(self) self:StartMoving() end)
	import:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
	import:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	import:SetBackdrop(backdrop)
	local importBox=CreateFrame("EditBox","LogBPTImportBox",import, "InputBoxTemplate" )
	importBox:SetHeight(30)
	importBox:SetWidth(100)
	importBox:ClearAllPoints()
	importBox:SetPoint("LEFT",import,"LEFT",20,0)
	importBox:SetAutoFocus(false)
	importBox:SetFocus()	
	importBox:SetScript( "OnEnterPressed", function() 
													LogBPTScrollingEventFrame:Clear()
													LogBPT.actualizarvalores()
													LogBPT.dibujarcola({})
													local registro = LogBPT.logs[LogBPT.selected]
													registro.playing=false
													LogBPT.disableLog(LogBPT.selected)
													LogBPT.checkAllButtons()
													if registro.import(importBox:GetText()) then 
														import:Hide() 
														local last,first = registro.getLast()
														for i = first,last-1 do registro.print(i)	end	
													else 
														registro.clear() 
														print("|c00a080ffBalancePowerTracker LOG|r: ERROR: Wrong format, log cleared.") 
													end 
												end)
	importBox:SetScript( "OnEscapePressed",function() import:Hide() end)
	importBox:HighlightText()
	local importBoxCloseButton = CreateFrame("Button","LogBPTImportFrameCloseButton",import, "UIPanelCloseButton" )
	importBoxCloseButton:SetPoint("RIGHT",import,"RIGHT",-10,0)
	local importBoxImportButton = CreateFrame("Button","LogBPTImportFrameImportButton",import, "UIPanelButtonTemplate" )
	importBoxImportButton:SetPoint("RIGHT",import,"RIGHT",-40,0)
	importBoxImportButton:SetHeight(20)
	importBoxImportButton:SetWidth(60)
	importBoxImportButton:SetText("Import")
	importBoxImportButton:SetScript("OnClick", function() 
													LogBPTScrollingEventFrame:Clear()  
													LogBPT.actualizarvalores()
													LogBPT.dibujarcola({})
													local registro = LogBPT.logs[LogBPT.selected]
													registro.playing=false
													LogBPT.disableLog(LogBPT.selected)
													LogBPT.checkAllButtons()
													if registro.import(importBox:GetText()) then 
														import:Hide() 
														local last,first = registro.getLast()
														for i = first,last-1 do registro.print(i)	end	
													else 
														registro.clear() 
														print("|c00a080ffBalancePowerTracker LOG|r: ERROR: Wrong format, log cleared.") 
													end 
												end)
	import:Hide()	


	--import/export button
	local importButton = CreateFrame("Button","LogBPTGUMainFrameImportButton",main, "UIPanelButtonTemplate" )
	importButton:SetPoint("TOPRIGHT",main,"TOPRIGHT",-25,-35)
	importButton:SetHeight(25)
	importButton:SetWidth(90)
	importButton:SetText("Import")
	importButton:SetScript("OnClick", function() import:Show() export:Hide() importBox:SetFocus() end)
	
	local exportButton = CreateFrame("Button","LogBPTGUMainFrameExportButton",main, "UIPanelButtonTemplate" )
	exportButton:SetPoint("TOPLEFT",main,"TOPLEFT",25,-35)
	exportButton:SetHeight(25)
	exportButton:SetWidth(90)
	exportButton:SetText("Export")
	exportButton:SetScript("OnClick", function() export:Show() import:Hide() exportBox:SetFocus() end)
	
	--zona de hechizos
	LogBPT.frames.spellFrame = CreateFrame("Frame","LogBPTSpellFrame",main) 
	local spellFrame = LogBPT.frames.spellFrame
	spellFrame:SetHeight(80)
	spellFrame:SetWidth(200)
	spellFrame:SetPoint("BOTTOM",main,"BOTTOM",0,20)
	spellFrame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"})
	local icons = {}
	for i=0,5 do
		local icon = spellFrame:CreateTexture("LogBPTSpellIcon"..i, "OVERLAY")
		icon:SetHeight(24)
		icon:SetWidth(24)
		if i == 0 then 
			icon:SetPoint("TOPLEFT",spellFrame,"TOPLEFT",15,-5)
		else
			icon:SetPoint("TOPLEFT",spellFrame,"TOPLEFT",i*25+35,-5)
		end
		icon:Hide()
		icons[i]=icon
	end
	function LogBPT.dibujarcola(tabla)
		local id = tabla[0]
		if id then 
			icons[0]:SetTexture(select(3,GetSpellInfo(id)))
			icons[0]:Show()
		else
			icons[0]:Hide()
		end
		for i=1,5 do
			local id = tabla[6-i]
			if id then 
				icons[i]:SetTexture(select(3,GetSpellInfo(id)))
				icons[i]:Show()
			else
				icons[i]:Hide()
			end
			
		end
	end
	
	--textos
	local ene = spellFrame:CreateFontString("LogBPTEnergyText","OVERLAY","GameFontNormal")
	ene:SetPoint("BOTTOMLEFT",spellFrame,"BOTTOMLEFT",15,25)
	ene:SetText("Energy: ?")
	ene:SetTextColor(1, 1, 1, 1)
	local vene = spellFrame:CreateFontString("LogBPTvEnergyText","OVERLAY","GameFontNormal")
	vene:SetPoint("BOTTOMLEFT",spellFrame,"BOTTOMLEFT",15,5)
	vene:SetText("Energy: ?")
	vene:SetTextColor(.5, .5, 1, 1)
	local dir = spellFrame:CreateFontString("LogBPTDirText","OVERLAY","GameFontNormal")
	dir:SetPoint("BOTTOMLEFT",spellFrame,"BOTTOMLEFT",105,25)
	dir:SetText("Direction: ?")
	dir:SetTextColor(1, 1, 1, 1)
	local vdir = spellFrame:CreateFontString("LogBPTvDirText","OVERLAY","GameFontNormal")
	vdir:SetPoint("BOTTOMLEFT",spellFrame,"BOTTOMLEFT",105,5)
	vdir:SetText("Direction: ?")
	vdir:SetTextColor(.5, .5, 1, 1)
	
	local asciiart = {moon = "<",sun = ">",none = "<>",}
	function LogBPT.actualizarvalores(comprimidoene,comprimidodir)
		if comprimidoene and comprimidodir then
			local fen,fdir,fven,fvdir=transform(comprimidoene,comprimidodir)
			vdir:SetText("Direction: "..asciiart[fvdir])
			dir:SetText("Direction: "..asciiart[fdir])
			vene:SetText("Energy: "..fven)
			ene:SetText("Energy: "..fen)
		else
			vdir:SetText("Direction: ?")
			dir:SetText("Direction: ?")
			vene:SetText("Energy: ?")
			ene:SetText("Energy: ?")
		end
	end
	
	--zona de eventos
	LogBPT.frames.eventFrame = CreateFrame("ScrollingMessageFrame","LogBPTScrollingEventFrame",main) 
	local eventFrame = LogBPT.frames.eventFrame
	eventFrame:SetPoint("BOTTOM",spellFrame,"TOP",0,10)
	eventFrame:SetHeight(160)
	eventFrame:SetWidth(200)
	eventFrame:SetFading(false)
	eventFrame:SetFontObject("GameFontNormal")
	eventFrame:SetMaxLines(4000)
	eventFrame:SetJustifyH("LEFT")
	eventFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",  
		--edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		--tile = true, tileSize = 32, edgeSize = 12,
		--insets = {left = 2,right = 2,top = 2, bottom = 2},
	})
	function LogBPT.annadirLinea(evento,id,cant,tiempo)
		if cant then
			if cant>0 then
				cant="|c00ff8000"..cant.."|r"
			else
				cant="|c00a080ff"..abs(cant).."|r"
			end
		else
			cant=""
		end
		tiempo=(tiempo and string.format("%.1fs ",tiempo/10)) or ""
		--tiempo= (tiempo and string.format("%.2d ",tiempo))or ""
		evento="|cffffffff"..evento.."|r"
		eventFrame:AddMessage(string.format("%.3d: ",(eventFrame:GetCurrentLine()+2))..tiempo..evento.." "..((id==0 and "") or id or "").." "..cant)
	end
	
	--start/stop loging
	local startLogButton = CreateFrame("Button","LogBPTGUIStartLogButton",main, "UIPanelButtonTemplate" )
	startLogButton:SetPoint("TOPLEFT",exportButton,"TOPLEFT",0,-30)
	startLogButton:SetHeight(25)
	startLogButton:SetWidth(90)
	startLogButton:SetText("Start Log")
	startLogButton:SetScript("OnClick", function() 
											LogBPT.logs[LogBPT.selected].logging=not LogBPT.logs[LogBPT.selected].logging 
											if not LogBPT.logs[LogBPT.selected].logging then 
												startLogButton:SetText("Start Log") LogBPT.disableLog(LogBPT.selected) 
											else 
												startLogButton:SetText("Stop Log") LogBPT.enableLog(LogBPT.selected,true) 
												LogBPTScrollingEventFrame:Clear()
												local registro = LogBPT.logs[LogBPT.selected]
												local last,first = registro.getLast()
												for i = first,last-1 do registro.print(i)	end												
											end 
											LogBPT.checkAllButtons() 
										end)
	
	--clear log
	local clearButton = CreateFrame("Button","LogBPTGUIClearButton",main, "UIPanelButtonTemplate" )
	clearButton:SetPoint("TOPLEFT",importButton,"TOPLEFT",0,-30)
	clearButton:SetHeight(25)
	clearButton:SetWidth(90)
	clearButton:SetText("Clear")
	clearButton:SetScript("OnClick", function() LogBPT.logs[LogBPT.selected].clear() LogBPT.checkAllButtons() LogBPTScrollingEventFrame:Clear() end)
	
	--start/stop playing
	local startPlayButton = CreateFrame("Button","LogBPTGUIStartPlayButton",main, "UIPanelButtonTemplate" )
	startPlayButton:SetPoint("TOPRIGHT",startLogButton,"TOPRIGHT",0,-30)
	startPlayButton:SetHeight(25)
	startPlayButton:SetWidth(90)
	startPlayButton:SetText("Play")
	startPlayButton:SetScript("OnClick", function() LogBPT.logs[LogBPT.selected].playing=not LogBPT.logs[LogBPT.selected].playing 
												if not LogBPT.logs[LogBPT.selected].playing then 
													startPlayButton:SetText("Play") LogBPT.checkAllButtons() LogBPT.play(LogBPT.selected,false) 
												else 
													startPlayButton:SetText("Stop") LogBPT.checkAllButtons() LogBPT.play(LogBPT.selected,true) 
												end  
											end)
	main:SetScript("OnHide",function()	if LogBPT.logs[LogBPT.selected].playing then  LogBPT.logs[LogBPT.selected].playing=false
										startPlayButton:SetText("Play") LogBPT.checkAllButtons() LogBPT.play(LogBPT.selected,false) end
							end)
	
	
	--step by step/speed
	local startPrevButton = CreateFrame("Button","LogBPTGUIStartPrevButton",main, "UIPanelButtonTemplate" )
	startPrevButton:SetPoint("TOPRIGHT",startPlayButton,"TOPRIGHT",0,-30)
	startPrevButton:SetHeight(25)
	startPrevButton:SetWidth(90)
	startPrevButton:SetText("Previous")
	local startNextButton = CreateFrame("Button","LogBPTGUIStartNextButton",main, "UIPanelButtonTemplate" )
	startNextButton:SetPoint("TOPLEFT",clearButton,"TOPLEFT",0,-60)
	startNextButton:SetHeight(25)
	startNextButton:SetWidth(90)
	startNextButton:SetText("Next")
	
	--pause/continue button
	local continueButton = CreateFrame("Button","LogBPTGUIContinuetButton",main, "UIPanelButtonTemplate" )
	continueButton:SetPoint("TOPLEFT",clearButton,"TOPLEFT",0,-60)
	continueButton:SetHeight(25)
	continueButton:SetWidth(90)
	continueButton:SetText("Continue")
	continueButton:SetScript("OnClick", function() local timer = LogBPT.frames.timer 
											if timer:IsShown() then
												timer:Hide()
											else
												timer:Show()
											end
											LogBPT.checkAllButtons()
										end)
	
	local speedBox=CreateFrame("EditBox","LogBPTSpeedBox",main, "InputBoxTemplate" )
	speedBox:SetHeight(25)
	speedBox:SetWidth(25)
	speedBox:ClearAllPoints()
	speedBox:SetPoint("TOPRIGHT",startPlayButton,"TOPRIGHT",-7,-30)
	speedBox:SetAutoFocus(false)
	speedBox:SetNumeric(true) 
	speedBox.speed = 1;
	speedBox:SetNumber(1)
	speedBox:SetScript( "OnChar", function (self,char) local speed = tonumber(speedBox:GetNumber()); if speed and speed>0 and speed <=10 then speedBox.speed = speed end  self:SetNumber(speedBox.speed) end )
	speedBox:SetScript( "OnEnterPressed", function() speedBox:ClearFocus() end)
	speedBox:SetScript( "OnEscapePressed",function() speedBox:ClearFocus() end)
	local speedtext = speedBox:CreateFontString("LogBPTEnergyText","OVERLAY","GameFontNormal")
	speedtext:SetPoint("RIGHT",speedBox,"LEFT",-10,0)
	speedtext:SetText("Speed:")
	
	local stepByStepCheckbox = CreateFrame("CheckButton","LogBPTGUIStepCheckButton",main, "UICheckButtonTemplate" )
	stepByStepCheckbox:SetPoint("LEFT", clearButton ,"LEFT",-2,-30)
	stepByStepCheckbox:SetHeight(20)
	stepByStepCheckbox:SetWidth(20)
	stepByStepCheckbox:SetChecked(false)
	stepByStepCheckbox:SetScript("OnClick",function() LogBPT.frames.timer:Hide() LogBPT.playButtonInteraction() LogBPT.checkAllButtons()  end)
	_G["LogBPTGUIStepCheckButtonText"]:SetText(" Step by step")

	
	--selector
	function LogBPT.selectLog(i)
		if LogBPT.logs[i] then LogBPT.selected =i end
		LogBPT.checkAllButtons()
	end
	
	function LogBPT.checkAllButtons()
		local tab = LogBPT.logs[LogBPT.selected]
		if not tab then 
			startPlayButton:Disable()
			startLogButton:Disable()
			stepByStepCheckbox:Disable()
			startNextButton:Disable()
			startPrevButton:Disable()
			clearButton:Disable()
			speedBox:Disable()
			continueButton:Disable()
			exportButton:Disable()
			importButton:Disable()
			startNextButton:Show()
			startPrevButton:Show()
			speedBox:Hide()
			continueButton:Hide()
		else
			exportButton:Enable()
			importButton:Enable()
			
			if tab.playing then 
				startLogButton:Disable()
				startNextButton:Enable()
				startPrevButton:Enable()
				continueButton:Enable()
				startPlayButton:SetText("Stop")
			else
				startPlayButton:SetText("Play Log")
				startLogButton:Enable()
				startNextButton:Disable()
				continueButton:Disable()
				startPrevButton:Disable()
			end
			if tab.logging then
				startPlayButton:Disable()
				speedBox:Disable()
				stepByStepCheckbox:Disable()
				startLogButton:SetText("Stop Log")
			else
				startPlayButton:Enable()
				speedBox:Enable()
				stepByStepCheckbox:Enable()
				startLogButton:SetText("Start Log")
			end
			
			if tab.logging or tab.playing then  clearButton:Disable() else   clearButton:Enable() end
			if stepByStepCheckbox:GetChecked() then startNextButton:Show() startPrevButton:Show() speedBox:Hide() continueButton:Hide() else startNextButton:Hide() startPrevButton:Hide() speedBox:Show() continueButton:Show()	end
			local timer = LogBPT.frames.timer 
			if timer:IsShown() then
				continueButton:SetText("Pause")
			else
				continueButton:SetText("Continue")
			end
		end
	end
	LogBPT.checkAllButtons()
	
	function LogBPT.playButtonInteraction()
	end
	
	LogBPT.play = function(i,enable)
		local timer = LogBPT.frames.timer
		if enable then
			local registro = LogBPT.logs[i]
			local last,first = registro.getLast()
			LogBPTScrollingEventFrame:Clear()
			if last == first then 
				registro.playing=false  
				LogBPT.checkAllButtons()
				return
			end
			LogBPT.infoTable.playFunction(true) 
			last=last-1
			for i = first,last do registro.print(i) end	
			local temp = {}
			local index = first
			LogBPTScrollingEventFrame:SetScrollOffset(LogBPTScrollingEventFrame:GetCurrentLine()-index+1)
			local tiempo,estado,comprimidoEn,comprimidoDir,evento,id,cant = decodificar(deStringAEntero(registro[index]),registro.dicIdReversed,registro.dicCantReversed)
			LogBPT.actualizarvalores(comprimidoEn,comprimidoDir) 
			local func = LogBPT.infoTable.queueNumberToTable
			local play = LogBPT.infoTable.customFunction
			if func then func(estado,temp) LogBPT.dibujarcola(temp) end
			if play then play(transform(comprimidoEn,comprimidoDir)) end
				local timeSinceLastEvent = 0;
			
				function LogBPT.playButtonInteraction()
					LogBPT.checkAllButtons()
					if index == first then startPrevButton:Disable() end
					if index == last  then startNextButton:Disable() continueButton:Disable() end
					if index >  first then	startPrevButton:Enable() end
					if index <  last  then	startNextButton:Enable() continueButton:Enable() end
				end

				startNextButton:SetScript("OnClick", function()
					index=index+1
					timeSinceLastEvent = 0
					LogBPTScrollingEventFrame:SetScrollOffset(LogBPTScrollingEventFrame:GetCurrentLine()-index+1)
					local tiempo,estado,comprimidoEn,comprimidoDir,evento,id,cant = decodificar(deStringAEntero(registro[index]),registro.dicIdReversed,registro.dicCantReversed)
					LogBPT.actualizarvalores(comprimidoEn,comprimidoDir) 
					if play then play(transform(comprimidoEn,comprimidoDir)) end
					if func then func(estado,temp) LogBPT.dibujarcola(temp) end
				
					LogBPT.playButtonInteraction()					
				end)
				startPrevButton:SetScript("OnClick",function()
					index=index-1
					timeSinceLastEvent = 0
					LogBPTScrollingEventFrame:SetScrollOffset(LogBPTScrollingEventFrame:GetCurrentLine()-index+1)
					local tiempo,estado,comprimidoEn,comprimidoDir,evento,id,cant = decodificar(deStringAEntero(registro[index]),registro.dicIdReversed,registro.dicCantReversed)
					LogBPT.actualizarvalores(comprimidoEn,comprimidoDir) 
					if play then play(transform(comprimidoEn,comprimidoDir)) end
					if func then func(estado,temp) LogBPT.dibujarcola(temp) end
					
					LogBPT.playButtonInteraction()
				end)
			
				timer:SetScript("OnUpdate",function(self,elapsed) 
					if index+1 > last then timer:Hide() LogBPT.playButtonInteraction() return end
					timeSinceLastEvent = timeSinceLastEvent + elapsed*speedBox.speed;
					
					local tiempo,estado,comprimidoEn,comprimidoDir,evento,id,cant = decodificar(deStringAEntero(registro[index+1]),registro.dicIdReversed,registro.dicCantReversed)
					
					while timeSinceLastEvent>(tiempo/10) do
						index=index+1
						LogBPTScrollingEventFrame:SetScrollOffset(LogBPTScrollingEventFrame:GetCurrentLine()-index+1)
						LogBPT.actualizarvalores(comprimidoEn,comprimidoDir) 
						if play then play(transform(comprimidoEn,comprimidoDir)) end
						if func then func(estado,temp) LogBPT.dibujarcola(temp) end
						timeSinceLastEvent = timeSinceLastEvent-(tiempo/10) 
						
						if index+1 > last then timer:Hide() LogBPT.playButtonInteraction() return end
						tiempo,estado,comprimidoEn,comprimidoDir,evento,id,cant = decodificar(deStringAEntero(registro[index+1]),registro.dicIdReversed,registro.dicCantReversed)
					end
				end)
				timer:Hide()
			
		else
			LogBPTScrollingEventFrame:SetScrollOffset(0)
			LogBPT.infoTable.customFunction() 
			LogBPT.infoTable.playFunction(false) 
			timer:Hide()
		end
	end

end

--Event listener frame(Only 1 event)
LogBPT.frames.listener = CreateFrame("Frame","LogBPTListener",UIParent);
LogBPT.frames.listener:RegisterEvent("ADDON_LOADED");
LogBPT.frames.listener:SetScript("OnEvent",function(_,_,name) 
											if name=="BalancePowerTracker_Log" then 
												if not  LibBalancePowerTracker then BPT_LOG_STATUS = "MISS" print("|c00a080ffBalancePowerTracker LOG|r: ERROR: LibBalancePowerTracker not found") return end
												LibBalancePowerTracker:RegisterFunctionsLog()
												BPT_LOG_STATUS = "WORK"
											end				
										end);
BPT_LOG_STATUS = "LOAD"