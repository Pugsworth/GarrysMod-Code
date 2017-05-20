local me = LocalPlayer()

function getLookatEntity()
	return me:GetEyeTrace().Entity
end

local itexture_rt = GetRenderTarget("test", ScrW(), ScrH(), false)
local mat_rt = CreateMaterial("rt_test", "UnlitGeneric", {
	["$basetexture"] = itexture_rt:GetName()
})

local mat_wireframe = Material("models/wireframe")

local lastEntity = nil
hook.Add("HUDPaint", me:GetActiveWeapon(), function()

	local entity = getLookatEntity()

	if not IsValid(entity) then
		if IsValid(lastEntity) then
			lastEntity:SetNoDraw(false)
		end
		return
	end

	cam.Start3D(EyePos(), EyeAngles())

	lastEntity = entity
	entity:SetNoDraw(true)

	entity:DrawModel()
	-- render.SetMaterial(mat_wireframe)
	render.SetBlend(0.1)

	entity:SetMaterial("models/wireframe")
	entity:DrawModel()
	entity:SetMaterial("")

	render.SetBlend(1.0)

	local sw, sh = ScrW(), ScrH()


	---[[

	render.ClearStencil(0, 0, 0)
	render.SetStencilEnable(true)

	render.SetStencilTestMask(1)
	render.SetStencilWriteMask(1)

	render.SetStencilReferenceValue(1)

	render.SetStencilCompareFunction(STENCIL_NEVER)
	render.SetStencilPassOperation(STENCIL_REPLACE)
	render.SetStencilFailOperation(STENCIL_KEEP)
	render.SetStencilZFailOperation(STENCIL_KEEP)

	-- entity:DrawModel()

	render.SetStencilReferenceValue(1)

	render.SetStencilCompareFunction(STENCIL_EQUAL)

	render.ClearBuffersObeyStencil(0, 0, 0, 0, true)

	-- surface.SetDrawColor(255, 255, 255, 255)
	-- surface.DrawRect(sw/2 - ScrW()/2, sh/2 - ScrH()/2, sw, sh)

	render.PushRenderTarget(itexture_rt)
	render.ClearRenderTarget(itexture_rt, color_black)
	render.SetMaterial(mat_rt)
	render.DrawScreenQuad()
	render.PopRenderTarget()

	render.SetStencilEnable(false)

	cam.End3D()

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(mat_rt)
	surface.DrawTexturedRect(0, 0, 512, 288)

	--]]

end)

--[[
hook.Add("HUDPaint", me:GetActiveWeapon(), function()

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(mat_rt)
	surface.DrawTexturedRect(0, 0, 512, 288)

end)
--]]
