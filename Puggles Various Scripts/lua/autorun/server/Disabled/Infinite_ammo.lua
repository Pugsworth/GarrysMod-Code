CreateConVar( "weapon_infinityammo", 0, true, false )

function iammo()
	if not ( GetConVarNumber( "weapon_infinityammo" ) == 1 ) then return end

	for _, ply in pairs( player.GetAll() ) do
		if ( ply:Alive() and ply:GetActiveWeapon() != NULL ) then
			local wep = ply:GetActiveWeapon()
			if wep:Clip1() < 255 then wep:SetClip1( 250 ) end
			if wep:Clip2() < 255 then wep:SetClip2( 250 ) end
			
			if wep:GetPrimaryAmmoType() == 10 or wep:GetPrimaryAmmoType() == 8 then
					ply:GiveAmmo( 9 - ply:GetAmmoCount( wep:GetPrimaryAmmoType() ), wep:GetPrimaryAmmoType() )
			elseif wep:GetSecondaryAmmoType() == 9 or wep:GetSecondaryAmmoType() == 2 then
					ply:GiveAmmo( 9 - ply:GetAmmoCount( wep:GetSecondaryAmmoType() ), wep:GetSecondaryAmmoType() )
			end
	    end
    end
end
hook.Add( "Think", "unlimitedammo", iammo )