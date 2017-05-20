local disableToolgunPickup = CreateConVar("sv_disablepickupfortoolgun", "1", FCVAR_ARCHIVE, "Disables the ability to pick up items if you have the toolgun out.");

hook.Add("AllowPlayerPickup", "ItemPickup.Toolgun", function(ply, item)
	if IsValid(ply) and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "gmod_tool" then
		return not disableToolgunPickup:GetBool();
	end
	return true;
end);