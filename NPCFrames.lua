local _G = _G
local ftype = "n"

function Skinner:MerchantFrames()
	if not self.db.profile.MerchantFrames or self.initialized.MerchantFrames then return end
	self.initialized.MerchantFrames = true

	self:add2Table(self.npcKeys, "MerchantFrames")

	-- display limited availability item's stock count even when zero
	self:SecureHook("SetItemButtonStock", function(button, numInStock)
		if numInStock == 0 and not button == MerchantBuyBackItemItemButton then
			_G[button:GetName().."Stock"]:SetFormattedText(MERCHANT_STOCK, numInStock)
			_G[button:GetName().."Stock"]:Show()
		end
	end)
	-- Items/Buyback Items
	for i = 1, BUYBACK_ITEMS_PER_PAGE do
		local btnName = "MerchantItem"..i
		_G[btnName.."NameFrame"]:SetTexture(nil)
		if not self.modBtnBs then
			_G[btnName.."SlotTexture"]:SetTexture(self.esTex)
		else
			_G[btnName.."SlotTexture"]:SetTexture(nil)
			self:addButtonBorder{obj=_G[btnName.."ItemButton"], ibt=true}
		end
	end
	local btnName = "MerchantBuyBackItem"
	_G[btnName.."NameFrame"]:SetTexture(nil)
	if not self.modBtnBs then
		_G[btnName.."SlotTexture"]:SetTexture(self.esTex)
	else
		_G[btnName.."SlotTexture"]:SetTexture(nil)
		self:addButtonBorder{obj=_G[btnName.."ItemButton"], ibt=true}
	end
	--[=[
		TODO remove surrounding border
	--]=]
	self:addButtonBorder{obj=MerchantRepairAllButton, ofs=3} -- ignore named region
	self:addButtonBorder{obj=MerchantRepairItemButton, ofs=3} -- no named region
	self:addButtonBorder{obj=MerchantGuildBankRepairButton, ofs=3} -- no named region
	self:removeRegions(MerchantPrevPageButton, {2})
	self:removeRegions(MerchantNextPageButton, {2})
	self:addSkinFrame{obj=MerchantFrame, ft=ftype, kfs=true, x1=10, y1=-11, x2=-33, y2=55}

-->>-- Tabs
	for i = 1, MerchantFrame.numTabs do
		local tabName = _G["MerchantFrameTab"..i]
		self:keepRegions(tabName, {7, 8}) -- N.B. region 7 is text, 8 is highlight
		local tabSF = self:addSkinFrame{obj=tabName, ft=ftype, noBdr=self.isTT, x1=6, x2=-6, y2=2}
		if i == 1 then
			if self.isTT then self:setActiveTab(tabSF) end
		else
			if self.isTT then self:setInactiveTab(tabSF) end
		end
	end
	self.tabFrames[MerchantFrame] = true

end

function Skinner:GossipFrame()
	if not self.db.profile.GossipFrame or self.initialized.GossipFrame then return end
	self.initialized.GossipFrame = true

	self:add2Table(self.npcKeys, "GossipFrame")

	-- setup Quest display colours here
	local QTHex = self:RGBPercToHex(self.HTr, self.HTg, self.HTb)
	NORMAL_QUEST_DISPLAY = "|cff"..QTHex.."%s|r"
	TRIVIAL_QUEST_DISPLAY = "|cff"..QTHex.."%s (low level)|r"

	self:keepFontStrings(GossipFrameGreetingPanel)
	GossipGreetingText:SetTextColor(self.HTr, self.HTg, self.HTb)
	self:skinScrollBar{obj=GossipGreetingScrollFrame}
	for i = 1, NUMGOSSIPBUTTONS do
		local text = self:getRegion(_G["GossipTitleButton"..i], 3)
		text:SetTextColor(self.BTr, self.BTg, self.BTb)
	end

	self:addSkinFrame{obj=GossipFrame, ft=ftype, kfs=true, x1=12, y1=-18, x2=-29, y2=66}

