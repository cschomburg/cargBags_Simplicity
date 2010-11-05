--[[
	Advanced users:
		If you like, you can embed the cargBags2-framework in your Implementation,
		serving as your personal bag-addon. This enables you to remove
		unneeded core-plugins/mixins, but could be more complicated.

	Class: Implementation
		Serves as the core for your cargBags layout.

	Attributes:
		.contByID - indexed table of all containers
		.contByName - containers by name, but the preferred way is to use :GetContainer(name)
		.buttons - bagSlot-indexed table of all buttons - see cargBags/base/core.lua @ cargBags:ToBagSlot(bagID, slotID)

	Functions:
		container = :GetContainer(name) - fetches a container by its name (wrapper for .contByName)
		Container = :GetContainerClass(name) - fetches a Container class by name or the default one (basis for all Containers)
		Button = :GetItemButtonClass() - fetches the ItemButton class (basis for all ItemButtons)
		:SetDefaultItemButtonClass(name) - you only need this if you have multiple ItemButton-classes
		:RegisterBlizzard() - Overwrite Blizzard functions for toggling bags
		:RegisterCallback(event, key, func) - The preferred way to handle events for plugins, they will be called func(key)
		:GetButton(bagID, slotID) - Gets a button from the storage
		:AtBank() - Returns whether the bank data is available
		item = :GetItemInfo(bagID, slotID) - Fetches all available information for one item into a table

	Callbacks:
		:OnInit(...) - called when the implementation is opened the first time, spawn your bags here
		:OnOpen() - called when it is shown
		:OnClose() - called when it is hidden
		:OnBankOpened() - called when the user visits a bank, good for toggling bank frame
		:OnBankClosed() - called when the user finished visiting the bank
]]

local addon, ns = ...
local Simplicity = ns.cargBags:Setup("Simplicity")
Simplicity:ReplaceBlizzard(true)

-- This function is called when the implementation inits,
-- normally this happens on the first opening of the containers.
function Simplicity:OnInit()
	self:SetSource("Default")
	self:SetSieve("Filters")

	-- The filters control which items go into which container
	local INVERTED = -1 -- with inverted filters (using -1), everything goes into this bag when the filter returns false

	local onlyBags =		function(item) return item.bagID >= 0 and item.bagID <= 4 end
	local onlyKeyring =		function(item) return item.bagID == -2 end
	local onlyBank =		function(item) return item.bagID == -1 or item.bagID >= 5 and item.bagID <= 11 end
	local onlyRareEpics =	function(item) return item.rarity and item.rarity > 3 end
	local onlyEpics =		function(item) return item.rarity and item.rarity > 3 end
	local hideJunk =		function(item) return not item.rarity or item.rarity > 0 end
	local hideEmpty =		function(item) return item.texture ~= nil end

	-- This fetches our container classes, it is styled in MyContainer.lua
	-- You can also create multiple prototypes by providing a name as arg #2, (no name actually means "", default)
	-- e.g. one for Bank/Bags with plugins and one simple one for additional bags/keyring
	local MyContainer = self:GetClass("Container")

	-- The settings-table passed in the :New() function is defined by your layout and fully optional, see MyContainer.lua

	-- Bagpack
	local main = MyContainer:New("Main", {
			Columns = 8,
			Scale = 1,
			Bags = "backpack+bags",
		})
		main:SetFilter(onlyBags, true) -- Take only items from the main bags
		main:SetPoint("RIGHT", -5, 0) -- Place at right side of UI

	-- Bank frame and bank bags
	local bank = MyContainer:New("Bank", {
			Columns = 12,
			Scale = 1,
			Bags = "bankframe+bank",
		})
		bank:SetFilter(onlyBank, true) -- Take only items from the bank frame
		bank:SetPoint("LEFT", 5, 0) -- Place at left side of UI
		bank:Hide() -- Hide at the beginning
		self.bank = bank -- We need to toggle it later, so store it

	--[[
		PRO TIP: Extended Filters
			If you have a lot of categories, you may can avoid writing
			lots of additional filter functions by passing an argument to them.

			Define a filter like
				local byType = function(item, myType) return item.type == myType

			And then use it:
				WeaponContainer:SetExtendedFilter(byType, "Weapon")
				ConsumablesContainer:SetExtendedFilter(byType, "Consumables")
	]]

	--[[
		PRO TIP: Simple Bags Sieve
			You are just sorting the items into different bags and
			dont't make real use of the filtering system?

			Visit http://github.com/xconstruct/cargBags/wiki/Sieve-Bags
			on information how to enable it, so you can use:
				Container:SetBags("backpack+bags")
				Container:SetBags("0-4")
	]]
end

-- Main bag will be toggled automatically at opening (actually it's always shown)
-- because it just follows the state of the Implementation
-- but the bank frame needs special treatment
function Simplicity:OnGroupState(group, state)
	if(group == "bank") then
		if(state) then
			self:Open()
			self.bank:Show()
		else
			self:Close()
			self.bank:Hide()
		end
	end
end
