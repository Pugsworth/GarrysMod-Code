-- function GAMEMODE:OnDamagedByExplosion( ply, dmginfo )
	-- ply:SetDSP( 1, false )
-- end
-- hook.Add( "OnDamagedByExplosion", "NoEarRing", NoEarRing )
local plyHealth = LocalPlayer():Health()

local function StopTheEarRape()
	if LocalPlayer():Health() >= plyHealth then
		plyHealth = LocalPlayer():Health()
		return true
	end
		LocalPlayer():SetDSP( 0, false )
		--chat.AddText( "Old Health was: " .. tostring( plyHealth ) .. " - " .. "New Health is: " .. tostring( LocalPlayer():Health() ) )
		plyHealth = LocalPlayer():Health()
end
hook.Add( "Think", "NoEarRape", StopTheEarRape )