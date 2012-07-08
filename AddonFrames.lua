local aName, aObj = ...

function aObj:BlizzardFrames()
--	  self:Debug("BlizzardFrames")

	local blizzFrames = {
		-- player
		"Buffs", "CharacterFrames", "CompactFrames", "DressUpFrame", "EquipmentFlyout", "FriendsFrame", "PVPFrame", 
		-- QuestLog, checked with EQL3 & QuestGuru below
		"ReadyCheck", "ScrollOfResurrection", "SpellBookFrame", "TradeFrame", "WatchFrame", 
	    -- npc
		"ArenaRegistrar", "BankFrame", "GossipFrame", "GuildRegistrar", "MerchantFrames", "Petition", "PetStableFrame", "QuestFrame", "SideDressUpFrame", "Tabard", "TaxiFrame", 
		-- ui
		"AlertFrames", "AutoComplete", "BNFrames", 
		-- CastingBar, checked with Quartz below
		"ChatConfig", "ChatEditBox", "ChatFrames", "ChatMenus", "ChatTabs", "ChatTemporaryWindow", "CinematicFrame",  "CoinPickup", "ColorPicker", "ContainerFrames", "DropDownPanels", "GhostFrame", "GroupLoot", "GuildInvite", "HelpFrame", "ItemText", "LevelUpDisplay", "LFDFrame", "LFGFrame", "LFRFrame", "LootFrame", "MailFrame",
		-- MainMenuBar, checked with Bongos below
		"MenuFrames", "Minimap", 
		-- MinimapButtons, done with timer
		"MirrorTimers", 
		-- ModelFrames, checked with CloseUp below
		-- Nameplates, checked with Aloft below
		"RaidFrame", "RolePollPopup", "ScriptErrors", "SpellFlyout", "StackSplit", "StaticPopups", 
		-- Tooltips, checked below
		"Tutorial", "WorldMap", "WorldState", 
	}

	-- optional frames
	if IsMacClient() then aObj:add2Table(blizzFrames, "MovieProgress") end -- ui
	if not self.isBeta then
		aObj:add2Table(blizzFrames, "VehicleMenuBar") -- player
	else
		aObj:add2Table(blizzFrames, "OverrideActionBar") -- player
		aObj:add2Table(blizzFrames, "DestinyFrame") -- ui
		aObj:add2Table(blizzFrames, "ItemUpgradeUI") -- ui
		aObj:add2Table(blizzFrames, "LootHistory") -- ui
		aObj:add2Table(blizzFrames, "PetBattleUI") -- ui
		aObj:add2Table(blizzFrames, "PVEFrame") -- ui
	end

	for _, v in pairs(blizzFrames) do
		self:checkAndRun(v)
	end
	blizzFrames = nil

	-- handle non standard ones here
	self:ScheduleTimer("checkAndRun", 1, "MinimapButtons") -- wait for a second before skinning the minimap buttons

end

local blizzLoDFrames = {
	-- player
	"AchievementUI", "ArchaeologyUI", "EncounterJournal", "GlyphUI", "GuildControlUI", "GuildUI", "RaidUI", "TalentUI", 
	-- TradeSkillUI, loaded when TRADE_SKILL_SHOW event is fired
	-- npc
 	--AuctionUI, loaded when AUCTION_HOUSE_SHOW event is fired
	"BarbershopUI", "ItemAlterationUI", "ReforgingUI", "TrainerUI", "VoidStorageUI",
	-- ui
	"BattlefieldMinimap", "BindingUI", "Calendar", "DebugTools", "GMChatUI", "GMSurveyUI", "GuildBankUI", "InspectUI", "ItemSocketingUI", "LookingForGuildUI", "MacroUI", "MovePad", "TimeManager", 
}
-- optional frames
if aObj.isPTR then aObj:add2Table(blizzLoDFrames, "FeedbackUI") end -- ui
if aObj.isBeta then
	aObj:add2Table(blizzLoDFrames, "BlackMarketUI") -- npc
	aObj:add2Table(blizzLoDFrames, "ChallengesUI") -- ui
	aObj:add2Table(blizzLoDFrames, "ItemUpgradeUI") -- ui
	aObj:add2Table(blizzLoDFrames, "PetJournal") -- ui
