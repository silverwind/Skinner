local _, aObj = ...

local _G = _G

-- skin Templates
aObj.skinTPLs = {
	defaults = {
		fType		= "a",
		-- obj         =,
		-- type        =,
	},
	button = {
		aso         = {},-- applySkin options,
		hide        = false, -- hide skin
		ofs         = 4, -- skin frame offset to object
		-- x1          = -4,
		-- y1          = 4,
		-- x2          = 4,
		-- y2          = -4,
		sap         = false, -- SetAllPoints to object
		sft         = false, -- use SecureFrameTemplate
	},
	dropdown= {
		lrgTpl      = false,
		noBB        = false,
		noSkin      = false,
		regions     = {1, 2, 3},
		x1          = 16,
		y1          = -1,
		x2          = -16,
		y2          = 7,
		adjBtnX		= false,
		initState	= false, -- initial State is "Enabled" i.e. NOT "Disabled"
		rp			= false,
	},
	editbox = {
		-- bd          = 3, -- medium
		-- clr         = "darkgrey", -- backdrop border colour [aso]
		-- ca          = 0.5, -- backdrop border alpha
		-- ng          = true, -- no Gradient texture
		regions     = {3, 4, 5}, -- 1 is text, 2 is cursor, 6 is text, 7 is icon
		si			= false, -- search icon
		ofs         = 2,
		x2          = 0,
	},
	frame = {
		bg          = false, -- put into Background FrameStrata
		cb          = false, -- skin close button
		cbns        = false, -- use noSkin otion when skinning the close button
		hat         = false, -- hide all textures except font strings
		kfs         = false, -- remove all textures except font strings
		regions     = {}, -- remove specified regions
		rb          = true, -- remove Backdrop
		ri          = true, -- disable draw layers; [Background, Border & Overlay]
		rns         = true, -- disable draw layers; [Background, Border & Overlay]
		rp          = false, -- reverse parent child relationship
		sft         = false, -- use SecureFrameTemplate
		ofs         = 2, -- skin frame offset to object
		-- x1          = ofs * -2,
		-- y1          = ofs,
		-- x2          = ofs,
		-- y2          = ofs * -1,
		aso         = {}, -- applySkin options
		bd          = 1, -- backdrop to use
		hdr         = false, -- header texture(s)
		noBdr       = false, -- equivalent to bd=11 when true
		ebc         = false, -- use edit box colours
		ba          = 1, -- backdrop alpha
		clr         = "default", -- backdrop border colour
		bba         = 1, -- backdrop border alpha
		ng          = false, -- no Gradient texture
		-- fh          =, -- fade height
		invert      = false, -- invert Gradient
		rotate      = false, -- rotate Gradient
		fb          = false, -- frame border [bd=10, ng=true, ofs=0]
	},
	glowbox = {
	},
	skin = {
		bd          = 1,
		hdr         = false,
		ebc         = false,
		ba          = 1, -- backdrop alpha
		bbclr       = "default", -- backdrop border colour
		bba         = 1, -- backdrop border alpha
		ng          = false,
		-- fh          =,
		-- invert      =,
		-- rotate      =,
	},
	slider = {
		-- bd          = 4, -- narrow
		-- clr         = "darkgrey", -- backdrop border colour
		-- ca          = 0.5, -- backdrop border alpha
		-- ng          = true, -- no Gradient texture
		rpTex       = false, -- remove parent's textures [single draw layer or array of draw layers]
		-- x1          = 2,
		-- y1          = -2,
		-- x2          = -3,
		-- y2          = 3,
	},
	tabs = {
		-- prefix      = "",
		-- tabs        = {},
		numTabs     = 1,
		selectedTab = 1,
		suffix      = "",
		regions     = {7, 8},
		ignoreSize  = false,
		lod         = false,
		upwards     = false,
		offsets     = {x1=6, y1=0, x2=-6, y2=2},
		ignoreHLTex = false,
		offsetsHL   = {x1=8, y1=2, x2=-8, y2=0},
		track       = true,
		noCheck     = false,
		func        = nil,
	},
	new = function(type, table)
		_G.setmetatable(table, {__index = function(table, key) return aObj.skinTPLs[type][key] end})
		return table
	end,
}
do
	for name, table in _G.pairs(aObj.skinTPLs) do
		if _G.type(table) == "table"
		and name ~= "defaults"
		then
			table.type = name
			_G.setmetatable(table, {__index = function(table, key) return aObj.skinTPLs.defaults[key] end})
		end
	end
