local modConfigMenu = {}

local Rooms = { "Treasure Room", "Library", "Planetarium", "Shop", "Curse Room", "Sacrifice Room" }

local ModSettings = {
	EnabledWhereOptions = { "First Room", "First Floor", "Everywhere" },
	RestartUntilOptions = {
		["Treasure Room"] = { Name = "Treasure Room", Enabled = false },
		["Library"] = { Name = "Library", Enabled = false },
		["Planetarium"] = { Name = "Planetarium", Enabled = false },
		["Shop"] = { Name = "Shop", Enabled = false },
		["Curse Room"] = { Name = "Curse Room", Enabled = false },
		["Sacrifice Room"] = { Name = "Sacrifice Room", Enabled = false },
	},
}

local pageName = "Instant Restart - R"

local Tab = "General"

local Settings = {
	AllowedRoom = ModSettings.EnabledWhereOptions[1],
}

local function getTableIndex(tbl, val)
	for i, v in ipairs(tbl) do
		if v == val then
			return i
		end
	end

	return 0
end

function modConfigMenu.registerSettings()
	--Add extra to settings
	for i = 1, #Rooms do
		Settings[Rooms[i]] = ModSettings.RestartUntilOptions[Rooms[i]]
	end

	ModConfigMenu.AddSetting(pageName, Tab, {
		Type = ModConfigMenu.OptionType.NUMBER,
		CurrentSetting = function()
			return getTableIndex(ModSettings.EnabledWhereOptions, Settings.AllowedRoom)
		end,
		Minimum = 1,
		Maximum = #ModSettings.EnabledWhereOptions,
		Display = function()
			return "Where can you instantly restart: " .. Settings.AllowedRoom
		end,
		OnChange = function(n)
			Settings.AllowedRoom = ModSettings.EnabledWhereOptions[n]
		end,
		Info = { "Where does this mod work?" },
	})

	for i = 1, #Rooms do
		local CurrentRoom = Settings[Rooms[i]]
		ModConfigMenu.AddSetting(
			pageName, -- This should be unique for your mod
			Tab, -- If you don't want multiple tabs, then set this to nil
			{
				Type = ModConfigMenu.OptionType.BOOLEAN,
				CurrentSetting = function()
					return CurrentRoom.Enabled
				end,
				Display = function()
					return "Search for " .. CurrentRoom.Name .. "" .. (CurrentRoom.Enabled and "x" or "")
				end,
				OnChange = function(b)
					CurrentRoom.Enabled = b
				end,
				Info = { -- This can also be a function instead of a table
					"Enable Search for " .. CurrentRoom.Name,
					"(Will not work if 4 or more rooms are chosen)",
				},
			}
		)
	end
end

function modConfigMenu.getSetting(Setting)
	return Settings[Setting]
end

function modConfigMenu.Check()
	if ModConfigMenu == nil then
		return false
	end
	return true
end

return modConfigMenu
