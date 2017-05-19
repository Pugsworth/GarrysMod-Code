local size = 1;	-- pixel scale
local scale = size / 0.8 + 0.8;	-- Based on a default scale of 1 = 10
local yScale = 0.8;
local center = {x = ScrW() / 2, y = ScrH() / 2};
local shouldDrawCenter = true;

local crosshairEnabled = CreateClientConVar("cl_crosshair", "1", true, false);

resource.AddFile("materials/vgui/crosshairs/plusthing.vmt");
local crossTexture = surface.GetTextureID("vgui/crosshairs/plusthing");
-- local colors = {}
local norm = {
	{0, 0},	-- Center
	{0, 1}, -- Down
	{0, -1},-- Up
	{1, 0}, -- Right
	{-1, 0} -- Left
};

local function drawCrosshair()
	
	for k = 1, #norm do
		local normals = norm[k];

		if k == 1 then

			if not shouldDrawCenter then -- if the center should be drawn
				continue;
			end

			if vgui.CursorVisible() then
				local x, y = input.GetCursorPos();
				center.x = x;
				center.y = y;
			end

			surface.SetTexture(crossTexture);
			surface.SetDrawColor(color_white);
			surface.DrawTexturedRect(center.x - 16 / 2, center.y - 16 / 2, 16, 16);

		else		
			center.x = ScrW() / 2;
			center.y = ScrH() / 2;
		end

		local x, y = normals[1] * (scale * 10), (normals[2] * yScale) * (scale * 10);

		local mid = size / 2;
		
		surface.SetDrawColor(Color(55, 55, 55, 55));
		surface.DrawRect(center.x - mid + x, center.y + (y - mid), size + 2, size + 2);
		//							            					size + 2; size of the white square plus one pixel for the border
		
		surface.SetDrawColor(color_white);
		surface.DrawRect(center.x - mid + x + 1, center.y + y + 1 - mid, size, size);
		//										+ 1 to move white one in

		if false then
			surface.SetDrawColor(Color(255, 25, 25));
			surface.DrawLine(center.x, 0, center.x, ScrH());
			surface.DrawLine(0, center.y, ScrW(), center.y);
		end
	end
end

if crosshairEnabled:GetBool() then
	hook.Add("HUDPaint", "HL2.Crosshair", drawCrosshair);
end

cvars.AddChangeCallback("cl_crosshair", function(cvar, old, new)
	if old == new then return; end
	
	if tobool(new) then
		hook.Add("HUDPaint", "HL2.Crosshair", drawCrosshair);
	else
		hook.Remove("HUDPaint", "HL2.Crosshair");
	end
end);