end

-- Add skinning functions to this table
local skinFuncs = {}
function aObj:skinObject(...)
	aObj:Debug2("skinObject: [%s, %s]", ...)
	-- handle called with both a type and a table or just a table
	local type, table
	if _G.select('#', ...) == 2 then
		type, table = ...
--@alpha@
		_G.assert(self.skinTPLs[type], "Unknown type (skinObject)\n" .. _G.debugstack(2, 3, 2))
--@end-alpha@
	else
		table = ...
	end
--@alpha@
	_G.assert(table and _G.type(table), "Missing table (skinObject)\n" .. _G.debugstack(2, 3, 2))
--@end-alpha@

	if type then
		skinFuncs[type](self.skinTPLs.new(type, table))
	else
		skinFuncs[table.type](table)
	end
	type, table = nil, nil

end

local hOfs = -7
local function hideHeader(obj)
	-- remove Header textures and move text
	if obj.header then -- Classic
		obj.header:DisableDrawLayer("BACKGROUND")
		obj.header:DisableDrawLayer("BORDER")
		if obj.header.text
		then
			aObj:moveObject{obj=obj.header.text, y=hOfs}
		else
			aObj:moveObject{obj=aObj:getRegion(obj.header, obj.header:GetNumRegions()), y=hOfs}
		end
		return
	end
	if obj.Header then
		aObj:removeRegions(obj.Header, {1, 2, 3})
		aObj:moveObject{obj=obj.Header.Text, y=hOfs}
		return
	end
	if obj:GetName() then
		for _, suffix in _G.pairs{"Header", "_Header", "_HeaderBox", "_FrameHeader", "FrameHeader", "HeaderTexture", "HeaderFrame"} do
			local hObj = _G[obj:GetName() .. suffix]
			if hObj then
				hObj:SetPoint("TOP", obj, "TOP", 0, hOfs * -1)
				if aObj:hasTextInTexture(hObj, "UI-DialogBox-Header") then
					hObj:SetAlpha(0)
				end
				break
			end
			hObj = nil
		end
	end
end
local function applySkin(tbl)
--@alpha@
	_G.assert(tbl.obj, "Missing object (applySkin)\n" .. _G.debugstack(2, 3, 2))
--@end-alpha@
	aObj:Debug2("applySkin: [%s]", tbl)

	aObj.gradFrames[tbl.fType][tbl.obj] = true
	-- fix for backdrop textures not tiling vertically
	-- using info from here: http://boss.wowinterface.com/forums/showthread.php?p=185868
	if aObj.prdb.BgUseTex then
		if not tbl.obj.tbg then
			tbl.obj.tbg = tbl.obj:CreateTexture(nil, "BORDER")
			tbl.obj.tbg:SetTexture(aObj.LSM:Fetch("background", aObj.bgTexName), true) -- have to use true for tiling to work
			tbl.obj.tbg:SetBlendMode("ADD") -- use existing frame alpha setting
			-- allow for border inset
			tbl.obj.tbg:SetPoint("TOPLEFT", tbl.obj, "TOPLEFT", aObj.prdb.BdInset, -aObj.prdb.BdInset)
			tbl.obj.tbg:SetPoint("BOTTOMRIGHT", tbl.obj, "BOTTOMRIGHT", -aObj.prdb.BdInset, aObj.prdb.BdInset)
			-- the texture will be stretched if the following tiling methods are set to false
			tbl.obj.tbg:SetHorizTile(aObj.prdb.BgTile)
			tbl.obj.tbg:SetVertTile(aObj.prdb.BgTile)
		end
	elseif tbl.obj.tbg then
		tbl.obj.tbg = nil -- remove background texture if it exists
	end
	if tbl.hdr then
		hideHeader(tbl.obj)
	end
	aObj:addBackdrop(tbl.obj)
	tbl.obj:SetBackdrop(aObj.Backdrop[tbl.bd])
	if not tbl.ng then
		aObj:applyGradient(tbl.obj, tbl.fh, tbl.invert, tbl.rotate)
	end
	if not tbl.ebc then
		local r, g, b, a = aObj.bClr:GetRGBA()
		tbl.obj:SetBackdropColor(r, g, b, tbl.ba or a)
		aObj:clrBBC(tbl.obj, tbl.bbclr, tbl.bba)
		r, g, b, a = nil, nil ,nil ,nil
	else
		tbl.obj:SetBackdropColor(.1, .1, .1, 1)
		tbl.obj:SetBackdropBorderColor(.2, .2, .2, 1)
	end
