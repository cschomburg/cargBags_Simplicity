--[[
	Class: ItemButton
		Serves as a base for all item buttons (surprise, surprise)

	attributes:
		.implementation
		.bagID
		.slotID
	child regions:
		.Icon
		.Count
		.Cooldown
		.Quest
		.Glow
	overwritable functions:
		:Update(item) - sets icon, count, glow, quest, etc
		:UpdateCooldown(item)
		:UpdateLock(item)
	callbacks:
		:OnCreate(template) - called when the button is created
		:OnUpdate(item) - called when the button is updated
		:OnUpdateCooldown(item) - called when the button's cooldown is updated
		:OnUpdateLock(item) - called when the button's lock is updated
		:OnAdd(container) - called when the button is added to a container
		:OnRemove(container) - called when the button is removed from a container
]]

local Simplicity = cargBags:GetImplementation("Simplicity")

-- And our ItemButton-prototype
local MyButton = Simplicity:GetItemButtonPrototype()

--[[
	Rather empty here, isn't it?

	You could define these functions:
		:OnCreate(template) - called when the button is created

		:OnUpdate(item) - called when the button is updated (you can also overwrite the whole :Update(item)-function if you want to
		:OnUpdateCooldown(item) - same for cooldowns
		:OnUpdateLock(item) - same for item lock changes

		:OnAdd(container) -- called when the button is added to a container
		:OnRemove(container) -- called when the button is removed from a container
]]