--[[
	Class: ItemButton
		Serves as a base for all item buttons (surprise, surprise)

	Attributes:
		.implementation
		.bagID
		.slotID
		.glowTex - texture used for glow
		.glowAlpha - alpha of glowTexture
		.glowBlend - blend mode of glow texture
		.glowCoords - table of texCoords
		.bgTex - background texture (used when slot is empty)

	Child widgets:
		.Icon
		.Count
		.Cooldown
		.Quest
		.Glow

	Functions:
		item = :GetItemInfo() - fetches item information

	Overwritable Functions:
		:Update(item) - sets icon, count, glow, quest, etc
		:UpdateCooldown(item)
		:UpdateLock(item)

	Callbacks:
		:OnCreate(template) - called when the button is created
		:OnUpdate(item) - called when the button is updated
		:OnUpdateCooldown(item) - called when the button's cooldown is updated
		:OnUpdateLock(item) - called when the button's lock is updated
		:OnAdd(container) - called when the button is added to a container
		:OnRemove(container) - called when the button is removed from a container

	Did you know?
		You can create fake ItemButtons which are not used by cargBags by using
		ItemButton:Create("ItemButtonTemplate"). These could come in handy if you
		want to hide all empty slots, but maybe still need a drop-target.
]]

local Simplicity = cargBags:GetImplementation("Simplicity")

-- And our ItemButton-class
local MyButton = Simplicity:GetButtonClass()

-- Yep, we don't do much here, it's just for reference
-- so that YOU can extend on it!
