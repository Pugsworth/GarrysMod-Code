local itRT = GetRenderTargetEx("test_rt" .. RealTime(), 1024, 1024, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_NONE, 8, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGBA8888)

local matRT = CreateMaterial("test_rt" .. RealTime()+1, "UnlitGeneric", {
	["$basetexture"] = itRT:GetName(),
	["$vertexalpha"] = 1,
	["$alphatest"] = 1
})

matRT:Recompute()

local polyCache = nil
local function drawMask(posx, posy, scale)

	if not polyCache then
		polyCache = {}

        for i = 0, math.pi*2.0, math.pi/16.0 do

        -- local count = 6
		-- local seg = math.pi*2 / count

		-- for i = 1, count do


			local x = 2 + math.sin(i)
			local y = 2 + (-0.2 + math.sin(i/2) * 2) * math.cos(i)

			-- local x = 2 + math.sin(seg * i)
			-- local y = 2 + math.cos(seg * i)

			print(x, y)

			polyCache[#polyCache+1] = {x=x, y=y, u=x/5, v=y/5}

		end

	end

	local mtrx = Matrix()
	mtrx:SetScale(Vector(1, 1) * -scale)
	mtrx:SetTranslation(Vector(posx, posy))
	-- mtrx:Rotate(Angle(0, RealTime()*150 % 360, 0))
	mtrx:Translate(Vector(-2, -1))

	cam.PushModelMatrix(mtrx)
		surface.SetDrawColor(255, 255, 255)
		surface.DrawPoly(polyCache)
	cam.PopModelMatrix()

end

local mat_shape = Material("models/props_lab/warp_sheet")
local function drawShape()

	-- surface.SetDrawColor(0, 0, 255, 255)
	-- surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(mat_shape)
	surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

end

hook.Add("HUDPaint", LocalPlayer():GetActiveWeapon(), function()

	render.PushRenderTarget(itRT)
	cam.Start2D()

	render.SetStencilEnable(true)
	-- render.ClearStencil(0, 0, 0, 0)

	render.SetStencilTestMask(255)
	render.SetStencilWriteMask(255)

	render.SetStencilReferenceValue(100)
	render.SetStencilCompareFunction(STENCIL_NEVER)
	render.SetStencilPassOperation(STENCIL_KEEP)
	render.SetStencilFailOperation(STENCIL_REPLACE)
	render.SetStencilZFailOperation(STENCIL_REPLACE)

	drawMask(512, 512, 64)

	--[[
	render.SetStencilReferenceValue(2)
	render.SetStencilCompareFunction(STENCIL_NEVER)
	render.SetStencilPassOperation(STENCIL_REPLACE)
	render.SetStencilFailOperation(STENCIL_REPLACE)
	render.SetStencilZFailOperation(STENCIL_REPLACE)

	-- render.OverrideAlphaWriteEnable(true, true)
	drawMask(512, 512, 48)
	-- render.OverrideAlphaWriteEnable(false, false)
	--]] 

	render.SetStencilReferenceValue(100)
	render.SetStencilCompareFunction(STENCIL_EQUAL)
	-- render.ClearBuffersObeyStencil(0, 0, 0, 0, true)

	drawShape()

	render.SetStencilEnable(false)

	cam.End2D()
	render.PopRenderTarget()

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(matRT)
	-- surface.DrawTexturedRect(math.sin(RealTime() * 2) * 128, 0, 1024, 1024)
	surface.DrawTexturedRect(0, 0, 1024, 1024)

end)

