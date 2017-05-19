include("shared.lua");

SWEP.DrawAmmo			= true;
SWEP.DrawCrosshair		= true;
SWEP.DrawWeaponInfoBox	= true;
SWEP.BounceWeaponIcon   = true;
SWEP.SwayScale			= 1.0;
SWEP.BobScale			= 1.0;

SWEP.RenderGroup 		= RENDERGROUP_OPAQUE

-- Override this in your SWEP to set the icon in the weapon selection
SWEP.WepSelectIcon		= surface.GetTextureID("weapons/swep");

local matBeam = Material("cable/physbeam");


function SWEP:DrawHUD()
end

function SWEP:ViewModelDrawn()

	if not self:GetCharging() then return; end

	local att, id = self:getMuzzleAttachment(true);

	local startpos = att.Pos;
	local eyetrace = self.Owner:GetEyeTrace();
	local endpos   = eyetrace.HitPos;

	if (startpos - eyetrace.HitPos):LengthSqr() <= 4096 then
		endpos = startpos + (self.Owner:GetAimVector() * 64);
	end

	local trace = util.TraceLine({start = startpos, endpos = endpos, filter = {self.Owner, self}});

	local t = CurTime() % 256;
	-- local length = trace.StartPos:Distance(trace.HitPos);

	render.SetMaterial(matBeam);
	render.DrawBeam(startpos, endpos, self:GetCharge(), t + 20 * FrameTime(), t, Color(255, 0, 0));

end

function SWEP:DrawWorldModel()
	self:DrawModel();
end

function SWEP:DrawWorldModelTranslucent()
	self:DrawModel();
end
