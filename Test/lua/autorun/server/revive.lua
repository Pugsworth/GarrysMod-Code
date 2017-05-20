local meta = FindMetaTable("Player");
if not meta then error("Player metatable not found???"); end

--[[
local revive_sounds = file.Find("sound/ambient/energy/zap*", "GAME");
for i = 1, #revive_sounds do
    local snd = revive_sounds[i];
    revive_sounds[i] = "ambient/energy/" .. snd;
end
--]]

local data = {};

local revive_sounds = {"ambient/energy/whiteflash.wav"};

local function getZapSound()
    local length = #revive_sounds;
    return revive_sounds[math.floor(math.random() * length) + 1];
end

local function dropToFloor(ply, pos, ibounds)

    ibounds = ibounds or 16; -- player default bounds

    local tr = util.TraceHull({
        start   = pos,
        endpos  = pos - Vector(0, 0, 1) * 128,
        mins    = Vector(-1, -1, 0) * ibounds,
        maxs    = Vector(1, 1, 0) * ibounds,
        filter  = {ply}
    });

    if tr.Hit and tr.FractionLeftSolid == 0 then
        return tr.HitPos;
    end

    return pos;

end

function meta:Revive(bIgnoreAlive)
    local cond = bIgnoreAlive and true or not self:Alive();
    if cond then

        if not data[self] then
            -- self:ChatPrint("Revive data missing??");
            return self:Spawn(); -- spawn normally if data is missing
        end

        local pos, yaw = unpack(data[self]);
        local ang = Angle(0, yaw, 0);

        pos = dropToFloor(self, pos);

        self:Spawn();
        self:SetPos(pos);
        self:SetEyeAngles(ang);
        self:EmitSound(getZapSound());
        self:ScreenFade(SCREENFADE.IN, color_white, 0.5, 0);

        local ed = EffectData();
        ed:SetOrigin(pos);
        ed:SetNormal(Vector(0, 0, 1));
        ed:SetScale(1);
        ed:SetMagnitude(25);

        util.Effect("sparks", ed);
    else
        self:ChatPrint("You aren't dead!");
    end
end

concommand.Add("revive", function(ply, cmd, args)
    if IsValid(ply) then
        ply:Revive(false);
    end
end);


concommand.Add("revive_lastdeath", function(ply, cmd, args)
    if IsValid(ply) then
        ply:Revive(true);
    end
end);

local function DoPlayerDeath(ply)
    -- ply.lastDeathPosition = ply:GetPos();
    data[ply] = {ply:GetPos(), ply:GetAimVector():Angle().yaw};
end

hook.Add("DoPlayerDeath", "LastPosition", DoPlayerDeath);
hook.Add("PlayerSilentDeath", "LastPosition", DoPlayerDeath);

hook.Add("PlayerDisconnected", "LastPosition", function(ply)

    data[ply] = nil;

end);