end

function Skinner:TrainerUI() -- LoD
	if not self.db.profile.TrainerUI or self.initialized.TrainerUI then return end
	self.initialized.TrainerUI = true

	if not self.isBeta then
		if self.modBtns then
			-- hook to manage changes to button textures
			self:SecureHook("ClassTrainerFrame_Update", function()
				for i = 1, CLASS_TRAINER_SKILLS_DISPLAYED do
					self:checkTex(_G["ClassTrainerSkill"..i])
				end
				self:checkTex(ClassTrainerCollapseAllButton)
			end)
		end
		self:keepFontStrings(ClassTrainerExpandButtonFrame)
		self:skinButton{obj=ClassTrainerCollapseAllButton, mp=true}
		for i = 1, CLASS_TRAINER_SKILLS_DISPLAYED do
			self:skinButton{obj=_G["ClassTrainerSkill"..i], mp=true}
		end
		if self.modBtns then ClassTrainerFrame_Update() end -- force update for button textures
		self:skinScrollBar{obj=ClassTrainerListScrollFrame}
		self:skinScrollBar{obj=ClassTrainerDetailScrollFrame}
		self:getRegion(ClassTrainerSkillIcon, 1):SetAlpha(0)
		self:addButtonBorder{obj=ClassTrainerSkillIcon}
		self:addSkinFrame{obj=ClassTrainerFrame, ft=ftype, kfs=true, x1=10, y1=-11, x2=-32, y2=74}
	else
		local btn = ClassTrainerFrame.skillStepButton
		btn.disabledBG:SetAlpha(0)
		btn:GetNormalTexture():SetAlpha(0)
		self:addButtonBorder{obj=btn, relTo=btn.icon}
		self:skinSlider{obj=ClassTrainerScrollFrameScrollBar}
		ClassTrainerFrame.bottomInset:DisableDrawLayer("BACKGROUND")
		ClassTrainerFrame.bottomInset:DisableDrawLayer("BORDER")
		self:addSkinFrame{obj=ClassTrainerFrame, ft=ftype, kfs=true, ri=true, y1=2, x2=1, y2=-2}
		for i = 1, #ClassTrainerFrame.scrollFrame.buttons do
			local btn = ClassTrainerFrame.scrollFrame.buttons[i]
			btn.disabledBG:SetAlpha(0)
			btn:GetNormalTexture():SetAlpha(0)
			self:addButtonBorder{obj=btn, relTo=btn.icon}
		end
		-- Magic Button textures
		local btn = "ClassTrainerTrainButton"
		if _G[btn.."_LeftSeparator"] then _G[btn.."_LeftSeparator"]:SetAlpha(0) end
		if _G[btn.."_RightSeparator"] then _G[btn.."_RightSeparator"]:SetAlpha(0) end
	end
	self:skinDropDown{obj=ClassTrainerFrameFilterDropDown}

end

function Skinner:TaxiFrame()
	if not self.db.profile.TaxiFrame or self.initialized.TaxiFrame then return end
	self.initialized.TaxiFrame = true

	self:add2Table(self.npcKeys, "TaxiFrame")

	if not self.isBeta then
		self:keepRegions(TaxiFrame, {6, 7}) -- N.B. region 6 is TaxiName, 7 is the Map background
		self:addSkinFrame{obj=TaxiFrame, ft=ftype, x1=10, y1=-11, x2=-32, y2=74}
	else
		self:keepRegions(TaxiFrame, {6, 13})-- N.B. region 6 is Title, 13 is the Map background
		self:addSkinFrame{obj=TaxiFrame, ft=ftype, x1=-3, y1=2, x2=1, y2=-2}
	end


end

