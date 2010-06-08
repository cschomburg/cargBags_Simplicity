--[[
	The BagButton-class is the template for all buttons on the BagBar, fully optional of course.
	Styling works similar to the ItemButtons:
	you fetch it and then define member functions.

	Attributes:
		.checkedTex			Holds the highlight-texture when checked
		.bgTex				Holds the background texture
		.itemFadeAlpha		Controls how much the items should be faded
		.HighlightFunction	Controls how the itemButtons should be styled when hovering over the bag default: fade)

	Child widgets:
		.Icon				the IconTexture
		.Count				the Count-FontString
		.Cooldown			the Cooldown-Frame
		.Quest				the Quest-border
		.Border				the normal border

	Callbacks:
		:OnCreate(bagID)	called when the button was created
		:OnUpdate()			called when the button was updated
]]
local Simplicity = cargBags:GetImplementation("Simplicity")

local BagButton = Simplicity:GetClass("BagButton", true, "BagButton")

-- We color the CheckedTexture golden, not bright yellow
function BagButton:OnCreate()
	self:GetCheckedTexture():SetVertexColor(1, 0.8, 0, 0.8)
end
