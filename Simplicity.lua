local Simplicity = cargBags:NewImplementation("Simplicity")
Simplicity:RegisterBlizzard()

function Simplicity:OnInit()

	local INVERTED = -1 -- with inverted filters (using -1), everything goes into this bag when the filter returns false

	local onlyBags =		function(item) return item.bagID >= 0 and item.bagID <= 4 end
	local onlyKeyring =		function(item) return item.bagID == -2 end
	local onlyBank =		function(item) return item.bagID == -1 or item.bagID >= 5 and item.bagID <= 11 end
	local onlyRareEpics =	function(item) return item.rarity and item.rarity > 3 end
	local onlyEpics =		function(item) return item.rarity and item.rarity > 3 end
	local hideJunk =		function(item) return not item.rarity or item.rarity > 0 end
	local hideEmpty =		function(item) return item.texture ~= nil end

	local MyContainer = Simplicity:GetContainerPrototype()

	-- Bagpack and bags
	local main = MyContainer:New("Main", {
			Columns = 8,
			Scale = 1,
		})
		main:SetFilter(onlyBags, true)
		main:SetPoint("RIGHT", -5, 0)

	-- Bank frame and bank bags
	local bank = MyContainer:New("Bank", {
			Columns = 12,
			Scale = 1,
		})
		bank:SetFilter(onlyBank, true)
		bank:SetPoint("LEFT", 5, 0)
		bank:Hide()
end

function Simplicity:OnOpen()
	if(self.atBank) then
		self:GetContainer("Bank"):Show()
	end
end

function Simplicity:OnClose()
	self:GetContainer("Bank"):Hide()
end