end
local blizzLoD = {}
for _, v in pairs(blizzLoDFrames) do
	blizzLoD["Blizzard_"..v] = v
end
blizzLoDFrames = nil
--[=[
	ArenaUI -- unitframes skinned in UnitFrames.lua
--]=]

aObj.addonSkins = {
	"_NPCScan",
	"Accomplishment", "Accountant", "Acheron", "AckisRecipeList", "ACP", "AdiBags", "AdvancedTradeSkillWindow", "AISeller", "AlleyMap", "Altoholic", "Analyst", "AnnounceIt", "AphesLootBrowser", "Ara_Broker_Guild_Friends", "Archy", "ArkInventory", "ArkInventoryRules", "Armory", "ArmoryGuildBank", "Atlas", "AtlasLoot", "AtlasQuest", "AuctionLite", "AuctionProfitMaster", "Auctionsnatch", "AutoDecline", "AutoPartyButtons", "AutoProfit",
	"Badapples", "Baggins", "Bagnon", "Bagnon_Forever", "BankItems", "BasicChatMods", "BaudBag", "BaudManifest", "BeanCounter", "beql", "BetterInbox", "BindPad", "BlackList", "BossInfo", "BossNotes", "BriefQuestComplete", "Broker_Transport", "Buffalo", "BugSack", "Butsu", "BuyEmAll",
	"CalendarNotify", "CallToArms", "Capping", "Carbonite", "CFM", "ChatBar", "Chatr", "Chatter", "Chinchilla", "Clique", "CloseUp", "Collectinator", "Combuctor", "CombustionHelper", "ConcessionStand", "Converse", "CoolLine", "Cork", "Cosplay", "CowTip", "CT_MailMod", "CT_RaidTracker",
	"DaemonMailAssist", "DailiesQuestTracker", "DamageMeters", "DeathNote", "DockingStation", "Dominos", "DragonCore",
	"EasyUnlock", "EavesDrop", "EditingUI", "EggTimer", "ElvUI", "EnchantMe", "EnergyWatch", "EngBags", "EnhancedColourPicker", "EnhancedFlightMap", "EnhancedStackSplit", "EnhancedTradeSkills", "epgp", "epgp_lootmaster", "epgp_lootmaster_ml", "EquipCompare", "EventEquip", "Examiner", "ExtVendor",
	"Factionizer", "FBagOfHolding", "FB_OutfitDisplayFrame", "FB_TrackingFrame", "FeedMachine", "FishingBuddy", "FlightMap", "FlightMapEnhanced", "FlyoutButtonCustom", "Fortress", "FPSideBar", "FramesResized", "FreierGeist_InstanceTime",
	"G15Buttons", "Gatherer", "GearScore", "GemHelper", "GemMe", "Glamour", "GnomeWorks", "GnomishVendorShrinker", "Gobling", "Gossipmonger", "Grid", "GrimReaper", "GroupCalendar", "GroupCalendar5", "GuildAds", "GuildBankAccount", "GuildGreet", "GuildLaunchCT_RaidTracker", "GuildMaster", "GupCharacter", "GupPet",
	"Hack", "Hadar_FocusFrame", "HandyNotes", "HatTrick", "HeadCount", "HealBot", "HealOrganizer", "Highlight", "HitsMode", "HoloFriends",
	"InspectEquip", "IntricateChatMods", "InventoryOnPar", "IPopBar", "ItemDB", "ItemRack", "ItemSync",
	"LauncherMenu", "LazyAFK", "LightHeaded", "Links", "LinksList", "LinkWrangler", "Livestock", "Luggage",
	"MacroBank", "MacroBrokerGUI", "MailTo", "MakeRocketGoNow", "Mapster", "Megaphone", "MinimalArchaeology", "MinimapButtonFrame", "Misdirectionhelper", "MobMap", "MogIt", "MonkeyQuest", "MonkeyQuestLog", "Mountiful", "MoveAnything", "MTLove", "MuffinMOTD", "MyBags", "myClock",
	"NeatFreak", "Necrosis", "NeonChat", "nQuestLog",
	"Odyssey", "Omen", "OneBag3", "OneBank3", "oRA3", "Outfitter", "Overachiever",
	"PallyPower", "Panda", "PartyBuilder", "PassLoot", "Pawn", "Perl_CombatDisplay", "Perl_Focus", "Perl_Party", "Perl_Party_Pet", "Perl_Party_Target", "Perl_Player", "Perl_Player_Pet", "Perl_Target", "Perl_Target_Target", "PetListPlus", "PetsPlus", "PhoenixStyle", "Planner", "PlayerExpBar", "PlusOneTable", "POMAssist", "PoMTracker", "Possessions", "Postal", "PowerAuras", "PowerAurasButtons", "Producer", "ProfessionsBook", "ProfessionTabs", "PvpMessages",
	"Quartz", "Quelevel", "QuestAgent", "QuestCompletist", "QuestGuru_Tracker", "QuestHelper", "QuestHelper2", "QuestHistory", "QuickMark",
	"RABuffs", "RaidAchievement", "RaidAchievement_AchieveReminder", "RaidBuffStatus", "RaidChecklist", "RaidComp", "RaidTracker", "RaidyCheck", "RandomPet30", "ReagentRestocker", "Recap", "RecipeBook", "RecipeRadar", "Recount", "REFlex", "ReforgeLite", "Reforgenator", "RicoMiniMap",
	"SayGMOTD", "ScrollMaster", "ShadowDancer3", "sienasGemViewer", "Skada", "Skillet", "SmoothQuest", "SnapShot", "Spew", "Squeenix", "sRaidFrames",
	"tabDB", "Talented", "TargetAnnounce", "tekBlocks", "tekDebug", "tekErr", "tekPad", "TheCollector", "TinyDPS", "TinyPad", "TipTac", "tomQuest2", "TomTom", "TooManyAddons", "Toons", "TotemCaddy", "TourGuide", "TradeSkillMaster", "TrinketBar", "Tukui", "TwinValkyr_shieldmonitor",
	"UberQuest", "UrbanAchiever",
	"vBagnon", "Vendorizer", "Vendomatic", "VendorSearch", "Violation", "Visor2_GUI", "Volumizer", "VuhDo", "VuhDoOptions",
	"Warden", "WeakAuras", "WebDKP", "WIM", "WoWEquip", "WowLua", "WoWPro", "WTFLatencyMeter",
	"xcalc", "XLoot", "XLootGroup", "XLootMonitor", "xMerchant", "XPerl", "XPerl_RaidAdmin", "XPerl_RaidHelper",
	"zfpoison", "ZOMGBuffs"
}
aObj.oddlyNamedAddons = {
	"!Swatter", "Auc-Advanced", "Auto-Bag", "DBM-Core", "Enchantrix-Barker", "Ogri'Lazy", "Prat-3.0", "XLoot1.0"
}
aObj.libsToSkin = {
	["Dewdrop-2.0"] = "Dewdrop",
	["AceAddon-2.0"] = "Ace2",
	["Tablet-2.0"] = "Tablet",
	["Waterfall-1.0"] = "Waterfall",
	["AceGUI-3.0"] = "Ace3",
	["LibSimpleOptions-1.0"] = "LibSimpleOptions",
	["Configator"] = "Configator",
	["LibExtraTip-1"] = "LibExtraTip",
	["tektip-1.0"] = "tektip",
	["LibQTip-1.0"] = "LibQTip",
	["LibSimpleFrame-Mod-1.0"] = "LibSimpleFrame",
	["ArkDewdrop-3.0"] = "ArkDewdrop",
}
function aObj:AddonFrames()
--	   self:Debug("AddonFrames")

	-- these addons colour the Tooltip Border
	if IsAddOnLoaded("Chippu")
	or IsAddOnLoaded("TipTac")
	then
		self.ttBorder = false
	end

	-- skin tooltips here after checking whether the ttBorder setting needed changing
	self:checkAndRun("Tooltips")

	-- skin the QuestLog if EQL3 isn't loaded
	-- N.B. Do it here as other Addons use the QuestLog size
	if not IsAddOnLoaded("EQL3") then self:checkAndRun("QuestLog") end

	-- skin the CastingBar if Quartz isn't loaded
	if not IsAddOnLoaded("Quartz") then self:checkAndRun("CastingBar") end

	-- skin the MenuBar if Bongos isn't loaded
	if not IsAddOnLoaded("Bongos")
	and not IsAddOnLoaded("Bongos2")
	then
		self:checkAndRun("MainMenuBar")
	end

	-- skin the Nameplates if other nameplate addons aren't loaded
	if not IsAddOnLoaded("Aloft")
	and not IsAddOnLoaded("nerNameplates")
	and not IsAddOnLoaded("TidyPlates")
	and not IsAddOnLoaded("DocsUI_Nameplates")
	then
		self:checkAndRun("Nameplates")
	end

	--	don't make Model Frames Rotatable if CloseUp is loaded
	if not IsAddOnLoaded("CloseUp") then self:checkAndRun("ModelFrames") end

	-- used for Addons that aren't LoadOnDemand
	for _, v in pairs(self.addonSkins) do
		self:checkAndRunAddOn(v)
	end
	self.addonSkins = nil

	-- handle Addons with odd names here
	for _, v in pairs(self.oddlyNamedAddons) do
		v2, _ = v:gsub("[-!'\.]", "")
		self:checkAndRunAddOn(v, nil, v2)
	end
	self.oddlyNamedAddons = nil

	-- this addon has a relation
	self:checkAndRunAddOn("EnhancedTradeSkills", nil, "EnhancedTradeCrafts")

	-- skin the Blizzard LoD frames if they have already been loaded by other addons
	for k, v in pairs(blizzLoD) do
		if IsAddOnLoaded(k) then self:checkAndRun(v) end
	end

	-- load MSBTOptions here if FuBar_MSBTFu is loaded
	if IsAddOnLoaded("FuBar_MSBTFu") then
		self:checkAndRunAddOn("MSBTOptions", true) -- use true so it isn't treated as a LoadManaged Addon
	end

	-- skin library objects
	for k, v in pairs(self.libsToSkin) do
		if LibStub(k, true) then
			if self[v] then self:checkAndRun(v) -- not an addon in its own right
			else
				if self.db.profile.Warnings then
					self:CustomPrint(1, 0, 0, v, "loaded but skin not found in SkinMe directory")
				end
			end
		end
	end

	-- skin Rock Config
	if Rock and Rock:HasLibrary("LibRockConfig-1.0") then
		if self.RockConfig then self:checkAndRun("RockConfig") -- not an addon in its own right
		else
			if self.db.profile.Warnings then
				self:CustomPrint(1, 0, 0, "RockConfig", "loaded but skin not found in SkinMe directory")
			end
		end
	end

	-- skin KeyboundDialog frame
	if self.db.profile.MenuFrames then
		if LibStub('LibKeyBound-1.0', true) then
			self:skinButton{obj=KeyboundDialogOkay} -- this is a CheckButton object
			self:skinButton{obj=KeyboundDialogCancel} -- this is a CheckButton object
			self:addSkinFrame{obj=KeyboundDialog, kfs=true, y1=4, y2=6}
		end
	end

	-- skin tekKonfig library objects
	if self.tekKonfig then self:checkAndRun("tekKonfig") end -- not an addon in its own right

