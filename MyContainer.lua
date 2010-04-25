--[[
	Class: Container
		Serves as a base for all containers/bags

	attributes:
		.implementation - The parent implementation
		.buttons - indexed table of all contained buttons
	callbacks:
		:OnCreate(...) - called when a container is created, arguments passed from :New(name, ...)
		:OnContentsChanged() - called when a button is added or removed, mostly used to update the layout
		:OnBagUpdate(bagID, slotID) - called every BAG_UPDATE
		:OnButtonAdd(button) - called when a button is added to this container
		:OnButtonRemove(button) - called when a button is removed from this container
]]

-- Fetch our implementation
local Simplicity = cargBags:GetImplementation("Simplicity")

-- Fetch our container prototype that serves as a basis for all our containers/bags
local MyContainer = Simplicity:GetContainerPrototype()

-- OnContentsChanged executes every time the layout needs to be changed
function MyContainer:OnContentsChanged()

	-- Tell cargBags to sort our buttons based on the slotID
	-- you can overwrite this with your own function, see cargBags/mixins/sort.lua
	self:SortButtons("bagSlot")

	-- Order the buttons in a layout, as SortButtons optional, see cargBags/mixins/layout.lua
	-- args: type
	--		"grid" : columns, spacing, xOffset, yOffset
	--		"circle" : radius (optional), xOffset, yOffset
	local width, height = self:LayoutButtons("grid", self.Settings.Columns, 5, 10, -36)

	-- Update our size, reserve space for infobar at top
	self:SetSize(width + 20, height + 46)
end

function MyContainer:OnBagUpdate(bagID, slotID)
	-- Temporary placement for the space-updating until plugins are integrated
	local free, total = 0, 0
	for bagID=0, 4 do
		total = total + GetContainerNumSlots(bagID)
		free = free + GetContainerNumFreeSlots(bagID)
	end
	self.Space:SetFormattedText("%d/%d free", free, total)
end

-- OnCreate is called every time a new container is created (you guessed that, right?)
-- The 'settings'-variable is solely passed from the :New()-function and thus independent from the cargBags-core
function MyContainer:OnCreate(settings)
	self.Settings = settings

	self:EnableMouse(true)

	self:SetBackdrop{
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4},
	}
	self:SetBackdropColor(0, 0, 0, 0.8)
	self:SetBackdropBorderColor(0, 0, 0, 0.5)

	self:SetParent(settings.Parent or Simplicity)
	self:SetFrameStrata("HIGH")

	if(settings.Movable) then
		self:SetMovable(true)
		self:RegisterForClicks("LeftButton", "RightButton");
	    self:SetScript("OnMouseDown", function() 
	        if(IsAltKeyDown()) then 
	            self:ClearAllPoints() 
	            self:StartMoving() 
	        end 
	    end)
	    self:SetScript("OnMouseUp",  self.StopMovingOrSizing)
	end

	settings.Columns = settings.Columns or 8
	self:SetScale(settings.Scale or 1)

	-- The plugin code here is all temporary, until I've implemented the plugin-system into cB 2.0

	local infoFrame = CreateFrame("Button", nil, self)
	infoFrame:SetPoint("TOPLEFT", 10, -3)
	infoFrame:SetPoint("TOPRIGHT", -10, -3)
	infoFrame:SetHeight(32)

	local space = infoFrame:CreateFontString(nil, "OVERLAY")
	space:SetFont("Interface\\AddOns\\cargBags_Simplicity\\media\\cambriai.ttf", 16)
	space:SetPoint("LEFT", infoFrame, "LEFT")
	space:SetText("99/99 free")
	self.Space = space

	-- Plugin: Money
	-- Creates a standard Money-display
	-- We parent it to the infoFrame, because of the toggleable search bar below!
	local money = self:SpawnPlugin("Money")
	money:SetParent(infoFrame)
	money:SetPoint("RIGHT")

	-- Plugin: SearchBar
	-- If we specify a frame as an optional arg #2, then this frame
	-- shows the search on click at its own place
	local search = self:SpawnPlugin("SearchBar", infoFrame)

	return self
end