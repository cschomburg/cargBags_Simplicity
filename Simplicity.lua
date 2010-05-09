--[[
	Class: Implementation
		Serves as the core for your cargBags layout

	attributes:
		.contByID - indexed table of all containers
		.contByName - containers by name
		.buttons - bagSlot-indexed table of all buttons
		.isOpen - boolean whether the implementation is currently open
		.atBank - boolean whether the user currently uses the bank
	functions:
		container = :GetContainer(name) - fetches a container by its name (wrapper for .contByName)
		protoContainer = :GetContainerPrototype() - fetches the Container prototype (basis for all Containers)
		protoButton = :GetItemButtonPrototype() - fetches the ItemButton prototype (basis for all ItemButtons)
		:RegisterBlizzard() - Overwrite Blizzard functions for toggling bags
		:GetButton(bagID, slotID) - Gets a button from the storage
	callbacks:
		:OnInit(...) - called when the implementation is opened the first time
		:OnOpen() - called when it is shown
		:OnClose() - called when it is hidden
]]

local Simplicity = cargBags:NewImplementation("Simplicity")	-- Let the magic begin!
Simplicity:RegisterBlizzard() -- This registers the frame for use with BLizzard's ToggleBag()-functions

-- This function is called when the implementation inits,
-- normally this happens on the first opening of the containers.
function Simplicity:OnInit()

	-- The filters control which items go into which container
	local INVERTED = -1 -- with inverted filters (using -1), everything goes into this bag when the filter returns false

	local onlyBags =		function(item) return item.bagID >= 0 and item.bagID <= 4 end
	local onlyKeyring =		function(item) return item.bagID == -2 end
	local onlyBank =		function(item) return item.bagID == -1 or item.bagID >= 5 and item.bagID <= 11 end
	local onlyRareEpics =	function(item) return item.rarity and item.rarity > 3 end
	local onlyEpics =		function(item) return item.rarity and item.rarity > 3 end
	local hideJunk =		function(item) return not item.rarity or item.rarity > 0 end
	local hideEmpty =		function(item) return item.texture ~= nil end

	local MyContainer = Simplicity:GetContainerPrototype() -- This fetches our container prototype, it is styled in MyContainer.lua

	-- The settings-table passed in the :New() function is defined by the layout and fully optional, see MyContainer.lua

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
end

-- Main bag will be toggled automatically on opening,
-- but the bank frame needs special treatment
function Simplicity:OnOpen()
	if(self.atBank) then
		self:GetContainer("Bank"):Show()
	end
end

function Simplicity:OnClose()
	self:GetContainer("Bank"):Hide()
end
