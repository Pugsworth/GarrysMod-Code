local sv_falldamage = CreateConVar("sv_falldamage", 1, FCVAR_ARCHIVE);
local sv_falldamage_scale = CreateConVar("sv_falldamage_scale", 1, FCVAR_ARCHIVE);

hook.Add("GetFallDamage", "MPFallDamage", function(ply, vel)
    if sv_falldamage:GetInt() == 1 then
        vel = vel - 580;
        return (vel * (100 / (1024 - 580))) * math.Clamp(sv_falldamage_scale:GetInt(), 0, 100);
    end
end);
