local aName, aObj = ...

local _G = _G

function aObj:addBackdrop(obj) -- luacheck: ignore self

	if not obj.ApplyBackdrop then
		_G.Mixin(obj, _G.BackdropTemplateMixin)
	end

end

local function __adjHeight(opts)
--[[
	Calling parameters:
		obj = object (Mandatory)
		adj = value to adjust height by
--]]
	--@alpha@
	_G.assert(opts.obj, "Missing object aH\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	if opts.adj == 0 then return end

	if not _G.strfind(_G.tostring(opts.adj), "+") then -- if not negative value
		opts.obj:SetHeight(opts.obj:GetHeight() + opts.adj)
	else
		opts.adj = opts.adj * -1 -- make it positive
		opts.obj:SetHeight(opts.obj:GetHeight() - opts.adj)
	end

end
function aObj:adjHeight(...) -- luacheck: ignore self

	local opts = _G.select(1, ...)

	--@alpha@
	_G.assert(opts, "Missing object aH\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	-- handle missing object (usually when addon changes)
	if not opts then return end

	if _G.type(_G.rawget(opts, 0)) == "userdata" and _G.type(opts.GetObjectType) == "function" then
		-- old style call
		opts = {}
		opts.obj = _G.select(1, ...) and _G.select(1, ...) or nil
		opts.adj = _G.select(2, ...) and _G.select(2, ...) or 0
	end
	__adjHeight(opts)

end

local function __adjWidth(opts)
--[[
	Calling parameters:
		obj = object (Mandatory)
		adj = value to adjust width by
--]]
	--@alpha@
	_G.assert(opts.obj, "Missing object aW\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	if opts.adj == 0 then return end

	if not _G.strfind(_G.tostring(opts.adj), "+") then -- if not negative value
		opts.obj:SetWidth(opts.obj:GetWidth() + opts.adj)
	else
		opts.adj = opts.adj * -1 -- make it positive
		opts.obj:SetWidth(opts.obj:GetWidth() - opts.adj)
	end

end
function aObj:adjWidth(...) -- luacheck: ignore self

	local opts = _G.select(1, ...)

	--@alpha@
	_G.assert(opts, "Missing object aW\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	-- handle missing object (usually when addon changes)
	if not opts then return end

	if _G.type(_G.rawget(opts, 0)) == "userdata" and _G.type(opts.GetObjectType) == "function" then
		-- old style call
		opts = {}
		opts.obj = _G.select(1, ...) and _G.select(1, ...) or nil
		opts.adj = _G.select(2, ...) and _G.select(2, ...) or 0
	end
	__adjWidth(opts)

end

function aObj:addFrameBorder(opts)

	local aso = opts.aso or {}
	if aObj.prdb.FrameBorders then
		aso.bd = 10
		aso.ng = true
	end
	-- setup some defaults
	if opts.kfs == nil then opts.kfs = true end
	if opts.nb == nil then opts.nb = true end
	self:addSkinFrame{obj=opts.obj, ft=opts.ft or "a", kfs=opts.kfs, nb=opts.nb, aso=aso, ofs=opts.ofs or 0, x1=opts.x1, y1=opts.y1, x2=opts.x2, y2=opts.y2}

end

function aObj:applyGradient(obj, fh, invert, rotate)

	-- don't apply a gradient if required
	if not self.prdb.Gradient.char then
		if self.gradFrames.p[obj] then return end
	end
	if not self.prdb.Gradient.ui then
		if self.gradFrames.u[obj] then return end
	end
	if not self.prdb.Gradient.npc then
		if self.gradFrames.n[obj] then return end
	end
	if not self.prdb.Gradient.skinner then
		if self.gradFrames.s[obj] then return end
	end
	if not self.prdb.Gradient.addon then
		if self.gradFrames.a[obj] then return end
	end

	invert = invert or self.prdb.Gradient.invert
	rotate = rotate or self.prdb.Gradient.rotate

	if not obj.tfade then
		obj.tfade = obj:CreateTexture(nil, "BORDER", nil, -1)
		obj.tfade:SetTexture(self.gradientTex)
		obj.tfade:SetBlendMode("ADD")
		if self.isClscERA then
			obj.tfade:SetGradientAlpha(self:getGradientInfo(invert, rotate))
		else
			obj.tfade:SetGradient(self:getGradientInfo(invert, rotate))
		end
	end

	if self.prdb.FadeHeight.enable
	and (self.prdb.FadeHeight.force or not fh)
	and _G.Round(obj:GetHeight()) ~= obj.hgt
	then
		-- set the Fade Height if not already passed to this function or 'forced'
		-- making sure that it isn't greater than the frame height
		obj.hgt = _G.Round(obj:GetHeight())
		fh = self.prdb.FadeHeight.value <= obj.hgt and self.prdb.FadeHeight.value or obj.hgt
	end

	local oFs = self.prdb.BdInset
	obj.tfade:ClearAllPoints()
	if not invert -- fade from top
	and not rotate
	then
		obj.tfade:SetPoint("TOPLEFT", obj, "TOPLEFT", oFs, oFs * -1)
		if fh then
			obj.tfade:SetPoint("BOTTOMRIGHT", obj, "TOPRIGHT", oFs * -1, -(fh - oFs))
		else
			obj.tfade:SetPoint("BOTTOMRIGHT", obj, "BOTTOMRIGHT", oFs * -1, oFs)
		end
	elseif invert -- fade from bottom
	and not rotate
	then
		obj.tfade:SetPoint("BOTTOMLEFT", obj, "BOTTOMLEFT", oFs, oFs)
		if fh then
			obj.tfade:SetPoint("TOPRIGHT", obj, "BOTTOMRIGHT", oFs * -1, (fh - oFs))
		else
			obj.tfade:SetPoint("TOPRIGHT", obj, "TOPRIGHT", oFs * -1, oFs * -1)
		end
	elseif not invert -- fade from right
	and rotate
	then
		obj.tfade:SetPoint("TOPRIGHT", obj, "TOPRIGHT", oFs * -1, oFs * -1)
		if fh then
			obj.tfade:SetPoint("BOTTOMLEFT", obj, "BOTTOMRIGHT", -(fh - oFs), oFs)
		else
			obj.tfade:SetPoint("BOTTOMLEFT", obj, "BOTTOMLEFT", oFs, oFs)
		end
	elseif invert -- fade from left
	and rotate
	then
		obj.tfade:SetPoint("TOPLEFT", obj, "TOPLEFT", oFs, oFs * -1)
		if fh then
			obj.tfade:SetPoint("BOTTOMRIGHT", obj, "BOTTOMLEFT", fh - oFs, oFs)
		else
			obj.tfade:SetPoint("BOTTOMRIGHT", obj, "BOTTOMRIGHT", oFs * -1, oFs)
		end
	end

end

function aObj:applyTooltipGradient(obj)

	if obj:IsForbidden() then return end

	if self.prdb.Tooltips.style == 1 then -- Rounded
		self:applyGradient(obj, 32)
	elseif self.prdb.Tooltips.style == 2 then -- Flat
		self:applyGradient(obj)
	elseif self.prdb.Tooltips.style == 3 then -- Custom
		self:applyGradient(obj, self.prdb.FadeHeight.value <= _G.Round(obj:GetHeight()) and self.prdb.FadeHeight.value or _G.Round(obj:GetHeight()))
	end

end

function aObj:capitStr(str) -- luacheck: ignore self

	return str:sub(1,1):upper() .. str:sub(2):lower()

end

function aObj:changeMinusPlusTex(obj, minus) -- luacheck: ignore self
	--@alpha@
	_G.assert(obj, "Unknown object changeMinusPlusTex\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	local nTex = obj:GetNormalTexture()
	nTex:SetTexture(aObj.tFDIDs.mpTex)
	if minus then
		nTex:SetTexCoord(0.29687500, 0.54687500, 0.00781250, 0.13281250)
	else
		nTex:SetTexCoord(0.57812500, 0.82812500, 0.14843750, 0.27343750)
	end

end

function aObj:changeShield(shldReg, iconReg)
	--@alpha@
	_G.assert(shldReg, "Unknown object changeShield\n" .. _G.debugstack(2, 3, 2))
	_G.assert(iconReg, "Unknown object changeShield\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	self:changeTandC(shldReg, self.tFDIDs.shieldTex)
	shldReg:SetSize(44, 44)
	-- move it behind the icon
	shldReg:ClearAllPoints()
	shldReg:SetPoint("CENTER", iconReg, "CENTER", 9, -1)

end

function aObj:changeTandC(obj, tex)
	--@alpha@
	_G.assert(obj, "Unknown object changeTandC\n" .. _G.debugstack(2, 3, 2))
	if tex == self.tFDIDs.lvlBG then
		self:CustomPrint(1, 0, 0, "changeTandC - Using default texture")
	end
	--@end-alpha@

	obj:SetTexture(tex or self.tFDIDs.lvlBG)
	obj:SetTexCoord(0, 1, 0, 1)
	if tex == self.sbTexture then
		self.sbGlazed[obj] = {}
	end

end

function aObj:changeTex(obj, isYellow, isUnitFrame)
	--@alpha@
	_G.assert(obj, "Unknown object changeTex\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	obj:SetTexture(self.tFDIDs.btnTex)
	if isYellow then
		obj:SetTexCoord(isUnitFrame and 0.015 or 0.0038, isUnitFrame and 0.66 or 0.7, 0.67, 0.855) -- yellow
	else
		obj:SetTexCoord(0.0038, 0.7, 0.004, 0.205) -- blue
	end

end

function aObj:changeTex2SB(obj)
	--@alpha@
	_G.assert(obj, "Unknown object changeTex2SB\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	obj:SetTexture(self.sbTexture)
	self.sbGlazed[obj] = {}

end

local errorhandler = _G.geterrorhandler()
local function safecall(funcName, funcObj, LoD, quiet)
	--@alpha@
	_G.assert(funcObj, "Unknown object safecall\n" .. _G.debugstack(2, 3, 2))
	local beginTime = _G.debugprofilestop()
	--@end-alpha@
	-- handle errors from internal functions
	local success, err = _G.xpcall(function() return funcObj(aObj, LoD) end, errorhandler)
	--@alpha@
	local timeUsed = _G.Round(_G.debugprofilestop() - beginTime)
	if timeUsed > 5 then
		 _G.print("Took " .. timeUsed .. " milliseconds to load " .. funcName)
	end
	--@end-alpha@
	if quiet then
		return success, err
	end
	if not success then
		if aObj.prdb.Errors then
			aObj:CustomPrint(1, 0, 0, "Error running", funcName)
		end
	end
end

local hadWarning = {}
function aObj:checkAndRun(funcName, funcType, LoD, quiet)
	--@alpha@
	_G.assert(funcName, "Unknown functionName checkAndRun\n" .. _G.debugstack(2, 3, 2))
	_G.assert(funcType, "Unknown functionType checkAndRun\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	self:Debug2("checkAndRun: [%s, %s, %s, %s]", funcName, funcType, LoD, quiet)

	-- handle in combat
	if _G.InCombatLockdown() then
		self:add2Table(self.oocTab, {self.checkAndRun, {self, funcName, funcType, LoD, quiet}})
		return
	end

	-- setup function's table object to use
	local tObj
	if funcType		== "s" then tObj = self
	elseif funcType == "l" then tObj = self.libsToSkin
	elseif funcType == "o" then tObj = self.otherAddons
	elseif funcType == "opt" then tObj = self
	else tObj = LoD and self.blizzLoDFrames[funcType] or self.blizzFrames[funcType]
	end

	-- only skin frames if required
	if (funcType == "n" and self.prdb.DisableAllNPC)
	or (funcType == "p" and self.prdb.DisableAllP)
	or (funcType == "u" and self.prdb.DisableAllUI)
	or (funcType == "s" and (self.prdb.DisabledSkins[funcName] or self.prdb.DisabledSkins[funcName .. " (LoD)"] or self.prdb.DisableAllAS))
	or (funcType == "l" and (self.prdb.DisabledSkins[funcName .. " (Lib)"] or self.prdb.DisableAllAS))
	or (funcType == "o" and (self.prdb.DisabledSkins[funcName] or self.prdb.DisableAllAS))
	then
		if self.prdb.Warnings
		and not hadWarning[funcName]
		then
			self:CustomPrint(1, 0, 0, funcName, "not skinned, flagged as disabled (c&R)")
			hadWarning[funcName] = true
		end
		return
	else
		self:Debug2("checkAndRun #2: [%s]", _G.type(tObj[funcName]))
		if _G.type(tObj[funcName]) == "function" then
			return safecall(funcName, tObj[funcName], nil, quiet)
		else
			if not quiet and self.prdb.Warnings then
				self:CustomPrint(1, 0, 0, "function [" .. funcName .. "] not found in " .. aName .. " (c&R)")
			end
		end
	end

end

function aObj:checkAndRunAddOn(addonName, addonFunc, LoD)
	--@alpha@
	_G.assert(addonName, "Unknown object checkAndRunAddOn\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	self:Debug2("checkAndRunAddOn#1: [%s, %s, %s, %s]", addonName, addonFunc, LoD, _G.type(addonFunc))

	-- handle in combat
	if _G.InCombatLockdown() then
		self:add2Table(self.oocTab, {self.checkAndRunAddOn, {self, addonName, addonFunc, LoD}})
		return
	end

	-- handle old & new function definitions
	addonFunc = _G.type(addonFunc) == "function" and addonFunc or self[addonFunc]

	-- don't skin any Addons whose skins are flagged as disabled
	if self.prdb.DisabledSkins[addonName]
	or self.prdb.DisabledSkins[addonName .. " (LoD)"]
	or self.prdb.DisableAllAS
	then
		if self.prdb.Warnings
		and not hadWarning[addonName]
		then
			self:CustomPrint(1, 0, 0, addonName, "not skinned, flagged as disabled (c&RA)")
			hadWarning[addonName] = true
		end
		return
	end

	self:Debug2("checkAndRunAddOn #2: [%s, %s, %s, %s]", _G.IsAddOnLoaded(addonName), _G.IsAddOnLoadOnDemand(addonName), addonFunc, _G.type(addonFunc))

	if not _G.IsAddOnLoaded(addonName) then
		-- deal with Addons under the control of an LoadManager
		if _G.IsAddOnLoadOnDemand(addonName) and not LoD then
			self.lmAddons[addonName:lower()] = addonFunc -- store with lowercase addonname (AddonLoader fix)
		-- Nil out loaded Skins for Addons that aren't loaded
		elseif addonFunc then
			addonFunc = nil -- luacheck: ignore addonFunc
		end
	else
		-- check to see if AddonSkin is loaded when Addon is loaded
		if not LoD and not addonFunc then
			if self.prdb.Warnings then
				self:CustomPrint(1, 0, 0, addonName, "loaded but skin not found in the AddonSkins directory (c&RA)")
			end
		elseif _G.type(addonFunc) == "function" then
			return safecall(addonName, addonFunc, LoD)
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
	if not loadable then
		if self.prdb.Warnings then
			self:CustomPrint(1, 0, 0, addonName, "not skinned, flagged as:", reason, "(cL)")
		end
	end

	return loadable

end

function aObj:checkShown(frame) -- luacheck: ignore self

	if frame:IsShown() then
		frame:Hide()
		frame:Show()
	end

end

function aObj:checkDisabledDD(obj, disabled)

	disabled = disabled or obj.isDisabled
	if obj.sf then
		self:clrBBC(obj.sf, disabled and "grey")
		if self.modBtnBs then
			local btn = obj.Button and obj.Button.sbb
					 or obj.dropButton and obj.dropButton.sbb
					 or obj:GetName() and _G[obj:GetName() .. "Button"] and _G[obj:GetName() .. "Button"].sbb
			if btn then
				self:clrBtnBdr(btn, disabled and "grey")
			end
		end
	end

end

function aObj:clrBBC(obj, clrName, alpha)

	local r, g, b, a = self:getColourByName(clrName)
	obj:SetBackdropBorderColor(r, g, b, alpha or a)

end

-- colour Frame border based upon Covenant
local tKit, r, g, b
function aObj:clrCovenantBdr(frame, uiTextureKit) -- luacheck: ignore self

	tKit = uiTextureKit or _G.C_Covenants.GetCovenantData(_G.C_Covenants.GetActiveCovenantID()).textureKit
	r, g, b = _G.COVENANT_COLORS[tKit]:GetRGB()
	frame.sf:SetBackdropBorderColor(r, g, b, 0.75)

end

function aObj:clrPNBtns(framePrefix, isObj)

	local ppb, npb
	if isObj then
		ppb, npb = framePrefix.PrevPageButton, framePrefix.NextPageButton
	else
		ppb, npb = _G[framePrefix .. "PrevPageButton"], _G[framePrefix .. "NextPageButton"]
	end
	self:clrBtnBdr(ppb, "gold")
	self:clrBtnBdr(npb, "gold")

end

function aObj:findFrame(height, width, children) -- luacheck: ignore self
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
						local tmpTab = {}
						for _, child in _G.ipairs{obj:GetChildren()} do
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

	return frame

end

function aObj:findFrame2(parent, objType, ...) -- luacheck: ignore self
	--@alpha@
	_G.assert(parent, "Unknown object findFrame2\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	if not parent then return end

	local point, relativeTo, relativePoint, xOfs, yOfs
	local frame, cKey
	local height, width

	for k, child in _G.ipairs{parent:GetChildren()} do
		-- check for forbidden objects (StoreUI components)
		if not child:IsForbidden() then
			if child:GetName() == nil then
				if child:IsObjectType(objType) then
					if _G.select("#", ...) > 2 then
						-- base checks on position
						point, relativeTo, relativePoint, xOfs, yOfs = child:GetPoint()
						xOfs = xOfs and _G.Round(xOfs) or 0
						yOfs = yOfs and _G.Round(yOfs) or 0
						if	point		  == _G.select(1, ...)
						and relativeTo	  == _G.select(2, ...)
						and relativePoint == _G.select(3, ...)
						and xOfs		  == _G.select(4, ...)
						and yOfs		  == _G.select(5, ...)
						then
							frame, cKey = child, k
							break
						end
					else
						-- base checks on size
						height, width = _G.Round(child:GetHeight()), _G.Round(child:GetWidth())
						if	height == _G.select(1, ...)
						and width  == _G.select(2, ...)
						then
							frame, cKey = child, k
							break
						end
					end
				end
			end
		end
	end

	return frame, cKey

end

function aObj:getChild(obj, childNo) -- luacheck: ignore self
	--@alpha@
	_G.assert(obj, "Unknown object getChild\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	if obj and childNo then return (_G.select(childNo, obj:GetChildren())) end

end

local clrTab = {
	blue        = _G.BLUE_FONT_COLOR,
	bright_blue = _G.BRIGHTBLUE_FONT_COLOR,
	light_blue  = _G.LIGHTBLUE_FONT_COLOR,
	common      = _G.LIGHTGRAY_FONT_COLOR,
	-- default is bbClr
	disabled    = _G.DISABLED_FONT_COLOR,
	gold_df     = _G.GOLD_FONT_COLOR,
	gold        = _G.PASSIVE_SPELL_FONT_COLOR,
	green       = _G.GREEN_FONT_COLOR,
	grey        = _G.GRAY_FONT_COLOR,
	normal      = _G.NORMAL_FONT_COLOR,
	orange      = _G.ORANGE_FONT_COLOR,
	red         = _G.DULL_RED_FONT_COLOR,
	selected    = _G.PAPER_FRAME_EXPANDED_COLOR,
	sepia       = _G.SEPIA_COLOR,
	silver      = _G.QUEST_OBJECTIVE_FONT_COLOR,
	topaz       = _G.CreateColor(0.6, 0.31, 0.24),
	turq        = _G.ADVENTURES_BUFF_BLUE,
	unused      = _G.DULL_RED_FONT_COLOR,
	white       = _G.HIGHLIGHT_FONT_COLOR,
	yellow      = _G.YELLOW_FONT_COLOR,
}
function aObj:getColourByName(clrName)

	if not clrTab.slider then
		clrTab.slider = _G.CopyTable(self.prdb.SliderBorder)
	end

	if clrTab[clrName] then
		return clrTab[clrName]:GetRGBA()
	else
		return self.bbClr:GetRGBA()
	end

end

function aObj:getGradientInfo(invert, rotate)

	local MinR, MinG, MinB, MinA = aObj.gminClr:GetRGBA()
	local MaxR, MaxG, MaxB, MaxA = aObj.gmaxClr:GetRGBA()

	if self.prdb.Gradient.enable then
		if invert then
			if self.isClscERA then
				return rotate and "HORIZONTAL" or "VERTICAL", MaxR, MaxG, MaxB, MaxA, MinR, MinG, MinB, MinA
			else
				return rotate and "HORIZONTAL" or "VERTICAL", aObj.gmaxClr, aObj.gminClr
			end
		else
			if self.isClscERA then
				return rotate and "HORIZONTAL" or "VERTICAL", MinR, MinG, MinB, MinA, MaxR, MaxG, MaxB, MaxA
			else
				return rotate and "HORIZONTAL" or "VERTICAL", aObj.gminClr, aObj.gmaxClr
			end
		end
	else
		if self.isClscERA then
			return rotate and "HORIZONTAL" or "VERTICAL", 0, 0, 0, 1, 0, 0, 0, 1
		else
			return rotate and "HORIZONTAL" or "VERTICAL", _G.BLACK_FONT_COLOR, _G.BLACK_FONT_COLOR
		end
	end

end

function aObj:getInt(num) -- luacheck: ignore self
	--@alpha@
	_G.assert(num, "Missing number\n" .. _G.debugstack(2, 3, 2))
	-- handle AddOn skins still using this code rather than _G.Round
	aObj:CustomPrint(1, 0, 0, "Using deprecated function - getInt, use _G.Round instead", _G.debugstack(2, 3, 2))
		--@end-alpha@

	return _G.math.floor(num + 0.5)

end

function aObj:getKeys(curTab) -- luacheck: ignore self

	if not curTab then return end

	local tmpTab = {}
	for i = 1, #curTab do
		tmpTab[curTab[i]] = true
	end

	return tmpTab

end

function aObj:getLastChild(obj)

	return self:getChild(obj, obj:GetNumChildren())

end

function aObj:getPenultimateChild(obj)

	return self:getChild(obj, obj:GetNumChildren() - 1)

end

function aObj:getLastRegion(obj)

	return self:getRegion(obj, obj:GetNumRegions())

end

function aObj:getRegion(obj, regNo) -- luacheck: ignore self
	--@alpha@
	_G.assert(obj, "Unknown object getRegion\n" .. _G.debugstack(2, 3, 2))
	_G.assert(regNo, "Missing value getRegion\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	if obj and regNo then return (_G.select(regNo, obj:GetRegions())) end

end

function aObj:hasTextInName(obj, text) -- luacheck: ignore self
	--@alpha@
	_G.assert(obj, "Unknown object hasTextInName\n" .. _G.debugstack(2, 3, 2))
	_G.assert(text, "Missing value hasTextInName\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	return obj and obj.GetName and obj:GetName() and obj:GetName():find(text, 1, true) and true or false

end

function aObj:hasTextInDebugNameRE(obj, text) -- luacheck: ignore self
	--@alpha@
	_G.assert(obj, "Unknown object hasTextInName\n" .. _G.debugstack(2, 3, 2))
	_G.assert(text, "Missing value hasTextInName\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	return obj and obj.GetDebugName and obj:GetDebugName() and obj:GetDebugName():find(text) and true or false

end

function aObj:hasAnyTextInName(obj, tab) -- luacheck: ignore self
	--@alpha@
	_G.assert(obj, "Unknown object hasAnyTextInName\n" .. _G.debugstack(2, 3, 2))
	_G.assert(tab, "Missing value hasAnyTextInName\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	if obj
	and obj.GetName
	and obj:GetName()
	then
		local oName = obj:GetName()
		for _, text in _G.ipairs(tab) do
			if oName:find(text, 1, true) then
				return true
			end
		end
	end

	return false

end

function aObj:hasTextInTexture(obj, text) -- luacheck: ignore self
	--@alpha@
	_G.assert(obj, "Unknown object hasTextInTexture\n" .. _G.debugstack(2, 3, 2))
	_G.assert(text, "Missing value hasTextInTexture\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	return obj and obj.GetTexture and obj:GetTexture() and _G.tostring(obj:GetTexture()):find(text, 1, true) and true or false

end

function aObj:hook(obj, method, func)

	if not self:IsHooked(obj, method) then
		self:Hook(obj, method, func)
	end

end

function aObj:hookQuestText(btn)

	self:rawHook(btn, "SetFormattedText", function(this, fmtString, text)
		if fmtString == _G.NORMAL_QUEST_DISPLAY then
			fmtString = self.HT:WrapTextInColorCode("%s|r")
		elseif fmtString == _G.TRIVIAL_QUEST_DISPLAY then
			fmtString = self.BT:WrapTextInColorCode("%s (low level)|r")
		elseif fmtString == _G.IGNORED_QUEST_DISPLAY then
			fmtString = self.IT:WrapTextInColorCode("%s (ignored)|r")
		end
		return self.hooks[this].SetFormattedText(this, fmtString, text)
	end, true)

end

function aObj:hookSocialToastFuncs(frame)

	self:SecureHook(frame.animIn, "Play", function(this)
		if this.sf then
			this.sf.tfade:SetParent(_G.MainMenuBar)
			if self.isClscERA then
				this.sf.tfade:SetGradientAlpha(self:getGradientInfo())
			else
				this.sf.tfade:SetGradient(self:getGradientInfo())
			end
		end
		if this.cb then
			this.cb.tfade:SetParent(_G.MainMenuBar)
			if self.isClscERA then
				this.cb.tfade:SetGradientAlpha(self:getGradientInfo())
			else
				this.cb.tfade:SetGradient(self:getGradientInfo())
			end
		end
	end)
	self:SecureHook(frame.waitAndAnimOut, "Play", function(this)
		if this.sf then
			this.sf.tfade:SetParent(this.sf)
		end
		if this.cb then
			this.cb.tfade:SetParent(this.cb)
		end
	end)

end

function aObj:hookScript(obj, method, func)

	if not self:IsHooked(obj, method) then
		self:HookScript(obj, method, func)
	end

end

function aObj:isAddonEnabled(addonName)
	--@alpha@
	_G.assert(addonName, "Unknown object isAddonEnabled\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	return _G.GetAddOnEnableState(self.uName, addonName) == 2 and true or false

end

function aObj:isDropDown(obj)
	--@alpha@
	_G.assert(obj, "Unknown object isDropDown\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	if obj:IsObjectType("Frame") then
		local chkObj = obj.Left or obj:GetName() and _G[obj:GetName() .. "Left"]
		if chkObj then
			if self:hasTextInTexture(chkObj, "CharacterCreate")
			or self:hasTextInTexture(chkObj, self.tFDIDs.ccLF)
			then
				return true
			end
		end
	end
	return false

end

function aObj:keepFontStrings(obj, hide) -- luacheck: ignore self
	--@alpha@
	_G.assert(obj, "Missing object kFS\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	for _, reg in _G.ipairs{obj:GetRegions()} do
		if not reg:IsObjectType("FontString") then
			if not hide then
				reg:SetAlpha(0)
			else
				reg:Hide()
			end
		end
	end

end

function aObj:keepRegions(obj, regions)
	--@alpha@
	_G.assert(obj, "Missing object kR\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	local tmpTab = self:getKeys(regions) or {}
	for key, reg in _G.ipairs{obj:GetRegions()} do
		if not tmpTab[key] then
			reg:SetAlpha(0)
			--@debug@
			if reg:IsObjectType("FontString") then
				self:Debug("kr FS: [%s, %s]", obj, key)
				self:Print(_G.debugstack(1, 5, 2))
			end
			--@end-debug@
		end
	end

end

function aObj:makeMFRotatable(modelFrame)
	--@alpha@
	_G.assert(modelFrame and modelFrame:IsObjectType("PlayerModel"), "Not a PlayerModel\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	-- Don't make Model Frames Rotatable if CloseUp is loaded
	if _G.IsAddOnLoaded("CloseUp") then return end

	-- hide rotation buttons
	for _, child in _G.ipairs{modelFrame:GetChildren()} do
		if self:hasTextInName(child, "Rotate") then
			child:Hide()
		end
	end

	if modelFrame.RotateLeftButton then
		modelFrame.RotateLeftButton:Hide()
		modelFrame.RotateRightButton:Hide()
	end

	if modelFrame.controlFrame then
		modelFrame.controlFrame:DisableDrawLayer("BACKGROUND")
	end

end

function aObj:makeIconSquare(obj, iconObjName, clr)

	obj[iconObjName]:SetTexCoord(.1, .9, .1, .9)

	if self.modBtnBs then
		self:addButtonBorder{obj=obj, relTo=obj[iconObjName], ofs=3, clr=clr}
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
		aObj:CustomPrint(1, 0, 0, "moveObject: %s, GetNumPoints = %d\n%s", opts.obj, opts.obj:GetNumPoints())
		_G.assert(false, _G.debugstack(2, 3, 2) )
		return
	end
	--@end-debug@

	local point, relTo, relPoint, xOfs, yOfs = opts.obj:GetPoint()

	-- handle no Point info
	if not point then return end

	relTo = opts.relTo or relTo
	--@alpha@
	_G.assert(relTo, "__moveObject relTo is nil\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@
	-- Workaround for relativeTo crash
	if not relTo then
		if aObj.prdb.Warnings then
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

end
function aObj:moveObject(...) -- luacheck: ignore self

	local opts = _G.select(1, ...)

	--@alpha@
	_G.assert(opts, "Missing object mO\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	-- handle missing object (usually when addon changes)
	if not opts then return end

	if _G.type(_G.rawget(opts, 0)) == "userdata" and _G.type(opts.GetObjectType) == "function" then
		-- old style call
		opts = {}
		opts.obj = _G.select(1, ...) and _G.select(1, ...) or nil
		opts.x = _G.select(3, ...) and _G.select(3, ...) or nil
		if _G.select(2, ...) and _G.select(2, ...) == "-" then opts.x = opts.x * -1 end
		opts.y = _G.select(5, ...) and _G.select(5, ...) or nil
		if _G.select(4, ...) and _G.select(4, ...) == "-" then opts.y = opts.y * -1 end
		opts.relTo = _G.select(6, ...) and _G.select(6, ...) or nil
	end

	__moveObject(opts)

end

function aObj:nilTexture(obj, nop) -- luacheck: ignore self

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

function aObj:removeBackdrop(obj, nop) -- luacheck: ignore self

	if obj.ClearBackdrop then
		obj:ClearBackdrop()
		if nop then
			obj.ApplyBackdrop = _G.nop
		end
	elseif obj.SetBackdrop then
		obj:SetBackdrop(nil)
		if nop then
			obj.SetBackdrop = _G.nop
		end
	end

end

--@debug@
--luacheck: ignore fromhex tohex
local function fromhex(str)
	return (str:gsub('..', function (cc)
		return _G.string.char(_G.tonumber(cc, 16))
	end))
end
local function tohex(str)
	return (str:gsub('.', function (c)
		return _G.string.format('%02X', _G.string.byte(c))
	end))
end
--@end-debug@
function aObj:removeColourCodes(text) -- luacheck: ignore self

	-- N.B. codes checked for are ASCII
	if text then
		local newText
		for _, aCode in _G.pairs{"\124\99", "\124\67"} do
			if text:find(aCode) then
				newText = text:gsub(aCode .. "%x%x%x%x%x%x%x%x", "") -- remove colour code string prefix [7C 63/43] |c & |C
			end
		end
		if newText then
			newText = newText:gsub("\124\114", "") -- remove colour code string suffix [7C 72] |r
			return newText, true
		else
			return text, false
		end
	end

end

local function ddlBBO(frame)
	frame:DisableDrawLayer("BACKGROUND")
	frame:DisableDrawLayer("BORDER")
	frame:DisableDrawLayer("OVERLAY")
end
function aObj:removeInset(frame) -- luacheck: ignore self
	--@alpha@
	_G.assert(frame, "Unknown object removeInset\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	ddlBBO(frame)
	-- InsetFrameTemplate has a NineSlice child
	if frame.NineSlice then
		self:removeNineSlice(frame.NineSlice)
	end

end

function aObj:removeMagicBtnTex(btn) -- luacheck: ignore self
	--@alpha@
	_G.assert(btn, "Unknown object removeMagicBtnTex\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	-- Magic Button textures
	if btn.LeftSeparator then btn.LeftSeparator:SetTexture(nil) end
	if btn.RightSeparator then btn.RightSeparator:SetTexture(nil) end

end

function aObj:removeNineSlice(frame) -- luacheck: ignore self
	--@alpha@
	_G.assert(frame, "Unknown object removeNineSlice\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	ddlBBO(frame)

end

function aObj:removeRegions(obj, regions)
	--@alpha@
	_G.assert(obj, "Missing object (removeRegions)\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	local tmpTab = self:getKeys(regions) or {}
	for key, reg in _G.pairs{obj:GetRegions()} do
		if tmpTab[key] then
			reg:SetAlpha(0)
			--@debug@
			if reg:IsObjectType("FontString") then
				self:Debug("rr FS: [%s, %s]", obj, key)
				self:Print(_G.debugstack(1, 5, 2))
			end
			--@end-debug@
		end
	end

end

function aObj:resizeTabs(frame) -- luacheck: ignore self
	--@alpha@
	_G.assert(frame, "Unknown object resizeTabs\n" .. _G.debugstack(2, 3, 2))
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

end

function aObj:resizeEmptyTexture(texture)
	--@alpha@
	_G.assert(texture, "Unknown object resizeEmptyTexture\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	texture:SetTexture(self.tFDIDs.esTex)
	texture:SetSize(64, 64)
	texture:SetTexCoord(0, 1, 0, 1)
	texture:ClearAllPoints()
	texture:SetPoint("CENTER", texture:GetParent())

end

function aObj:rmRegionsTex(obj, regions)
	--@alpha@
	aObj:CustomPrint(1, 0, 0, "Using deprecated function - rmRegionsTex, use removeRegions(obj, regions) instead", obj)
	--@end-alpha@

	self:removeRegions(obj, regions)

end

function aObj:round2(num, idp) -- luacheck: ignore self
	--@alpha@
	_G.assert(num, "Missing number\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

  return _G.tonumber(_G.string.format("%." .. (idp or 0) .. "f", num))

end

local function scanChildren(obj)

	for idx, child in _G.ipairs_reverse{_G[obj]:GetChildren()} do
		-- check for forbidden objects (StoreUI components etc.)
		if not child:IsForbidden() then
			aObj.callbacks:Fire(obj .. "_GetChildren", child, idx)
		end
	end

	-- remove all callbacks for this event
	aObj.callbacks.events[obj .. "_GetChildren"] = nil

end
function aObj:scanUIParentsChildren() -- luacheck: ignore self

	scanChildren("UIParent")

end

function aObj:scanWorldFrameChildren() -- luacheck: ignore self

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
	_G.assert(tabSF, "Missing object sAT\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	if not tabSF then return end
	if not tabSF.tfade then return end

	tabSF.tfade:SetTexture(self.gradientTex)
	if self.isClscERA then
		tabSF.tfade:SetGradientAlpha(self:getGradientInfo(self.prdb.Gradient.invert, self.prdb.Gradient.rotate))
	else
		tabSF.tfade:SetGradient(self:getGradientInfo(self.prdb.Gradient.invert, self.prdb.Gradient.rotate))
	end

end

function aObj:setInactiveTab(tabSF)
	--@alpha@
	_G.assert(tabSF, "Missing object sIT\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	if not tabSF then return end
	if not tabSF.tfade then return end

	tabSF.tfade:SetTexture(self.itTex)
	tabSF.tfade:SetAlpha(1)

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

function aObj:setupFramesOptions(optTab, framesType)

	local opt, oDesc
	for optName, optVals in _G.pairs(optTab) do
		oDesc = optName
		if _G.type(optVals) == "table" then
			if optVals.desc then
				oDesc = optVals.desc
			elseif optVals.suff then
				oDesc = _G.string.format("%s %s", optName, optVals.suff)
			end
		end
		opt = optName:gsub("%s+", "")
		-- aObj:Debug("setupFramesOptions: [%s, %s, %s, %s, %s]", optName, optVals, opt, oDesc)
		self.db.defaults.profile[opt] = true
		if self.db.profile[opt] == nil then
			self.db.profile[opt] = true
		end
		self.optTables[framesType .. " Frames"].args[opt] = {
			type = "toggle",
			name = self.L[oDesc],
			desc = _G.strjoin(" ", self.L["Toggle the skin of the"], self.L[oDesc]),
			width = oDesc:len() > 21 and "double" or nil,
		}
	end

end

function aObj:setupTextures()
--[[
	N.B. Texture paths replaced by FileDataIDs
	These can be found here: https://wow.tools/files/#search=&page=1&sort=0&desc=asc

		-- 136509 - ui-backpack-emptyslot
		-- 4701874 - bagitemslot2x
		-- 651080 - whiteiconframe
		-- 130841 - ui-quickslot2

--]]
	self.tFDIDs = {
		["bHLS"]      = _G.GetFileIDFromPath([[Interface\Buttons\ButtonHilight-Square]]),
		["btnTex"]    = _G.GetFileIDFromPath([[Interface\HelpFrame\HelpButtons]]),
		["cbSC"]      = _G.GetFileIDFromPath([[Interface\Buttons\UI-Checkbox-SwordCheck]]),
		["cbUP"]      = _G.GetFileIDFromPath([[interface\Buttons\UI-CheckBox-Up]]),
		["ccLF"]      = _G.GetFileIDFromPath([[Interface\Glues\CharacterCreate\CharacterCreate-LabelFrame]]),
		["cfBg"]      = _G.GetFileIDFromPath([[Interface\ChatFrame\ChatFrameBackground]]),
		["ctabHL"]    = _G.GetFileIDFromPath([[Interface\PaperDollInfoFrame\UI-Character-Tab-Highlight]]),
		["dpI"]       = _G.GetFileIDFromPath([[Interface\PetBattles\DeadPetIcon]]),
		["ejt"]       = _G.GetFileIDFromPath([[Interface\EncounterJournal\UI-EncounterJournalTextures]]),
		["enI"]       = _G.GetFileIDFromPath([[Interface\Tooltips\EliteNameplateIcon]]),
		["esTex"]     = _G.GetFileIDFromPath([[Interface\Buttons\UI-Quickslot2]]),
		["gAOI"]      = _G.GetFileIDFromPath([[Interface\Glues\CharacterSelect\Glues-AddOn-Icons]]),
		["gearWhl"]   = _G.GetFileIDFromPath([[Interface\AddOns\]] .. aName .. [[\Textures\gear]]),
		["inactTab"]  = _G.GetFileIDFromPath([[Interface\AddOns\]] .. aName .. [[\Textures\inactive]]),
		["lfgIR"]     = _G.GetFileIDFromPath([[Interface\LFGFrame\UI-LFG-ICON-ROLES]]),
		["lvlBG"]     = _G.GetFileIDFromPath([[Interface\PetBattles\BattleBar-AbilityBadge-Neutral]]),
		["mHG"]       = _G.GetFileIDFromPath([[Interface\Common\mini-hourglass]]),
		["mpTex"]     = _G.GetFileIDFromPath([[Interface\Common\UI-ModelControlPanel]]),
		["mpw01"]     = _G.GetFileIDFromPath([[Interface\Icons\INV_Misc_Pelt_Wolf_01]]),
		["pMBHL"]     = _G.GetFileIDFromPath([[Interface\Buttons\UI-Panel-MinimizeButton-Highlight]]),
		["qltHL"]     = _G.GetFileIDFromPath([[Interface\QuestFrame\UI-QuestLogTitleHighlight]]),
		["rB"]        = _G.GetFileIDFromPath([[Interface\Glues\CharacterSelect\RestoreButton]]),
		["renI"]      = _G.GetFileIDFromPath([[Interface\Tooltips\RareEliteNameplateIcon]]),
		["rareNP"]    = _G.GetFileIDFromPath([[Interface\AddOns\]] .. aName .. [[\Textures\RareNameplateIcon]]),
		["shieldTex"] = _G.GetFileIDFromPath([[Interface\CastingBar\UI-CastingBar-Arena-Shield]]),
		["skinBdr"]   = _G.GetFileIDFromPath([[Interface\AddOns\]] .. aName .. [[\Textures\krsnik]]),
		["tfBF"]      = _G.GetFileIDFromPath([[Interface\TargetingFrame\UI-TargetingFrame-BarFill]]),
		["tMB"]       = _G.GetFileIDFromPath([[Interface\Minimap\Tracking\Mailbox]]),
		["w8x8"]      = _G.GetFileIDFromPath([[Interface\Buttons\WHITE8X8]]),
	}
	if aObj.isRtl then
		self.tFDIDs["cbMin"] = _G.GetFileIDFromPath([[interface/common/minimalcheckbox.blp]])
	end

end

function aObj:skinAceDropdown(obj, x2, y2)

	self:skinObject("dropdown", {obj=obj.dropdown, x2=x2, y2=y2})
	self:skinObject("frame", {obj=obj.pullout.frame, kfs=true})
	self:secureHook(obj, "SetDisabled", function(this, disabled)
		self:checkDisabledDD(this.dropdown, disabled)
	end)

end

function aObj:skinIconSelector(frame)

	self:removeNineSlice(frame.BorderBox)
	frame.BorderBox.SelectedIconArea.SelectedIconButton:DisableDrawLayer("BACKGROUND")
	self:skinObject("editbox", {obj=frame.BorderBox.IconSelectorEditBox})
	self:skinObject("scrollbar", {obj=frame.IconSelector.ScrollBar})
	self:skinObject("frame", {obj=frame, ofs=1, y1=2})
	if self.modBtns then
		self:skinStdButton{obj=frame.BorderBox.CancelButton}
		self:skinStdButton{obj=frame.BorderBox.OkayButton, schk=true}
	end
	if self.modBtnBs then
		self:addButtonBorder{obj=frame.BorderBox.SelectedIconArea.SelectedIconButton, relTo=frame.BorderBox.SelectedIconArea.SelectedIconButton.Icon}
		local function skinElement(...)
			local _, element, new
			if _G.select("#", ...) == 2 then
				element, _ = ...
			elseif _G.select("#", ...) == 3 then
				element, _, new = ...
			else
				_, element, _, new = ...
			end
			if new ~= false then
				element:DisableDrawLayer("BACKGROUND")
				aObj:addButtonBorder{obj=element, relTo=element.Icon, clr="grey"}
			end
		end
		_G.ScrollUtil.AddAcquiredFrameCallback(frame.IconSelector.ScrollBox, skinElement, aObj, true)
	end

end

function aObj:skinNavBarButton(btn) -- luacheck: ignore self

	btn:DisableDrawLayer("OVERLAY")
	btn:GetNormalTexture():SetAlpha(0)
	btn:GetPushedTexture():SetAlpha(0)

end

--@debug@
function aObj:tableCount(table) -- luacheck: ignore self

	local count = 0

	for _ in _G.pairs(table) do count = count + 1 end

	return count

end
--@end-debug@
--[===[@non-debug@
aObj.tableCount = _G.nop
--@end-non-debug@]===]

function aObj:updateSBTexture()

	-- get updated colour/texture
	local sBar = self.prdb.StatusBar
	self.sbTexture = self.LSM:Fetch("statusbar", sBar.texture)
	self.sbClr = _G.CreateColor(sBar.r, sBar.g, sBar.b, sBar.a)

	for obj, tab in _G.pairs(self.sbGlazed) do
		if obj:IsObjectType("StatusBar") then
			obj:SetStatusBarTexture(self.sbTexture)
		else
			obj:SetTexture(self.sbTexture)
		end
		for k, tex in _G.pairs(tab) do
			tex:SetTexture(self.sbTexture)
			if k == "bg" then tex:SetVertexColor(self.sbClr:GetRGBA()) end
		end
	end

end

function aObj:unwrapTextFromColourCode(text, sOfs, eOfs) -- luacheck: ignore self

	local newText = _G.gsub(text, "\124", "\124\124") -- turn Hex string into text

	if _G.strlen(newText) == _G.strlen(text) then return text end

	local clrCode = _G.strsub(newText, 6, 11)
	newText = _G.strsub(newText, sOfs or 12, eOfs or -4) -- remove colour prefix and suffix
	newText = _G.gsub(newText, "\124\124", "\124") -- convert string to Hex for any embedded characters (e.g. newlines)
	return newText, clrCode

end

function aObj:RaiseFrameLevelByFour(frame) -- luacheck: ignore self

	frame:SetFrameLevel(frame:GetFrameLevel() + 4)

end

--@alpha@
function aObj:SetupCmds()

	local function makeString(obj)
		if _G.type(obj) == "table" then
			if _G.type(_G.rawget(obj, 0)) == "userdata"
			and _G.type(obj.GetObjectType) == "function"
			then
				return ("<%s:%s:%s>"):format(_G.tostring(obj), obj:GetObjectType(), obj:GetName() or "(Anon)")
			end
		end
		return _G.tostring(obj)
	end
	local function makeText(fStr, ...)
		local tmpTab = {}
		local output = ""
		if fStr
		and fStr.find
		and fStr:find("%%")
		and _G.select('#', ...) >= 1
		then
			for i = 1, _G.select('#', ...) do
				tmpTab[i] = makeString(_G.select(i, ...))
			end
			 -- handle missing variables
			local varCnt = _G.select(2, fStr:gsub("%%", ""))
			for i = #tmpTab, varCnt do
				tmpTab[i + 1] = "nil"
			end
			output = _G.string.join(" ", fStr:format(_G.unpack(tmpTab)))
		else
			tmpTab[1] = output
			tmpTab[2] = fStr and _G.type(fStr) == "table" and makeString(fStr) or fStr or ""
			for i = 1, _G.select('#', ...) do
				tmpTab[i + 2] = makeString(_G.select(i, ...))
			end
			output = _G.table.concat(tmpTab, " ")
		end
		return output
	end
	local function print_family_tree(fName)
		if fName:IsForbidden() then
			_G.print("Frame access is forbidden", fName)
			return
		end
		local lvl = "Parent"
		_G.print(makeText("Frame is %s, %s, %s, %s, %s", fName, fName:GetFrameLevel(), fName:GetFrameStrata(), _G.Round(fName:GetWidth()) or "nil", _G.Round(fName:GetHeight()) or "nil"))
		while fName:GetParent() do
			fName = fName:GetParent()
			_G.print(makeText("%s is %s, %s, %s, %s, %s", lvl, fName, (fName:GetFrameLevel() or "<Anon>"), (fName:GetFrameStrata() or "<Anon>"), _G.Round(fName:GetWidth()) or "nil", _G.Round(fName:GetHeight()) or "nil"))
			lvl = (lvl:find("Grand") and "Great" or "Grand") .. lvl
		end
	end
	local function getObjFromString(input)
		local tmpTab = {}
		-- first split the string on "."
		for word in _G.string.gmatch(input, "%w+") do
			tmpTab[#tmpTab + 1] = word
		end
		-- then build string in the form _G["str1"]["str2"]...["strn"]
		local objString = "_G"
		for i = 1, #tmpTab do
			objString = objString .. '["' .. tmpTab[i] .. '"]'
		end
		-- finally use loadstring to get the object from the command
		-- _G.print("getObjFromString", input, objString)
		return _G.assert(_G.loadstring("return " .. objString)())
	end
	local function getObj(input)
		-- _G.print("getObj", input, _G[input], GetMouseFocus())
		if not input or input:trim() == "" then
			return _G.GetMouseFocus()
		else
			return getObjFromString(input)
		end
	end
	local function getObjP(input)
		-- _G.print("getObjP", input, _G[input], GetMouseFocus():GetParent())
		if not input or input:trim() == "" then
			return _G.GetMouseFocus():GetParent()
		else
			return getObjFromString(input)
		end
	end
	local function getObjGP(input)
		-- _G.print("getObjGP", input, _G[input], GetMouseFocus():GetParent():GetParent())
		if not input or input:trim() == "" then
			return _G.GetMouseFocus():GetParent():GetParent()
		else
			return getObjFromString(input)
		end
	end
	local function showInfo(obj, showKids, noDepth)
		_G.print("showInfo:", obj, showKids, noDepth, obj:IsForbidden())
		_G.assert(obj, "Unknown object showInfo\n" .. _G.debugstack(2, 3, 2))
		if obj:IsForbidden() then return end
		showKids = showKids or false
		local function showIt(...)
			aObj:Debug3(...)
		end
		local function getRegions(cObj, lvl)
			for k, reg in _G.ipairs{cObj:GetRegions()} do
				showIt("[lvl%sr%s : %s : %s : %s : %s : %s]", lvl, k, reg, reg:GetObjectType() or "nil", reg.GetWidth and _G.Round(reg:GetWidth()) or "nil", reg.GetHeight and _G.Round(reg:GetHeight()) or "nil", reg:GetObjectType() == "Texture" and ("%s : %s"):format(reg:GetTexture() or "nil", reg:GetDrawLayer() or "nil") or "nil")
			end
		end
		local function getChildren(frame, lvl)
			if not showKids then return end
			if lvl > 1 and noDepth then return end
			for k, child in _G.ipairs{frame:GetChildren()} do
				local objType = child:GetObjectType()
				showIt("[lvl%sc%s : %s : %s : %s : %s : %s]", lvl, k, child, child.GetWidth and _G.Round(child:GetWidth()) or "nil", child.GetHeight and _G.Round(child:GetHeight()) or "nil", child:GetFrameLevel() or "nil", child:GetFrameStrata() or "nil")
				if objType == "Frame"
				or objType == "Button"
				or objType == "StatusBar"
				or objType == "Slider"
				or objType == "ScrollFrame"
				then
					getRegions(child, lvl .. "c" .. k)
					getChildren(child, lvl + k)
				end
			end
		end
		showIt("%s : %s : %s : %s : %s : %s : %s", obj, _G.Round(obj:GetWidth()) or "nil", _G.Round(obj:GetHeight()) or "nil", obj:GetFrameLevel() or "nil", obj:GetFrameStrata() or "nil", obj:GetNumRegions(), obj:GetNumChildren())
		showIt("Started Regions")
		getRegions(obj, 0)
		showIt("Finished Regions")
		showIt("Started Children")
		getChildren(obj, 0)
		showIt("Finished Children")
	end

	self:RegisterChatCommand("ft", function() print_family_tree(_G.GetMouseFocus()) end)
	self:RegisterChatCommand("ftp", function() print_family_tree(_G.GetMouseFocus():GetParent()) end)
	self:RegisterChatCommand("gp", function() _G.print(_G.GetMouseFocus():GetPoint()) end)
	self:RegisterChatCommand("gpp", function() _G.print(_G.GetMouseFocus():GetParent():GetPoint()) end)
	self:RegisterChatCommand("lo", function() _G.UIErrorsFrame:AddMessage("Use /camp instead of /lo", 1.0, 0.1, 0.1, 1.0) end)
	self:RegisterChatCommand("pii", function(msg) _G.print(_G.GetItemInfo(msg)) end)
	self:RegisterChatCommand("pil", function(msg) _G.print(_G.gsub(msg, "\124", "\124\124")) end)
	self:RegisterChatCommand("pin", function(msg) _G.print(msg, "is item:", (_G.GetItemInfoFromHyperlink(msg))) end)
	-- self:RegisterChatCommand("rl", function() _G.C_UI.Reload() end)
	self:RegisterChatCommand("si1", function(msg) showInfo(getObj(msg), true, true) end) -- 1 level only
	self:RegisterChatCommand("si1p", function(msg) showInfo(getObjP(msg), true, true) end) -- 1 level only
	self:RegisterChatCommand("si1gp", function(msg) showInfo(getObjGP(msg), true, true) end) -- 1 level only
	self:RegisterChatCommand("sid", function(msg) showInfo(getObj(msg), true, false) end) -- detailed
	self:RegisterChatCommand("sidp", function(msg) showInfo(getObjP(msg), true, false) end) -- detailed
	self:RegisterChatCommand("sidgp", function(msg) showInfo(getObjGP(msg), true, false) end) -- detailed
	self:RegisterChatCommand("sir", function(msg) showInfo(getObj(msg), false, false) end) -- regions only
	self:RegisterChatCommand("sirp", function(msg) showInfo(getObjP(msg), false, false) end) -- regions only
	self:RegisterChatCommand("sirgp", function(msg) showInfo(getObjGP(msg), false, false) end) -- regions only
	self:RegisterChatCommand("mspew", function(_) return _G.Spew and _G.Spew("", _G.GetMouseFocus()) end)
	self:RegisterChatCommand("sspew", function(msg) return _G.Spew and _G.Spew(msg, getObj(msg)) end)
	self:RegisterChatCommand("sspewp", function(msg) return _G.Spew and _G.Spew(msg, getObjP(msg)) end)
	self:RegisterChatCommand("sspewgp", function(msg) return _G.Spew and _G.Spew(msg, getObjGP(msg)) end)

	self:RegisterChatCommand("shc", function() self:Debug("Hooks table Count: [%s]", self:tableCount(self.hooks)) end)

	self:RegisterChatCommand("wai", function() -- where am I ?
		local posTab = _G.C_Map.GetPlayerMapPosition(_G.C_Map.GetBestMapForUnit("player"), "player")
		_G.DEFAULT_CHAT_FRAME:AddMessage(_G.format("%s, %s: %.1f, %.1f", _G.GetZoneText(), _G.GetSubZoneText(), posTab.x * 100, posTab.y * 100))
		return
	end)

	self:RegisterChatCommand("tad", function(frame) _G.LoadAddOn("Blizzard_DebugTools"); _G.TableAttributeDisplay:InspectTable(_G[frame] or _G.GetMouseFocus()); _G.TableAttributeDisplay:Show() end)

end
--@end-alpha@
