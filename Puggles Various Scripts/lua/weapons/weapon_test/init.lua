AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
AddCSLuaFile("sck_base_code.lua");
 
include("shared.lua");
 
SWEP.Weight = 5;
SWEP.AutoSwitchTo 	= false;
SWEP.AutoSwitchFrom = false;

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType);
	-- self.BaseClass.Initialize(self);

end

function SWEP:Think()

end

function SWEP:PrimaryAttack()
	if self:GetNextPrimaryFire() <= CurTime() and self:CanPrimaryAttack() then
		-- self.BaseClass.PrimaryAttack(self);

		self:FireBullets({
			Entity = self.Owner,
			Damage = 3,
			Force = 15,
			Hull = 0,
			Num = 1,
			Tracer = 1,
			AmmoType = "AR2",
			TracerName = "AR2Tracer",
			Dir = self.Owner:GetAimVector(),
			Spread = Vector(1, 1, 0) * (self.Owner:Crouching() and 0.02 or 0.05);
			Src = self.Owner:GetShootPos()
		});

		self:ShootEffects();

		if game.SinglePlayer() then self:CallOnClient("PrimaryAttack", "") end -- Garry!!!!!!!

		self:TakePrimaryAmmo(1);

		self:SetNextPrimaryFire(CurTime() + 0.06);
	end
end

function SWEP:SecondaryAttack()
	if self:GetNextSecondaryFire() <= CurTime() then

		self:SetNextSecondaryFire(CurTime() + 1);
	end

	if game.SinglePlayer() then self:CallOnClient("SecondaryAttack", "") end -- Garry!!!!!!!
end

function SWEP:Deploy(...)
	if game.SinglePlayer() then self:CallOnClient("Deploy", "") end -- Garry!!!!!!!
	return self.BaseClass.Deploy(self, ...);
end

function SWEP:ShootEffects()

	local rand = math.random();

	if rand < 0.3 then
		self:EmitSound("^npc/turret_floor/shoot1.wav");
	elseif rand > 0.3 and rand < 0.6 then
		self:EmitSound("^npc/turret_floor/shoot2.wav");
	else
		self:EmitSound("^npc/turret_floor/shoot3.wav");
	end

	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK);
	self.Owner:MuzzleFlash();
	self.Owner:SetAnimation(PLAYER_ATTACK1);

end

function SWEP:CanPrimaryAttack()

	if ( self.Weapon:Clip1() <= 0 ) then
	
		self:EmitSound( "Weapon_AR2.Empty" )
		self:SetNextPrimaryFire( CurTime() + 0.2 )
		-- self:Reload()
		return false
		
	end

	return true

end

function SWEP:Reload()

	self.BaseClass.Reload(self);

	if game.SinglePlayer() then self:CallOnClient("Reload", "") end -- Garry!!!!!!!
end

function SWEP:OnRemove()

end
