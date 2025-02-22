local aName, aObj = ...

local _G = _G

local module = aObj:NewModule("UIButtons", "AceEvent-3.0", "AceHook-3.0")

local db
local defaults = {
	profile = {
		UIButtons     = false,
		ButtonBorders = false,
		CheckButtons  = false,
		Quality		  = {file = "None", texture = "Blizzard Tooltip"},
	}
}

do
	-- characters used on buttons
	module.mult    = "×" -- multiplication sign NOT lower case X
	module.plus    = "+"
	module.minus   = "-" -- using Hyphen-minus(-) instead of minus sign(−) for font compatiblity reasons
	module.larrow  = "←" -- Leftwards Arrow (U+2190)
	module.uarrow  = "↑" -- Upwards Arrow (U+2191)
	module.rarrow  = "→" -- Rightwards Arrow (U+2192)
	module.darrow  = "↓" -- Downwards Arrow (U+2193)
	module.nwarrow = "↖" -- North West Arrow (U+2196)
	module.nearrow = "↗" -- North East Arrow (U+2197)
	module.searrow = "↘" -- South East Arrow (U+2198)
	module.swarrow = "↙" -- South West Arrow (U+2199)
	-- create font to use for Close Buttons
	module.fontX = _G.CreateFont("fontX")
	module.fontX:SetFont([[Fonts\FRIZQT__.TTF]], 20, "")
	module.fontX:SetTextColor(_G.NORMAL_FONT_COLOR:GetRGB())
	-- create font to use for Black Close Buttons (TalkingHeadFrame)
	module.fontBX = _G.CreateFont("fontBX")
	module.fontBX:SetFont([[Fonts\FRIZQT__.TTF]], 20, "")
	module.fontBX:SetTextColor(_G.BLACK_FONT_COLOR:GetRGB())
	-- create font for disabled text
	module.fontDX = _G.CreateFont("fontDX")
	module.fontDX:SetFont(module.fontX:GetFont())
	module.fontDX:SetTextColor(_G.DISABLED_FONT_COLOR:GetRGB())
	-- create font to use for small blue Close Buttons (e.g. BNToastFrame)
	module.fontSBX = _G.CreateFont("fontSBX")
	module.fontSBX:SetFont([[Fonts\FRIZQT__.TTF]], 14, "")
	module.fontSBX:SetTextColor(_G.BATTLENET_FONT_COLOR:GetRGB())
	-- create font to use for small Buttons (e.g. MinimalArchaeology)
	module.fontSB = _G.CreateFont("fontSB")
	module.fontSB:SetFont([[Fonts\FRIZQT__.TTF]], 14, "")
	module.fontSB:SetTextColor(_G.NORMAL_FONT_COLOR:GetRGB())
	-- create font to use for Minus/Plus Buttons
	module.fontP = _G.CreateFont("fontP")
	module.fontP:SetFont([[Fonts\ARIALN.TTF]], 16, "")
	module.fontP:SetTextColor(_G.NORMAL_FONT_COLOR:GetRGB())
	-- create font for disabled text on Minus/Plus Buttons
	module.fontDP = _G.CreateFont("fontDP")
	module.fontDP:SetFont(module.fontP:GetFont())
	module.fontDP:SetTextColor(_G.DISABLED_FONT_COLOR:GetRGB())
	-- create font to use for Arrow buttons
	module.fontS = _G.CreateFont("fontS")
	module.fontS:SetFont([[Interface\AddOns\]] .. aName .. [[\Fonts\NotoSansSymbols-Medium.ttf]], 14, "")
	module.fontS:SetTextColor(_G.NORMAL_FONT_COLOR:GetRGB())
	-- create font for disabled Arrow buttons
	module.fontDS = _G.CreateFont("fontDS")
	module.fontDS:SetFont(module.fontS:GetFont())
	module.fontDS:SetTextColor(_G.DISABLED_FONT_COLOR:GetRGB())
end
local texNumbers = {
	[130821] = "minus",
	[130838] = "plus",
}
local texSuffixes = {
	["PlusButton"]    = "plus",
	["ZoomInButton"]  = "plus",
	["_Closed"]       = "plus",
	["MinusButton"]   = "minus",
	["ZoomOutButton"] = "minus",
	["_Open"]         = "minus",
}

local btn, nTex
local function __checkTex(opts)
--[[
	Calling parameters:
		obj = object (Mandatory)
		nTex = Texture
		mp2 = minus/plus type 2
--]]
	--@alpha@
	 _G.assert(opts.obj, "Missing object __cT\n" .. _G.debugstack(2, 3, 2))
	 --@end-alpha@

	 -- handle in combat
	 if _G.InCombatLockdown() then
		 aObj:add2Table(aObj.oocTab, {__checkTex, {opts}})
		 return
	 end

	-- hide existing textures if they exist (Armory/GupCharacter requires this)
	if opts.obj:GetNormalTexture() then opts.obj:GetNormalTexture():SetAlpha(0) end
	if opts.obj:GetPushedTexture() then opts.obj:GetPushedTexture():SetAlpha(0) end
	if opts.obj:GetDisabledTexture() then opts.obj:GetDisabledTexture():SetAlpha(0) end

	btn = opts.obj.onSB and opts.obj.sb or opts.obj
	if not btn then return end -- handle unskinned buttons
	nTex = opts.nTex or opts.obj:GetNormalTexture() and opts.obj:GetNormalTexture():GetTexture() or nil

	local header = false
	if nTex then
		if _G.tonumber(nTex) then
			for num, type in _G.pairs(texNumbers) do
				if nTex == num then
					btn:SetText(module[type])
					btn:Show()
					header = true
					break
				end
			end
		else
			for str, type in _G.pairs(texSuffixes) do
				if nTex:find(str) then
					btn:SetText(module[type])
					btn:Show()
					header = true
					break
				end
			end
		end
	end
	if not header then
		btn:SetText("")
		btn:Hide()
	end

