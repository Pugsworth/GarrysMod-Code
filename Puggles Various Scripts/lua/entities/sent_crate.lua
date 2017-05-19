AddCSLuaFile();
--
-- sh_
--
ENT.Type = "anim";
ENT.Base = "base_anim";
 
ENT.PrintName		= "Crate";
ENT.Author			= "Pugsworth";
ENT.Contact			= "191292";
ENT.Category		= "Other";
ENT.Purpose			= "item_item_crate";
ENT.Instructions	= "";

ENT.Editable		= true;

ENT.Spawnable		= true;
ENT.AdminSpawnable	= true;

function ENT:SetupDataTables()

	self:NetworkVar("String", 0, "ItemClass", {KeyName = "item_class", Edit = {title = "Item Class", type = "generic", order = 1}});
	self:NetworkVar("Int", 0, "ItemCount", {KeyName = "item_count", Edit = {title = "Item Count", type = "Int", min = 1, max = 64, order = 2}});

end

--
-- sv_
--
if SERVER then

	local cvar = {
		crate_item		 = 	CreateConVar("crate_item", "item_dynamic_resupply", {FCVAR_REPLICATED}, "The item class to spawn when the crate is broken. model path can be supplied, which will attempt to use the best matched class (prop_physics, prop_ragdoll, etc).");
		crate_item_count = 	CreateConVar("crate_item_count", "1", {FCVAR_REPLICATED}, "Amount to spawn.");
	}

	function GetEntityClass(str)

		if type(str) ~= "string" then return false; end

		if util.IsValidRagdoll(str) then
			return "prop_ragdoll";

		elseif util.IsValidProp(str) then
			return "prop_physics";

		elseif util.IsValidModel(str) then
			return "prop_effect";
		end

		return false;

	end

	function IsValidClass(str)

		local ent = ents.Create(str);

		if not IsValid(ent) then
			return false;
		else
			ent:Remove();
			return true;
		end

	end

	function ENT:SpawnFunction(ply, tr, classname)

		if (!tr.Hit) then return end
		
		local spawnpos = tr.HitPos + tr.HitNormal * 8;
		
		local ent = ents.Create(classname);
		ent:SetPos(spawnpos);
		ent:Spawn();
		ent:Activate();
		
		return ent;
		
	end

	function ENT:Initialize()

		self:SetModel("models/items/item_item_crate.mdl");

		self:PhysicsInit(SOLID_VPHYSICS);
		self:SetMoveType(MOVETYPE_VPHYSICS);
		self:SetSolid(SOLID_VPHYSICS);

		self:SetUseType(SIMPLE_USE);
		
		self:SetMaxHealth(20);
		self:SetHealth(20);
		
		local phys = self:GetPhysicsObject();
		if phys then
			phys:Wake();
			phys:EnableMotion(true);
		end
		
		self:PrecacheGibs();

		local sclass = cvar.crate_item:GetString()
		self:SetItemClass(#sclass > 0 and sclass or "item_dynamic_resupply");
		self:SetItemCount(cvar.crate_item_count:GetInt() or 1);



		hook.Add("GravGunPunt", self, function(self, ply, ent)

			if ent ~= self then return end; -- break out of the function, but don't stop the player from punting

			local phys = self:GetPhysicsObject();

			if phys and not phys:HasGameFlag(FVPHYSICS_WAS_THROWN) and phys:HasGameFlag(FVPHYSICS_PLAYER_HELD) then
				phys:AddGameFlag(FVPHYSICS_WAS_THROWN);
			end

		end);

	end

	function ENT:Think()

		if self.shouldbreak then
			self:DoDeath();
		end

	end

	function ENT:PhysicsCollide()

		local phys = self:GetPhysicsObject();

		if phys and phys:HasGameFlag(FVPHYSICS_WAS_THROWN) then
			-- local dmginfo = DamageInfo();

			-- dmginfo:SetDamage(20);
			-- dmginfo:SetAttacker(); -- player who punted it
			-- dmginfo:SetInflictor();

			-- self:TakeDamage(dmginfo);
			self.shouldbreak = true;
		end

	end

	function ENT:Use(act, call, usetype, value) -- cannot pick up the objects for some reason, so let's manually try it

		if not IsValid(call) or not call:IsPlayer() then return end
		if call:IsPlayerHolding() then return end

		local phys = self:GetPhysicsObject();

		if not IsValid(phys) and phys:GetMass() > 35 then return end
		if not phys:IsMotionEnabled() then return end

		if act:GetPos():Distance(self:GetPos()) < 90 then
			call:PickupObject(self);
		end

	end

	function ENT:OnTakeDamage(cdmginfo)

		local ihealthleft = self:Health() - cdmginfo:GetDamage();

		if ihealthleft > 0 then

			self:SetHealth(ihealthleft);

		else
			self.shouldbreak = true;
		end

	end

	function ENT:DoDeath()

		self:GibBreakServer(self:GetPhysicsObject():GetVelocity());

		self:SpawnItem();

		self:Remove();

	end

	function ENT:SpawnItem() -- TODO: refine

		local sclass, icount = self:GetItemClass(), self:GetItemCount();
		local smodel = sclass; -- copy the variable if it's a model

		sclass = GetEntityClass(sclass) or #sclass > 0 and sclass or "item_dynamic_resupply"; -- if it is a model, this will return the correct class to use

		if not IsValidClass(sclass) then
			smodel, sclass = "item_dynamic_resupply"; -- if the class is invalid, revert to the default class
		end


		for i = 1, math.min(icount or 1, 64) do
			
			local ent = ents.Create(sclass);

			if smodel ~= sclass then -- if they are different, then it is a model of some kind
				ent:SetModel(smodel);
			end

			ent:SetPos(self:GetPos()); -- TODO: check if the position is valid?
			ent:SetAngles(Angle(0, self:GetAngles().yaw, 0));
			ent:Spawn();
			ent:Activate(); -- is this needed?

			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(self:GetVelocity());
			end
			-- self:DeleteOnRemove(ent); -- remove the entities if the player undoes the crate?

		end

	end


end

--
-- cl_
--
if CLIENT then

	function ENT:Draw()

		self:DrawModel();

	end

end
