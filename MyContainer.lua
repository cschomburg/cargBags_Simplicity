local Simplicity = cargBags:GetImplementation("Simplicity")

local MyContainer = Simplicity:GetContainerPrototype()

function MyContainer:OnUpdate()
	self:SortButtons("bagSlot")
	local width, height = self:LayoutButtons("grid", self.Settings.Columns, 5, 10, -36)

	self:SetSize(width + 20, height + 46)

	local free, total = 0, 0
	for bagID=0, 4 do
		total = total + GetContainerNumSlots(bagID)
		free = free + GetContainerNumFreeSlots(bagID)
	end
	self.Space:SetFormattedText("%d/%d free", free, total)
end

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



	local infoFrame = CreateFrame("Button", nil, self)
	infoFrame:SetPoint("TOPLEFT", 10, -3)
	infoFrame:SetPoint("TOPRIGHT", -10, -3)
	infoFrame:SetHeight(32)

	local space = infoFrame:CreateFontString(nil, "OVERLAY")
	space:SetFont("Interface\\AddOns\\cargBags_Simplicity\\media\\cambriai.ttf", 16)
	space:SetPoint("LEFT", infoFrame, "LEFT")
	space:SetText("99/99 free")
	self.Space = space

	local money = CreateFrame("Frame", "SimplicityMoney", infoFrame, "SmallMoneyFrameTemplate")
	money:SetPoint("RIGHT", infoFrame, "RIGHT")

	Simplicity:SetupSearch(self, infoFrame)

	return self
end