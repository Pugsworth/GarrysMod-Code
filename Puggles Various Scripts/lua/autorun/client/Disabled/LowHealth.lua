local GreyDeathEnabled = CreateConVar("cl_greydeath", 1, FCVAR_ARCHIVE)
local  GreyDeathAmount = CreateConVar("cl_greydeath_amount", 50, FCVAR_ARCHIVE) 

local function HealthCheck()
	local me = LocalPlayer()
	local hp = me:Health()

	if GreyDeathEnabled:GetBool() then return end
	if hp > GreyDeathAmount:GetInt()  then return end

	local mult = math.Clamp( ( hp / GreyDeathAmount:GetInt() ) - 0.15, 0, 1 )

	tab= {}
	tab[ "$pp_colour_addr" ] 			= 0
	tab[ "$pp_colour_addg" ] 			= 0
	tab[ "$pp_colour_addb" ] 			= 0
	tab[ "$pp_colour_brightness" ] 		= 0
	tab[ "$pp_colour_contrast" ] 		= 1
	tab[ "$pp_colour_colour" ] 			= mult
	tab[ "$pp_colour_mulr" ] 			= 0
	tab[ "$pp_colour_mulg" ] 			= 0
	tab[ "$pp_colour_mulb" ] 			= 0
	
	DrawColorModify( tab )
end

hook.Add( "HUDPaint", "MyHealthIsGone", HealthCheck )