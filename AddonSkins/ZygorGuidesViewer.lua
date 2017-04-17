local aName, aObj = ...
if not aObj:isAddonEnabled("ZygorGuidesViewer") then return end
local _G = _G

function aObj:ZygorGuidesViewer()

	local ZGV = _G.ZygorGuidesViewer

	-- Hook this to skin frames
	self:RawHook(ZGV.UI, "Create", function(this, uiType, parent, name, ...)
		-- aObj:Debug("ZGV.UI Create: [%s, %s, %s, %s, %s]", this, uiType, parent, name, ...)
		local obj = self.hooks[this].Create(this, uiType, parent, name, ...)
		if uiType == "Frame" then
			self:addSkinFrame{obj=obj, ofs=4}
		elseif (uiType == "Button" and obj:GetParent().acceptbutton) then -- this is a popup
			self:skinButton{obj=obj}
			self:skinButton{obj=obj:GetParent().acceptbutton}
		end
		return obj
	end, true)
	self:RawHook(ZGV, "ChainCall", function(obj)
		-- aObj:Debug("ZGV ChainCall: [%s, %s]", obj, obj:GetObjectType())
		local object = self.hooks[ZGV].ChainCall(obj)
		if obj:GetObjectType() == "Frame"
		and (obj:GetName() and not obj:GetName():find("PointerOverlay"))
		then
			self:addSkinFrame{obj=obj, ofs=4}
			obj.SetBackdrop = _G.nop
		end
		return object
	end, true)

	-- Notification_Center
	self:SecureHook(ZGV.NotificationCenter, "CreateNotificationFrame", function(this)
		self:addSkinFrame{obj=_G.Zygor_Notification_Center, ofs=4}
		self:Unhook(this, "CreateNotificationFrame")
	end)

	-- Viewer frame
	_G.ZygorGuidesViewerFrame:SetBackdrop(nil)
	_G.ZygorGuidesViewerFrame_Border:SetBackdrop(nil)
	self:addSkinFrame{obj=_G.ZygorGuidesViewerFrame, nb=true, ofs=4}

	-- Gear Finder
	self:SecureHookScript(_G.CharacterFrame, "OnShow", function(this)
		if _G.ZygorGearFinderFrame then
			_G["PaperDollSidebarTab" .. 4] = _G.ZGVCharacterGearFinderButton -- set here so .sbb is shown
			local tab = _G["PaperDollSidebarTab" .. 4]
			tab.TabBg:SetAlpha(0)
			tab.Hider:SetAlpha(0)
			-- use a button border to indicate the active tab
			self.modUIBtns:addButtonBorder{obj=tab, relTo=tab.Icon, x1=-6, y1=9, x2=8, y2=-4} -- use module function here to force creation
			tab.sbb:SetBackdropBorderColor(1, 0.6, 0, 1)
			tab.sbb:SetShown(_G[_G.PAPERDOLL_SIDEBARS[4].frame]:IsShown())
			self:keepFontStrings(_G.ZygorGearFinderFrame)
			self:skinSlider{obj=_G.ZygorGearFinderFrameScrollBar}
			for i = 1, #_G.ZygorGearFinderFrame.Items do
				local btn = _G.ZygorGearFinderFrame.Items[i]
				btn.BgTop:SetTexture(nil)
				btn.BgBottom:SetTexture(nil)
				btn.BgMiddle:SetTexture(nil)
			end
			self:Unhook(_G.CharacterFrame, "OnShow")
		end
	end)

	-- Maintenance Frame
	self:addSkinFrame{obj=_G.ZygorGuidesViewerMaintenanceFrame}

	-- DropDownForkLists
	_G.DropDownForkList1MenuBackdrop:SetBackdrop(nil)
	self:addSkinFrame{obj=_G.DropDownForkList1}
	_G.DropDownForkList2MenuBackdrop:SetBackdrop(nil)
	self:addSkinFrame{obj=_G.DropDownForkList2}

end

local AceGUIZ
function aObj:Ace3Z()
	if self.initialized.Ace3Z then return end
	self.initialized.Ace3Z = true

	local function skinAceGUIZ(obj, objType)

		local objVer = AceGUIZ.GetWidgetVersion and AceGUIZ:GetWidgetVersion(objType) or 0
		-- aObj:Debug("skinAceGUIZ: [%s, %s, %s]", obj, objType, objVer)

		if obj
		and not obj.sknd
		then
			-- aObj:Debug("Skinning: [%s, %s]", obj, objType)
			if objType == "Dropdown-Z" then
				aObj:skinDropDown{obj=obj.dropdown, rp=true, y2=0}
				aObj:applySkin{obj=obj.pullout.frame}
			elseif objType == "Dropdown-Pullout-Z" then
				aObj:applySkin{obj=obj.frame}
			elseif objType == "EditBox-Z" then
				aObj:skinEditBox{obj=obj.editbox, regs={9}, noHeight=true}
				if not aObj:IsHooked(obj.editbox, "SetTextInsets") then
					aObj:RawHook(obj.editbox, "SetTextInsets", function(this, left, right, top, bottom)
						return left + 6, right, top, bottom
					end, true)
				end
				aObj:skinButton{obj=obj.button, as=true}
			elseif objType == "MultiLineEditBox-Z" then
				aObj:skinButton{obj=obj.button, as=true}
				aObj:skinSlider{obj=obj.scrollFrame.ScrollBar, adj=-4, size=3}
				aObj:applySkin{obj=aObj:getChild(obj.frame, 2)} -- backdrop frame
			elseif objType == "Button-Z" then
				aObj:skinButton{obj=obj.frame, as=true} -- just skin it otherwise text is hidden
			-- ignore these types for now
			elseif objType == "Dropdown-Item-Toggle-Z"
			or objType == "CheckBox-Z"
			or objType == "Label-Z"
			or objType == "SliderLabeled-Z"
			or objType == "ScrollFrame-Z"
			or objType == "SimpleGroup-Z"
			then
				-- aObj:Debug("Ignoring: [%s]", objType)
			else
				aObj:Debug("AceGUIZ, unmatched type - %s", objType)
			end
		end

	end

	self:RawHook(AceGUIZ, "Create", function(this, objType)
		local obj = self.hooks[this].Create(this, objType)
		skinAceGUIZ(obj, objType)
		return obj
	end, true)

end

_G.C_Timer.After(0.1, function()
	AceGUIZ = _G.LibStub("AceGUI-3.0-Z", true)
	aObj:checkAndRun("Ace3Z", "s") -- not an addon in its own right
end)