end
skinFuncs.skin = function(table) applySkin(table) end
local function skinButton(tbl)
--@alpha@
	_G.assert(tbl.obj, "Missing object (skinButton)\n" .. _G.debugstack(2, 3, 2))
--@end-alpha@
	aObj:Debug2("skinButton [%s]", tbl)

	if tbl.obj.sb
	or tbl.noSkin
	then
		return
	end
	-- add a frame to the object
	tbl.obj.sb = _G.CreateFrame("Button", nil, tbl.obj, tbl.sft and "SecureFrameTemplate")
	if tbl.sap then
		tbl.obj.sb:SetAllPoints(tbl.obj)
	else
		-- position around the original frame
		tbl.x1 = tbl.x1 or tbl.ofs * -1
		tbl.y1 = tbl.y1 or tbl.ofs
		tbl.x2 = tbl.x2 or tbl.ofs
		tbl.y2 = tbl.y2 or tbl.ofs * -1
		tbl.obj.sb:ClearAllPoints()
		tbl.obj.sb:SetPoint("TOPLEFT", tbl.obj, "TOPLEFT", tbl.x1, tbl.y1)
		tbl.obj.sb:SetPoint("BOTTOMRIGHT", tbl.obj, "BOTTOMRIGHT", tbl.x2, tbl.y2)
	end
	-- allow clickthrough
	tbl.obj.sb:EnableMouse(false)
	-- adjust frame level
	local success, _ = _G.pcall(_G.LowerFrameLevel, tbl.obj.sb) -- catch any error, doesn't matter if already 0
	-- raise parent's Frame Level if 0
	if not success then
		_G.RaiseFrameLevel(tbl.obj)
	end
	success = nil
	 -- make sure it's lower than its parent's Frame Strata
	if tbl.bg then
		tbl.obj.sb:SetFrameStrata("BACKGROUND")
	end
	if tbl.hide then
		tbl.obj.sb:Hide()
	end
	if tbl.rp
	and not tbl.obj.SetParent_orig
	then
		tbl.obj.sb:SetParent(tbl.obj:GetParent())
		tbl.obj:SetParent(tbl.obj.sb)
		tbl.obj.SetParent_orig = tbl.obj.SetParent
		tbl.obj.SetParent = function(this, parent)
			tbl.obj.sb:SetParent(parent)
			this:SetParent_orig(tbl.obj.sb)
		end
	end
	-- change the draw layer of the Icon and Count
	if tbl.chgDL then
		for _, reg in _G.pairs{tbl.obj:GetRegions()} do
			-- change the DrawLayer to make the Icon show if required
			if aObj:hasAnyTextInName(reg, {"[Ii]con", "[Cc]ount"})
			or aObj:hasTextInTexture(reg, "[Ii]con") then
				if reg:GetDrawLayer() == "BACKGROUND" then
					reg:SetDrawLayer("ARTWORK")
				end
			end
		end
	end
	-- setup applySkin options
	local so = aObj.skinTPLs.new("skin", tbl.aso)
	so.obj   = tbl.obj.sb
	so.fType = tbl.fType
	so.ba    = tbl.ba
	so.bbclr = so.bbclr or tbl.clr
	so.bba   = tbl.bba
	so.bd    = tbl.bd
	so.ng    = tbl.ng
	-- apply the 'Skinner effect' to the frame
	aObj:skinObject(so)
	return tbl.obj.sb
end
skinFuncs.button = function(table) skinButton(table) end
local function skinDropDown(tbl)
--@alpha@
	_G.assert(tbl.obj, "Missing object (skinDropDown)\n" .. _G.debugstack(2, 3, 2))
