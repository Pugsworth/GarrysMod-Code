local nextthink = 0
local Ragdolls
hook.Add( "Think", "RemoveThemVermins", function()
	if nextthink <= CurTime() then
		Ragdolls = ents.FindByClass("class C_ClientRagdoll")
		for k,v in pairs( Ragdolls ) do
			if( v:GetModel() == "models/headcrabclassic.mdl" ) then
				v:Remove()
			end
		end
		nextthink = CurTime() + 10
	end
end )
