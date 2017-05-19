local smooth_color = Vector(0)
local cvar = CreateClientConVar("pp_lightcolor", "1")
local BadMaps = {
	"gm_bigcity",
	}
hook.Add("RenderScreenspaceEffects", 1, function()
	if not cvar:GetBool() then return end
	for i = 1, table.Count( BadMaps ) do
		if game.GetMap() == BadMaps[i] then return end
	end
	
	local ply = LocalPlayer()
	local color = vector_origin

	for i = 1, 5 do
		color = color + render.GetLightColor(ply:EyePos() + (ply:GetAimVector() * 30 * i))
	end

	color = color / 10

	smooth_color = LerpVector(FrameTime() * 10, smooth_color, color * 0.6)

	local sat = math.Clamp(smooth_color:Length() / 2 + 0.5, 1, 2)
	local len = smooth_color:Length()	
	local mult = (smooth_color - (Vector() * 0.2)) * 4
	
	mult.x = math.max(mult.x, 0)
	mult.y = math.max(mult.y, 0)
	mult.z = math.max(mult.z, 0)
		
	DrawColorModify{
		["$pp_colour_addr"] = smooth_color.x,
		["$pp_colour_addg"] = smooth_color.y,
		["$pp_colour_addb"] = smooth_color.z,
		
		["$pp_colour_mulr"] = mult.x,
		["$pp_colour_mulg"] = mult.y,
		["$pp_colour_mulb"] = mult.z,

		["$pp_colour_brightness"] = -len * 0.1,
		["$pp_colour_contrast"] = len * 0.2 + 1,
		["$pp_colour_colour"] = sat,
	}
end)