--@end-alpha@

	aObj:Debug2("skinDropDown: [%s]", tbl)

	-- don't skin it twice
	if tbl.obj.sf then return end
	-- hide textures
	aObj:removeRegions(tbl.obj, tbl.regions)
	-- return if not to be skinned
	if tbl.noSkin then return end
	-- skin the DropDown
	aObj:skinObject("frame", {obj=tbl.obj, fType=tbl.fType, ng=true, bd=5, rp=tbl.rp, x1=tbl.x1, y1=tbl.y1, x2=tbl.x2, y2=tbl.y2})
	-- add a button border around the dd button
	if not tbl.noBB then
		local btn = tbl.obj.Button or tbl.obj.dropButton or _G[tbl.obj:GetName() .. "Button"]
		if tbl.lrgTpl then
			aObj:addButtonBorder{obj=btn, es=12, ofs=0}
		else
			local xOfs1 = tbl.adjBtnX and tbl.obj:GetWidth() + 10 or 1
			aObj:addButtonBorder{obj=btn, es=12, ofs=-2, x1=xOfs1}
			xOfs1 = nil
		end
		btn = nil
	end
	-- add texture
	if aObj.prdb.TexturedDD then
		tbl.obj.ddTex = tbl.obj:CreateTexture(nil, "ARTWORK", -5) -- appear behind text
		tbl.obj.ddTex:SetTexture(aObj.prdb.TexturedDD and aObj.itTex or nil)
		-- align it to the middle texture
		local lTex = tbl.obj.Left or tbl.obj.DLeft or tbl.obj.LeftTexture or _G[tbl.obj:GetName() .. "Left"]
		local rTex = tbl.obj.Right or tbl.obj.DRight or tbl.obj.RightTexture or _G[tbl.obj:GetName() .. "Right"]
		if tbl.lrgTpl then
			tbl.obj.ddTex:SetPoint("LEFT", lTex, "RIGHT", -11, 2)
			tbl.obj.ddTex:SetPoint("RIGHT", rTex, "LEFT", -15, 0)
			tbl.obj.ddTex:SetHeight(24)
		else
			tbl.obj.ddTex:SetPoint("LEFT", lTex, "RIGHT", -5, 2)
			tbl.obj.ddTex:SetPoint("RIGHT", rTex, "LEFT", 5, 2)
			tbl.obj.ddTex:SetHeight(17)
		end
		lTex, rTex = nil, nil
	end
	-- colour on Initial State
	aObj:checkDisabledDD(tbl.obj, tbl.initState)
	-- show Text and Icon
	if tbl.obj.Text then
		tbl.obj.Text:SetAlpha(1)
	end
	if tbl.obj.Icon then
		tbl.obj.Icon:SetAlpha(1)
	end
end
skinFuncs.dropdown = function(table) skinDropDown(table) end
local function skinEditBox(tbl)
--@alpha@
	_G.assert(tbl.obj, "Missing object (skinEditBox)\n" .. _G.debugstack(2, 3, 2))
	_G.assert(tbl.obj:IsObjectType("EditBox"), "Not an EditBox (skinEditBox)\n" .. _G.debugstack(2, 3, 2))
--@end-alpha@
	aObj:Debug2("skinEditBox: [%s]", tbl)

	-- don't skin it twice
	if tbl.obj.sf then return end
	aObj:removeRegions(tbl.obj, tbl.regions)
	aObj:skinObject("frame", {obj=tbl.obj, bd=3, ng=true, ofs=tbl.ofs, x2=tbl.x2, clr="slider", bba=0.5})
	-- move the search icon
	if tbl.si then
		local sIcon = tbl.obj.searchIcon or tbl.obj.icon or tbl.obj:GetName() and _G[tbl.obj:GetName() .. "SearchIcon"]
		if not sIcon then  -- e.g. WeakAurasFilterInput
			for _, reg in _G.pairs{tbl.obj:GetRegions()} do
				if aObj:hasTextInTexture(reg, "UI-Searchbox-Icon") then
					sIcon = reg
					break
				end
			end
		end
		aObj:moveObject{obj=sIcon, x=3}
		sIcon:SetAlpha(1)
		sIcon = nil
	else
		-- move left text insert
		local l, r, t, b = tbl.obj:GetTextInsets()
		tbl.obj:SetTextInsets(l + 5, r, t, b)
		l, r, t, b = nil, nil, nil, nil
	end
	aObj:getRegion(tbl.obj, 2):SetAlpha(1) -- cursor texture
