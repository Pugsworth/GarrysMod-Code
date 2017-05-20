local tex = GetRenderTarget("P/rt_MapOverview", 512, 512, false);
local mat = CreateMaterial("P/MapOverview", "UnlitGeneric", {
	["$basetexture"] = tex:GetName(),
	-- ["$vertexalpha"] = 1,
	-- ["$vertexcolor"] = 1
});

local bDrawOverview = false;
local bDrawing = false;

hook.Add("ShouldDrawLocalPlayer", "MapOverview", function()
	-- if bDrawing then return true; end
end);

hook.Add("PreDrawSkyBox", "MapOverview", function()
	if bDrawing then
		render.Clear(0, 0, 0, 0, true, true);
		return true;
	end
end);

local bounds = {game.GetWorld():GetModelBounds()};
local origin = (bounds[1] + bounds[2]) / 2;
local mins = bounds[1];
local maxs = bounds[2];

hook.Add("RenderScene", "MapOverview", function()

	if bDrawing then return end

	local oldrt = render.GetRenderTarget();
	local ow, oh = ScrW(), ScrH();

	render.SetRenderTarget(tex)
	render.SetViewPort(0, 0, 512, 512);
	render.Clear(0, 0, 0, 255, true, true); -- clear color, depth, and stencils
	render.ClearDepth();

	local plypos = LocalPlayer():GetPos();
	local z = 1000;

	bDrawing = true;

	cam.Start2D()
	render.RenderView({
		origin        = Vector(origin.x, origin.y, plypos.z),
		angles        = Angle(90, 90, 0),
		x             = 0,
		y             = 0,
		w             = 512,
		h             = 512,
		-- fov           = 90,
		aspectratio   = 1,
		drawviewmodel = false,
		drawhud       = false,
		dopostprocess = false,
		drawmonitors  = false,
		ortho         = true,
		orthotop      = mins.x,
		ortholeft     = mins.y,
		orthoright    = maxs.x,
		orthobottom   = maxs.y,
		znear         = 0,
		zfar          = 10000
	});

	surface.SetDrawColor(color_black);
	surface.DrawOutlinedRect(1, 1, 510, 510);
	cam.End2D();

	bDrawing = false;

	render.SetRenderTarget(oldrt);
	render.SetViewPort(0, 0, ow, oh);

	bDrawOverview = true;

	hook.Remove("RenderScene", "MapOverview");

end);

hook.Add("HUDPaint", "MapOverview", function()

	if bDrawOverview then

		surface.SetDrawColor(color_white);
		surface.SetMaterial(mat);
		surface.DrawTexturedRect(0, 0, 512, 512);

		local plypos = LocalPlayer():GetPos();
		local px, py = plypos.x, plypos.y;

		local sx = maxs.x - mins.x;
		local sy = maxs.y - mins.y;

		local x = (maxs.x - px) / sx;
		local y = (maxs.y - py) / sy;

		surface.SetDrawColor(Color(75, 75, 200));
		surface.DrawRect((512 - (x * 512)) - 4, (y * 512) - 4, 8, 8);
		surface.SetDrawColor(color_black);
		surface.DrawOutlinedRect((512 - (x * 512)) - 4, (y * 512) - 4, 8, 8);

		print(x, y);

	end

end);