function Skinner:QuestFrame()
	if not self.db.profile.QuestFrame or self.initialized.QuestFrame then return end
	self.initialized.QuestFrame = true

	self:add2Table(self.npcKeys, "QuestFrame")

	-- setup Quest display colours here
	local QTHex = self:RGBPercToHex(self.HTr, self.HTg, self.HTb)
	NORMAL_QUEST_DISPLAY = "|cff"..QTHex.."%s|r"
	TRIVIAL_QUEST_DISPLAY = "|cff"..QTHex.."%s (low level)|r"

	self:RawHook("QuestFrame_SetTitleTextColor", function(fontString, ...)
		fontString:SetTextColor(self.HTr, self.HTg, self.HTb)
	end, true)
	self:RawHook("QuestFrame_SetTextColor", function(fontString, ...)
		fontString:SetTextColor(self.BTr, self.BTg, self.BTb)
	end, true)

	self:addSkinFrame{obj=QuestFrame, ft=ftype, kfs=true, x1=12, y1=-18, x2=-29, y2=66}

-->>--	Reward Panel
	self:keepFontStrings(QuestFrameRewardPanel)
	self:skinScrollBar{obj=QuestRewardScrollFrame}

-->>--	Progress Panel
	self:keepFontStrings(QuestFrameProgressPanel)
	if self.isBeta then
		QuestProgressTitleText:SetTextColor(self.HTr, self.HTg, self.HTb)
		QuestProgressText:SetTextColor(self.BTr, self.BTg, self.BTb)
		QuestProgressRequiredMoneyText:SetTextColor(self.BTr, self.BTg, self.BTb)
	end
	QuestProgressRequiredItemsText:SetTextColor(self.HTr, self.HTg, self.HTb)
	self:skinScrollBar{obj=QuestProgressScrollFrame}
	for i = 1, MAX_REQUIRED_ITEMS do
		local btnName = "QuestProgressItem"..i
		_G[btnName.."NameFrame"]:SetTexture(nil)
		self:addButtonBorder{obj=_G[btnName], libt=true}
	end

-->>--	Detail Panel
	self:keepFontStrings(QuestFrameDetailPanel)
	self:skinScrollBar{obj=QuestDetailScrollFrame}

-->>--	Greeting Panel
	self:keepFontStrings(QuestFrameGreetingPanel)
	self:keepFontStrings(QuestGreetingScrollChildFrame) -- hide Horizontal Break texture
	self:skinScrollBar{obj=QuestGreetingScrollFrame}
	if QuestFrameGreetingPanel:IsShown() then
		GreetingText:SetTextColor(self.BTr, self.BTg, self.BTb)
		CurrentQuestsText:SetTextColor(self.HTr, self.HTg, self.HTb)
		AvailableQuestsText:SetTextColor(self.HTr, self.HTg, self.HTb)
	end

	if self.isBeta then
	-->>-- QuestNPCModel
		self:keepFontStrings(QuestNPCModel)
		self:keepFontStrings(QuestNPCModelTextFrame)
		self:skinScrollBar{obj=QuestNPCModelTextScrollFrame}
		self:addSkinFrame{obj=QuestNPCModel, ft=ftype, x1=-4, y1=4, x2=4, y2=-81}
	end

	self:QuestInfo()

end

function Skinner:AuctionUI() -- LoD
	if not self.db.profile.AuctionUI or self.initialized.AuctionUI then return end
	self.initialized.AuctionUI = true

	-- hide filter texture when filter is clicked
	self:SecureHook("FilterButton_SetType", function(button, type, text, isLast)
		_G[button:GetName().."NormalTexture"]:SetAlpha(0)
	end)

	self:addSkinFrame{obj=AuctionFrame, ft=ftype, kfs=true, hdr=true, x1=10, y1=-11, y2=4}

