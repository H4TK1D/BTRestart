local Setup = {}

local modConfigMenu = require("scripts/modConfig")

function Setup.Run()
	if modConfigMenu.Check() then
		--Preload data if it exists or
		modConfigMenu.registerSettings()
	end
end

return Setup
