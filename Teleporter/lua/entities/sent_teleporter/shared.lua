ENT.Type           = "anim";
ENT.Base           = "base_entity";
ENT.PrintName      = "Teleporter";
ENT.Author         = "Pugsworth";
ENT.Instructions   = "";

ENT.Spawnable      = true;
ENT.AdminOnly      = false;
ENT.Editable       = true;


-- enums
ENT.TSEQUENCE = {
    STARTUP  = 0,
    IDLE     = 1,
    PRE      = 2,
    ANIM     = 3,
    TELE     = 4,
    POST     = 5,
    DISABLED = 6
    -- reserved for more
};

-- Contains the network of all portals in the world.
-- used for things like rendering and iterating
ENT.portalNetwork = {};

-- the data needed for everything (sounds, materials, models, etc)
ENT.data = {
    sounds    = {
        teleport_complete = Sound("custom/Teleporter.wav")
    },
    materials = {
        wireframe = Material("models/wireframe")
    }
};

function ENT:SetupDataTables()

    -- self:NetworkVar("Bool",   0, "IsLinked");
    self:NetworkVar("Vector", 0, "ExitPos");
    -- a unique integer that represents
    self:NetworkVar("Int",    0, "PortalIndex");
    self:NetworkVar("Int",    1, "TeleportSequence");

    self:NetworkVar("Entity", 0, "LinkedPortal");

    self:NetworkVar("String", 0, "Dummy", {
        KeyName = "Dummy",
        Edit = {
            type     = "TargetSelect",
            title    = "Teleport Target",
            category = "Other",
            callback = self.OnTargetSelected
        }
    });

end

-- called by NetworkVar property
function ENT:OnTargetSelected()
end

function ENT:SetupEffects()

end

function ENT:IsLinked()
    return self:GetExitPos() ~= nil and self:GetExitPos() ~= vector_origin;
end

function ENT:StartTouch(ent)
    if CLIENT then return; end

    if self:IsLinked() and IsValid(self.m_teleMarked) then
        self.m_teleMarked = ent;
    end
end

function ENT:Touch(ent)
end

function ENT:EndTouch(ent)
end

function ENT:Wait(delay)
    -- self.m_waiting = true;
    self.m_waitUntil = RealTime() + delay;
end


