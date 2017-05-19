AddCSLuaFile();
--
-- sh_
--
ENT.Type = "anim";

DEFINE_BASECLASS("base_hl2pickup");
 
ENT.PrintName		= "Battery";
ENT.Author			= "Pugsworth";
ENT.Contact			= "191292";
ENT.Category		= "HL2 Pickups";
ENT.Purpose			= "Heal";
ENT.Instructions	= "Walk over to gain Armor";

ENT.Editable		= true;

ENT.Spawnable		= true;
ENT.AdminSpawnable	= true;

local HealSound = Sound("ItemBattery.Touch");

function ENT:SetupDataTables()

	self:NetworkVar("Int", 0, "Value", {KeyName = "value", Edit = { title = "Armor", type = "Int", min = 1, max = 1000, order = 1}});
	self:NetworkVar("Int", 1, "MaxValue", {KeyName = "maxvalue", Edit = { title = "MaxArmor", type = "Int", min = 1, max = 1000, order = 2}});

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

		self:SetModel("models/items/battery.mdl");
		self.BaseClass.Initialize(self);
		self:SetValue(15);
		self:SetMaxValue(100);

	end

	function ENT:Think()
	end

	function ENT:OnPickup(ent)

		if not ent:IsPlayer() then return end

		local imaxArmor = self:GetMaxValue();
		local iarmor = ent:Armor();

		if iarmor < imaxArmor then

			local iamount = math.Clamp(imaxArmor - iarmor, 0, self:GetValue());
			local ileft = self:GetValue() - iamount;

			self:EmitSound(HealSound, 100, 100);
			ent:SetArmor(iarmor + iamount);

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
