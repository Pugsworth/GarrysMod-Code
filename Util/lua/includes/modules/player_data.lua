module("player_data", package.seeall);

local player_data = {};

local function checkPlayer(ply)

	if not IsValid(ply) then
		return false;
	end

	if not player_data[ply] then
		player_data[ply] = {};
	end

	return true;

end

function GetData(ply, key, default)

	if not checkPlayer(ply) then return end

	return player_data[key] or default;

end

function SetData(ply, key, value)

	if not checkPlayer(ply) then return end

	player_data[ply][key] = value;

end

----------------------
-- Metatable proxy --
----------------------
--[[
	Provides an syntax abstraction layer so you can
	continue to use the player object for data.

	e.g.
	ply.data.jumpHeight = 16;

	print(ply.data.jumpHeight);
--]]
do
	local meta = FindMetaTable("Player");

	local data_mt = {
		__index = function(self, k)
			return GetData(self, k);
		end,
		__newindex = function(self, k, v)
			SetData(self, k, v);
		end,
		__metatable = {}
	};

	meta.data = setmetatable({}, data_mt);
end
