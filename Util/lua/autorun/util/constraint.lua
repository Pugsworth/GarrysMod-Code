local function isValidConstraintEntity(ent)
	if not IsValid(ent) then return false; end
	if ent:IsPlayer() then return false; end
	if ent == game.GetWorld() then return true; end
	return true;
end

function rope(ent1, ent2, addlength, rigid)
	if isValidConstraintEntity(ent1) and isValidConstraintEntity(ent2) then
		return constraint.Rope(ent1, ent2, 0, 0, vector_origin, vector_origin, ent1:GetPos():Distance(ent2:GetPos()), addlength, 0, 4, 'cable/rope', rigid);
	end
	return nil;
end
