local mat_bar = surface.GetTextureID("bar")
local mat_background = surface.GetTextureID("background")

function scissor(x, y, w, h, enabled)

	if isbool(x) then
		render.SetScissorRect(0, 0, 0, 0, x)
	else
		render.SetScissorRect(x, y, x + w, y + h, enabled)	
	end
	
end

local x, y = 32, ScrH() - 128
hook.Add("HUDPaint", "a", function()

	surface.SetTexture(mat_background)
	surface.SetDrawColor(Color(255, 255, 255, 255))
	surface.DrawTexturedRect(x, y, 256, 256)

	surface.SetTexture(mat_bar)
	surface.SetDrawColor(Color(50, 90, 255, 255))

	local hp = LocalPlayer():Health() / 100

	scissor(x, y, hp * 165, 256, true)
	surface.DrawTexturedRect(x, y, 256, 256)
	scissor(false)
	
end)