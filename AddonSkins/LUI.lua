local aName, aObj = ...
if not aObj:isAddonEnabled("LUI") then return end
local _G = _G

-- The following code handles the Initial setup of Skinner when the LUI is loaded
aObj.otherAddons.LUIInit = function(self) -- v 3.35

	self:RawHook(self, "OnInitialize", function(this)
		-- Do these before we run the function

		-- setup the default DB values and register them
		self:checkAndRun("SetupDefaults", "opt", false, true)
		self.Defaults = nil -- only need to run this once

		-- check to see if there is already a. profile called LUI, if so we'll use it
		for _, prof in _G.pairs(self.db:GetProfiles(_G[aName .. "DB"])) do
			if prof == "LUI" then
				self.db:SetProfile(prof)
				break
			end
		end
		
		-- create and use a new db profile called LUI
		local dbProfile = self.db:GetCurrentProfile()
		if dbProfile ~= "LUI" then
			self.db:SetProfile("LUI") -- create new profile
			self.db:CopyProfile(dbProfile) -- use settings from previous profile

			-- change settings
            self.db.profile.DropDownButtons = false
            self.db.profile.TexturedTab = false
            self.db.profile.TexturedDD = false
            self.db.profile.TooltipBorder  = {r = 0.3, g = 0.3, b = 0.3, a = 1}
            self.db.profile.BackdropBorder = {r = 0.2, g = 0.2, b = 0.2, a = 1}
            self.db.profile.Backdrop       = {r = 0.18, g = 0.18, b = 0.18, a = 1}
			self.db.profile.BdDefault = false
			self.db.profile.BdFile = "None"
			self.db.profile.BdEdgeFile = "None"
			self.db.profile.BdTexture = "Blizzard Tooltip"
			self.db.profile.BdBorderTexture = "Stripped_medium"
			self.db.profile.BdTileSize = 0
			self.db.profile.BdEdgeSize = 5
			self.db.profile.BdInset = 3
			self.db.profile.Gradient = {enable = false, invert = false, rotate = false, char = true, ui = true, npc = true, skinner = true, texture = "Blizzard Tooltip"}
			self.db.profile.Buffs = false
			self.db.profile.Nameplates = false
			self.db.profile.ChatEditBox = {skin = false, style = 1}
			self.db.profile.StatusBar = {texture = "LUI_Minimalist", r = 0, g = 0.5, b = 0.5, a = 0.5}
			self.db.profile.WorldMap = {skin = false, size = 1}
			self.db.profile.Minimap = {skin = false, gloss = false}
		end

		-- run the function
		self.hooks[this].OnInitialize(this)

		-- Now do this after we have run the function
		-- setup backdrop(s)
		for i, _ in _G.ipairs(self.Backdrop) do
			self.Backdrop[i] = self.backdrop
		end

		self:Unhook(self, "OnInitialize")

	end)

end

-- Load support for LUI
local success, err = _G.xpcall(function() return aObj.otherAddons.LUIInit(aObj) end, _G.geterrorhandler())
if not success then
	aObj:CustomPrint(1, 0, 0, "Error running LUIInit")
end