end
skinFuncs.editbox = function(table) skinEditBox(table) end
local function skinFrame(tbl)
--@alpha@
	_G.assert(tbl.obj, "Missing object (skinFrame)\n" .. _G.debugstack(2, 3, 2))
--@end-alpha@
	aObj:Debug2("skinFrame [%s]", tbl)

	-- don't skin it twice
	if tbl.obj.sf then return end
	-- make all textures transparent
	if tbl.kfs
	or tbl.hat
	then
		aObj:keepFontStrings(tbl.obj, tbl.hat)
	else
		aObj:removeRegions(tbl.obj, tbl.regions)
	end
	if tbl.rb then
		aObj:removeBackdrop(tbl.obj)
	end
	if tbl.ri
	and tbl.obj.Inset
	then
		aObj:removeInset(tbl.obj.Inset)
	end
	if tbl.rns
	and tbl.obj.NineSlice
	then
		aObj:removeNineSlice(tbl.obj.NineSlice)
	end
	if tbl.hdr then
		hideHeader(tbl.obj)
	end
	-- add a frame to the object
	tbl.obj.sf = _G.CreateFrame("Frame", nil, tbl.obj, tbl.sft and "SecureFrameTemplate")
	-- allow clickthrough
	tbl.obj.sf:EnableMouse(false)
	-- adjust frame level
	local success, _ = _G.pcall(_G.LowerFrameLevel, tbl.obj.sf) -- catch any error, doesn't matter if already 0
	-- raise parent's Frame Level if 0
	if not success then
		_G.RaiseFrameLevel(tbl.obj)
	end
	success = nil
	 -- make sure it's lower than its parent's Frame Strata
	if tbl.bg then
		tbl.obj.sf:SetFrameStrata("BACKGROUND")
	end
	-- skin the CloseButton
	if aObj.modBtns
	and tbl.cb
	or tbl.cbns
	then
		local cBtn = tbl.obj.CloseButton or tbl.obj.closeButton or tbl.obj.closebutton or tbl.obj:GetName() and _G[tbl.obj:GetName() .. "CloseButton"] or tbl.obj.Close
		if cBtn then
			aObj:skinCloseButton{obj=cBtn, noSkin=tbl.cbns}
		end
		cBtn = nil
	end
	-- reverse parent child relationship
	if tbl.rp
	and not tbl.obj.SetParent_orig
	then
		tbl.obj.sf:SetParent(tbl.obj:GetParent())
		tbl.obj:SetParent(tbl.obj.sf)
		tbl.obj.SetParent_orig = tbl.obj.SetParent
		tbl.obj.SetParent = function(this, parent)
			tbl.obj.sf:SetParent(parent)
			this:SetParent_orig(tbl.obj.sf)
		end
		-- hook Show and Hide methods
		aObj:SecureHook(tbl.obj, "Show", function(this) this.sf:Show() end)
		aObj:SecureHook(tbl.obj, "Hide", function(this) this.sf:Hide() end)
	end
	-- setup Frame Border options
	if tbl.fb
	and aObj.prdb.FrameBorders
	then
		tbl.bd  = 10
		tbl.ng  = true
		tbl.ofs = tbl.ofs or 0
	end
	-- position around the original frame
	tbl.x1  = tbl.x1 or tbl.ofs * -1
	tbl.y1  = tbl.y1 or tbl.ofs
	tbl.x2  = tbl.x2 or tbl.ofs
	tbl.y2  = tbl.y2 or tbl.ofs * -1
	tbl.obj.sf:ClearAllPoints()
	tbl.obj.sf:SetPoint("TOPLEFT", tbl.obj, "TOPLEFT", tbl.x1, tbl.y1)
	tbl.obj.sf:SetPoint("BOTTOMRIGHT", tbl.obj, "BOTTOMRIGHT", tbl.x2, tbl.y2)
	-- setup applySkin options
	local so  = aObj.skinTPLs.new("skin", tbl.aso)
	so.obj    = tbl.obj.sf
	so.fType  = tbl.fType
	so.bd     = tbl.noBdr and 11 or tbl.bd
	so.ebc    = tbl.ebc
	so.ba     = tbl.ba
	so.bbclr  = tbl.clr
	so.bba    = tbl.bba
	so.ng     = tbl.ng
	so.fh     = _G.rawget(tbl, "fh")
	-- if _G.rawget(tbl, "fh") then
	-- 	so.fh = tbl.fh
	-- end
	so.invert = tbl.invert
	so.rotate = tbl.rotate
	-- apply the 'Skinner effect' to the frame
	aObj:skinObject(so)
	return tbl.obj.sf