-->>--	Browse Frame
	for k, v in pairs{"Name", "MinLevel", "MaxLevel"} do
		local obj = _G["Browse"..v]
		self:skinEditBox{obj=obj, regs={9}}
		self:moveObject{obj=obj, x=v=="MaxLevel" and -6 or -4, y=v~="MaxLevel" and 3 or 0}
	end
	self:skinDropDown{obj=BrowseDropDown}
	for _, v in pairs{"Quality", "Level", "Duration", "HighBidder", "CurrentBid"} do
		local obj = _G["Browse"..v.."Sort"]
		self:keepRegions(obj, {4, 5, 6}) -- N.B. region 4 is the text, 5 is the arrow, 6 is the highlight
		self:addSkinFrame{obj=obj, ft=ftype, nb=true}
	end
	self:skinScrollBar{obj=BrowseFilterScrollFrame}
	for i = 1, NUM_FILTERS_TO_DISPLAY do
		self:keepRegions(_G["AuctionFilterButton"..i], {3, 4}) -- N.B. region 3 is the highlight, 4 is the text
		self:addSkinFrame{obj=_G["AuctionFilterButton"..i], ft=ftype, nb=true}
	end
	self:skinScrollBar{obj=BrowseScrollFrame}
	for i = 1, NUM_BROWSE_TO_DISPLAY do
		local btnName = "BrowseButton"..i
		if _G[btnName].Orig then break end -- Auctioneer CompactUI loaded
		self:keepFontStrings(_G[btnName])
		if _G[btnName.."Highlight"] then _G[btnName.."Highlight"]:SetAlpha(1) end
		_G[btnName.."ItemCount"]:SetDrawLayer("ARTWORK") -- fix for 3.3.3 bug
		self:addButtonBorder{obj=_G[btnName.."Item"], ibt=true}
	end
	self:skinMoneyFrame{obj=BrowseBidPrice, moveSEB=true}

-->>--	Bid Frame
	for _, v in pairs{"Quality", "Level", "Duration", "Buyout", "Status", "Bid"} do
		local obj = _G["Bid"..v.."Sort"]
		self:keepRegions(obj, {4, 5, 6}) -- N.B. region 4 is the text, 5 is the arrow, 6 is the highlight
		self:addSkinFrame{obj=obj, ft=ftype, nb=true}
	end
	for i = 1, NUM_BIDS_TO_DISPLAY do
		local btnName = "BidButton"..i
		self:keepFontStrings(_G[btnName])
		if _G[btnName.."Highlight"] then _G[btnName.."Highlight"]:SetAlpha(1) end
		self:addButtonBorder{obj=_G[btnName.."Item"], ibt=true}
	end
	self:skinScrollBar{obj=BidScrollFrame}
	self:skinMoneyFrame{obj=BidBidPrice, moveSEB=true}

-->>--	Auctions Frame
	if not self.modBtnBs then
		self:resizeEmptyTexture(self:getRegion(AuctionsItemButton, 2))
	else
		self:getRegion(AuctionsItemButton, 2):SetAlpha(0) -- texture is changed in blizzard code
		self:addButtonBorder{obj=AuctionsItemButton}
	end
	for _, v in pairs{"Quality", "Duration", "HighBidder", "Bid"} do
		local obj = _G["Auctions"..v.."Sort"]
		self:keepRegions(obj, {4, 5, 6}) -- N.B. region 4 is the text, 5 is the arrow, 6 is the highlight
		self:addSkinFrame{obj=obj, ft=ftype, nb=true}
	end
	for i = 1, NUM_AUCTIONS_TO_DISPLAY do
		local btnName = "AuctionsButton"..i
		self:keepFontStrings(_G[btnName])
		if _G[btnName.."Highlight"] then _G[btnName.."Highlight"]:SetAlpha(1) end
		self:addButtonBorder{obj=_G[btnName.."Item"], ibt=true}
	end
	self:skinScrollBar{obj=AuctionsScrollFrame}
	self:skinEditBox{obj=AuctionsStackSizeEntry, regs={9}, noWidth=true}
	self:skinEditBox{obj=AuctionsNumStacksEntry, regs={9}, noWidth=true}
	self:skinDropDown{obj=PriceDropDown}
	self:skinDropDown{obj=DurationDropDown}
	AuctionProgressFrame:DisableDrawLayer("BACKGROUND")
	AuctionProgressFrame:DisableDrawLayer("ARTWORK")
	self:keepFontStrings(AuctionProgressBar)
	self:moveObject{obj=_G["AuctionProgressBar".."Text"], y=-2}
	self:glazeStatusBar(AuctionProgressBar, 0)
	self:skinMoneyFrame{obj=StartPrice, moveSEB=true}
	self:skinMoneyFrame{obj=BuyoutPrice, moveSEB=true}

