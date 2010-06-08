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
	        if(IsAltKeyDown()) then 
	            self:ClearAllPoints() 
	            self:StartMoving() 
	        end 
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

	-- Plugin: SpaceText
	-- Creates a space-fontstring - it's an extension of :SpawnPlugin("Space", frame, bags) which transforms a frame into a space-updater
	-- You can overwrite the update-routine with :UpdateSpace(free, max) or use the callback :OnUpdateSpace(free, max)
	-- The settings.Bags thing just holds the bags which are included in the count, see Simplicity.lua
	local space = self:SpawnPlugin("SpaceText", "[free]/[max] free", settings.Bags, infoFrame)
	space:SetFont("Interface\\AddOns\\cargBags_Simplicity\\media\\cambriai.ttf", 16)
	space:SetPoint("LEFT", infoFrame, "LEFT")

	-- Plugin: TagDisplay
	-- Creates a font string which is fomatted according to different tags
	-- Possible: [currencies], [currency:id] [money], [item:name], [item:id], [shards], [ammo], [space:free/max/used]
	-- You can provide your own tags in tagDisplay.tags[tagName] = function(self, arg1) end
	local tagDisplay = self:SpawnPlugin("TagDisplay", "[currencies] [ammo] [money]", infoFrame, nil, "NumberFontNormal")
	tagDisplay:SetPoint("RIGHT", infoFrame, "RIGHT", -10, 0)

	-- Plugin: BagBar
	-- Creates a collection of buttons for your bags
	-- The buttons can be positioned with the same :LayoutButtons() as the above ItemButtons (don't forget to update size!)
	-- You want to style the buttons? No problem! Fetch their prototype via Implementation:GetClass("BagButton")!
	local bagBar = self:SpawnPlugin("BagBar", name == "Bank" and "bank" or "bags")
	bagBar:SetSize(bagBar:LayoutButtons("grid", 1))
	bagBar:SetScale(0.75)

	if(name == "Bank") then
		bagBar:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, -5)
	else
		bagBar:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, -5)
	end

	-- Plugin: SearchBar
	-- If we specify a frame as an optional arg #2, then this frame
	-- shows the search on click at its own place
	local search = self:SpawnPlugin("SearchBar", infoFrame)
	-- search.isGlobal = true -- This would make the search apply to all containers instead of just this one

	-- if a highlight-function is provided, the items are styled as you define it
	-- otherwise they are hidden completely
	-- search.HighlightFunction = function(button, match)
	-- 	button:SetAlpha(match and 1 or 0.1)
	-- end
end