end
skinFuncs.frame = function(table) skinFrame(table) end
local function skinGlowBox(tbl)
--@alpha@
	_G.assert(tbl.obj, "Missing object (skinGlowBox)\n" .. _G.debugstack(2, 3, 2))
--@end-alpha@
	aObj:Debug2("skinGlowBox: [%s]", tbl)

	-- don't skin it twice
	if tbl.obj.sf then return end
	-- remove Arrow Glow texture
	if tbl.obj.Glow then
		tbl.obj.Glow:SetTexture(nil)
	elseif tbl.obj.Arrow
	and tbl.obj.Arrow.Glow then
		tbl.obj.Arrow.Glow:SetTexture(nil)
	elseif tbl.obj.ArrowGlow then
		tbl.obj.ArrowGlow:SetTexture(nil)
	end
	tbl.obj:DisableDrawLayer("BACKGROUND")
	-- skin the GlowBox
	aObj:skinObject("frame", {obj=tbl.obj, fType=tbl.fType, cbns=true, clr="gold"})
end
skinFuncs.glowbox = function(table) skinGlowBox(table) end
local function skinSlider(tbl)
	--@alpha@
	_G.assert(tbl.obj, "Missing object (skinSlider)\n" .. _G.debugstack(2, 3, 2))
	_G.assert(tbl.obj:IsObjectType("Slider"), "Not a Slider (skinSlider)\n" .. _G.debugstack(2, 3, 2))
--@end-alpha@
	aObj:Debug2("skinSlider: [%s, %s]", tbl)

	-- don't skin it twice
	if tbl.obj.sf then return end
	-- remove textures
	aObj:keepFontStrings(tbl.obj)
	-- remove parent's textures
	if tbl.rpTex then
		if _G.type(tbl.rpTex) == "table" then
			for _, layer in _G.pairs(tbl.rpTex) do
				tbl.obj:GetParent():DisableDrawLayer(layer)
			end
		else
			tbl.obj:GetParent():DisableDrawLayer(tbl.rpTex)
		end
	end
	local h, w, o = _G.Round(tbl.obj:GetHeight()), _G.Round(tbl.obj:GetWidth()), tbl.obj:GetOrientation()
	aObj:Debug("skinSlider H/W: [%s, %s, %s]", o, h, w)
	-- setup offsets based on Orientation/Height/Width
	if o == "HORIZONTAL" then
		if h <= 16 then
			tbl.y1 = _G.rawget(tbl, "y1") or -1
			tbl.y2 = _G.rawget(tbl, "y2") or 2
		elseif h <= 18 then
			tbl.y1 = _G.rawget(tbl, "y1") or -2
			tbl.y2 = _G.rawget(tbl, "y2") or 3
		elseif h <= 20 then
			tbl.y1 = _G.rawget(tbl, "y1") or -3
			tbl.y2 = _G.rawget(tbl, "y2") or 4
		elseif h <= 22 then
			tbl.y1 = _G.rawget(tbl, "y1") or -4
			tbl.y2 = _G.rawget(tbl, "y2") or 5
		end
		tbl.x1 = _G.rawget(tbl, "x1") or 0
		tbl.x2 = _G.rawget(tbl, "x2") or 0
	else
		if w <= 8 then
			tbl.x1 = _G.rawget(tbl, "x1") or -4
			tbl.x2 = _G.rawget(tbl, "x2") or 1
		elseif w <= 12 then
			tbl.x1 = _G.rawget(tbl, "x1") or -2
			tbl.x2 = _G.rawget(tbl, "x2") or -1
		elseif w <= 16 then
			tbl.x1 = _G.rawget(tbl, "x1") or 0
			tbl.x2 = _G.rawget(tbl, "x2") or -1
		elseif w <= 20 then
			tbl.x1 = _G.rawget(tbl, "x1") or 2
			tbl.x2 = _G.rawget(tbl, "x2") or -3
			tbl.y1 = _G.rawget(tbl, "y1") or -1
			tbl.y2 = _G.rawget(tbl, "y2") or 1
		elseif w == 22 then
			tbl.x1 = _G.rawget(tbl, "x1") or 3
			tbl.x2 = _G.rawget(tbl, "x2") or -3
			tbl.y1 = _G.rawget(tbl, "y1") or -1
			tbl.y2 = _G.rawget(tbl, "y2") or 1
		end
		tbl.y1 = _G.rawget(tbl, "y1") or 0
		tbl.y2 = _G.rawget(tbl, "y2") or 0
	end
	aObj:Debug("skinSlider#2: [%s, %s, %s, %s]", tbl.x1, tbl.x2, tbl.y1, tbl.y2)
	-- skin the Slider
	aObj:skinObject("frame", {obj=tbl.obj, fType=tbl.fType, bd=4, ng=true, x1=tbl.x1, y1=tbl.y1, x2=tbl.x2, y2=tbl.y2, clr="slider", bba=0.5})
	-- make objects visible
	tbl.obj:SetAlpha(1)
	tbl.obj:GetThumbTexture():SetAlpha(1)
	h, w, o = nil, nil, nil