-->>--	Auction DressUp Frame
	self:keepRegions(AuctionDressUpFrame, {3, 4}) --N.B. regions 3 & 4 are the background
	self:keepRegions(AuctionDressUpFrameCloseButton, {1}) -- N.B. region 1 is the button artwork
	self:makeMFRotatable(AuctionDressUpModel)
	self:moveObject{obj=AuctionDressUpFrame, x=6}
	self:addSkinFrame{obj=AuctionDressUpFrame, ft=ftype, x1=-6, y1=-3, x2=-2}
-->>--	Tabs
	for i = 1, AuctionFrame.numTabs do
		local tabName = _G["AuctionFrameTab"..i]
		self:keepRegions(tabName, {7, 8}) -- N.B. region 7 is text, 8 is highlight
		local tabSF = self:addSkinFrame{obj=tabName, ft=ftype, noBdr=self.isTT, x1=6, x2=-6, y2=2}
		if i == AuctionFrame.selectedTab then
			if self.isTT then self:setActiveTab(tabSF) end
		else
			if self.isTT then self:setInactiveTab(tabSF) end
		end
	end
	self.tabFrames[AuctionFrame] = true

end

function Skinner:BankFrame()
	if not self.db.profile.BankFrame or self.initialized.BankFrame then return end
	self.initialized.BankFrame = true

	self:add2Table(self.uiKeys1, "BankFrame")

	self:addSkinFrame{obj=BankFrame, ft=ftype, kfs=true, x1=10, y1=-11, x2=-25, y2=91}

	if self.modBtnBs then
		-- add button borders
		for i = 1, NUM_BANKGENERIC_SLOTS do
			self:addButtonBorder{obj=_G["BankFrameItem"..i], ibt=true}
		end
		for i = 1, NUM_BANKBAGSLOTS do
			self:addButtonBorder{obj=_G["BankFrameBag"..i], ibt=true}
		end
	end

end

function Skinner:Battlefields()
	if not self.db.profile.Battlefields or self.initialized.Battlefields then return end
	self.initialized.Battlefields = true

	self:add2Table(self.npcKeys, "Battlefields")

	if not self.isBeta then
	   self:skinScrollBar{obj=BattlefieldListScrollFrame}
	end
	if not self.isBeta then
	   BattlefieldFrameInfoScrollFrameChildFrameDescription:SetTextColor(self.BTr, self.BTg, self.BTb)
	   BattlefieldFrameInfoScrollFrameChildFrameRewardsInfo.description:SetTextColor(self.BTr, self.BTg, self.BTb)
	   self:addSkinFrame{obj=BattlefieldFrame, ft=ftype, kfs=true, x1=10, y1=-11, x2=-32, y2=71}
	end

end

function Skinner:ArenaFrame()
	if not self.db.profile.ArenaFrame or self.initialized.ArenaFrame then return end
	self.initialized.ArenaFrame = true

	self:add2Table(self.npcKeys, "ArenaFrame")

	if not self.isBeta then
	   ArenaFrameZoneDescription:SetTextColor(self.BTr, self.BTg, self.BTb)
	   self:addSkinFrame{obj=ArenaFrame, ft=ftype, kfs=true, x1=10, y1=-12, x2=-32, y2=71}
	end

end