end

local lodFrames = {
	"Altoholic_Characters", "Altoholic_Search", "Altoholic_Achievements", "Altoholic_Guild", "Altoholic_Agenda", "AzCastBarOptions",
	"Bagnon", "Bagnon_Options", "Banknon", "BetterBindingFrame",
	"DockingStation_Config", "Dominos_Config", "DoTimer_Options",
	"Enchantrix", "EnhTooltip",
	"FramesResized_TalentUI",
	"GnomishAuctionShrinker", "GuildBankSearch",
	"ItemRackOptions",
	"LilSparkysWorkshop", "Ludwig_Window",
	"MSBTOptions",
	"oRA2_Leader", "oRA2_Participant", "Overachiever_Tabs",
	"Perl_Config_Options",
	"Scrap_Merchant", "Scrap_Options", "Scrap_Visualizer", "Squire2_Config",
	"Talented_GlyphFrame", "TradeTabs", "TipTacOptions",
	"WeakAurasOptions", "WIM_Options",
	"XPerl_Options",
	"ZOMGBuffs_BlessingsManager",
}
aObj.lodAddons = {}
for _, v in pairs(lodFrames) do
	aObj.lodAddons[v] = v
end
lodFrames = nil
-- MobMap Databases
for i = 1, 8 do
	aObj.lodAddons["MobMapDatabaseStub"..i] = "MobMapDatabaseStub"..i