end
function module:checkTex(...) -- luacheck: ignore self

	local opts = _G.select(1, ...)

	--@alpha@
	 _G.assert(opts, "Missing object cT\n" .. _G.debugstack(2, 3, 2))
	 --@end-alpha@

	-- handle missing object (usually when addon changes)
	if not opts then return end

	if _G.type(_G.rawget(opts, 0)) == "userdata" and _G.type(opts.GetObjectType) == "function" then
		-- old style call
		opts = {}
		opts.obj = _G.select(1, ...) and _G.select(1, ...) or nil
		opts.nTex = _G.select(2, ...) and _G.select(2, ...) or nil
		opts.mp2 = _G.select(3, ...) and _G.select(3, ...) or nil
	end
	__checkTex(opts)

end
if not aObj.isRtl then
	_G.DULL_RED_FONT_COLOR = _G.CreateColor(0.75, 0.15, 0.15)
end
local function clrTex(clr, hTex)
	local r, g, b
	if clr == "grey" then
		r, g, b = _G.GRAY_FONT_COLOR:GetRGB()
	elseif clr == "red" then
		r, g, b = _G.DULL_RED_FONT_COLOR:GetRGB()
	elseif clr == "blue" then
		r, g, b = _G.LIGHTBLUE_FONT_COLOR:GetRGB()
	elseif clr == "yellow" then
		r, g, b = _G.YELLOW_FONT_COLOR:GetRGB()
	end
	hTex:SetColorTexture(r, g, b, 0.25)
end
function module:chgHLTex(obj, hTex)

	-- handle in combat
	if _G.InCombatLockdown() then
		aObj:add2Table(aObj.oocTab, {self.chgHLTex, {self, obj, hTex}})
		return
	end

	if hTex then
		local hTexFile = hTex:GetTexture()
		if hTexFile then
			local clr
			if _G.tonumber(hTexFile) then
				if _G.tonumber(hTexFile) == 3046538 then -- auctionhouse-nav-button
					clr = "grey"
				elseif _G.tonumber(hTexFile) == 1536801 then -- addonlist button highlight
					clr = "red"
				end
			else
				if hTexFile:find("UI-Panel-Button-Highlight", 1, true) -- UIPanelButtonHighlightTexture
				or hTexFile:find("UI-DialogBox-Button-Highlight", 1, true) -- StaticPopupButton/PetPopupButton/CinematicDialogButton
				then
					clr = "red"
				elseif hTexFile:find("UI-Silver-Button-Highlight", 1, true) -- UIMenuButtonStretchTemplate
				or hTexFile:find("UI-Minimap-ZoomButton-Highlight", 1, true)
				or hTexFile:find("HelpButtons", 1, true) -- Classic Help Buttons
				then
					clr = "blue"
				elseif hTexFile:find("UI-Silver-Button-Select", 1, true) then -- UIMenuButtonStretchTemplate
					clr = "yellow"
				end
			end
			if clr then
				clrTex(clr, hTex)
				-- inset colour
				if obj.sb then
					hTex:ClearAllPoints()
					hTex:SetPoint("TOPLEFT", obj.sb, "TOPLEFT", 5, -5)
					hTex:SetPoint("BOTTOMRIGHT", obj.sb, "BOTTOMRIGHT", -5, 5)
				end
			end
		end
	end

end

