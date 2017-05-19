AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:SpawnFunction(ply, tr)

	if (!tr.Hit) then return end

	local pos = tr.HitPos + tr.HitNormal * 8

	local ent = ents.Create("sent_dev")
	ent:SetPos(pos)
	ent:Spawn()
	ent:Activate()

	return ent

end

function ENT:Initialize()
	self:SetModel("models/props_borealis/bluebarrel001.mdl");
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);

	local phys = self:GetPhysicsObject();
	if (phys:IsValid()) then
		phys:Wake();
	end
end

function ENT:Use(activator, caller)
	return
end

function ENT:Think()
end

function ENT:Touch(entTouched)
end