function Skinner:ArenaRegistrar()
	if not self.db.profile.ArenaRegistrar or self.initialized.ArenaRegistrar then return end
	self.initialized.ArenaRegistrar = true

	self:add2Table(self.npcKeys, "ArenaRegistrar")

	if not self.isBeta then
	   self:keepFontStrings(ArenaRegistrarGreetingFrame)
	   self:getRegion(ArenaRegistrarGreetingFrame, 1):SetTextColor(self.HTr, self.HTg, self.HTb) -- AvailableServicesText (name also used by GuildRegistrar frame)
	   RegistrationText:SetTextColor(self.HTr, self.HTg, self.HTb)
		for i = 1, MAX_TEAM_BORDERS do
			local text = self:getRegion(_G["ArenaRegistrarButton"..i], 3)
			text:SetTextColor(self.BTr, self.BTg, self.BTb)
		end
		ArenaRegistrarPurchaseText:SetTextColor(self.BTr, self.BTg, self.BTb)
		self:skinEditBox{obj=ArenaRegistrarFrameEditBox}
		self:addSkinFrame{obj=ArenaRegistrarFrame, ft=ftype, kfs=true, x1=10, y1=-17, x2=-29, y2=64}
	end

	--	PVP Banner Frame
	if not self.isBeta then
		self:keepRegions(PVPBannerFrame, {17, 18, 19, 20, 21, 22}) -- N.B. regions 17 - 20 are the emblem, 21, 22 are the text
		self:addSkinFrame{obj=PVPBannerFrame, ft=ftype, x1=10, y1=-12, x2=-32, y2=74}
	else
		self:skinEditBox{obj=PVPBannerFrameEditBox, regs={9}}
		self:keepRegions(PVPBannerFrame, {8, 29, 30, 31, 32, 33, 34, 35}) -- N.B. region 8 is the title, 29 - 32 are the emblem, 33 - 35 are the text
		self:addSkinFrame{obj=PVPBannerFrame, ft=ftype, ri=true, y1=2, x2=1, y2=-4}
		-- Magic Button textures
		for _, v in pairs{"Cancel", "Accept"} do
			local btn = "PVPBannerFrame"..v.."Button"
			if _G[btn.."_LeftSeparator"] then _G[btn.."_LeftSeparator"]:SetAlpha(0) end
			if _G[btn.."_RightSeparator"] then _G[btn.."_RightSeparator"]:SetAlpha(0) end
		end
	end
	self:removeRegions(PVPBannerFrameCustomizationFrame)
	self:keepFontStrings(PVPBannerFrameCustomization1)
	self:keepFontStrings(PVPBannerFrameCustomization2)

end

function Skinner:GuildRegistrar()
	if not self.db.profile.GuildRegistrar or self.initialized.GuildRegistrar then return end
	self.initialized.GuildRegistrar = true

	self:add2Table(self.npcKeys, "GuildRegistrar")

	self:keepFontStrings(GuildRegistrarGreetingFrame)
	AvailableServicesText:SetTextColor(self.HTr, self.HTg, self.HTb)
	GuildRegistrarPurchaseText:SetTextColor(self.BTr, self.BTg, self.BTb)
	for i = 1, 2 do
		local text = self:getRegion(_G["GuildRegistrarButton"..i], 3)
		text:SetTextColor(self.BTr, self.BTg, self.BTb)
	end
	self:skinEditBox{obj=GuildRegistrarFrameEditBox}

	self:addSkinFrame{obj=GuildRegistrarFrame, ft=ftype, kfs=true, x1=12, y1=-17, x2=-29, y2=65}

end

