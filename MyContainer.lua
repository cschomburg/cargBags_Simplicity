--[[
	Class: Container
		Serves as a base for all containers/bags

	Attributes:
		.implementation - The parent implementation
		.buttons - indexed table of all contained ItemButtons

	Functions:
		:ScheduleContentCallback() - Update the layout on the next OnUpdate
		:ApplyToButtons(func, ...) - Apply this function to all buttons, calling func(button, ...)

	Callbacks:
		:OnCreate(...) - called when a container is created, arguments passed from :New(name, ...)
		:OnContentsChanged() - called when a button is added or removed, mostly used to update the layout
		:OnBagUpdate(bagID, slotID) - called every BAG_UPDATE
		:OnButtonAdd(button) - called when a button is added to this container
		:OnButtonRemove(button) - called when a button is removed from this container
]]

-- Fetch our implementation
local Simplicity = cargBags:GetImplementation("Simplicity")

-- Fetch our container class that serves as a basis for all our containers/bags
local MyContainer = Simplicity:GetContainerClass()

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

-- A highlight function styles the button if they match a certain condition
-- e.g. searching for buttons / hovering the BagBar for a specific bag
local function highlightFunction(button, match)
	button:SetAlpha(match and 1 or 0.1)
end

-- OnCreate is called every time a new container is created (you guessed that, right?)
-- The 'settings'-variable is solely passed from your :New()-function and thus independent from the cargBags-core
function MyContainer:OnCreate(name, settings)
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
	    	self:ClearAllPoints() 
			self:StartMoving() 
	    end)
		self:SetScript("OnMouseUp",  self.StopMovingOrSizing)
	end

	settings.Columns = settings.Columns or 8
	self:SetScale(settings.Scale or 1)

	-- Our infoFrame serves as a basic bar for information (yeah, right ...)
	-- It will toggle the searchbar on click, see below

	local infoFrame = CreateFrame("Button", nil, self)
	infoFrame:SetPoint("TOPLEFT", 10, -3)
	infoFrame:SetPoint("TOPRIGHT", -10, -3)
	infoFrame:SetHeight(32)

	-- Plugin: TagDisplay
	-- Creates a font string which is fomatted according to different tags
	-- Possible: [currencies], [currency:id] [money], [item:name], [item:id], [shards], [ammo], [space:free/max/used]
	-- You can provide your own tags in tagDisplay.tags[tagName] = function(self, arg1) end
	local space = self:SpawnPlugin("TagDisplay", "[space:free/max] free", infoFrame)
	space:SetFont("Interface\\AddOns\\cargBags_Simplicity\\media\\cambriai.ttf", 16) -- Yay, custom font
	space:SetPoint("LEFT", infoFrame, "LEFT")
	space.bags = cargBags:ParseBags(settings.Bags) -- Temporary until I find a better solution

	-- This one shows currencies, ammo and - most important - money!
	local tagDisplay = self:SpawnPlugin("TagDisplay", "[currencies] [ammo] [money]", infoFrame)
	tagDisplay:SetFontObject("NumberFontNormal")
	tagDisplay:SetPoint("RIGHT", infoFrame, "RIGHT", -10, 0)

	-- Plugin: BagBar
	-- Creates a collection of buttons for your bags
	-- The buttons can be positioned with the same :LayoutButtons() as the above ItemButtons (don't forget to update size!)
	-- You want to style the buttons? No problem! Fetch their class via Implementation:GetBagButtonClass()!
	local bagBar = self:SpawnPlugin("BagBar", settings.Bags)
	bagBar:SetSize(bagBar:LayoutButtons("grid", 10))
	bagBar:SetScale(0.75)
	bagBar.highlightFunction = highlightFunction -- from above, optional, used when hovering over bag buttons
	bagBar.isGlobal = nil -- This would make the hover-effect apply to all containers instead of the current one
	bagBar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 15, -4)

	-- Plugin: SearchBar
	-- If we specify a frame as an optional arg #2, then this frame
	-- shows the search onClick at its own place
	local search = self:SpawnPlugin("SearchBar", infoFrame)
	search.highlightFunction = highlightFunction -- same as above, only for search
	search.isGlobal = nil -- This would make the search apply to all containers instead of just this one
end
