SWEP.Base = "weapon_base";

SWEP.Author             = "Pugsworth";
SWEP.Contact            = "";
SWEP.Purpose            = "";
SWEP.Instructions       = "";
 
SWEP.Spawnable = true;
SWEP.AdminOnly = false;

SWEP.HoldType = "ar2";
SWEP.ViewModelFOV = 70;
SWEP.ViewModelFlip = false;

SWEP.ViewModel 	= "models/weapons/c_irifle.mdl";
SWEP.WorldModel = "models/weapons/w_rifar3.mdl"; -- "models/weapons/w_irifle.mdl";

SWEP.ShowViewModel 	= false;
SWEP.ShowWorldModel = true;
SWEP.ViewModelBoneMods = {};

SWEP.Primary.ClipSize = 120;
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize * 4;
SWEP.Primary.Automatic = true;
SWEP.Primary.Ammo = "AR2";
SWEP.Secondary.ClipSize = 3;
-- SWEP.Secondary.DefaultClip = 200
SWEP.Secondary.Automatic = true;
SWEP.Secondary.Ammo = "Pistol";

function SWEP:Precache()
end