function Skinner:Petition()
	if not self.db.profile.Petition or self.initialized.Petition then return end
	self.initialized.Petition = true

	self:add2Table(self.npcKeys, "Petition")

	PetitionFrameCharterTitle:SetTextColor(self.HTr, self.HTg, self.HTb)
	PetitionFrameCharterName:SetTextColor(self.BTr, self.BTg, self.BTb)
	PetitionFrameMasterTitle:SetTextColor(self.HTr, self.HTg, self.HTb)
	PetitionFrameMasterName:SetTextColor(self.BTr, self.BTg, self.BTb)
	PetitionFrameMemberTitle:SetTextColor(self.HTr, self.HTg, self.HTb)
	for i = 1, 9 do
		_G["PetitionFrameMemberName"..i]:SetTextColor(self.BTr, self.BTg, self.BTb)
	end
	PetitionFrameInstructions:SetTextColor(self.BTr, self.BTg, self.BTb)

	self:addSkinFrame{obj=PetitionFrame, ft=ftype, kfs=true, x1=12, y1=-17, x2=-29, y2=65}

end

function Skinner:Tabard()
	if not self.db.profile.Tabard or self.initialized.Tabard then return end
	self.initialized.Tabard = true

	self:add2Table(self.npcKeys, "Tabard")

	self:keepRegions(TabardFrame, {6, 17, 18, 19, 20, 21, 22}) -- N.B. region 6 is the background, 17 - 20 are the emblem, 21, 22 are the text

	self:makeMFRotatable(TabardModel)
	TabardFrameCostFrame:SetBackdrop(nil)
	self:keepFontStrings(TabardFrameCustomizationFrame)
	for i = 1, 5 do
		self:keepFontStrings(_G["TabardFrameCustomization"..i])
	end

	self:addSkinFrame{obj=TabardFrame, ft=ftype, kfs=true, x1=10, y1=-12, x2=-32, y2=74}

end

function Skinner:BarbershopUI() -- LoD
	if not self.db.profile.BarbershopUI or self.initialized.Barbershop then return end
	self.initialized.Barbershop = true

	self:keepFontStrings(BarberShopFrameMoneyFrame)
	self:addSkinFrame{obj=BarberShopFrame, ft=ftype, kfs=true, x1=35, y1=-32, x2=-32, y2=42}
	-- Banner Frame
	self:keepFontStrings(BarberShopBannerFrame)
	BarberShopBannerFrameCaption:ClearAllPoints()
	BarberShopBannerFrameCaption:SetPoint("CENTER", BarberShopFrame, "TOP", 0, -46)

end

