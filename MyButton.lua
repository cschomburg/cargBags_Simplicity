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