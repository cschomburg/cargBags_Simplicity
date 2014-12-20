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
		.icon				the IconTexture
		.Count				the Count-FontString
		.Cooldown			the Cooldown-Frame
		.Quest				the Quest-border
		.Border				the normal border

	Callbacks:
		:OnCreate(bagID)	called when the button was created
		:OnUpdate()			called when the button was updated
]]

local BagButton = Simplicity:GetClass("BagButton")

local visPercent = 0.5 -- we want to hide a part of the button

function BagButton:OnCreate()
	-- We color the CheckedTexture golden, not bright yellow
	self:GetCheckedTexture():SetVertexColor(1, 0.8, 0, 0.6)

	-- now update height / texture coords based on the visible part
	self:SetHeight(visPercent * 37)
	self.Border:SetHeight(visPercent * 64)
	self.Border:SetPoint("CENTER", 0, visPercent*64/4)

	self:GetCheckedTexture():SetTexCoord(0, 1, 0, visPercent)
	self:GetPushedTexture():SetTexCoord(0, 1, 0, visPercent)
end

function BagButton:OnUpdate()
	-- moving behind container frame
	self:SetFrameLevel(self.bar:GetFrameLevel() - 3)

	-- again clip textures in case they were updated
	self:GetNormalTexture():SetTexCoord(0, 1, 0, visPercent)
	self.Border:SetTexCoord(0, 1, 0, visPercent)
	self.icon:SetTexCoord(0, 1, 0, visPercent)
end
