local Mod = RegisterMod("BTRestart", 1)

Mod.Version = "1.0"

--Initial require
local Setup = require("scripts/Setup")
local Config = require("scripts/modConfig")
local Helper = require("scripts/Helper")

Setup.Run()

--Init variables
local isRestarting = false
local RoomTypes = {
	["Treasure Room"] = { ["id"] = 4, ["Name"] = "Treasure Room" },
	["Library"] = { ["id"] = 12, ["Name"] = "Library" },
	["Planetarium"] = { ["id"] = 24, ["Name"] = "Planetarium" },
	["Shop"] = { ["id"] = 2, ["Name"] = "Shop" },
	["Curse Room"] = { ["id"] = 10, ["Name"] = "Curse Room" },
	["Sacrifice Room"] = { ["id"] = 13, ["Name"] = "Sacrifice Room" },
}

local shouldRestart = false

local foundRooms = {}
local EnabledSearches = {}

local function inputAction(_, _, _, buttonAction)
	--Game Variables
	local Game = Game()
	local Level = Game:GetLevel()
	local currentFloor = Level:GetAbsoluteStage()
	local startingFloorID = 1
	local doorEnteredFrom = Level.EnterDoor
	local noDoorEntrance = -1

	--Conditions
	local isStartingFloor = (currentFloor == startingFloorID)
	local notEnteredDoors = (doorEnteredFrom == noDoorEntrance)

	--Check if Action is restart
	if not Input.IsActionTriggered(ButtonAction.ACTION_RESTART, 0) then
		return nil
	end

	--Check the action button is the restart button
	if not buttonAction == ButtonAction.ACTION_RESTART then
		return nil
	end

	--Check if game is paused
	if Game:IsPaused() then
		return nil
	end

	--Check if it's Ascent
	if Level:IsAscent() then
		return nil
	end

	--Check if it's the starting floor
	if Config.getSetting("AllowedRoom") == "First Floor" or Config.getSetting("AllowedRoom") == "First Room" then
		if not isStartingFloor then
			return nil
		end
	end

	--Check if any doors have been entered
	if Config.getSetting("AllowedRoom") == "First Room" then
		if not notEnteredDoors then
			return nil
		end
	end

	if isRestarting == true then
		return nil
	end

	isRestarting = true

	Isaac.ExecuteCommand("restart")

	EnabledSearches = {}

	for _, roomtype in pairs(RoomTypes) do
		if Config.getSetting(roomtype.Name).Enabled then
			table.insert(EnabledSearches, roomtype.id)
		end
	end

	return false
end

local function searchRoom(_, continued)
	if #EnabledSearches < 4 and #EnabledSearches > 0 and isRestarting and continued == false then
		foundRooms = {}
		local Game = Game()
		local Level = Game:GetLevel()
		local RoomList = {
			LeftRoom = Level:GetRoomByIdx(Level:GetStartingRoomIndex() - 1, -1).Data,
			RightRoom = Level:GetRoomByIdx(Level:GetStartingRoomIndex() + 1, -1).Data,
			UpRoom = Level:GetRoomByIdx(Level:GetStartingRoomIndex() - 13, -1).Data,
			DownRoom = Level:GetRoomByIdx(Level:GetStartingRoomIndex() + 13, -1).Data,
		}
		for _, room in pairs(RoomList) do
			if room == nil then
				goto continueRoomLoop
			end
			for _, enabledRoomId in pairs(EnabledSearches) do
				if enabledRoomId == room.Type and Helper.SearchTable(foundRooms, enabledRoomId) == false then
					table.insert(foundRooms, room.Type)
				end
			end
			::continueRoomLoop::
		end

		if #foundRooms ~= #EnabledSearches then
			shouldRestart = true
		elseif #foundRooms == #EnabledSearches then
			isRestarting = false
		end
	else
		isRestarting = false
	end
end

local function renderRestart()
	if shouldRestart then
		Isaac.ExecuteCommand("restart")
		shouldRestart = false
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_RENDER, renderRestart)
Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, searchRoom)
Mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, inputAction, InputHook.IS_ACTION_PRESSED)
