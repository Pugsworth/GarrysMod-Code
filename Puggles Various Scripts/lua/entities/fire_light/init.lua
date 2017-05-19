AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");


function ENT:SpawnFunction(ply, tr, class)
	if not tr.Hit then return end

	// local z = self:GetCollisionBounds().z;
	local pos = tr.HitPos + tr.HitNormal * 16;

	local ent = ents.Create(class);
	ent:SetPos(pos);
	ent:Spawn();
	ent:Activate();

	ent:DropToFloor();

	return ent;
end

function ENT:Initialize()
	self:SetModel("models/props_junk/plasticbucket001a.mdl");
	self:SetUseType(SIMPLE_USE);

	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);

	self:SetActive(false);
end

function ENT:Use(act, call)
	self:SetActive(not self:GetActive());
end

function ENT:Think()
end