function Skinner:QuestInfo()
	if not self.db.profile.QuestFrame or self.initialized.QuestInfo then return end
	self.initialized.QuestInfo = true

	self:add2Table(self.npcKeys, "QuestInfo")

	self:SecureHook("QuestInfo_Display", function(...)
		-- headers
		QuestInfoTitleHeader:SetTextColor(self.HTr, self.HTg, self.HTb)
		QuestInfoDescriptionHeader:SetTextColor(self.HTr, self.HTg, self.HTb)
		QuestInfoObjectivesHeader:SetTextColor(self.HTr, self.HTg, self.HTb)
		QuestInfoRewardsHeader:SetTextColor(self.HTr, self.HTg, self.HTb)
		-- other text
		QuestInfoDescriptionText:SetTextColor(self.BTr, self.BTg, self.BTb)
		QuestInfoObjectivesText:SetTextColor(self.BTr, self.BTg, self.BTb)
		QuestInfoGroupSize:SetTextColor(self.BTr, self.BTg, self.BTb)
		QuestInfoRewardText:SetTextColor(self.BTr, self.BTg, self.BTb)
		-- reward frame text
		QuestInfoItemChooseText:SetTextColor(self.BTr, self.BTg, self.BTb)
		QuestInfoItemReceiveText:SetTextColor(self.BTr, self.BTg, self.BTb)
		QuestInfoSpellLearnText:SetTextColor(self.BTr, self.BTg, self.BTb)
		if not self.isBeta then
			QuestInfoTalentFrameReceiveText:SetTextColor(self.BTr, self.BTg, self.BTb)
			QuestInfoHonorFrameReceiveText:SetTextColor(self.BTr, self.BTg, self.BTb)
			QuestInfoArenaPointsFrameReceiveText:SetTextColor(self.BTr, self.BTg, self.BTb)
		end
		QuestInfoXPFrameReceiveText:SetTextColor(self.BTr, self.BTg, self.BTb)
		QuestInfoReputationText:SetTextColor(self.BTr, self.BTg, self.BTb)
		-- reputation rewards
		for i = 1, MAX_REPUTATIONS do
			_G["QuestInfoReputation"..i.."Faction"]:SetTextColor(self.BTr, self.BTg, self.BTb)
		end
		local r, g, b = QuestInfoRequiredMoneyText:GetTextColor()
		QuestInfoRequiredMoneyText:SetTextColor(self.BTr - r, self.BTg - g, self.BTb - b)
		-- Objectives
		for i = 1, MAX_OBJECTIVES do
			local r, g, b = _G["QuestInfoObjective"..i]:GetTextColor()
			_G["QuestInfoObjective"..i]:SetTextColor(self.BTr - r, self.BTg - g, self.BTb - b)
		end
		if self.isBeta then
			QuestInfoSpellObjectiveLearnLabel:SetTextColor(self.BTr, self.BTg, self.BTb)
		end
	end)

	QuestInfoTimerText:SetTextColor(self.BTr, self.BTg, self.BTb)
	QuestInfoAnchor:SetTextColor(self.BTr, self.BTg, self.BTb)

	for i = 1, MAX_NUM_ITEMS do
		local btnName = "QuestInfoItem"..i
		_G[btnName.."NameFrame"]:SetTexture(nil)
		self:addButtonBorder{obj=_G[btnName], libt=true}
	end
	if self.isBeta then
		QuestInfoRewardSpellNameFrame:SetTexture(nil)
		QuestInfoRewardSpellSpellBorder:SetTexture(nil)
	end

	if self.isBeta then
		local btnName = "QuestInfoSkillPointFrame"
		_G[btnName.."NameFrame"]:SetTexture(nil)
		if self.modBtnBs then
			self:addButtonBorder{obj=_G[btnName], libt=true}
			_G[btnName.."SkillPointBg"]:SetParent(_G[btnName].sknrBdr)
			_G[btnName.."SkillPointBgGlow"]:SetParent(_G[btnName].sknrBdr)
			_G[btnName.."Points"]:SetParent(_G[btnName].sknrBdr)
		end
	end

end

if Skinner.isBeta then

	function Skinner:ReforgingUI()
		if not self.db.profile.ReforgingUI or self.initialized.ReforgingUI then return end
		self.initialized.ReforgingUI = true

		ReforgingFrame.topInset:DisableDrawLayer("BACKGROUND")
		ReforgingFrame.topInset:DisableDrawLayer("BORDER")
		ReforgingFrame.bottomInset:DisableDrawLayer("BACKGROUND")
		ReforgingFrame.bottomInset:DisableDrawLayer("BORDER")
		ReforgingFrameItemButton:DisableDrawLayer("OVERLAY")
		ReforgingFrameTopInsetLableBg:Hide()
		ReforgingFrameItemButton.missingText:SetTextColor(self.BTr, self.BTg, self.BTb)
		ReforgingFrame.missingDescription:SetTextColor(self.BTr, self.BTg, self.BTb)
		self:skinDropDown{obj=ReforgingFrameFilterOldStat}
		self:skinDropDown{obj=ReforgingFrameFilterNewStat}
		self:addSkinFrame{obj=ReforgingFrame, ft=ftype, kfs=true, ri=true, y1=2, x2=1, y2=-2}
		-- Magic Button textures
		for _, v in pairs{"Reforge", "Restore"} do
			local btn = "ReforgingFrame"..v.."Button"
			if _G[btn.."_LeftSeparator"] then _G[btn.."_LeftSeparator"]:SetAlpha(0) end
			if _G[btn.."_RightSeparator"] then _G[btn.."_RightSeparator"]:SetAlpha(0) end
		end

	end

end
