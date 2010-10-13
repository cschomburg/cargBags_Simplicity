--[[
	This file extends the layout, but is not mandatory for your own.

	It adds a button to the container where the user
	can toggle between different 'filter modes'.

	It gives a good introduction into various aspects of cargBags:
	- Extended Filters and FilterSets
	- Writing own plugins
	- Locale table
]]

local addon, ns = ...
local cargBags = ns.cargBags

local FilterSet = cargBags.Class:Get("FilterSet")
local L = cargBags:GetLocalizedTypes()

--[[
	Filters
		We need them in our FilterSets
		Note the second argument on 'byType'
]]

local function byType(item, type) return item.type == type end
local function onlyJunk(item) return item.rarity == 0 end
local function onlyBoE(item) return item.bindOn == "equip" end
local function onlyCombatItems(item)
	return item.type == L.Consumable
		or (item.type == L.Weapon and item.subType ~= L['Fishing Poles'])
		or item.subType == L.Explosives
		or item.subType == L.Devices
		or (item.isQuestItem and item.isActive)
end

--[[
	Modes
		The user can toggle these in the dropdown
		They are FilterSets, containing one or more filters

		FilterSets have functions like :Set(filter, flag) or :SetExtended(filter, arg)
		and can be chained together via :Chain(filterSet, flag)
		Containers use them in the background
]]

local modes = {}

local noFilter = FilterSet:New()
noFilter.name = "No Filter"
table.insert(modes, noFilter)

local consumables = FilterSet:New()
consumables.name = "Consumables"
consumables:SetExtended(byType, L.Consumable)
table.insert(modes, consumables)

local armor = FilterSet:New()
armor.name = "Armor"
armor:SetExtended(byType, L.Armor)
table.insert(modes, armor)

local weapons = FilterSet:New()
weapons.name = "Weapons"
weapons:SetExtended(byType, L.Weapon)
table.insert(modes, weapons)

local junk = FilterSet:New()
junk.name = "Junk"
junk:Set(onlyJunk, true)
table.insert(modes, junk)

local boe = FilterSet:New()
boe.name = "BoE Items"
boe:Set(onlyBoE, true)
table.insert(modes, boe)

local combatItems = FilterSet:New()
combatItems.name = "Combat Items"
combatItems:Set(onlyCombatItems, true)
table.insert(modes, combatItems)

modes.default = noFilter

--[[
	DropDown
]]

local dropdown, currentButton, currentSet

-- Set a special mode when a dropdown entry was clicked
local function DropDownEntry_OnClick(self)
	UIDropDownMenu_SetSelectedValue(dropdown, self.value)
	currentButton:SetMode(self.value)
end

-- Updates the entries of the dropdown
local function DropDown_Update(self)
	local info = {}
	info.func = DropDownEntry_OnClick

	for i, set in ipairs(modes) do
		local selectedValue = UIDropDownMenu_GetSelectedValue(self)
		info.text = set.name
		info.value = set
		info.checked = (set == selectedValue)

		UIDropDownMenu_AddButton(info)
	end
end

-- When the 'Modes'-Button was clicked,
-- open the dropdown
local function Button_OnClick(self)
	if(not dropdown) then
		dropdown = CreateFrame("Frame", addon.."ModeSelect", UIParent, "UIDropDownMenuTemplate")
		dropdown:SetID(1)
		UIDropDownMenu_Initialize(dropdown, DropDown_Update, "MENU")
		UIDropDownMenu_SetSelectedValue(dropdown, "Default")
		UIDropDownMenu_SetWidth(dropdown, 90)
	end

	-- We need this to find the right container later
	currentButton = self

	-- Position the dropdown and toggle it
	local y = self:GetBottom() >= GetScreenHeight()/2 and "TOP" or "BOTTOM"
	local x = self:GetRight() >= GetScreenWidth()/2 and "LEFT" or "RIGHT"
	ToggleDropDownMenu(1, nil, dropdown, self, 0, 0)
end

function Button_SetMode(self, arg1)
	local set = arg1

	-- If arg1 is a string, select by name
	if(type(arg1) == "string") then
		for i, mode in ipairs(modes) do
			if(mode.name == arg1) then
				set = mode
			end
		end
	end
	if(not arg1.__index == FilterSet) then return end

	-- Clear the previous set
	if(currentSet) then
		self.container:ChainFilters(currentSet, nil)
	end

	-- Set the new one
	currentSet = set
	self.container:ChainFilters(currentSet, true)


	cargBags:UpdateAll()
end

--[[
	Registering the Plugin
		We register our ModeButton by providing
		a Spawn-function which returns the plugin
]]

cargBags:Register("plugin", "FilterDropDown", function(self)
	local button = CreateFrame("Button", nil, self)
	button.container = self

	button:SetBackdrop{
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4},
	}
	button:SetBackdropColor(0, 0, 0, 0.8)
	button:SetBackdropBorderColor(0, 0, 0, 0.5)
	button:SetNormalFontObject(GameFontHighlightSmall)
	button:SetHighlightFontObject(GameFontNormalSmall)
	button:SetText("M")
	button:SetHeight(24)
	button:SetWidth(24)
	button:SetAlpha(0.8)
	button:SetScript("OnClick", Button_OnClick)

	button.SetMode = Button_SetMode

	return button
end)
