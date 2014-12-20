--[[
	Class: ItemButton
		Serves as a base for all item buttons (surprise, surprise)

	Attributes:
		.implementation
		.bagID
		.slotID

		"Default" scaffold ones:
			.glowTex - texture used for glow
			.glowAlpha - alpha of glowTexture
			.glowBlend - blend mode of glow texture
			.glowCoords - table of texCoords
			.bgTex - background texture (used when slot is empty)

		Child widgets of "Default" scaffold:
			.icon
			.Count
			.Cooldown
			.Quest
			.Glow

	Functions:
		item = :GetItemInfo() - fetches item information

	Callbacks:
		:OnCreate(template) - called when the button is created
		:OnAdd(container) - called when the button is added to a container
		:OnRemove(container) - called when the button is removed from a container

		:Update(item) OR :OnUpdate(item)
		:UpdateCooldown(item) OR :OnUpdateCooldown(item)
		:UpdateLock(item) OR :OnUpdateLock(item)

	Did you know?
		You can create fake ItemButtons which are not used by cargBags by using
		ItemButton:Create("ItemButtonTemplate"). These could come in handy if you
		want to hide all empty slots, but maybe still need a drop-target.
]]

-- And our ItemButton-class
local MyButton = Simplicity:GetClass("ItemButton")

-- Setting a Scaffold, they provide default functions for updating fontstrings/icons
-- e.g. the scaffold implements ItemButton:Update() and takes over most updating
-- and you can use ItemButton:OnUpdate() for the rest
-- If you don't use a scaffold, you have to write your own ItemButton:Update() function
MyButton:Scaffold("Default") -- we use the default one

function MyButton:OnUpdate(item)
	-- fade empty slots
	self.Border:SetAlpha(item.texture and 1 or 0.3)
end

-- Yep, we don't do much here, it's just for reference
-- so that YOU can extend on it!
