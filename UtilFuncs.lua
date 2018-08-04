local aName, aObj = ...
local _G = _G

local assert, debugstack, ipairs, pairs, rawget, select, type, print, tostring, Round = _G.assert, _G.debugstack, _G.ipairs, _G.pairs, _G.rawget, _G.select, _G.type, _G.print, _G.tostring, _G.Round

-- populate addon Index table first time through
local addonIdx, uName = {}, _G.UnitName("player")
do
	for i = 1, _G.GetNumAddOns() do
		addonIdx[_G.GetAddOnInfo(i)] = i
	end

	-- handle specific lowercase name
	if addonIdx["spew"] then
		addonIdx["Spew"] = addonIdx["spew"]
		addonIdx["spew"] = nil
	end

end

local tmpTab = {}
local function getObjFromString(input)

	_G.wipe(tmpTab)

    -- first split the string on "."
    for word in _G.string.gmatch(input, "%a+") do
        tmpTab[#tmpTab + 1] = word
    end
    -- then build string in the form _G["str1"]["str2"]...["strn"]
    local objString = "_G"
    for i = 1, #tmpTab do
        objString = objString .. '["' .. tmpTab[i] .. '"]'
    end

    -- finally use loadstring to get the object from the command
    -- print("getObjFromString", input, objString)
    return assert(_G.loadstring("return " .. objString)())

end

local function makeString(obj)

	if type(obj) == "table" then
		if type(rawget(obj, 0)) == "userdata" and type(obj.GetObjectType) == "function" then
			return ("<%s:%s:%s>"):format(tostring(obj), obj:GetObjectType(), obj:GetName() or "(Anon)")
		end
	end

	return tostring(obj)

end

local function makeText(fstr, ...)

    _G.wipe(tmpTab)
	local output = ""

	if fstr
	and fstr.find
	and fstr:find("%%")
	and select('#', ...) >= 1
	then
		for i = 1, select('#', ...) do
			tmpTab[i] = makeString(select(i, ...))
		end
		tmpTab[#tmpTab + 1] = "nil" -- handle 1 missing variable
		output = output .. " " .. fstr:format(_G.unpack(tmpTab))
	else
		tmpTab[1] = output
		tmpTab[2] = fstr and type(fstr) == "table" and makeString(fstr) or fstr or ""
		for i = 1, select('#', ...) do
			tmpTab[i + 2] = makeString(select(i, ...))
		end
		output = _G.table.concat(tmpTab, " ")
	end

	return output

end

local function revTable(curTab)

	if not curTab then return end

    local tmpTab = {}

	for i = 1, #curTab do
		tmpTab[curTab[i]] = true
	end

	return tmpTab

end

--@debug@
local beginTime, timeUsed
--@end-debug@
local errorhandler = _G.geterrorhandler()
local function safecall(funcName, funcObj, LoD, quiet)
--@alpha@
	assert(funcObj, "Unknown object safecall\n" .. debugstack(2, 3, 2))
--@end-alpha@

--@debug@
	beginTime = _G.debugprofilestop()
--@end-debug@
 	-- handle errors from internal functions
	local success, err = _G.xpcall(function() return funcObj(aObj, LoD) end, errorhandler)
--@debug@
	timeUsed = _G.Round(_G.debugprofilestop() - beginTime)
	if timeUsed > 5 then
		_G.print("Took " .. timeUsed .. " milliseconds to load " .. funcName)
	end
--@end-debug@
	if quiet then
		return success, err
	end
	if not success then
		if aObj.db.profile.Errors then
			aObj:CustomPrint(1, 0, 0, "Error running", funcName)
		end
	end

end

local function __adjHeight(opts)
--[[
	Calling parameters:
		obj = object (Mandatory)
		adj = value to adjust height by
--]]
--@alpha@
	assert(opts.obj, "Missing object aH\n" .. debugstack(2, 3, 2))
--@end-alpha@

	if opts.adj == 0 then return end

	if not _G.strfind(_G.tostring(opts.adj), "+") then -- if not negative value
		opts.obj:SetHeight(opts.obj:GetHeight() + opts.adj)
	else
		opts.adj = opts.adj * -1 -- make it positive
		opts.obj:SetHeight(opts.obj:GetHeight() - opts.adj)
	end

end
function aObj:adjHeight(...)

	local opts = select(1, ...)

--@alpha@
	assert(opts, "Missing object aH\n" .. debugstack(2, 3, 2))
--@end-alpha@

	-- handle missing object (usually when addon changes)
	if not opts then return end

	if type(rawget(opts, 0)) == "userdata" and type(opts.GetObjectType) == "function" then
		-- old style call
		opts = {}
		opts.obj = select(1, ...) and select(1, ...) or nil
		opts.adj = select(2, ...) and select(2, ...) or 0
	end
	__adjHeight(opts)
	opts = nil

end

local function __adjWidth(opts)
--[[
	Calling parameters:
		obj = object (Mandatory)
		adj = value to adjust width by
--]]
--@alpha@
	assert(opts.obj, "Missing object aW\n" .. debugstack(2, 3, 2))
--@end-alpha@

	if opts.adj == 0 then return end

	if not _G.strfind(_G.tostring(opts.adj), "+") then -- if not negative value
		opts.obj:SetWidth(opts.obj:GetWidth() + opts.adj)
	else
		opts.adj = opts.adj * -1 -- make it positive
		opts.obj:SetWidth(opts.obj:GetWidth() - opts.adj)
	end

end
function aObj:adjWidth(...)

	local opts = select(1, ...)

--@alpha@
	assert(opts, "Missing object aW\n" .. debugstack(2, 3, 2))
--@end-alpha@

	-- handle missing object (usually when addon changes)
	if not opts then return end

	if type(rawget(opts, 0)) == "userdata" and type(opts.GetObjectType) == "function" then
		-- old style call
		opts = {}
		opts.obj = select(1, ...) and select(1, ...) or nil
		opts.adj = select(2, ...) and select(2, ...) or 0
	end
	__adjWidth(opts)
	opts = nil

end

function aObj:add2Table(table, value)
--@alpha@
	assert(table, "Unknown table add2Table\n" .. debugstack(2, 3, 2))
	assert(value, "Missing value add2Table\n" .. debugstack(2, 3, 2))
--@end-alpha@

	table[#table + 1] = value

end

aObj.mpTex = [[Interface\Common\UI-ModelControlPanel]]
function aObj:changeMinusPlusTex(obj, minus)
--@alpha@
	assert(obj, "Unknown object changeMinusPlusTex\n" .. debugstack(2, 3, 2))
--@end-alpha@

	local nTex = obj:GetNormalTexture()
	nTex:SetTexture(aObj.mpTex)
	if minus then
		nTex:SetTexCoord(0.29687500, 0.54687500, 0.00781250, 0.13281250)
	else
		nTex:SetTexCoord(0.57812500, 0.82812500, 0.14843750, 0.27343750)
	end
	nTex = nil

end

aObj.RecTex = [[Interface\HelpFrame\HelpButtons]]
function aObj:changeRecTex(obj, isYellow, isUnitFrame)

	obj:SetTexture(self.RecTex)
	if isYellow then
		obj:SetTexCoord(isUnitFrame and 0.015 or 0.0038, isUnitFrame and 0.66 or 0.7, 0.67, 0.855) -- yellow
	else
		obj:SetTexCoord(0.0038, 0.7, 0.004, 0.205) -- blue
	end

end

aObj.shieldTex = [[Interface\CastingBar\UI-CastingBar-Arena-Shield]]
function aObj:changeShield(shldReg, iconReg)
--@alpha@
	assert(shldReg, "Unknown object changeShield\n" .. debugstack(2, 3, 2))
	assert(iconReg, "Unknown object changeShield\n" .. debugstack(2, 3, 2))
--@end-alpha@

	self:changeTandC(shldReg, self.shieldTex)
	shldReg:SetSize(44, 44)
	-- move it behind the icon
	shldReg:ClearAllPoints()
	shldReg:SetPoint("CENTER", iconReg, "CENTER", 9, -1)

end

aObj.lvlBG = [[Interface\PetBattles\BattleBar-AbilityBadge-Neutral]]
function aObj:changeTandC(obj, tex)
--@alpha@
	assert(obj, "Unknown object changeTandC\n" .. debugstack(2, 3, 2))
--@end-alpha@

	obj:SetTexture(tex)
	obj:SetTexCoord(0, 1, 0, 1)

end

function aObj:checkAndRun(funcName, funcType, LoD, quiet)
--@alpha@
	assert(funcName, "Unknown functionName checkAndRun\n" .. debugstack(2, 3, 2))
	assert(funcType, "Unknown functionType checkAndRun\n" .. debugstack(2, 3, 2))
--@end-alpha@

	-- self:Debug("checkAndRun: [%s, %s, %s, %s]", funcName, funcType, LoD, quiet)

	-- handle in combat
	if _G.InCombatLockdown() then
		self:add2Table(self.oocTab, {self.checkAndRun, {self, funcName, funcType, LoD, quiet}})
		return
	end

	-- setup function's table object to use
	local tObj
	if funcType     == "s" then tObj = self
	elseif funcType == "l" then tObj = self.libsToSkin
	elseif funcType == "o" then tObj = self.otherAddons
	else tObj = LoD and self["blizzLoDFrames"][funcType] or self["blizzFrames"][funcType]
	end

	-- only skin frames if required
	if (funcType == "n" and self.prdb.DisableAllNPC)
	or (funcType == "p" and self.prdb.DisableAllP)
	or (funcType == "u" and self.prdb.DisableAllUI)
	or (funcType == "s" and (self.prdb.DisabledSkins[funcName] or self.prdb.DisableAllAS))
	or (funcType == "l" and (self.prdb.DisabledSkins[funcName] or self.prdb.DisableAllAS))
	or (funcType == "o" and (self.prdb.DisabledSkins[funcName] or self.prdb.DisableAllAS))
	then
		tObj[funcName] = nil
		return
	else
		-- aObj:Debug("checkAndRun #2: [%s]", type(tObj[funcName]))
		if type(tObj[funcName]) == "function" then
			return safecall(funcName, tObj[funcName], nil, quiet)
		else
			if not quiet and self.prdb.Warnings then
				self:CustomPrint(1, 0, 0, "function [" .. funcName .. "] not found in " .. aName .. " (c&R)")
			end
		end
	end

end

function aObj:checkAndRunAddOn(addonName, LoD, addonFunc)
--@alpha@
	assert(addonName, "Unknown object checkAndRunAddOn\n" .. debugstack(2, 3, 2))
--@end-alpha@

	-- self:Debug("checkAndRunAddOn#1: [%s, %s, %s, %s]", addonName, LoD, addonFunc, type(addonFunc))

	-- handle in combat
	if _G.InCombatLockdown() then
		self:add2Table(self.oocTab, {self.checkAndRunAddOn, {self, addonName, LoD, addonFunc}})
		return
	end

	if not addonFunc then addonFunc = addonName end

	-- handle old & new function definitions
	local aFunc = self[addonFunc] or addonFunc

	-- don't skin any Addons whose skins are flagged as disabled
	if self.prdb.DisabledSkins[addonName]
	or self.prdb.DisableAllAS
	then
		if self.prdb.Warnings then
			self:CustomPrint(1, 0, 0, addonName, "not skinned, flagged as disabled (c&RA)")
		end
		aFunc = nil
		return
	end

	-- self:Debug("checkAndRunAddOn #2: [%s, %s, %s, %s]", _G.IsAddOnLoaded(addonName), _G.IsAddOnLoadOnDemand(addonName), aFunc, type(aFunc))

	if not _G.IsAddOnLoaded(addonName) then
		-- deal with Addons under the control of an LoadManager
		if _G.IsAddOnLoadOnDemand(addonName) and not LoD then
			self.lmAddons[addonName:lower()] = aFunc -- store with lowercase addonname (AddonLoader fix)
		-- Nil out loaded Skins for Addons that aren't loaded
		elseif aFunc then
			aFunc = nil
		end
	else
		-- check to see if AddonSkin is loaded when Addon is loaded
		if not LoD and not aFunc then
			if self.prdb.Warnings then
				self:CustomPrint(1, 0, 0, addonName, "loaded but skin not found in the AddonSkins directory (c&RA)")
			end
		elseif type(aFunc) == "function" then
			return safecall(addonName, aFunc, LoD)
			-- return safecall(addonFunc, LoD)
		else
			if self.prdb.Warnings then
				self:CustomPrint(1, 0, 0, "function [" .. addonName .. "] not found in " .. aName .. " (c&RA)")
			end
		end
	end

end

function aObj:checkLoadable(addonName)

	local _, _, _, loadable, reason = _G.GetAddOnInfo(addonName)
	-- local name, title, notes, loadable, reason, security, newVersion = _G.GetAddOnInfo(addonName)
	-- aObj:Debug("checkLoadable: [%s, %s, %s, %s, %s, %s, %s]", name, title, notes, loadable, reason, security, newVersion)
	if not loadable then
		if self.prdb.Warnings then
			self:CustomPrint(1, 0, 0, addonName, "not skinned, flagged as:", reason, "(cL)")
		end
	end
	reason = nil

	return loadable

end

function aObj:findFrame(height, width, children)
	-- find frame by matching children's object types

	local matched, frame
	local obj = _G.EnumerateFrames()

	while obj do

		if obj.IsObjectType -- handle object not being a frame !?
		and obj:IsObjectType("Frame")
		then
			if obj:GetName() == nil then
				if obj:GetParent() == nil then
					if _G.Round(obj:GetHeight()) == height
					and _G.Round(obj:GetWidth()) == width
					then
						_G.wipe(tmpTab)
						for _, child in ipairs{obj:GetChildren()} do
							tmpTab[#tmpTab + 1] = child:GetObjectType()
						end
						matched = 0
						for i = 1, #children do
							for j = 1, #tmpTab do
								if children[i] == tmpTab[j] then matched = matched + 1 end
							end
						end
						if matched == #children then
							frame = obj
							break
						end
					end
				end
			end
		end

		obj = _G.EnumerateFrames(obj)
	end
	matched = nil

	return frame

end

function aObj:findFrame2(parent, objType, ...)
--@alpha@
	assert(parent, "Unknown object findFrame2\n" .. debugstack(2, 3, 2))
--@end-alpha@

	if not parent then return end

	local point, relativeTo, relativePoint, xOfs, yOfs
	local frame, cKey
	local height, width

	for k, child in ipairs{parent:GetChildren()} do
		-- check for forbidden objects (StoreUI components)
		if not child:IsForbidden() then
			if child:GetName() == nil then
				if child:IsObjectType(objType) then
					if select("#", ...) > 2 then
						-- base checks on position
						point, relativeTo, relativePoint, xOfs, yOfs = child:GetPoint()
						xOfs = xOfs and _G.Round(xOfs) or 0
						yOfs = yOfs and _G.Round(yOfs) or 0
						if	point		  == select(1, ...)
						and relativeTo	  == select(2, ...)
						and relativePoint == select(3, ...)
						and xOfs		  == select(4, ...)
						and yOfs		  == select(5, ...)
						then
							frame, cKey = child, k
							break
						end
					else
						-- base checks on size
						height, width = _G.Round(child:GetHeight()), _G.Round(child:GetWidth())
						if	height == select(1, ...)
						and width  == select(2, ...)
						then
							frame, cKey = child, k
							break
						end
					end
				end
			end
		end
	end

	point, relativeTo, relativePoint, xOfs, yOfs = nil, nil, nil, nil, nil
	height, width = nil, nil

	return frame, cKey

end

function aObj:getChild(obj, childNo)
--@alpha@
	assert(obj, "Unknown object getChild\n" .. debugstack(2, 3, 2))
--@end-alpha@

	if obj and childNo then return (select(childNo, obj:GetChildren())) end

end

function aObj:getLastChild(obj)

	return self:getChild(obj, obj:GetNumChildren())

end

function aObj:getPenultimateChild(obj)

	return self:getChild(obj, obj:GetNumChildren() - 1)

end

function aObj:getGradientInfo(invert, rotate)

	local MinR, MinG, MinB, MinA = self.prdb.GradientMin.r, self.prdb.GradientMin.g, self.prdb.GradientMin.b, self.prdb.GradientMin.a
	local MaxR, MaxG, MaxB, MaxA = self.gmColour[1], self.gmColour[2], self.gmColour[3], self.gmColour[4]

	if self.prdb.Gradient.enable then
		if invert then
			return rotate and "HORIZONTAL" or "VERTICAL", MaxR, MaxG, MaxB, MaxA, MinR, MinG, MinB, MinA
		else
			return rotate and "HORIZONTAL" or "VERTICAL", MinR, MinG, MinB, MinA, MaxR, MaxG, MaxB, MaxA
		end
	else
		return rotate and "HORIZONTAL" or "VERTICAL", 0, 0, 0, 1, 0, 0, 0, 1
	end
	MinR, MinG, MinB, MinA, MaxR, MaxG, MaxB, MaxA = nil, nil, nil, nil, nil, nil, nil, nil

end

function aObj:getInt(num)
--@alpha@
	assert(num, "Missing number\n" .. debugstack(2, 3, 2))
	-- handle AddOn skins still using this code rather than _G.Round
	aObj:CustomPrint(1, 0, 0, "Using deprecated function - getInt, use _G.Round instead", debugstack(2, 3, 2))
--@end-alpha@

	return _G.math.floor(num + 0.5)

end

function aObj:getRegion(obj, regNo)
--@alpha@
	assert(obj, "Unknown object getRegion\n" .. debugstack(2, 3, 2))
	assert(regNo, "Missing value getRegion\n" .. debugstack(2, 3, 2))
--@end-alpha@

	if obj and regNo then return (select(regNo, obj:GetRegions())) end

end

function aObj:hasTextInName(obj, text)
--@alpha@
	assert(obj, "Unknown object hasTextInName\n" .. debugstack(2, 3, 2))
	assert(text, "Missing value hasTextInName\n" .. debugstack(2, 3, 2))
--@end-alpha@

	return obj and obj.GetName and obj:GetName() and obj:GetName():find(text) and true or false

end

function aObj:hasAnyTextInName(obj, tab)
--@alpha@
	assert(obj, "Unknown object hasAnyTextInName\n" .. debugstack(2, 3, 2))
	assert(tab, "Missing value hasAnyTextInName\n" .. debugstack(2, 3, 2))
--@end-alpha@

	if obj
	and obj.GetName
	and obj:GetName()
	then
		local oName = obj:GetName()
		for i = 1, #tab do
			if oName:find(tab[i]) then return true end
		end
	end

	return false

end

function aObj:hasTextInTexture(obj, text, plain)
--@alpha@
	-- assert(obj, "Unknown object hasTextInTexture\n" .. debugstack(2, 3, 2)) -- N.B. allow for missing texture object
	assert(text, "Missing value hasTextInTexture\n" .. debugstack(2, 3, 2))
--@end-alpha@

	return obj and obj.GetTexture and obj:GetTexture() and _G.tostring(obj:GetTexture()):find(text, 1, plain) and true or false

end

function aObj:hook(obj, method, func)

	if not self:IsHooked(obj, method) then
		self:Hook(obj, method, func)
	end

end

function aObj:hookSocialToastFuncs(frame)

	self:SecureHook(frame.animIn, "Play", function(this)
		if this.sf then
			this.sf.tfade:SetParent(_G.MainMenuBar)
			this.sf.tfade:SetGradientAlpha(self:getGradientInfo())
		end
		if this.cb then
			this.cb.tfade:SetParent(_G.MainMenuBar)
			this.cb.tfade:SetGradientAlpha(self:getGradientInfo())
		end
	end)
	self:SecureHook(frame.waitAndAnimOut, "Play", function(this)
		if this.sf then this.sf.tfade:SetParent(this.sf) end
		if this.cb then this.cb.tfade:SetParent(this.cb) end
	end)

end

function aObj:hookScript(obj, method, func)

	if not self:IsHooked(obj, method) then
		self:HookScript(obj, method, func)
	end

end

function aObj:isAddonEnabled(addonName)
--@alpha@
	assert(addonName, "Unknown object isAddonEnabled\n" .. debugstack(2, 3, 2))
--@end-alpha@

	if addonIdx[addonName] then
		return (_G.GetAddOnEnableState(uName, addonIdx[addonName]) > 0) or _G.IsAddOnLoadOnDemand(addonName)
	end

end

function aObj:isDropDown(obj)
--@alpha@
	assert(obj, "Unknown object isDropDown\n" .. debugstack(2, 3, 2))
--@end-alpha@

	if obj:IsObjectType("Frame")
	and obj:GetName()
	then
		return self:hasTextInTexture(_G[obj:GetName() .. "Left"], "CharacterCreate")
	else
		return false
	end

end

function aObj:keepFontStrings(obj, hide)
--@alpha@
	assert(obj, "Missing object kFS\n" .. debugstack(2, 3, 2))
--@end-alpha@

	for _, reg in ipairs{obj:GetRegions()} do
		if not reg:IsObjectType("FontString") then
			if not hide then reg:SetAlpha(0) else reg:Hide() end
		end
	end

end

function aObj:keepRegions(obj, regions)
--@alpha@
	assert(obj, "Missing object kR\n" .. debugstack(2, 3, 2))
--@end-alpha@

	local regions = revTable(regions)

	for i, reg in ipairs{obj:GetRegions()} do
		-- if we have a list, hide the regions not in that list
		if regions
		and not regions[i]
		then
			reg:SetAlpha(0)
--@debug@
			if reg:IsObjectType("FontString") then
				self:Debug("kr FS: [%s, %s]", obj, i)
				self:Print(debugstack(1, 5, 2))
			end
--@end-debug@
		end
	end

end

function aObj:makeMFRotatable(modelFrame)
--@alpha@
	assert(modelFrame and modelFrame:IsObjectType("PlayerModel"), "Not a PlayerModel\n" .. debugstack(2, 3, 2))
--@end-alpha@

	-- Don't make Model Frames Rotatable if CloseUp is loaded
	if _G.IsAddOnLoaded("CloseUp") then return end

	--frame:EnableMouseWheel(true)
	modelFrame:EnableMouse(true)
	modelFrame.draggingDirection = nil
	modelFrame.cursorPosition = {}

	-- hide rotation buttons
	for _, child in ipairs{modelFrame:GetChildren()} do
		if self:hasTextInName(child, "Rotate") then
			child:Hide()
		end
	end

	if modelFrame.RotateLeftButton then
		modelFrame.RotateLeftButton:Hide()
		modelFrame.RotateRightButton:Hide()
	end

	self:HookScript(modelFrame, "OnUpdate", function(this, elapsedTime, ...)
		if this.dragging then
			local x, y = _G.GetCursorPosition()
			if this.cursorPosition.x > x then
				_G.Model_RotateLeft(this, (this.cursorPosition.x - x) * elapsedTime * 2)
			elseif this.cursorPosition.x < x then
				_G.Model_RotateRight(this, (x - this.cursorPosition.x) * elapsedTime * 2)
			end
			this.cursorPosition.x, this.cursorPosition.y = _G.GetCursorPosition()
			x, y = nil, nil
		end
	end)
	self:HookScript(modelFrame, "OnMouseDown", function(this, button)
		if button == "LeftButton" then
			this.dragging = true
			this.cursorPosition.x, this.cursorPosition.y = _G.GetCursorPosition()
		end
	end)
	self:HookScript(modelFrame, "OnMouseUp", function(this, button)
		if this.dragging then
			this.dragging = false
			this.cursorPosition.x, this.cursorPosition.y = nil
		end
	end)

	--[[ MouseWheel to zoom Modelframe - in/out works, but needs to be fleshed out
	modelFrame:SetScript("OnMouseWheel", function()
		local xPos, yPos, zPos = frame:GetPosition()
		if arg1 == 1 then
			modelFrame:SetPosition(xPos+00.1, 0, 0)
		else
			modelFrame:SetPosition(xPos-00.1, 0, 0)
		end
	end) ]]

	if modelFrame.controlFrame then
		modelFrame.controlFrame:DisableDrawLayer("BACKGROUND")
	end

end

function aObj:makeIconSquare(obj, iconObjName, chkDisabled)

	obj[iconObjName]:SetTexCoord(.1, .9, .1, .9)
	self:addButtonBorder{obj=obj, relTo=obj[iconObjName], ofs=3}

	if chkDisabled then
		if self.modBtnBs then
			if obj.disabled
			or (obj.IsEnabled and not obj:IsEnabled())
			then
				obj.sbb:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
			else
				obj.sbb:SetBackdropBorderColor(self.bbColour[1], self.bbColour[2], self.bbColour[3], self.bbColour[4])

			end
		end
	end

end

local function __moveObject(opts)
--[[
	Calling parameters:
		obj = object (Mandatory)
		x = left/right adjustment
		y = up/down adjustment
		relTo = object to move relative to
--]]

--@debug@
	if opts.obj:GetNumPoints() > 1 then
		aObj:CustomPrint(1, 0, 0, "moveObject: %s, GetNumPoints = %d", opts.obj, opts.obj:GetNumPoints())
		return
	end
--@end-debug@

	local point, relTo, relPoint, xOfs, yOfs = opts.obj:GetPoint()

	-- handle no Point info
	if not point then return end

	relTo = opts.relTo or relTo
--@alpha@
	assert(relTo, "__moveObject relTo is nil\n" .. debugstack(2, 3, 2))
--@end-alpha@
	-- Workaround for relativeTo crash
	if not relTo then
		if aObj.db.profile.Warnings then
			aObj:CustomPrint(1, 0, 0, "moveObject (relativeTo) is nil: %s", opts.obj)
		end
		return
	end

	-- apply the adjustment
	xOfs = opts.x and xOfs + opts.x or xOfs
	yOfs = opts.y and yOfs + opts.y or yOfs

	-- now move it
	opts.obj:ClearAllPoints()
	opts.obj:SetPoint(point, relTo, relPoint, xOfs, yOfs)

	point, relTo, relPoint, xOfs, yOfs = nil, nil, nil, nil, nil

end
function aObj:moveObject(...)

	local opts = select(1, ...)

--@alpha@
	assert(opts, "Missing object mO\n" .. debugstack(2, 3, 2))
--@end-alpha@

	-- handle missing object (usually when addon changes)
	if not opts then return end

	if type(rawget(opts, 0)) == "userdata" and type(opts.GetObjectType) == "function" then
		-- old style call
		opts = {}
		opts.obj = select(1, ...) and select(1, ...) or nil
		opts.x = select(3, ...) and select(3, ...) or nil
		if select(2, ...) and select(2, ...) == "-" then opts.x = opts.x * -1 end
		opts.y = select(5, ...) and select(5, ...) or nil
		if select(4, ...) and select(4, ...) == "-" then opts.y = opts.y * -1 end
		opts.relTo = select(6, ...) and select(6, ...) or nil
	end

	__moveObject(opts)
	opts = nil

end

function aObj:nilTexture(obj, nop)

	obj:SetTexture(nil)
	obj:SetAtlas(nil)

	if nop then
		obj.SetTexture = _G.nop
		obj.SetAtlas = _G.nop
	end

end

function aObj:rawHook(obj, method, func, sec)

	if not self:IsHooked(obj, method) then
		self:RawHook(obj, method, func, sec)
	end

end

function aObj:removeInset(frame)
--@alpha@
	assert(frame, "Unknown object removeInset\n" .. debugstack(2, 3, 2))
--@end-alpha@

	frame:DisableDrawLayer("BACKGROUND")
	frame:DisableDrawLayer("BORDER")

end

function aObj:removeMagicBtnTex(btn)
--@alpha@
	assert(btn, "Unknown object removeMagicBtnTex\n" .. debugstack(2, 3, 2))
--@end-alpha@

	-- Magic Button textures
	if btn.LeftSeparator then btn.LeftSeparator:SetTexture(nil) end
	if btn.RightSeparator then btn.RightSeparator:SetTexture(nil) end

end

local function __rmRegs(obj, regions, rmTex)

	local regions = revTable(regions)

	for i, reg in ipairs{obj:GetRegions()} do
		if not regions
		or regions
		and regions[i]
		then
			if not rmTex then
				reg:SetAlpha(0)
			else
				if reg:IsObjectType("Texture") then
					reg:SetTexture(nil)
				end
			end
--@debug@
			if reg:IsObjectType("FontString") then
				aObj:Debug("rr FS: [%s, %s]", obj, i)
				aObj:Print(debugstack(1, 5, 2))
			end
--@end-debug@
		end
	end

end
function aObj:removeRegions(obj, regions)
--@alpha@
	assert(obj, "Missing object rR\n" .. debugstack(2, 3, 2))
--@end-alpha@

	__rmRegs(obj, regions)

end

function aObj:resizeTabs(frame)
--@alpha@
	assert(frame, "Unknown object resizeTabs\n" .. debugstack(2, 3, 2))
--@end-alpha@

	local tabName, nT, tTW, fW, tLW
	tabName = frame:GetName() .. "Tab"
	-- get the number of tabs
	nT = ((frame == _G.CharacterFrame and not _G.CharacterFrameTab2:IsShown()) and 4 or frame.numTabs)
	-- accumulate the tab text widths
	tTW = 0
	for i = 1, nT do
		tTW = tTW + _G[tabName .. i .. "Text"]:GetWidth()
	end
	-- add the tab side widths
	tTW = tTW + (40 * nT)
	-- get the frame width
	fW = frame:GetWidth()
	-- calculate the Tab left width
	tLW = (tTW > fW and (40 - (tTW - fW) / nT) / 2 or 20)
	-- set minimum left width
	tLW = ("%.2f"):format(tLW >= 6 and tLW or 5.5)
	-- update each tab
	for i = 1, nT do
		_G[tabName .. i .. "Left"]:SetWidth(tLW)
		_G.PanelTemplates_TabResize(_G[tabName .. i], 0)
	end
	tabName, nT, tTW, fW, tLW = nil, nil, nil, nil, nil

end

function aObj:resizeEmptyTexture(texture)
--@alpha@
	assert(texture, "Unknown object resizeEmptyTexture\n" .. debugstack(2, 3, 2))
--@end-alpha@

	texture:SetTexture(self.esTex)
	texture:SetSize(64, 64)
	texture:SetTexCoord(0, 1, 0, 1)
	texture:ClearAllPoints()
	texture:SetPoint("CENTER", texture:GetParent())

end

function aObj:rmRegionsTex(obj, regions)
--@alpha@
	assert(obj, "Missing object rRT\n" .. debugstack(2, 3, 2))
--@end-alpha@

	__rmRegs(obj, regions, true)

end

function aObj:round2(num, idp)
--@alpha@
	assert(num, "Missing number\n" .. debugstack(2, 3, 2))
--@end-alpha@

  return _G.tonumber(_G.string.format("%." .. (idp or 0) .. "f", num))

end

local function scanChildren(obj)

	for _, child in ipairs{_G[obj]:GetChildren()} do
		-- check for forbidden objects (StoreUI components etc.)
		if not child:IsForbidden() then
			aObj.callbacks:Fire(obj .. "_GetChildren", child)
		end
	end

	-- remove all callbacks for this event
	aObj.callbacks.events[obj .. "_GetChildren"] = nil

end
function aObj:scanUIParentsChildren()

	scanChildren("UIParent")

end

function aObj:scanWorldFrameChildren()

	scanChildren("WorldFrame")

end

function aObj:secureHook(obj, method, func)

	if not self:IsHooked(obj, method) then
		self:SecureHook(obj, method, func)
	end

end

function aObj:secureHookScript(obj, method, func)

	if not self:IsHooked(obj, method) then
		self:SecureHookScript(obj, method, func)
	end

end

function aObj:setActiveTab(tabSF)
--@alpha@
	-- assert(tabSF, "Missing object sAT\n" .. debugstack(2, 3, 2))
--@end-alpha@

	if not tabSF then return end
	if not tabSF.tfade then return end

	tabSF.tfade:SetTexture(self.gradientTex)
	tabSF.tfade:SetGradientAlpha(self:getGradientInfo(self.prdb.Gradient.invert, self.prdb.Gradient.rotate))

	if not tabSF.ignore and not tabSF.grown then
		local point, relativeTo, relativePoint, xOfs, yOfs
		if not tabSF.up then
			point, relativeTo, relativePoint, xOfs, yOfs = tabSF:GetPoint(2)
			tabSF:SetPoint("BOTTOMRIGHT", relativeTo, "BOTTOMRIGHT", xOfs, yOfs - 6)
		else
			point, relativeTo, relativePoint, xOfs, yOfs = tabSF:GetPoint(1)
			tabSF:SetPoint("TOPLEFT", relativeTo, "TOPLEFT", xOfs, yOfs + 6)
		end
		tabSF.grown = true
		point, relativeTo, relativePoint, xOfs, yOfs = nil, nil, nil, nil, nil
	end

end

function aObj:setInactiveTab(tabSF)
--@alpha@
	assert(tabSF, "Missing object sIT\n" .. debugstack(2, 3, 2))
--@end-alpha@

	if not tabSF then return end
	if not tabSF.tfade then return end

	tabSF.tfade:SetTexture(self.itTex)
	tabSF.tfade:SetAlpha(1)

	if not tabSF.ignore and tabSF.grown then
		local point, relativeTo, relativePoint, xOfs, yOfs
		if not tabSF.up then
			point, relativeTo, relativePoint, xOfs, yOfs = tabSF:GetPoint(2)
			tabSF:SetPoint("BOTTOMRIGHT", relativeTo, "BOTTOMRIGHT", xOfs, yOfs + 6)
		else
			point, relativeTo, relativePoint, xOfs, yOfs = tabSF:GetPoint(1)
			tabSF:SetPoint("TOPLEFT", relativeTo, "TOPLEFT", xOfs, yOfs - 6)
		end
		tabSF.grown = nil
		point, relativeTo, relativePoint, xOfs, yOfs = nil, nil, nil, nil, nil
	end

end

function aObj:setupBackdrop()

	local dflts = self.db.defaults.profile

	self.bdTexName = dflts.BdTexture
	self.bdbTexName = dflts.BdBorderTexture
	if self.prdb.BdDefault then
		self.backdrop = {
			bgFile = self.LSM:Fetch("background", self.bdTexName),
			tile = dflts.BdTileSize > 0 and true or false, tileSize = dflts.BdTileSize,
			edgeFile = self.LSM:Fetch("border", self.bdbTexName),
			edgeSize = dflts.BdEdgeSize,
			insets = {left = dflts.BdInset, right = dflts.BdInset, top = dflts.BdInset, bottom = dflts.BdInset},
		}
	else
		if self.prdb.BdFile
		and self.prdb.BdFile ~= "None"
		then
			self.bdTexName = aName .. " User Backdrop"
			self.LSM:Register("background", self.bdTexName, self.prdb.BdFile)
		else
			self.bdTexName = self.prdb.BdTexture
		end
		if self.prdb.BdEdgeFile
		and self.prdb.BdEdgeFile ~= "None"
		then
			self.bdbTexName = aName .. " User Border"
			self.LSM:Register("border", self.bdbTexName, self.prdb.BdEdgeFile)
		else
			self.bdbTexName = self.prdb.BdBorderTexture
		end
		self.backdrop = {
			bgFile = self.LSM:Fetch("background", self.bdTexName),
			tile = self.prdb.BdTileSize > 0 and true or false, tileSize = self.prdb.BdTileSize,
			edgeFile = self.LSM:Fetch("border", self.bdbTexName),
			edgeSize = self.prdb.BdEdgeSize,
			insets = {left = self.prdb.BdInset, right = self.prdb.BdInset, top = self.prdb.BdInset, bottom = self.prdb.BdInset},
		}
	end

end

--@debug@
function aObj:tableCount(table)

	local count = 0

	for _ in pairs(table) do count = count + 1 end

	return count

end
--@end-debug@
--[===[@non-debug@
function aObj:tableCount() end
--@end-non-debug@]===]

function aObj:toggleTabDisplay(tab, active)

	if active then
		if self.isTT then
			self:setActiveTab(tab.sf)
		else
			-- HIGHLIGHT_FONT_COLOR is white
			tab.Text:SetVertexColor(_G.HIGHLIGHT_FONT_COLOR.r, _G.HIGHLIGHT_FONT_COLOR.g, _G.HIGHLIGHT_FONT_COLOR.b)
		end
	else
		if self.isTT then
			self:setInactiveTab(tab.sf)
		else
			-- NORMAL_FONT_COLOR is yellow
			tab.Text:SetVertexColor(_G.NORMAL_FONT_COLOR.r, _G.NORMAL_FONT_COLOR.g, _G.NORMAL_FONT_COLOR.b)
		end
	end

end

function aObj:updateSBTexture()

	-- get updated colour/texture
	local sBar = self.prdb.StatusBar
	self.sbColour = {sBar.r, sBar.g, sBar.b, sBar.a}
	self.sbTexture = self.LSM:Fetch("statusbar", sBar.texture)

	for statusBar, tab in pairs(self.sbGlazed) do
		statusBar:SetStatusBarTexture(self.sbTexture)
		for k, tex in pairs(tab) do
			tex:SetTexture(self.sbTexture)
			if k == "bg" then tex:SetVertexColor(sBar.r, sBar.g, sBar.b, sBar.a) end
		end
	end
	sBar = nil

end

function aObj:CustomPrint(r, g, b, fstr, ...)

	_G.DEFAULT_CHAT_FRAME:AddMessage("|cffffff78" .. aName .. ":|r " .. makeText(fstr, ...), r, g, b)

end

--@debug@
-- specify where debug messages go & increase buffer size
aObj.debugFrame = _G.ChatFrame10
aObj.debugFrame:SetMaxLines(10000)
function aObj:Debug(fstr, ...)

	local output = ("|cff7fff7f(DBG) %s:[%s.%03d]|r"):format(aName, _G.date("%H:%M:%S"), (_G.GetTime() % 1) * 1000)
	self.debugFrame:AddMessage(output .. " " .. makeText(fstr, ...))
	output = nil

end
function aObj:Debug2(...)
	-- self:Debug(...)
end

function aObj:DebugSpew(title, obj, fmtStr, ...)

	self:Debug(title .. ": " .. fmtStr, ...)
	if _G.Spew then _G.Spew(title, obj) end

end
--@end-debug@

--[===[@non-debug@
aObj.debugFrame = nil
aObj.Debug = _G.nop
aObj.Debug2 = _G.nop
aObj.DebugSpew = _G.nop
--@end-non-debug@]===]

-- This function was copied from WoWWiki
-- http://www.wowwiki.com/RGBPercToHex
function aObj:RGBPercToHex(r, g, b)
--@alpha@
	assert(r, "Missing value (red) - RGBPercToHex\n" .. debugstack(2, 3, 2))
	assert(g, "Missing value (green) - RGBPercToHex\n" .. debugstack(2, 3, 2))
	assert(b, "Missing value (blue) - RGBPercToHex\n" .. debugstack(2, 3, 2))
--@end-alpha@

--	Check to see if the passed values are strings, if so then use some default values
	if type(r) == "string" then r, g, b = 0.8, 0.8, 0.0 end

	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0

	return ("%02x%02x%02x"):format(r*255, g*255, b*255)

end

function aObj:RaiseFrameLevelByFour(frame)

	frame:SetFrameLevel(frame:GetFrameLevel() + 4)

end

--@alpha@
local function print_family_tree(fName)

	if fName:IsForbidden() then
		print("Frame access is forbidden")
		return
	end

	local lvl = "Parent"
	print(makeText("Frame is %s, %s, %s, %s, %s", fName, fName:GetFrameLevel(), fName:GetFrameStrata(), _G.Round(fName:GetWidth()) or "nil", _G.Round(fName:GetHeight()) or "nil"))
	while fName:GetParent() do
		fName = fName:GetParent()
		print(makeText("%s is %s, %s, %s, %s, %s", lvl, fName, (fName:GetFrameLevel() or "<Anon>"), (fName:GetFrameStrata() or "<Anon>"), _G.Round(fName:GetWidth()) or "nil", _G.Round(fName:GetHeight()) or "nil"))
		lvl = (lvl:find("Grand") and "Great" or "Grand") .. lvl
	end
	lvl = nil

end

local GetMouseFocus = _G.GetMouseFocus
function aObj:SetupCmds()

	local function getObj(input)
        -- print("getObj", input, _G[input], GetMouseFocus())
		if not input or input:trim() == "" then
			return GetMouseFocus()
		else
            return getObjFromString(input)
        end
	end
	local function getObjP(input)
		-- print("getObjP", input, _G[input], GetMouseFocus():GetParent())
		if not input or input:trim() == "" then
			return GetMouseFocus():GetParent()
		else
            return getObjFromString(input)
        end
	end
	local function getObjGP(input)
		-- print("getObjGP", input, _G[input], GetMouseFocus():GetParent():GetParent())
		if not input or input:trim() == "" then
			return GetMouseFocus():GetParent():GetParent()
		else
            return getObjFromString(input)
        end
	end
	self:RegisterChatCommand("lo", function() _G.UIErrorsFrame:AddMessage("Use /camp instead of /lo", 1.0, 0.1, 0.1, 1.0) end)
	self:RegisterChatCommand("rl", function() _G.C_UI.Reload() end)
	self:RegisterChatCommand("pin", function(msg) print(msg, "is item:", (_G.GetItemInfoFromHyperlink(msg))) end)
	self:RegisterChatCommand("pii", function(msg) print(_G.GetItemInfo(msg)) end)
	self:RegisterChatCommand("pil", function(msg) print(_G.gsub(msg, "\124", "\124\124")) end)
	self:RegisterChatCommand("ft", function() print_family_tree(GetMouseFocus()) end)
	self:RegisterChatCommand("ftp", function() print_family_tree(GetMouseFocus():GetParent()) end)
	self:RegisterChatCommand("sid", function(msg) self:ShowInfo(getObj(msg), true, false) end) -- detailed
	self:RegisterChatCommand("si1", function(msg) self:ShowInfo(getObj(msg), true, true) end) -- 1 level only
	self:RegisterChatCommand("sir", function(msg) self:ShowInfo(getObj(msg), false, false) end) -- regions only
	self:RegisterChatCommand("sidp", function(msg) self:ShowInfo(getObjP(msg), true, false) end) -- detailed
	self:RegisterChatCommand("si1p", function(msg) self:ShowInfo(getObjP(msg), true, true) end) -- 1 level only
	self:RegisterChatCommand("sirp", function(msg) self:ShowInfo(getObjP(msg), false, false) end) -- regions only
	self:RegisterChatCommand("sidgp", function(msg) self:ShowInfo(getObjGP(msg), true, false) end) -- detailed
	self:RegisterChatCommand("si1gp", function(msg) self:ShowInfo(getObjGP(msg), true, false) end) -- 1 level only
	self:RegisterChatCommand("sirgp", function(msg) self:ShowInfo(getObjGP(msg), false, false) end) -- regions only
	self:RegisterChatCommand("gp", function() print(GetMouseFocus():GetPoint()) end)
	self:RegisterChatCommand("gpp", function() print(GetMouseFocus():GetParent():GetPoint()) end)
	self:RegisterChatCommand("sspew", function(msg) return _G.Spew and _G.Spew(msg, getObj(msg)) end)
	self:RegisterChatCommand("sspewp", function(msg) return _G.Spew and _G.Spew(msg, getObjP(msg)) end)
	self:RegisterChatCommand("sspewgp", function(msg) return _G.Spew and _G.Spew(msg, getObjGP(msg)) end)

	self:RegisterChatCommand("shc", function(msg) self:Debug("Hooks table Count: [%s]", self:tableCount(self.hooks))
 end)

	self:RegisterChatCommand("wai", function() -- where am I ?
		local posTab = _G.C_Map.GetPlayerMapPosition(_G.C_Map.GetBestMapForUnit("player"), "player")
		_G.DEFAULT_CHAT_FRAME:AddMessage(_G.format("%s, %s: %.1f, %.1f", _G.GetZoneText(), _G.GetSubZoneText(), posTab.x * 100, posTab.y * 100))
		posTab = nil
		return
	end)

end

function aObj:ShowInfo(obj, showKids, noDepth)

    print("ShowInfo:", obj, showKids, noDepth, obj:IsForbidden())

	assert(obj, "Unknown object ShowInfo\n" .. debugstack(2, 3, 2))

	if obj:IsForbidden() then return end

    print(makeText("ShowInfo: [%s, %s, %s]", obj, showKids, noDepth))
	showKids = showKids or false

	local function showIt(fmsg, ...)

		self.debugFrame:AddMessage("dbg:" .. makeText(fmsg, ...))

	end

	local function getRegions(obj, lvl)

		for k, reg in ipairs{obj:GetRegions()} do
			showIt("[lvl%sr%s : %s : %s : %s : %s : %s]", lvl, k, reg, reg:GetObjectType() or "nil", reg.GetWidth and _G.Round(reg:GetWidth()) or "nil", reg.GetHeight and _G.Round(reg:GetHeight()) or "nil", reg:GetObjectType() == "Texture" and ("%s : %s"):format(reg:GetTexture() or "nil", reg:GetDrawLayer() or "nil") or "nil")
		end

	end

	local function getChildren(frame, lvl)

		if not showKids then return end
		if type(lvl) == "string" and lvl:find("c") == 2 and noDepth then return end

        local kids = {frame:GetChildren()}
        for k, child in ipairs(kids) do
			local objType = child:GetObjectType()
			showIt("[lvl%sc%s : %s : %s : %s : %s : %s]", lvl, k, child, child.GetWidth and _G.Round(child:GetWidth()) or "nil", child.GetHeight and _G.Round(child:GetHeight()) or "nil", child:GetFrameLevel() or "nil", child:GetFrameStrata() or "nil")
			if objType == "Frame"
			or objType == "Button"
			or objType == "StatusBar"
			or objType == "Slider"
			or objType == "ScrollFrame"
			then
				getRegions(child, lvl .. "c" .. k)
				getChildren(child, lvl .. "c" .. k)
			end
        end
        kids = nil

	end

	showIt("%s : %s : %s : %s : %s : %s : %s", obj, _G.Round(obj:GetWidth()) or "nil", _G.Round(obj:GetHeight()) or "nil", obj:GetFrameLevel() or "nil", obj:GetFrameStrata() or "nil", obj:GetNumRegions(), obj:GetNumChildren())

	showIt("Started Regions")
	getRegions(obj, 0)
	showIt("Finished Regions")
	showIt("Started Children")
	getChildren(obj, 0)
	showIt("Finished Children")

end
--@end-alpha@
