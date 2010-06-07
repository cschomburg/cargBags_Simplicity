local Simplicity = cargBags:GetImplementation("Simplicity")

local BagButton = Simplicity:GetClass("BagButton", true, "BagButton")

function BagButton:OnCreate()
	self:GetCheckedTexture():SetVertexColor(1, 0.8, 0, 0.8)
end
