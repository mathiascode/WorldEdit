
-- PlayerState.lua

-- Implements the cPlayerState object, representing the full information that is remembered per player
-- Also implements the GetPlayerState() function for retrieving / initializing the player state





--- The dict-table of player states.
--[[
Each player has an entry in this dictionary, indexed by the player's Key.
The player name has been chosen as the Key, this means that multiple players of the same name
share their state and the state is global for all worlds.
Each entry is a cPlayerState class instance
--]]
local g_PlayerStates = {}





--- Class for storing the player's state
local cPlayerState = {}





--- Creates a new PlayerState object
function cPlayerState:new(a_Obj, a_PlayerKey)
	a_Obj = a_Obj or {}
	setmetatable(a_Obj, cPlayerState)
	self.__index = self
	
	-- Initialize the object members to their defaults:
	a_Obj.PlayerKey = a_PlayerKey
	a_Obj.Selection = cPlayerSelection:new({}, a_Obj)
	
	return a_Obj
end





--- Loads the state from persistent storage (if so configured)
function cPlayerState:Load()
	-- TODO
end





--- Saves the state to persistent storage (if so configured)
function cPlayerState:Save()
	-- TODO
end





--- Returns a PlayerState object for the specified Player
-- Creates one if it doesn't exist yet
function GetPlayerState(a_Player)
	local Key = a_Player:GetName()
	local res = g_PlayerStates[Key]
	if (res ~= nil) then
		return res
	end
	
	-- The player state doesn't exist yet, create a new one:
	res = cPlayerState:new()
	res.WandActivated = true
	g_PlayerStates[Key] = res
	res:Load()
	
	return res
end





local function OnPlayerDestroyed(a_Player)
	-- Allow the player state to be saved to a persistent storage:
	local State = g_PlayerStates[a_Player:GetName()]
	if (State == nil) then
		return false
	end
	State:Save()

	-- Remove the player state altogether:
	g_PlayerStates[a_Player:GetName()] = nil
end





local function SetPos(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_SetFn)
	-- Check if a wand is used:
	if (a_Player:GetEquippedItem().m_ItemType ~= Wand) then
		return false
	end
	
	-- Check the WE permission:
	if not(a_Player:HasPermission("worldedit.selection.pos")) then
		return false
	end
	
	-- Check the wand activation state:
	local State = GetPlayerState(a_Player)
	if not(State.WandActivated) then
		return false
	end
	
	-- When shift is pressed, use the air block instead of the clicked block:
	if (a_Player:IsCrouched()) then
		a_BlockX, a_BlockY, a_BlockZ = AddFaceDirection(a_BlockX, a_BlockY, a_BlockZ, a_BlockFace)
	end
	
	a_SetFn(State.Selection, a_BlockX, a_BlockY, a_BlockZ)
	return true
end





local function OnPlayerRightClick(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ)
	return SetPos(Player, BlockX, BlockY, BlockZ, BlockFace, cPlayerSelection.SetSecondPoint)
end





local function OnPlayerLeftClick(Player, BlockX, BlockY, BlockZ, BlockFace, BlockType, BlockMeta)
	return SetPos(Player, BlockX, BlockY, BlockZ, BlockFace, cPlayerSelection.SetFirstPoint)
end





-- Register the hooks needed:
cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_DESTROYED,   OnPlayerDestroyed)
cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICK, OnPlayerRightClick)
cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_LEFT_CLICK,  OnPlayerLeftClick)




