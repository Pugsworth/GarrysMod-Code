local size             = 1; -- pixel scale
local scale            = size / 0.8 + 0.2; -- Based on a default scale of 1 = 10
local yScale           = 0.8;
local center           = {x = ScrW() / 2, y = ScrH() / 2};
local shouldDrawCenter = true;
local velLimit         = math.pow(200, 2);

local crosshairEnabled = CreateClientConVar("cl_crosshair", "1", true, false);

resource.AddFile("materials/vgui/crosshairs/plusthing.vmt");
local crossTexture = surface.GetTextureID("vgui/crosshairs/plusthing");
-- local colors = {}
local norm = {
    {0, 0}, -- Center
    {0, 1}, -- Down
    {0, -1},-- Up
    {1, 0}, -- Right
    {-1, 0} -- Left
};

local velocity = 0;
local function drawCrosshair()

    local speedmod         = Lerp(math.min(1, velocity / velLimit), 0, 8);
    local cursorVisible    = vgui.CursorVisible();
    local curposX, curposY = input.GetCursorPos();

    local cx = center.x;
    local cy = center.y;

    local mid = size / 2;


    for k = 1, #norm do
        local normals = norm[k];

        if k == 1 then

            if not shouldDrawCenter then -- if the center should be drawn
                continue;
            end

            if cursorVisible then
                cx = curposX;
                cy = curposY;
            end

            surface.SetTexture(crossTexture);
            surface.SetDrawColor(color_white);
            surface.DrawTexturedRect(cx - 8, cy - 8, 16, 16);

        end

        local x, y = normals[1] * (scale * (10 + speedmod)), (normals[2] * yScale) * (scale * (10 + speedmod));

        surface.SetDrawColor(Color(55, 55, 55, 55));
        surface.DrawRect(cx - mid + x, cy + (y - mid), size + 2, size + 2);
        --                                             size + 2; size of the white square plus one pixel for the border

        surface.SetDrawColor(color_white);
        surface.DrawRect(cx - mid + x + 1, cy + y + 1 - mid, size, size);
        --                                        + 1 to move white one in

        if false then
            surface.SetDrawColor(Color(255, 25, 25));
            surface.DrawLine(cx, 0, cx, ScrH());
            surface.DrawLine(0, cy, ScrW(), cy);
        end
    end

end

hook.Add("Tick", "HL2.Crosshair", function()
    if not IsValid(LocalPlayer()) then return; end

    velocity = LocalPlayer():GetVelocity():LengthSqr();

end);

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
