local ply_data = {};

local cvarSpawnDelay = CreateConVar("sv_spawndelay", 1, {FCVAR_ARCHIVE}, "Time delay before you can spawn after death.");

hook.Add("PlayerDeathThink", "Spawn", function(ply)

	if ply_data[ply] and RealTime() < ply_data[ply] + cvarSpawnDelay:GetFloat() then
		return false;
	end

	if ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_JUMP) then
		ply:Spawn();

	elseif ply:KeyPressed(IN_ATTACK2) then
		ply:Revive();
	end

	return false;

end);


local function DoPlayerDeath(ply)
    ply_data[ply] = RealTime();
end

hook.Add("DoPlayerDeath",     "Spawn", DoPlayerDeath);
hook.Add("PlayerSilentDeath", "Spawn", DoPlayerDeath);

hook.Add("PlayerDisconnected", "Spawn", function(ply)
    ply_data[ply] = nil;
end);