end
skinFuncs.slider = function(table) skinSlider(table) end
local function skinTabs(tbl)
--@alpha@
	_G.assert(tbl.obj, "Missing Tab Object (skinTabs)\n" .. _G.debugstack(2, 3, 2))
	_G.assert(_G.type(tbl.tabs) == "table" or tbl.prefix, "Missing Tabs Table or Tab Prefix (skinTabs)\n" .. _G.debugstack(2, 3, 2))
--@end-alpha@
	aObj:Debug2("skinTabs: [%s]", tbl)

	-- don't skin it twice unless required (Ace3)
	if tbl.noCheck then
		tbl.obj.sknd = false
	end
	if tbl.obj.sknd then
		return
	end
	tbl.obj.sknd = true
	-- create table of tab objects if not supplied
	if not tbl.tabs then
		tbl.tabs = {}
		for i = 1, tbl.obj.numTabs or tbl.numTabs do
			aObj:add2Table(tbl.tabs, _G[tbl.prefix .. "Tab"  ..  tbl.suffix .. i])
		end
	end
	local oFs = tbl.offsets
	for i, tab in _G.pairs(tbl.tabs) do
		aObj:keepRegions(tab, tbl.regions)
		aObj:skinObject("frame", {obj=tab, fType=tbl.fType, noBdr=aObj.isTT, x1=oFs.x1, y1=oFs.y1, x2=oFs.x2, y2=oFs.y2})
		tab.sf.ignore = tbl.ignoreSize
		tab.sf.up = tbl.upwards
		if tbl.lod then
			if aObj.isTT then
				if i == tbl.selectedTab then
					aObj:setActiveTab(tab.sf)
				else
					aObj:setInactiveTab(tab.sf)
				end
			end
		end
		-- change highlight texture
		if tbl.ignoreHLTex then
			local ht = tab:GetHighlightTexture()
			if ht then
				ht:SetTexture([[Interface\PaperDollInfoFrame\UI-Character-Tab-Highlight]])
				ht:ClearAllPoints()
				if tbl.upwards then -- (GuildInfoFrame, LookingForGuild, MacroFrame, FriendsTabHeader)
					ht:SetPoint("TOPLEFT", 1, -5)
					ht:SetPoint("BOTTOMRIGHT", -1, -5)
				else
					local hOFs = tbl.offsetsHL
					ht:SetPoint("TOPLEFT", hOFs.x1, hOFs.y1)
					ht:SetPoint("BOTTOMRIGHT", hOFs.x2, hOFs.y2)
					hOFs = nil
				end
			end
			ht = nil
		end
		if tbl.func then
			tbl.func(tab)
		end
	end
	oFs = nil
	-- track tab updates
	aObj.tabFrames[tbl.obj] = tbl.track
end
skinFuncs.tabs = function(table) skinTabs(table) end
