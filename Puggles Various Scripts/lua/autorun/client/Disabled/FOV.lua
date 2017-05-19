FOV_Enabled = CreateClientConVar( "FOV_Enabled", 1, true, false )

local FOVList = {}
FOVList["weapon_crowbar"] = 74
FOVList["weapon_pistol"] = 64
FOVList["weapon_357"] = 64

local lastfov = 54



local function ParseWeaponFOV()
	if not ( FOV_Enabled:GetInt() == 1 ) then return end
	if not LocalPlayer() then return end

	local wep = LocalPlayer():GetActiveWeapon()
	local class = wep:GetClass()

	for k, v in pairs( FOVList ) do
		if(  k == class ) then
			print( v )
			if lastfov ~= v then
				local CamData = {}
				CamData.viewmodelfov = v
				render.RenderView( CamData )
				lastfov = v
				LocalPlayer():PrintMessage( HUD_PRINTCENTER, ( v or 54 ):tostring() )
			end
			//LocalPlayer():ConCommand( "viewmodel_fov " .. tostring( v ) )
		-- else
			-- if GetConVar( "viewmodel_fov" ) == 54 then return end
			-- LocalPlayer():ConCommand( "viewmodel_fov " .. "54" )
			-- LocalPlayer():PrintMessage( HUD_PRINTCENTER, "54" )
		end
	end

end
hook.Add( "Think", "FOVThink", ParseWeaponFOV )