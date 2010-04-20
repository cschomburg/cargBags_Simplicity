--[[
	This file serves as the core of your own cargBags implementation.
	From here you can control container-spawning and similar things.

	The implementation is a button with the dimensions of UIParent and
	it will be opened and closed by cargBags. It is therefore recommended
	that you parent all your containers to this frame, so that they are shown
	automatically.
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
		})
		main:SetFilter(onlyBags, true) -- Take only items from the main bags
		main:SetPoint("RIGHT", -5, 0) -- Place at right side of UI

	-- Bank frame and bank bags
	local bank = MyContainer:New("Bank", {
			Columns = 12,
			Scale = 1,
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