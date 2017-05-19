AddCSLuaFile("cl_render.lua");
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

include("shared.lua");

function ENT:SpawnFunction(ply, tr, classname)

    if (!tr.Hit) then return end

    local ent = ents.Create(classname);

    local pos = tr.HitPos + tr.HitNormal * ent:BoundingRadius();

    ent:SetPos(pos);
    ent:Spawn();
    ent:Activate();

    local phys = ent:GetPhysicsObject();
    if IsValid(phys) then
        phys:EnableMotion(false);
    end

    return ent;

end

function ENT:Initialize()

    self:SetModel("models/props_combine/combine_mine01.mdl");

    self:PhysicsInit(SOLID_VPHYSICS);
    self:SetSolid(SOLID_VPHYSICS);
    self:SetMoveType(MOVETYPE_VPHYSICS);

    -- self:SetIsLinked(false);

    self:SetMaxHealth(300);
    self:SetHealth(300);

    -- Fields

    -- the entity marked for teleportation after teleportation sequence has finished
    self.m_teleMarked = nil;

    -- when set to non-zero, halt sequencing until time
    self.m_waitUntil = 0;
    -- if an interrupt is needed, this will cancel waiting
    self.m_waitInterrupt = false;

end

function ENT:Use(activator, caller, type, value)
end

function ENT:Think()

    -- self:NextThink(CurTime() + 0.05);

    -- return true;


    -- halt sequence logic until time
    if self.m_waitUntil > RealTime() and not self.m_waitInterrupt then
        return;
    elseif self.m_waitInterrupt then
        self.m_waitUntil = 0;
        self.m_waitInterrupt = false;
    end

    -- state sequence logic
    -- TODO: research temporal logic sequencing
    local tseq = self:GetTeleportSequence();

    if tseq == self.TSEQUENCE.IDLE then
        -- do nothing
        self:SetTeleportSequence(self.TSEQUENCE.PRE);

    elseif tseq == self.TSEQUENCE.PRE then
        self:EmitSound();
        self:SetTeleportSequence(self.TSEQUENCE.ANIM);
        self:Wait(1000);

    elseif tseq == self.TSEQUENCE.ANIM then
        self:SetTeleportSequence(self.TSEQUENCE.TELE);
        self:Wait(1000);

    elseif tseq == self.TSEQUENCE.TELE then

        if IsValid(self.m_teleMarked) then
            ent:SetPos(self:GetExitPos());
            ent:EmitSound(self.m_sndTeleportComplete);

            self:SetTeleportSequence(self.TSEQUENCE.POST);
            self:Wait(1000);
        else
            self:Wait(500);
        end

    elseif tseq == self.TSEQUENCE.POST then
        self.m_teleMarked = nil;
        self:SetTeleportSequence(self.TSEQUENCE.IDLE);
        self:Wait(500);

    elseif tseq == self.TSEQUENCE.DISABLED then
    end

end

function ENT:OnTakeDamage(dmginfo)
    local dmg = dmginfo:GetDamage();
    -- TODO: damage scaling

    if dmg > self:Health() then
        self.m_waitInterrupt = true;
        self:SetTeleportSequence(self.TSEQUENCE.DISABLED);
    end

    -- TODO: should we be able to die?
    self:SetHealth(math.max(0, self:Health() - dmg));
end
