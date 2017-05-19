SWEP.PrintName				= "Rail Rifle";
SWEP.Category				= "Other";

SWEP.Author					= "Pugsworth";
SWEP.Contact				= "";
SWEP.Purpose				= "Weapon";
SWEP.Instructions			= "Hold Left click to charge, release to fire. The longer the charge, the more damage is dealt.";

SWEP.ViewModelFOV			= 72;
SWEP.ViewModelFlip			= false;
SWEP.ViewModel				= "models/weapons/c_irifle.mdl";
SWEP.WorldModel				= "models/weapons/w_irifle.mdl";
SWEP.UseHands				= true;

SWEP.Spawnable				= true;
SWEP.AdminOnly				= false;

SWEP.Primary.ClipSize		= -1;
SWEP.Primary.DefaultClip	= 3;
SWEP.Primary.Automatic		= false;
SWEP.Primary.Ammo			= "AR2AltFire";

SWEP.Secondary.ClipSize		= -1;
SWEP.Secondary.DefaultClip	= -1;
SWEP.Secondary.Automatic	= false;
SWEP.Secondary.Ammo			= "None";

SWEP.Slot					= 2;
SWEP.SlotPos				= 2;

-- AccessorFunc(SWEP, "m_bCharging", "Charging");

if CLIENT then
	-- AccessorFunc(SWEP, "m_fCharge", "Charge");
	-- AccessorFunc(SWEP, "m_fChargeStart", "ChargeStart");
end

local DEBUG = true;
local Debug = function(...)
	if DEBUG then
		print("[RailRifle]", table.concat({...}, " "));
	end
end

local SOUNDS = {
	charge = {
		"weapons/strider_buster/ol12_stickybombcreator.wav",
		"weapons/physcannon/superphys_chargeup.wav"
	},
	shot = {
		"ambient/energy/ion_cannon_shot1.wav",
		"ambient/energy/ion_cannon_shot2.wav",
		"ambient/energy/ion_cannon_shot3.wav",
	}
}

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "Charge");
	self:NetworkVar("Float", 1, "ChargeStart");
	self:NetworkVar("Bool", 0, "Charging");
end

function SWEP:Precache()

	util.PrecacheSound("ambient/energy/ion_cannon_shot1.wav");
	PrecacheParticleSystem("Weapon_Combine_Ion_Cannon");
	PrecacheParticleSystem("Weapon_Combine_Ion_Cannon_Explosion");

	for k, v in pairs(SOUNDS) do // precache all the sounds
		for i = 1, #v do
			util.PrecacheSound(v[i]);
		end
	end

end

function SWEP:Initialize()

	self:SetWeaponHoldType("AR2");
	self:SetCharging(false);
	self.sndCharge = CreateSound(self, SOUNDS.charge[2]);

end

function SWEP:PrimaryAttack(ShootPos, ShootDir)

	if not self:CanPrimaryAttack() then return; end

	if not self:GetCharging() then
		self:SetCharging(true);
		self:SetChargeStart(CurTime());

		if not self.sndCharge:IsPlaying() then
			self.sndCharge:PlayEx(0.5, 120);
		end
		return;
	end

	self.sndCharge:Stop();

	local snd = table.Random(SOUNDS.shot)
	self:EmitSound(snd);
	Debug(snd);

	local damage = 10 + self:GetCharge() * 21;
	
	if self.Owner:IsNPC() then
		damage = damage * 5; -- not even sure if npcs can charge at all, so the only damage they do is the minimum
	end

	self:ShootBullet(damage, 1, 0.01);
	Debug("Charge:", self:GetCharge(), "Damage:", damage);

	self:TakePrimaryAmmo(1);

	self:SetCharge(0.0);
	self:SetCharging(false);

	self:SetNextPrimaryFire(CurTime() + 0.2);

end

function SWEP:Reload()

	self.BaseClass.Reload(self);

end

function SWEP:Think()

	-- if CLIENT then return; end

	if self:GetCharging() then

		if not self.Owner:KeyDown(IN_ATTACK) then
			self:PrimaryAttack();
		elseif self:GetCharge() <= 10.0 then
			local charge = (CurTime() - self:GetChargeStart()) * 2;

			self:SetCharge(math.min(10, charge));
		end

	end

