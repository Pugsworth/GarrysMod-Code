AddCSLuaFile();
--
-- sh_
--
ENT.Type = "anim";

DEFINE_BASECLASS("base_hl2pickup");
 
ENT.PrintName		= "Health Vial";
ENT.Author			= "Pugsworth";
ENT.Contact			= "191292";
ENT.Category		= "HL2 Pickups";
ENT.Purpose			= "Heal";
ENT.Instructions	= "Walk over to gain health";

ENT.Editable		= true;

ENT.Spawnable		= true;
ENT.AdminSpawnable	= true;

local HealSound = Sound("HealthVial.Touch");

function ENT:SetupDataTables()

	self:NetworkVar("Int", 0, "Value", {KeyName = "value", Edit = { title = "Health", type = "Int", min = 1, max = 1000, order = 1}});

end

--
-- sv_
--
if SERVER then


	function ENT:SpawnFunction(ply, tr, classname)

		if (!tr.Hit) then return end
		
		local SpawnPos = tr.HitPos + tr.HitNormal * 8;
		
		local ent = ents.Create(classname);
		ent:SetPos(SpawnPos);
		ent:Spawn();
		ent:Activate();
		
		return ent;
		
	end

	function ENT:Initialize()

		self:SetModel("models/healthvial.mdl");
		self.BaseClass.Initialize(self);
		self:SetValue(10);

	end

	function ENT:Think()
	end

	function ENT:OnPickup(ent)

		if not ent:IsPlayer() then return end

		local imaxHealth = ent:GetMaxHealth();
		local ihealth = ent:Health();

		if ihealth < imaxHealth then

			local iamount = math.Clamp(imaxHealth - ihealth, 0, self:GetValue());
			local ileft = self:GetValue() - iamount;

			ent:SetHealth(ihealth + iamount);
			if ileft <= 0 then
				self:Remove();
			else
				self:SetValue(ileft);
			end

		end

	end

end

--
-- cl_
--
if CLIENT then

end
