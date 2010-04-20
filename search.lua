--NOTE: move this into own plugin

local Simplicity = cargBags:GetImplementation("Simplicity")

local sText = {}
local filters = {
	n = function(i) return i.name and i.name:lower():match(sText.n) end,
	t = function(i) return (i.type and i.type:lower():match(sText.t)) or (i.subType and i.subType:lower():match(sText.t)) or (i.equipLoc and i.equipLoc:lower():match(sText.t)) end,
	b = function(i) return i.bindOn and i.bindOn:match(sText.b) end,
	q = function(i) return i.rarity == tonumber(sText.q) end,
	bag = function(i) return i.bagID == tonumber(sText.bag) end,
}

local function doSearch(search)
	local self = search.object

	for k,v in pairs(filters) do self.filters[v] = nil end

	local text = search:GetText():trim()

	for match in text:gmatch("[^,;&]+") do
		local mod, type, value = match:match("^(!?)(.-)[:=]?([^:=]*)$")
		mod = (mod == "!" and -1 or true)
		if(value and type ~= "" and filters[type]) then
			sText[type] = value:lower()
			self.filters[filters[type]] = mod
		elseif(value and type == "") then
			sText.n = value:lower()
			self.filters[filters.n] = mod
		end
	end
	Simplicity:BAG_UPDATE()
end

local function openSearch(target)
	target:Hide()
	target.search:Show()
end

local function closeSearch(search)
	search.target:Show()
	search:Hide()
end

local function clearSearch(search)
	search:SetText("")
	doSearch(search)
	closeSearch(search)
end

local function saveSearch(search)
	search:ClearFocus()
end

function Simplicity:SetupSearch(container, target)
	local search = CreateFrame("EditBox", nil, container)
	search:SetFontObject(GameFontHighlight)
	search:SetAutoFocus(true)
	search:SetAllPoints(target)
	search:Hide()
	container.Search = search

	local left = search:CreateTexture(nil, "BACKGROUND")
	left:SetTexture("Interface\\Common\\Common-Input-Border")
	left:SetTexCoord(0, 0.0625, 0, 0.625)
	left:SetWidth(8)
	left:SetHeight(20)
	left:SetPoint("LEFT", -5, 0)

	local right = search:CreateTexture(nil, "BACKGROUND")
	right:SetTexture("Interface\\Common\\Common-Input-Border")
	right:SetTexCoord(0.9375, 1, 0, 0.625)
	right:SetWidth(8)
	right:SetHeight(20)
	right:SetPoint("RIGHT", 0, 0)

	local center = search:CreateTexture(nil, "BACKGROUND")
	center:SetTexture("Interface\\Common\\Common-Input-Border")
	center:SetTexCoord(0.0625, 0.9375, 0, 0.625)
	center:SetHeight(20)
	center:SetPoint("RIGHT", right, "LEFT", 0, 0)
	center:SetPoint("LEFT", left, "RIGHT", 0, 0)

	target.search, search.target, search.object = search, target, container
	target:RegisterForClicks("anyUp")
	target:SetScript("OnClick", openSearch)
	search:SetScript("OnTextChanged", doSearch)
	search:SetScript("OnEscapePressed", clearSearch)
	search:SetScript("OnEnterPressed", closeSearch)
	search:SetScript("OnEditFocusLost", closeSearch)
end