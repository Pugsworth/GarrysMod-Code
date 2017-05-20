local me = LocalPlayer()

function getLookatEntity()

	return me:GetEyeTrace().Entity

end

function drawCross(origin, size, angles, color)

	render.DrawLine(origin - angles:Forward() * size, origin + angles:Forward() * size, color, false)
	render.DrawLine(origin - angles:Right() * size, origin + angles:Right() * size, color, false)
	render.DrawLine(origin - angles:Up() * size, origin + angles:Up() * size, color, false)

end

function calculateScreenAABB(entity, vertices)
	local left, top, right, bottom = math.huge, math.huge, 0, 0

	for i = 1, #vertices do
		local sVert = entity:LocalToWorld(vertices[i]):ToScreen()

		left   = math.min(left,   sVert.x)
		top    = math.min(top,    sVert.y)
		right  = math.max(right,  sVert.x)
		bottom = math.max(bottom, sVert.y)
	end

	return {x = left, y = top, width = right - left, height = bottom - top}

end

local lastEntity = nil
hook.Add("HUDPaint", me:GetActiveWeapon(), function()

	local entity = getLookatEntity()

	if IsValid(entity) then
		lastEntity = entity
	end

	if not IsValid(lastEntity) then return end


	local ang = lastEntity:GetAngles()

	local mins, maxs = lastEntity:GetModelBounds()
	local vCenter = mins + ((maxs - mins) / 2)
	-- clockwise from top, starting wtih maxs
	local corners = {
		-- top
		maxs,
		Vector(mins.x, maxs.y, maxs.z),
		Vector(mins.x, mins.y, maxs.z),
		Vector(maxs.x, mins.y, maxs.z),

		-- bottom
		Vector(maxs.x, maxs.y, mins.z),
		Vector(mins.x, maxs.y, mins.z),
		mins,
		Vector(maxs.x, mins.y, mins.z)
	}

	local rect = calculateScreenAABB(lastEntity, corners)

	-- draw corners of AABB
	cam.Start3D(EyePos(), EyeAngles())

	for i = 1, #corners do
		local vert = corners[i]
		-- print(i, vert)
		drawCross(lastEntity:LocalToWorld(vert), 2, ang, Color(83, 241, 235))
	end

	cam.End3D()

	-- print(rect.x, rect.y, rect.width, rect.height)
	surface.SetDrawColor(color_white)
	surface.DrawOutlinedRect(rect.x, rect.y, rect.width, rect.height)

	surface.SetDrawColor(Color(75, 200, 75, 75))
	surface.DrawRect(rect.x+1, rect.y+1, rect.width-2, rect.height-2)

end)
