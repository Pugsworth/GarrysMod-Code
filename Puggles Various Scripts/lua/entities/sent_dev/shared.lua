ENT.Type = "anim";
ENT.Base = "base_gmodentity";
 
ENT.PrintName		= "Tested Scripted Entity";
ENT.Author			= "Pugsworth";
ENT.Contact			= "191292";
ENT.Purpose			= "Used in the aid of developing";
ENT.Instructions	= "";
ENT.Category		= "Developer Testing";

ENT.Spawnable		= true;
ENT.AdminSpawnable	= true;

ENT.Editable		= true;

ENT.bDataTablesSetup = false;

function ENT:SetupDataTables()

	self:NetworkVar("Int",    0, "Count",    {KeyName = "count",    Edit = {title = "Prop Count",    type = "Int", min = 1, max = 90, order = 1}});
	self:NetworkVar("Int",    1, "Distance", {KeyName = "distance", Edit = {title = "Prop Distance", type = "Int", min = 0, max = 512, order = 2}});  

	self:NetworkVar("String", 0, "CModel",   {KeyName = "cmodel",   Edit = {title = "Model Path",    type = "Generic", order = 3}});

	self:NetworkVar("Bool",   0, "Snap",        {KeyName = "snap",        Edit = {title = "Snap",         category = "Angle", type = "Boolean", order = 10}});
	self:NetworkVar("Int",    2, "SnapDegrees", {KeyName = "snapdegrees", Edit = {title = "Snap Degrees", category = "Angle", type = "Int", min = 0, max = 180, order = 11}});

	self:NetworkVarElement("Angle", 0, 'p', "Pitch", {KeyName = "pitch", Edit = {title = "Pitch", category = "Angle", type = "Float", min = 0, max = 360, order = 12}});
	self:NetworkVarElement("Angle", 0, 'y', "Yaw",   {KeyName = "yaw",   Edit = {title = "Yaw",   category = "Angle", type = "Float", min = 0, max = 360, order = 13}});
	self:NetworkVarElement("Angle", 0, 'r', "Roll",  {KeyName = "roll",  Edit = {title = "Roll",  category = "Angle", type = "Float", min = 0, max = 360, order = 14}});

	self.bDataTablesSetup = true; -- is something like this already created?

end

local function SnapAngles(ang, deg)

	local p = math.Round(a.p / deg) * deg;
	local y = math.Round(a.y / deg) * deg;
	local r = math.Round(a.r / deg) * deg;

	return Angle(p, y, r);
end

function ENT:SetCMAngles(ang)
	if self.bDataTablesSetup then

		if self:GetSnap() then
			ang = SnapAngles(ang, self:GetSnapDegrees());
		end

		self:SetPitch(ang.p);
		self:SetYaw(ang.y);
		self:SetRoll(ang.r);
	end
end

function ENT:GetCMAngles()
	local p = self:GetPitch();
	local y = self:GetYaw();
	local r = self:GetRoll();

	return Angle(p, y, r);
end
