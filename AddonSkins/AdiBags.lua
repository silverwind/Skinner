local aName, aObj = ...
if not aObj:isAddonEnabled("AdiBags") then return end

function aObj:AdiBags()

	local aBag = LibStub("AceAddon-3.0"):GetAddon("AdiBags", true)
	
	-- hook this for bag creation
	aBag:HookBagFrameCreation(aObj, function(bag)
		aObj:ScheduleTimer(function(bag)
			local frame = bag:GetFrame()
			aObj:addSkinFrame{obj=frame}
			aObj:skinEditBox{obj=_G[frame:GetName().."SearchBox"], regs={9}, mi=true}
		end, 0.2, bag) -- wait for 2/10th second for frame to be created fully
	end)

	if self.modBtnBs then
		-- hook this for equipped bag panel creation
		self:RawHook(aBag, "CreateBagSlotPanel", function(this, ...)
			local bPanel = self.hooks[this].CreateBagSlotPanel(this, ...)
			self:addSkinFrame{obj=bPanel}
			for _, v in pairs(bPanel.buttons) do
				self:addButtonBorder{obj=v}
			end
			return bPanel
		end, true)
		local r, g, b, a = unpack(self.bbColour)
		-- colour the button border 
		local function updBtn(evt, btn)
			if not btn.sknrBdr then aObj:addButtonBorder{obj=btn} end
			if btn.IconQuestTexture:GetBlendMode() == "ADD" then
				btn.sknrBdr:SetBackdropBorderColor(btn.IconQuestTexture:GetVertexColor())
				btn.IconQuestTexture:Hide()
			else
				btn.sknrBdr:SetBackdropBorderColor(r, g, b, a)
				btn.IconQuestTexture:Show()
			end
		end
		-- register for button updates
		aBag:RegisterMessage("AdiBags_UpdateButton", updBtn)
	end

end
