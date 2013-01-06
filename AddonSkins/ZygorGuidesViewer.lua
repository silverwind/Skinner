local aName, aObj = ...
if not aObj:isAddonEnabled("ZygorGuidesViewer") then return end

function aObj:ZygorGuidesViewer()

	local ZGV = ZygorGuidesViewer

	-- Viewer frame
	self:addSkinFrame{obj=ZGV.Frame, nb=true, anim=true, ofs=4}
	ZGV.Frame.Border:SetBackdrop(nil)

	-- hook this to skin the menu frame
	self:SecureHook(ZGV.Menu, "CreateFrame", function(this)
		self:addSkinFrame{obj=this.Frame, nb=true, anim=true, ofs=4}
		self:Unhook(ZGV.Menu, "CreateFrame")
	end)

	-- Tutorial frame
	self:SecureHook(ZGV.Tutorial, "CreateFrame", function(this)
		self:addSkinFrame{obj=this.TooltipFrame, nb=true, ofs=4}
		self:Unhook(ZGV.Tutorial, "CreateFrame")
	end)

	-- Creature Viewer
	self:addSkinFrame{obj=ZGV.CreatureViewer.Frame, ofs=4}

	-- Gear Finder
	self:SecureHookScript(CharacterFrame, "OnShow", function(this)
		if ZygorGearFinderFrame then
			local tab = PaperDollSidebarTab4
			tab.TabBg:SetAlpha(0)
			tab.Hider:SetAlpha(0)
			-- use a button border to indicate the active tab
			self.modUIBtns:addButtonBorder{obj=tab, relTo=tab.Icon, ofs=4, y1=9, x2=6} -- use module function here to force creation
			tab.sbb:SetBackdropBorderColor(1, 0.6, 0, 1)
			tab.sbb:SetShown(ZygorGearFinderFrame:IsShown())
			self:keepFontStrings(ZygorGearFinderFrame)
			self:skinSlider{obj=ZygorGearFinderFrameScrollBar}
			for i = 1, #ZygorGearFinderFrame.Items do
				local btn = ZygorGearFinderFrame.Items[i]
				btn.BgTop:SetTexture(nil)
				btn.BgBottom:SetTexture(nil)
				btn.BgMiddle:SetTexture(nil)
			end
		end
		self:Unhook(CharacterFrame, "OnShow")
	end)

	-- TalentAdvisor Popout
	ZygorTalentAdvisorPopoutButton:SetSize(36, 32)
	self:addButtonBorder{obj=ZygorTalentAdvisorPopoutButton, x1=2, x2=-2}
	ZygorTalentAdvisorPopoutButton:SetNormalTexture(ZGV.DIR .. [[\ZygorTalentAdvisor\Skin\popout-button]])
	ZygorTalentAdvisorPopoutButton:SetPushedTexture(ZGV.DIR .. [[\ZygorTalentAdvisor\Skin\popout-button-pushed]])
	ZygorTalentAdvisorPopout.accept:DisableDrawLayer("OVERLAY")
	self:addSkinFrame{obj=ZygorTalentAdvisorPopout, kfs=true}

	-- Pet Battles frame(s)
	self:skinAllButtons{obj=ZGV.PetBattle.BattleFrame}
	self:addSkinFrame{obj=ZGV.PetBattle.BattleFrame.Main, kfs=true}
	self:addSkinFrame{obj=ZGV.PetBattle.BattleFrame.Enemy, kfs=true}
	self:addSkinFrame{obj=ZGV.PetBattle.BattleFrame.Ally, kfs=true}

end