end

function SWEP:getMuzzleAttachment(bviewmodel)

	local ent;

	if self.Owner:IsNPC() then
		ent = self.Owner:GetActiveWeapon();
	else
		if bviewmodel then
			ent = self.Owner:GetViewModel();
		else
			ent = self;
		end

	end

	local id = ent:LookupAttachment("muzzle");

	if id == 0 then
		id = ent:LookupAttachment('1');
	end

	return ent:GetAttachment(id), id;

end

function SWEP:ShootEffects(trace)

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK);
	self.Owner:MuzzleFlash();
	self.Owner:SetAnimation(PLAYER_ATTACK1);

	local att, id = self:getMuzzleAttachment();

	if self.Owner:IsNPC() then
		util.ParticleTracerEx("Weapon_Combine_Ion_Cannon", trace.StartPos, trace.HitPos, false, self.Owner:GetActiveWeapon():EntIndex(), id);
	else

		local vm = self.Owner:GetViewModel();
		util.ParticleTracerEx("Weapon_Combine_Ion_Cannon", att.Pos, trace.HitPos, false, vm:EntIndex(), id);
	end

	if self:GetCharge() >= 5.0 then
		ParticleEffect("Weapon_Combine_Ion_Cannon_Explosion", trace.HitPos, trace.HitNormal:Angle(), SERVER and game.GetWorld() or Entity(0));
	end

end

function SWEP:ShootBullet(damage, num_bullets, aimcone)
	
	-- local bullet = {
	-- 	Num 		= num_bullets;
	-- 	Src 		= self.Owner:GetShootPos();
	-- 	Dir 		= self.Owner:GetAimVector();
	-- 	Spread 		= Vector(aimcone, aimcone, 0);
	-- 	Tracer		= 5;
	-- 	Force		= 1;
	-- 	Damage		= damage;
	-- 	AmmoType 	= "AR2AltFire";
	-- };
	
	-- self.Owner:FireBullets(bullet);

	local startpos = self.Owner:GetShootPos();
	local endpos = startpos + self.Owner:GetAimVector() * 16384;

	if self.Owner:IsPlayer() then self.Owner:LagCompensation(true); end
	local trace = util.TraceLine({start = startpos, endpos = endpos, filter = {self.Owner, self}});
	if self.Owner:IsPlayer() then self.Owner:LagCompensation(false); end

	if SERVER then
		local radius = (32 + damage * 1.21) / 2
		util.BlastDamage(self, self.Owner, trace.HitPos, radius, damage);
		Debug("radius:", radius);
	end

	self:ShootEffects(trace);

end

function SWEP:TakePrimaryAmmo(num)

	if self.Owner:IsNPC() then return true; end -- npc doesn't have ammo?

	-- Doesn't use clips
	if self:Clip1() <= 0 then 
		if self:Ammo1() <= 0 then return; end

		self.Owner:RemoveAmmo(num, self:GetPrimaryAmmoType());
	
		return;
	end
	
	self.Weapon:SetClip1(self:Clip1() - num);
	
end

function SWEP:CanPrimaryAttack()

	if self.Owner:IsNPC() then return true; end -- npc doesn't have ammo?

	if self.Weapon:Ammo1() <= 0 then
		self:EmitSound("Weapon_AR2.Empty");
		self:SetNextPrimaryFire(CurTime() + 0.2);
		-- self:Reload();

		return false;

	elseif self:GetNextPrimaryFire() > CurTime() then
		return false;
	end

	return true;

end

function SWEP:CanSecondaryAttack()
	return false;
end

function SWEP:OnRemove()
end

function SWEP:OnDrop(...)
	Debug("Dropped", ..., self.Owner, self);
	if self:GetCharging() then
		self:SetCharging(false);
	end
end

---
-- NPC Methods
---

function SWEP:NPCShoot_Primary(ShootPos, ShootDir)
	self:PrimaryAttack(ShootPos, ShootDir);
end