function module:clrButtonFromBorder(bObj, texture)
	-- handle in combat
	if _G.InCombatLockdown() then
		aObj:add2Table(aObj.oocTab, {self.clrButtonFromBorder, {self, bObj, texture}})
		return
	end

	--@alpha@
	 _G.assert(bObj.sbb, "Missing object__cBB\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	local iBdr = bObj.IconBorder or bObj.iconBorder or bObj[texture]
	iBdr:SetAlpha(1) -- ensure alpha is 1 otherwise btn.sbb isn't displayed
	-- use the colour of the quality border as the BackdropBorderColor if shown
	if iBdr:IsShown() then
		bObj.sbb:SetBackdropBorderColor(iBdr:GetVertexColor())
	else
		module:clrBtnBdr(bObj, "common")
	end
	iBdr:SetAlpha(0)

end

function module:clrBtnBdr(bObj, clrName, alpha) -- luacheck: ignore self

	-- check button state and alter colour accordingly
	clrName = bObj.IsEnabled and not bObj:IsEnabled() and "disabled" or clrName
	aObj:clrBBC(bObj.sbb or bObj.sb or bObj, clrName, alpha)

end

function module:isButton(obj) -- luacheck: ignore self

	-- ignore named/AceConfig/XConfig/AceGUI objects
	if aObj:hasAnyTextInName(obj, {"AceConfig", "XConfig", "AceGUI"}) then return end
	if obj.OrigSetText then return end -- Cork ui-tab buttons

	local bType

	if (obj.Left or obj.leftArrow or obj.GetNormalTexture) -- is it a true button
	and not obj.GetChecked -- and not a checkbutton
	and not (obj.obj and obj.obj.checkbg) -- an Ace3 checkbutton
	and not obj.SetSlot -- and not a lootbutton
	then
		local oW, oH, nR = _G.Round(obj:GetWidth()), _G.Round(obj:GetHeight()), obj:GetNumRegions()
		if oH == 18 and oW == 18 and nR == 3 -- BNToast close button
		then
			bType = "toast"
		-- standard close button is 32x32 and has 4 regions
		-- RolePollPopup has 3 regions
		-- Channel Pullout is 24 high
		-- MasterPlan LootFrame is 28 high
		elseif obj:GetParent().CloseButton == obj
		or oH == oW and (nR >= 3 or nR <= 5) and (oH == 32 or oH == 24 or oH == 28)
		and (aObj:hasTextInName(obj, "Close") or aObj:hasTextInTexture(obj:GetNormalTexture(), "UI-Panel-MinimizeButton-Up"))
		then
			bType = "close"
		elseif (obj.Left and obj.Right and obj.Middle and nR == 5) -- based upon UIPanelButtonTemplate
		or (oH >= 20 and oH <= 25 and nR >= 5 and nR <= 8) -- std button
		or (oH == 30 and oW == 160) -- HelpFrame
		or (oH == 32 and oW == 128 and nR == 4) -- BasicScriptErrors Frame
		or (oH == 22 and oW == 108 and nR == 4) -- Tutorial Frame
		then
			bType = "normal"
		elseif oH == 54 then
			bType = "help"
		end
	end

	return bType

end

function module:secureHook(obj, method, func) -- luacheck: ignore self

	if not module:IsHooked(obj, method) then
		module:SecureHook(obj, method, func)
	end

end

function module:setBtnClr(bObj, quality)

	if bObj.sbb then
		if quality then
			if quality >= (self.isRtl and _G.Enum.ItemQuality.Common or _G.LE_ITEM_QUALITY_COMMON)
			and _G.BAG_ITEM_QUALITY_COLORS[quality]
			then
				bObj.sbb:SetBackdropBorderColor(_G.BAG_ITEM_QUALITY_COLORS[quality].r, _G.BAG_ITEM_QUALITY_COLORS[quality].g, _G.BAG_ITEM_QUALITY_COLORS[quality].b, 1)
			else
				module:clrBtnBdr(bObj, "grey", 0.75)
			end
		else
			module:clrBtnBdr(bObj, "grey", 0.75)
			if _G.TradeSkillFrame
			and _G.TradeSkillFrame.DetailsFrame
			and bObj == _G.TradeSkillFrame.DetailsFrame.Contents.ResultIcon
			then
				module:clrBtnBdr(bObj, "normal", 1)
			end
		end
	end

end

function module:skinCloseButton(opts)
-- text on button
--[[
	Calling parameters:
		obj     = object (Mandatory)
		ft      = Frame Type (Skinner classification)
		sap     = set all points of skinButton to object
		onSB    = put text on skinButton
		noSkin  = don't add skin frame
		font    = font to use
		disfont = disabled font to use
--]]
	--@alpha@
	_G.assert(opts.obj, "Missing object skinCloseButton\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	-- handle in combat
	if _G.InCombatLockdown() then
	    aObj:add2Table(aObj.oocTab, {self.skinCloseButton, {self, opts}})
	    return
	end

	aObj:keepFontStrings(opts.obj)

	--@alpha@
	-- skin GlowBox frame
	if opts.obj:GetParent().GlowTop then
		 _G.assert(opts.noSkin, "GlowBox should be skinned" .. _G.debugstack(2, 3, 2))
	end
	--@end-alpha@

	-- don't skin button if required
	if not opts.noSkin then
		if opts.sap then
			aObj:skinObject("button", {obj=opts.obj, fType=opts.ftype, sap=true})
		else
			local bW = _G.Round(opts.obj:GetWidth())
			opts.x1 = opts.x1 or bW == 32 and 6 or 4
			opts.y1 = opts.y1 or bW == 32 and -6 or -4
			opts.x2 = opts.x2 or bW == 32 and -6 or -4
			opts.y2 = opts.y2 or bW == 32 and 6 or 4
			aObj:skinObject("button", {obj=opts.obj, fType=opts.ftype, bd=5, x1=opts.x1, y1=opts.y1, x2=opts.x2, y2=opts.y2})
		end
		module:clrBtnBdr(opts.obj, opts.clr, opts.ca)
	end
	if not opts.onSB then
		opts.obj:SetNormalFontObject(opts.font or module.fontX)
		opts.obj:SetDisabledFontObject(opts.disfont or module.fontDX)
		opts.obj:SetText(module.mult)
		opts.obj:SetPushedTextOffset(-1, -1)
	else -- Ace3, ArkInventory & BNToastFrame
		opts.obj.sb:SetNormalFontObject(opts.font or module.fontX)
		opts.obj.sb:SetDisabledFontObject(opts.disfont or module.fontDX)
		opts.obj.sb:SetText(module.mult)
	end

	if aObj.isRtl then
		local text = aObj:getLastRegion(opts.obj)
		text:SetDrawLayer("OVERLAY")
		aObj:moveObject{obj=text, x=-1, y=-1}
	end
	if opts.schk then
		module:secureHook(opts.obj, "Disable", function(bObj, _)
			module:clrBtnBdr(bObj)
		end)
		module:secureHook(opts.obj, "Enable", function(bObj, _)
			module:clrBtnBdr(bObj, bObj.sb.clr or bObj.clr, bObj.sb.ca or bObj.ca)
		end)
	end

end
function module:skinCloseButton1(opts) -- luacheck: ignore self
-- text on button
	opts.cb = nil
	module:skinCloseButton(opts)

end
function module:skinCloseButton2(opts) -- luacheck: ignore self
-- text on skinButton
	opts.cb2 = nil
	opts.onSB = true
	module:skinCloseButton(opts)

end
function module:skinCloseButton3(opts) -- luacheck: ignore self
-- small text on skinButton (used by Details)
	opts.font = module.fontSBX
	opts.cb3 = nil
	opts.onSB = true
	module:skinCloseButton(opts)

end

function module:skinExpandButton(opts)
--[[
	Calling parameters:
		obj    = object (Mandatory)
		ft     = Frame Type (Skinner classification)
		aso    = applySkin options
		as     = use applySkin rather than addSkinButton, used when text appears behind the gradient
		noHook = don't hook SetNormalTexture function to manage texture changes
		onSB   = put text on skinButton
		plus   = use plus sign
		clr    = border colour
--]]
	--@alpha@
	_G.assert(opts.obj, "Missing object skinExpandButton\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	-- handle in combat
	if _G.InCombatLockdown() then
	    aObj:add2Table(aObj.oocTab, {self.skinExpandButton, {self, opts}})
	    return
	end

	-- don't skin it twice (BUGFIX)
	if opts.obj and opts.obj.sb then return end

	if not opts.noddl then
		opts.obj:DisableDrawLayer("BACKGROUND")
	end
	aObj:keepFontStrings(opts.obj)

	if not opts.as then
		aObj:skinObject("button", {obj=opts.obj, fType=opts.ftype, sap=opts.sap, bd=6, ofs=opts.ofs, clr=opts.clr})
		if not opts.noHook then
			module:SecureHook(opts.obj, "SetNormalTexture", function(this, tObj)
				module:checkTex{obj=this, nTex=tObj}
			end)
			module:SecureHook(opts.obj, "SetNormalAtlas", function(this, tObj)
				module:checkTex{obj=this, nTex=tObj}
			end)
		end
	else -- Ace3, Archy, ReagentRestocker
		-- opts.aso.bd  = opts.aso.bd or 6
		-- opts.aso.obj = opts.obj
		-- aObj:applySkin(opts.aso)
		aObj:skinObject("skin", {obj=opts.obj, fType=opts.ftype, bd=opts.aso.bd or 6})
	end
	opts.obj.onSB = opts.onSB -- store this for use in checkTex function
	if not opts.onSB then
		opts.obj:SetNormalFontObject(module.fontP)
		opts.obj:SetDisabledFontObject(module.fontDP)
		opts.obj:SetText(opts.plus and module.plus or module.minus)
		opts.obj:SetPushedTextOffset(-1, -1)
	else
		opts.obj.sb:SetNormalFontObject(module.fontP)
		opts.obj.sb:SetDisabledFontObject(module.fontDP)
		opts.obj.sb:SetAllPoints(opts.obj:GetNormalTexture())
		opts.obj.sb:SetText(opts.plus and module.plus or module.minus)
	end

end
function module:skinExpandButton1(opts) -- luacheck: ignore self
-- text on skinButton
	opts.onSB = true
	module:skinExpandButton(opts)

end
function module:skinExpandButton2(opts) -- luacheck: ignore self
-- text on button
	opts.sap = true
	module:skinExpandButton(opts)

end

function module:skinOtherButton(opts)
--[[
	Calling parameters:
		obj     = object (Mandatory)
		ft      = Frame Type (Skinner classification)
		size    = use smaller edgesize, different highlight textue and resize the button
		sap     = set all points of skinButton to object
		font    = font to use
		disfont = disabled font to use
		text    = text to use
--]]
	--@alpha@
	_G.assert(opts.obj, "Missing object skinOtherButton\n" .. _G.debugstack(2, 3, 2))
	_G.assert(opts.text, "Missing text to use skinOtherButton\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	-- handle in combat
	if _G.InCombatLockdown() then
	    aObj:add2Table(aObj.oocTab, {self.skinOtherButton, {self, opts}})
	    return
	end

	opts.obj:DisableDrawLayer("BACKGROUND")
	aObj:keepFontStrings(opts.obj)

	if opts.size then
		opts.obj:SetSize(opts.size, opts.size)
		opts.obj:SetHighlightTexture(aObj.tFDIDs.pMBHL)
	end
	opts.obj:SetNormalFontObject(opts.font or module.fontP)
	opts.obj:SetDisabledFontObject(opts.disfont or module.fontDP)
	opts.obj:SetText(opts.text)
	opts.obj:SetPushedTextOffset(-1, -1)
	if not opts.noSkin then
		if opts.sap then
			aObj:skinObject("button", {obj=opts.obj, fType=opts.ftype, sap=true, aso=opts.aso})
		else
			local bW = _G.Round(opts.obj:GetWidth())
			opts.x1 = opts.x1 or bW == 32 and 6 or 4
			opts.y1 = opts.y1 or bW == 32 and -6 or -4
			opts.x2 = opts.x2 or bW == 32 and -6 or -4
			opts.y2 = opts.y2 or bW == 32 and 6 or 4
			aObj:skinObject("button", {obj=opts.obj, fType=opts.ftype, bd=5, aso=opts.aso, x1=opts.x1, y1=opts.y1, x2=opts.x2, y2=opts.y2})
		end
	end

end
function module:skinOtherButton1(opts) -- luacheck: ignore self
-- text on button
	opts.font = module.fontP
	opts.text = opts.ob
	opts.ob = nil
	module:skinOtherButton(opts)

end
function module:skinOtherButton2(opts) -- luacheck: ignore self
-- small text on button
	opts.size = 18
	opts.sap = true
	opts.font = module.fontSB
	opts.text = opts.ob2
	opts.ob2 = nil
	module:skinOtherButton(opts)

end
function module:skinOtherButton3(opts) -- luacheck: ignore self
-- sizeUp/Down text on button

	opts.font = module.fontS
	opts.text = opts.ob3
	opts.ob3 = nil
	module:skinOtherButton(opts)

end
function module:skinOtherButton4(opts) -- luacheck: ignore self
-- Normal text on button

	opts.font = "GameFontNormal"
	opts.text = opts.ob4
	opts.ob4 = nil
	module:skinOtherButton(opts)

end

function module:skinStdButton(opts)
-- standard panel button
--[[
	Calling parameters:
		obj         = object (Mandatory)
		ft          = Frame Type (Skinner classification)
		aso         = applySkin options
		as          = use applySkin rather than addSkinButton, used when text appears behind the gradient
		clr         = set colour
		ca          = set colour alpha
		sabt        = use SecureActionButtonTemplate
		ignoreHLTex = ignore Highlight texture changes
		schk        = state check for colour changes
		sechk       = set enabled check for colour changes
--]]
	--@alpha@
	_G.assert(opts.obj, "Missing object skinStdButton\n" .. _G.debugstack(2, 3, 2))
	--@end-alpha@

	-- handle in combat
	if _G.InCombatLockdown() then
		aObj:add2Table(aObj.oocTab, {self.skinStdButton, {self, opts}})
		return
	end

	opts.obj:DisableDrawLayer("BACKGROUND")
	if opts.obj:GetNormalTexture() then
		opts.obj:GetNormalTexture():SetAlpha(0)
	end
	if opts.obj:GetPushedTexture() then
		opts.obj:GetPushedTexture():SetAlpha(0)
	end
	if opts.obj:GetDisabledTexture() then
		opts.obj:GetDisabledTexture():SetAlpha(0)
	end

	local bW, bH = _G.Round(opts.obj:GetWidth()), _G.Round(opts.obj:GetHeight())

	local aso = opts.aso or {}
	aso.bd = bH > 18 and 5 or 7 -- use narrower backdrop if required
	if not opts.as then
		opts.ofs = opts.ofs or 0
		opts.x1  = opts.x1 or opts.ofs * -1
		opts.y1  = opts.y1 or opts.ofs
		opts.x2  = opts.x2 or opts.ofs
		opts.y2  = opts.y2 or opts.ofs * -1
		aObj:skinObject("button", {obj=opts.obj, fType=opts.ftype, name=opts.name, sabt=opts.sabt, aso=aso, x1=opts.x1, y1=opts.y1, x2=opts.x2, y2=opts.y2})
		opts.obj.sb.clr = opts.clr
		opts.obj.sb.ca = opts.ca
	else
		aso.obj = opts.obj
		if bH < 16 then opts.obj:SetHeight(16) end -- set minimum button height (DBM option buttons)
		if bW < 16 then opts.obj:SetWidth(16) end -- set minimum button width (oQueue remove buttons)
		aObj:skinObject("skin", {obj=opts.obj, fType=opts.ftype, bd=aso.bd, ng=aso.ng})
		opts.obj.clr = opts.clr
		opts.obj.ca = opts.ca
	end

	if not opts.ignoreHLTex then
		module:chgHLTex(opts.obj, opts.obj:GetHighlightTexture())
	end

	module:clrBtnBdr(opts.obj, opts.clr, opts.ca)

	if opts.schk then
		module:secureHook(opts.obj, "Disable", function(bObj, _)
			module:clrBtnBdr(bObj)
		end)
		module:secureHook(opts.obj, "Enable", function(bObj, _)
			module:clrBtnBdr(bObj, bObj.sb.clr or bObj.clr, bObj.sb.ca or bObj.ca)
		end)
	end
	if opts.sechk then
		module:SecureHook(opts.obj, "SetEnabled", function(bObj)
			module:clrBtnBdr(bObj, bObj.sb.clr or bObj.clr, bObj.sb.ca or bObj.ca)
		end)
	end

end

function module:skinButton(opts) -- luacheck: ignore self
--[[
	Calling parameters:
		as = use applySkin rather than addSkinButton, used when text appears behind the gradient
		cb = close button
		cb2 = close button style 2 (based upon OptionsButtonTemplate)
		mp = minus/plus texture on a larger button
		mp2 = minus/plus button
		ob = other button, text supplied
		ob2 = other button style 2, text supplied
		plus = use plus sign
		anim = reparent skinButton to avoid whiteout issues caused by animations
		other options as per addSkinButton
		nc = don't check to see if already skinned (Ace3)
--]]
	--@alpha@
	_G.assert(opts.obj, "Missing object skinButton\n" .. _G.debugstack(2, 3, 2))
	aObj:CustomPrint(1, 0, 0, "Not using a specific Button skinning function", opts.obj, opts.cb)
	if not opts.obj:GetName() then _G.print("No Name supplied __sB\n", _G.debugstack(2, 5, 2)) end
	--@end-alpha@

	if not opts.obj then return end

	-- don't skin it twice unless required
	if not opts.nc
	and opts.obj.sb
	then
		return
	end

	if opts.cb then -- it's a close button
		module:skinCloseButton1(opts)
	elseif opts.cb2 then -- it's pretending to be a close button (e.g. ArkInventory/Recount/Outfitter)
		module:skinCloseButton2(opts)
	elseif opts.cb3 then -- it's a small blue close button (e.g. BNToastFrame)
		module:skinCloseButton3(opts)
	elseif opts.mp then -- it's a minus/plus texture on a larger button
		module:skinExpandButton1(opts)
	elseif opts.mp2 then -- it's a minus/plus button (IOF has them on RHS)
		module:skinExpandButton2(opts)
	elseif opts.ob then -- it's another type of button, text supplied (e.g. beql minimize)
		module:skinOtherButton1(opts)
	elseif opts.ob2 then -- it's another type of button, text supplied, style 2 (e.g. MinimalArchaeology)
		module:skinOtherButton2(opts)
	elseif opts.ob3 then -- it's another type of button, text supplied, style 3 (e.g. worldmapsizeup/down button)
		module:skinOtherButton3(opts)
	elseif opts.ob4 then -- it's another type of button, text supplied, style 4 (e.g. WorldQuestTracker)
		module:skinOtherButton4(opts)
	else -- standard button (UIPanelButtonTemplate/UIPanelButtonTemplate2 and derivatives)
		module:skinStdButton(opts)
	end

end

local function __skinAllButtons(opts, bgen)
--[[
	Calling parameters:
		obj = object (Mandatory)
		bgen = generations of children to traverse
		other options as per skinButton
--]]
	--@alpha@
	_G.assert(opts.obj, "Missing object__sAB\n" .. _G.debugstack(2, 3, 2))
	-- handle AddOn skins still using this code
	aObj:CustomPrint(1, 0, 0, "Using deprecated function - skinAllButtons", opts.obj)
	--@end-alpha@
	if not opts.obj then return end

	-- maximum number of button generations to traverse
	bgen = bgen or opts.bgen or 5

	for _, child in _G.ipairs{opts.obj:GetChildren()} do
		if child:GetNumChildren() > 0
		and bgen > 0
		then
			opts.obj = child
			__skinAllButtons(opts, bgen - 1)
		elseif child:IsObjectType("CheckButton") then
			aObj:skinCheckButton{obj=child}
		elseif child:IsObjectType("Button") then
			local bType = module:isButton(child)
			if bType == "normal" then
				module:skinButton{obj=child, ft=opts.ft, x1=opts.x1, y1=opts.y1, x2=opts.x2, y2=opts.y2, anim=opts.anim, as=opts.as}
			elseif bType == "close" then
				module:skinButton{obj=child, ft=opts.ft, cb=true, sap=opts.sap, anim=opts.anim}
			elseif bType == "toast" then
				module:skinButton{obj=child, ft=opts.ft, cb3=true}
			elseif bType == "help" then
				module:skinButton{obj=child, ft=opts.ft, x1=0, y1=0, x2=-3, y2=3}
			end
		end
	end

end
function module:skinAllButtons(...) -- luacheck: ignore self

	local opts = _G.select(1, ...)

	--@alpha@
	 _G.assert(opts, "Missing object sAB\n" .. _G.debugstack(2, 3, 2))
	-- handle AddOn skins still using this code rather than skinning button individually
	aObj:CustomPrint(1, 0, 0, "Using deprecated function - skinAllButtons, use skin???Button instead", opts.obj)
	--@end-alpha@

	-- handle missing object (usually when addon changes)
	if not opts then return end

	if _G.type(_G.rawget(opts, 0)) == "userdata" and _G.type(opts.GetObjectType) == "function" then
		-- old style call
		opts = {}
		opts.obj = _G.select(1, ...) and _G.select(1, ...) or nil
	end
	__skinAllButtons(opts)

end

local function __addButtonBorder(opts)
--[[
	Calling parameters:
		obj      = object (Mandatory)
		relTo    = object to position relative to
		ofs      = global offset
		abt      = Action Button template
		ibt      = Item Button template
		tibt     = Talent Item Button template
		libt     = Large Item Button template
		sibt     = Small Item Button template
		gibt     = Giant Item Button template
		cgibt    = Circular Giant Item Button template
		auit     = auction item template(s)
		bmit     = blackmarket item template
		sft      = requires SecureFrameTemplate
		sabt     = requires SecureActionButtonTemplate
		subt     = requires SecureUnitButtonTemplate
		reParent = table of objects to reparent to the border frame
		es       = edgeSize, used for small icons
		ofs      = offset value to use
		x1       = X offset for TOPLEFT
		y1       = Y offset for TOPLEFT
		x2       = X offset for BOTTOMRIGHT
		y2       = Y offset for BOTTOMRIGHT
		nc       = don't check to see if already skinned
		clr      = set colour
		ca       = set colour alpha
		schk     = state check for colour changes
		sechk    = set enabled check for colour changes
--]]
	--@alpha@
	 _G.assert(opts.obj, "Missing object__aBB\n" .. _G.debugstack(2, 3, 2))
	-- handle AddOn skins using deprecated options
	 if opts.seca
	 or opts.secu
	 then
		aObj:CustomPrint(1, 0, 0, "Using deprecated options - seca,secu, use sabt or subt instead", opts.obj)
	 elseif opts.sec then
		aObj:CustomPrint(1, 0, 0, "Using deprecated options - sec, use sft instead", opts.obj)
	end
	--@end-alpha@
	if not opts.obj then return end
	-- don't skin it twice unless required
	if opts.obj.sbb
	and not opts.nc
	then
		return
	end
	-- remove Normal/Pushed textures if required (vertex colour changed in blizzard code)
	if opts.ibt
	or opts.abt
	or opts.auit
	or opts.bmit
	then
		if opts.obj.GetNormalTexture
		and opts.obj:GetNormalTexture()
		then
			opts.obj:GetNormalTexture():SetTexture(nil)
		end
		if opts.obj.GetPushedTexture
		and opts.obj:GetPushedTexture()
		then
			opts.obj:GetPushedTexture():SetTexture(nil)
		end
	end
	if opts.gibt then
		opts.obj.EmptyBackground:SetTexture(nil)
	end
	-- create the button border object
	opts.sft = opts.sft or opts.sec or nil
	local template = opts.sft and "SecureFrameTemplate" or opts.sabt and "SecureActionButtonTemplate" or opts.subt and "SecureUnitButtonTemplate"
	opts.obj.sbb = _G.CreateFrame(opts.obj:GetObjectType(), nil, opts.obj, template)
	opts.obj.sbb:EnableMouse(false) -- enable clickthrough
	aObj:addBackdrop(opts.obj.sbb)
	-- DON'T lower the frame level otherwise the border appears below the frame
	-- setup and apply the backdrop
	opts.obj.sbb:SetBackdrop({edgeFile = aObj.Backdrop[1].edgeFile, edgeSize = opts.es or aObj.Backdrop[1].edgeSize})
	module:clrBtnBdr(opts.obj, opts.clr, opts.ca)
	-- store colour and alpha values with the skin button
	opts.obj.sbb.clr = opts.clr
	opts.obj.sbb.ca = opts.ca
	-- position the frame
	opts.ofs = opts.ofs or 2
	opts.x1 = opts.x1 or opts.ofs * -1
	opts.y1 = opts.y1 or opts.ofs
	opts.x2 = opts.x2 or opts.ofs
	opts.y2 = opts.y2 or opts.ofs * -1
	-- Large Item Button templates have an IconTexture to position to
	local relTo = opts.relTo or opts.libt and opts.obj.Icon or nil
	opts.obj.sbb:SetPoint("TOPLEFT", relTo or opts.obj, "TOPLEFT", opts.x1, opts.y1)
	opts.obj.sbb:SetPoint("BOTTOMRIGHT", relTo or opts.obj, "BOTTOMRIGHT", opts.x2, opts.y2)
	-- reparent objects
	if opts.reParent then
		for _, obj in _G.pairs(opts.reParent) do
			obj:SetParent(opts.obj.sbb)
		end
	end
	-- reparent these textures so they are displayed above the border
	if opts.ibt then -- Item Buttons
		aObj:getRegion(opts.obj, 3):SetParent(opts.obj.sbb) -- Stock region
		opts.obj.searchOverlay:SetParent(opts.obj.sbb)
		module:clrButtonFromBorder(opts.obj)
	elseif opts.abt then -- Action Buttons
		opts.obj.Border:SetParent(opts.obj.sbb)
		opts.obj.NewActionTexture:SetParent(opts.obj.sbb)
		if opts.obj.FlyoutArrow then
			opts.obj.FlyoutArrow:SetParent(opts.obj.sbb)
		end
	elseif opts.gibt  -- Giant Item Buttons
	or opts.cgibt -- Circular Giant Item Buttons
	then
		module:clrButtonFromBorder(opts.obj)
	end
	if opts.obj.HotKey then
		opts.obj.HotKey:SetParent(opts.obj.sbb)
	end
	if opts.obj.Count then
		opts.obj.Count:SetParent(opts.obj.sbb)
	end
	if opts.obj.Flash
	and opts.obj.Flash:GetObjectType() == "Texture" -- N.B. ignore Bagnon AnimationGroup
	then
		opts.obj.Flash:SetParent(opts.obj.sbb)
	end
	if opts.obj.Name then
		opts.obj.Name:SetParent(opts.obj.sbb)
	end
	if opts.schk then
		module:secureHook(opts.obj, "Disable", function(bObj, _)
			module:clrBtnBdr(bObj)
		end)
		module:secureHook(opts.obj, "Enable", function(bObj, _)
			module:clrBtnBdr(bObj, bObj.sbb.clr, bObj.sbb.ca)
		end)
	end
	if opts.sechk then
		module:SecureHook(opts.obj, "SetEnabled", function(bObj)
			module:clrBtnBdr(bObj, bObj.sbb.clr, bObj.sbb.ca)
		end)
	end

end
function module:addButtonBorder(...) -- luacheck: ignore self

	local opts = _G.select(1, ...)

	--@alpha@
	 _G.assert(opts, "Missing object sAB\n" .. _G.debugstack(2, 3, 2))
	 --@end-alpha@

	-- handle missing object (usually when addon changes)
	if not opts then return end

	if _G.type(_G.rawget(opts, 0)) == "userdata" and _G.type(opts.GetObjectType) == "function" then
		-- old style call
		opts = {}
		opts.obj = _G.select(1, ...) and _G.select(1, ...) or nil
	end
	__addButtonBorder(opts)

end

local function __skinCheckButton(opts)
--[[
	Calling parameters:
		obj = object (Mandatory)
		nc  = don't check to see if already skinned
		hf  = hook show/hide functions
--]]
	--@alpha@
	 _G.assert(opts.obj, "Missing object __sCB\n" .. _G.debugstack(2, 3, 2))
	 --@end-alpha@

	 -- handle in combat
	 if _G.InCombatLockdown() then
	     aObj:add2Table(aObj.oocTab, {__skinCheckButton, {opts}})
	     return
	 end

	-- don't skin it twice unless required
	if not opts.nc
	and opts.obj.sb
	then
		return
	end

	-- check to see if it's a 'real' CheckButton
	if not aObj:hasTextInTexture(opts.obj:GetNormalTexture(), "CheckBox")
	and not aObj:hasTextInTexture(opts.obj:GetNormalTexture(), aObj.tFDIDs.cbUP)
	and not (aObj.isRtl and aObj:hasTextInTexture(opts.obj:GetNormalTexture(), aObj.tFDIDs.cbMin))
	then
		return
	end

	if not aObj.isRtl then
		opts.obj:GetNormalTexture():SetTexture(nil)
		opts.obj:GetPushedTexture():SetTexture(nil)
	else
		opts.obj:GetNormalTexture():SetTexture("")
		opts.obj:GetPushedTexture():SetTexture("")
	end

	-- handle small check buttons (e.g. GuildControlUI - Rank Permissions)
	local bd, ofs, yOfs = 5, opts.ofs or -4, opts.yOfs or opts.ofs and opts.ofs * -1 + 1 or 5
	if opts.obj:GetWidth() < 23 then
		bd = 12
		if aObj:hasTextInName(opts.obj, "AchievementFrame") then
			ofs = -2
			yOfs = nil
		end
	end
	aObj:skinObject("button", {obj=opts.obj, fType=opts.ftype, bd=bd, ng=true, ofs=ofs, y2=yOfs, clr="grey"})

end
function module:skinCheckButton(...) -- luacheck: ignore self

	local opts = _G.select(1, ...)

	--@alpha@
	 _G.assert(opts, "Missing object sCB\n" .. _G.debugstack(2, 3, 2))
	 --@end-alpha@

	-- handle missing object (usually when addon changes)
	if not opts then return end

	if _G.type(_G.rawget(opts, 0)) == "userdata" and _G.type(opts.GetObjectType) == "function" then
		-- old style call
		opts = {}
		opts.obj = _G.select(1, ...) and _G.select(1, ...) or nil
	end

	__skinCheckButton(opts)

end

function module:OnInitialize()

	self.db = aObj.db:RegisterNamespace("UIButtons", defaults)
	db = self.db.profile

	-- convert any old settings
	if aObj.db.profile.Buttons then
		db.UIButtons = aObj.db.profile.Buttons
		aObj.db.profile.Buttons = nil
	end

	if not db.UIButtons
	and not db.ButtonBorders
	and not db.CheckButtons
	then
		self:Disable()
	end -- disable ourself

end

function module:OnEnable()

	-- bypass the Item Quality Border Texture changes if the specified addons aren't loaded
	if not _G.IsAddOnLoaded("AdiBags")
	and not _G.IsAddOnLoaded("Fizzle")
	and not _G.IsAddOnLoaded("oGlowClassic")
	and not _G.IsAddOnLoaded("XLoot")
	then
		return
	end

	_G.LibStub:GetLibrary("AceConfigRegistry-3.0", true):NotifyChange(aName .. " Modules")

	-- setup default backdrop values (AdiBags, Fizzle, oGlow, XLoot)
	self.bDrop = {
		edgeFile = aObj.Backdrop[1].edgeFile,
		edgeSize = aObj.Backdrop[1].edgeSize
	}
	self.iqbDrop = {
		edgeSize = aObj.Backdrop[1].edgeSize
	}
	if db.Quality.file
	and db.Quality.file ~= "None"
	then
		aObj.LSM:Register("border", aName .. " Quality Border", db.Quality.file)
		self.iqbDrop.edgeFile = aObj.LSM:Fetch("border", aName .. " Quality Border")
	else
		self.iqbDrop.edgeFile = aObj.LSM:Fetch("border", db.Quality.texture)
	end

end

function module:GetOptions() -- luacheck: ignore self

	local options = {
		type = "group",
		name = aObj.L["Button Settings"],
		order = 1,
		get = function(info) return db[info[#info]] end,
		set = function(info, value)
			if info[#info] == "ButtonBorders" and not module:IsEnabled() then module:Enable() end
			db[info[#info]] = value
		end,
		args = {
			UIButtons = {
				type = "toggle",
				order = 1,
				name = aObj.L["Buttons"],
				desc = _G.strjoin(" ",  aObj.L["Toggle the skinning of"], aObj.L["the"], aObj.L["UI Buttons"], aObj.L["(reload required)"]),
			},
			ButtonBorders = {
				type = "toggle",
				order = 2,
				name = aObj.L["Button Borders"],
				desc = _G.strjoin(" ",  aObj.L["Toggle the skinning of"], aObj.L["the"], aObj.L["Button Borders"], aObj.L["(reload required)"]),
			},
			CheckButtons = {
				type = "toggle",
				order = 3,
				name = aObj.L["Check Buttons"],
				desc = _G.strjoin(" ",  aObj.L["Toggle the skinning of"], aObj.L["the"], aObj.L["Check Buttons"], aObj.L["(reload required)"]),
			},
			Quality = {
				type = "group",
				order = 4,
				inline = true,
				name = aObj.L["Item Quality Border"],
				hidden = function()
					if not _G.IsAddOnLoaded("AdiBags")
					and not _G.IsAddOnLoaded("Fizzle")
					and not _G.IsAddOnLoaded("oGlowClassic")
					and not _G.IsAddOnLoaded("XLoot")
					then
						return true
					else
						return false
					end
				end,
				get = function(info) return db.Quality[info[#info]] end,
				set = function(info, value) db.Quality[info[#info]] = value end,
				args = {
					file = {
						type = "input",
						order = 1,
						width = "full",
						name = aObj.L["Border Texture File"],
						desc = aObj.L["Set Border Texture Filename"],
					},
					texture = _G._G.AceGUIWidgetLSMlists and {
						type = "select",
						order = 2,
						width = "double",
						name = aObj.L["Border Texture"],
						desc = aObj.L["Choose the Texture for the Border"],
						dialogControl = 'LSM30_Border',
						values = _G._G.AceGUIWidgetLSMlists.border,
					} or nil,
				},
			},
		},
	}

	return options

end
