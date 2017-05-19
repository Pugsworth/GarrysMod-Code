AddCSLuaFile();

ENT.Type = "anim";
ENT.Base = "base_anim";

ENT.PrintName		= "";
ENT.Author			= "";
ENT.Contact			= "";
ENT.Purpose			= "";
ENT.Instructions	= "";

ENT.Spawnable		= false;
ENT.AdminSpawnable	= false;

if SERVER then
	-- AccessorFunc(ENT, "m_btouched", "Touched", FORCE_BOOL);
	AccessorFunc(ENT, "m_fnextTouch", "NextTouch", FORCE_NUMBER);
	AccessorFunc(ENT, "m_ftouchDelay", "TouchDelay", FORCE_NUMBER);
end
--[[
function ENT:SpawnFunction(ply, tr, ClassName)

	if (!tr.Hit) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 10;
	
	local ent = ents.Create(ClassName);
		ent:SetPos(SpawnPos);
	ent:Spawn();
	ent:Activate();
	
	return ent;
	
end
--]]
function ENT:Initialize()

	if CLIENT then return end

	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON);
	-- self:SetCollisionBounds(Vector(-100, -100, -100), Vector(100, 100, 100));
	self:SetTrigger(true);

	if VERSION >= 140826 then
		self:UseTriggerBounds(true, 36);
	end

	self:SetUseType(SIMPLE_USE);

	local phys = self:GetPhysicsObject();
	if (IsValid(phys)) then
		phys:Wake();
		phys:SetMass(5); -- default, override
	end

	self:SetValue(10);
	self:SetNextTouch(CurTime());
	self:SetTouchDelay(1.0);

	self:SetHealth(10);

end

if SERVER then

	function ENT:OnPickup() -- override
	end

	function ENT:Use(act, call, usetype, value) -- cannot pick up the objects for some reason, so let's manually try it

		if not IsValid(act) or not act:IsPlayer() then return end
		if self:IsPlayerHolding() then return end

		local phys = self:GetPhysicsObject();

		if not IsValid(phys) and phys:GetMass() > 35 then return end

		local cpos = act:GetShootPos();
		local dist = (self:GetPos() - cpos):LengthSqr()

		-- print(dist);

		if dist > 8100 then return end -- greater than 8100 = 90^2

		-- print(act, act, usetype, value);
		-- print(act:GetPos():Distance(self:GetPos()));
		act:PickupObject(self);
		-- self:Touch(act);

	end

	function ENT:Touch(hitent)

		if self:GetNextTouch() < CurTime() then

			-- print("Pre OnPickup: ", CurTime());

			self:SetNextTouch(CurTime() + self:GetTouchDelay());
			self:OnPickup(hitent);
		end

	end

	function ENT:OnTakeDamage(dmginfo)
		local damage = dmginfo:GetDamage();

		// print(damage);
		if damage >= self:Health() then
			self:Destroy((damage - self:Health()) * 0.8);
		else
			self:SetHealth(self:Health() - damage);
		end
	end

	function ENT:Destroy(damage)

		local radius = math.max(64, (4 + damage) * 2);
		print(radius);

		local ef = EffectData();
		ef:SetOrigin(self:GetPos());
		ef:SetRadius(radius);
		ef:SetNormal(Vector(0, 0, 1));

		util.Effect("cball_explode", ef);
		util.Effect("AR2Explosion", ef);

		local di = DamageInfo();
		di:SetDamage(damage);
		di:SetDamageType(DMG_BLAST + DMG_SHOCK);

		util.BlastDamageInfo(di, self:GetPos(), radius * 2);

		self:EmitSound("weapons/physcannon/energy_sing_explosion2.wav");

		self:Remove();
	end

end

if CLIENT then
	function ENT:Draw()

		if GetConVarNumber('developer') == 1 then
			local mins, maxs = self:GetCollisionBounds();
			render.DrawWireframeBox(self:LocalToWorld(Vector(0, 0, 0)), self:GetAngles(), mins, maxs, Color(200, 255, 220), true);
			mins = mins - Vector(36, 36, 18);
			maxs = maxs + Vector(36, 36, 36);
			render.DrawWireframeBox(self:LocalToWorld(Vector(0, 0, 0)), Angle(), mins, maxs, Color(180, 255, 180), true);
		end

		self:DrawModel();

		local angles = EyeAngles()
		angles:RotateAroundAxis(angles:Up(), -90);
		angles:RotateAroundAxis(angles:Forward(), 90);

		cam.Start3D2D(self:GetPos() + Vector(0, 0, 16), angles, 0.25);
			surface.SetFont('Trebuchet24');
			surface.SetTextColor(color_white);
			surface.SetTextPos(0, 0);
			surface.DrawText(self:GetValue());
		cam.End3D2D();

	end
end

