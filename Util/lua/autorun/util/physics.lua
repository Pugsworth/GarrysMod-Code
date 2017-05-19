local entmeta = FindMetaTable("Entity");

function entmeta:GPO(i)
	if i == nil then
		return self:GetPhysicsObject();
	end

	return self:GetPhysicsObjectNum(i);
end

----------
-- Mass --
----------
function entmeta:SetMass(...)
	local phys = self:GetPhysicsObject();

	if phys then
		return phys:SetMass(...);
	end
end

function entmeta:GetMass()
 local phys = self:GetPhysicsObject();
 
 if phys then
  return phys:GetMass();
 end
end