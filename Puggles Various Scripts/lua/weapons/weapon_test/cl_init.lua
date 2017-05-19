include("shared.lua");

include("sck_base_code.lua");

SWEP.PrintName          = "Developer Weapon";
SWEP.Slot               = 3;
SWEP.SlotPos            = 3;
SWEP.DrawAmmo           = true;
SWEP.DrawCrosshair      = true;

SWEP.UseHands 			= true;

SWEP.RenderGroup 		= RENDERGROUP_OPAQUE;

SWEP.VElements = {
	["weapon"] 	= { type = "Model", model = "models/weapons/w_rifar3.mdl", bone = "Base", rel = "", pos = Vector(-0.345, 3.913, 17.152), angle = Angle(-90, 90, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["glow1"]	= {
		type = "Model",
		model = "models/Items/battery.mdl",
		bone = "Base",
		rel = "",
		pos = Vector(-0.5, -0.5, 17),
		angle = Angle(0, 0, 0),
		size = Vector(0.5, 0.5, 0.5),
		color = Color(255, 255, 255, 255),
		surpresslightning = false,
		material = "",
		skin = 0,
		bodygroup = {}
	}
};

SWEP.WElements = {
	["weapon"] = { type = "Model", model = "models/weapons/w_rifar3.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(16.132, 0, -2.228), angle = Angle(170, 0, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
};

function SWEP:Initialize()
	-- LocalPlayer():ChatPrint("Initialize!");

	self:SetWeaponHoldType(self.HoldType);

	self:SCKInitialize();
	-- self.BaseClass.Initialize(self);

end

function SWEP:PrimaryAttack()
	-- LocalPlayer():ChatPrint("PrimaryAttack!");
end

function SWEP:SecondaryAttack()
	-- LocalPlayer():ChatPrint("SecondaryAttack!");
end

function SWEP:Reload()
	-- LocalPlayer():ChatPrint("Reload!");
	self.BaseClass.Reload(self);
end

function SWEP:Deploy()
	-- LocalPlayer():ChatPrint("Deploy!");

	local vm = self.Owner:GetViewModel();
	if (self.ShowViewModel == nil or self.ShowViewModel) then
		vm:SetColor(Color(255,255,255,255))
	else
		vm:SetColor(Color(255,255,255,1))
		vm:SetMaterial("Debug/hsv")			
	end

	return true; -- self.BaseClass.Deploy(self);
end

function SWEP:Holster()
	-- LocalPlayer():ChatPrint("Holster!");
	if self.Owner and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel();
		if vm and IsValid(vm) then
			vm:SetMaterial("");
		end
	end
	return self:SCKHolster() and self.BaseClass.Holster(self);
end

function SWEP:OnRemove()
	-- LocalPlayer():ChatPrint("OnRemove!");
	self:SCKOnRemove();
	self.BaseClass.OnRemove(self);
end

function SWEP:Think()
	
end
