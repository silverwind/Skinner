local aName, aObj = ...
if not aObj:isAddonEnabled("Cork") then return end
local _G = _G

aObj.addonsToSkin.Cork = function(self) -- v 7.1.0.62-Beta

	-- anchor
	self.RegisterCallback("Cork", "UIParent_GetChildren", function(this, child)
		if child:IsObjectType("Button")
		and _G.Round(child:GetHeight()) == 24
		then
			self:addSkinFrame{obj=child, ft="a", kfs=true, nb=true, x1=-2}
			self.UnregisterCallback("Cork", "UIParent_GetChildren")
		end
	end)

	-- tooltip
	_G.C_Timer.After(0.1, function()
		self:add2Table(self.ttList, _G.Corkboard)
	end)

	self.RegisterCallback("Cork", "IOFPanel_Before_Skinning", function(this, panel)
		if panel.name ~= "Cork" then return end
		self.iofSkinnedPanels[panel] = true
		-- find tab buttons
		_G.CorkFrame.Tabs = {} -- store on Button
		for _, child in _G.ipairs{panel:GetChildren()} do
			if child:IsObjectType("Button")
			and child.OrigSetText
			then
				aObj:add2Table(_G.CorkFrame.Tabs, child)
			end
		end
		self:skinObject(self.skinTPLs.new("tabs", {obj=_G.CorkFrame, names=_G.CorkFrame.Tabs, fType=ftype, ignoreSize=true, lod=true, offsets={x1=6, y1=0, x2=-6, y2=-1}, regions={5}, func=aObj.isTT and function(tab) aObj:SecureHookScript(tab, "OnClick", function(this) for _, tab in _G.pairs(_G.CorkFrame.Tabs) do if tab == this then aObj:setActiveTab(tab. sf) else aObj:setInactiveTab(tab.sf) end end end) end}))

		self.UnregisterCallback("Cork", "IOFPanel_Before_Skinning")
	end)

end