end
aObj.lodAddons["MobMapDatabaseStub6"] = nil -- ignore stub6
-- RaidAchievement modules
for _, v in pairs{"Icecrown", "Naxxramas", "Ulduar", "WotlkHeroics", "CataHeroics", "CataRaids"} do
	aObj.lodAddons["RaidAchievement_"..v] = "RaidAchievement_"..v
end
aObj.oddlyNamedLoDAddons = { "_DevPad.GUI", "DBM-GUI" }
local prev_addon
function aObj:LoDFrames(addon)
	  -- self:Debug("LoDFrames: [%s]", addon)

	if addon == prev_addon then return end
	prev_addon = addon

	-- used for Blizzard LoadOnDemand Addons
	if blizzLoD[addon] then self:checkAndRun(blizzLoD[addon]) end

	-- used for User LoadOnDemand Addons
	if self.lodAddons[addon] then self:checkAndRunAddOn(self.lodAddons[addon], true) end

	-- handle Addons with odd names here
	for _, v in pairs(self.oddlyNamedLoDAddons) do
		v2, _ = v:gsub("[-!'\.]", "")
		if addon == v then self:checkAndRunAddOn(v, true, v2) end
	end

	-- handle addons linked to the InspectUI
	if addon == "Blizzard_InspectUI" then
		--	This addon is dependent upon the Inspect Frame
		self:checkAndRunAddOn("Spyglass")
	end

	-- deal with Addons under the control of an LoadManager
	-- use lowercase addonname (lazyafk issue)
	if self.lmAddons[addon:lower()] then
		self:checkAndRunAddOn(addon, true, self.lmAddons[addon:lower()])
		self.lmAddons[addon:lower()] = nil
	end

	-- handle FramesResized changes
	if IsAddOnLoaded("FramesResized") then
		if addon == "Blizzard_TradeSkillUI" and self.FR_TradeSkillUI then self:checkAndRun("FR_TradeSkillUI") -- not an addon in its own right
		elseif addon == "Blizzard_TrainerUI" and self.FR_TrainerUI then self:checkAndRun("FR_TrainerUI") -- not an addon in its own right
		end
	end

	-- load library skins here as well, they may only get loaded by a LoD AddOn
	-- e.g. Dewdrop by ArkInventory when an AddonLoader is used
	for k, v in pairs(self.libsToSkin) do
		if LibStub(k, true) then
			if self[v] then self:checkAndRun(v) end
		end
	end

end

function aObj:ADDON_LOADED(event, addon)
--	self:Debug("ADDON_LOADED: [%s]", addon)

	self:ScheduleTimer("LoDFrames", self.db.profile.Delay.LoDs, addon)

end

function aObj:AUCTION_HOUSE_SHOW()
--	self:Debug("AUCTION_HOUSE_SHOW")

	self:checkAndRun("AuctionUI") -- npc
	-- trigger these when AH loads otherwise errors occur
	self:checkAndRunAddOn("BtmScan")
	self:checkAndRunAddOn("AuctionFilterPlus")
	self:checkAndRunAddOn("Auctionator")

	self:UnregisterEvent("AUCTION_HOUSE_SHOW")

end

function aObj:TRADE_SKILL_SHOW()
--	self:Debug("TRADE_SKILL_SHOW")

	self:checkAndRun("TradeSkillUI") -- player
	-- trigger this when TradeSkill loads otherwise it doesn't get loaded
	self:checkAndRunAddOn("MrTrader_SkillWindow")
	self:checkAndRunAddOn("ReagentMaker")

	self:UnregisterEvent("TRADE_SKILL_SHOW")

end
