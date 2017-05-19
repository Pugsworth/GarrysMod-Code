ENT.Type = "anim";
ENT.Base = "base_entity";

ENT.PrintName    = "Fire Can";
ENT.Author       = "Pugsworth";
ENT.Contact      = "n/a";
ENT.Purpose      = "n/a";
ENT.Instructions = "n/a";
ENT.Category     = "Puggle's Entities";

ENT.Spawnable    = true;
ENT.AdminOnly    = false;

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Active");
end
