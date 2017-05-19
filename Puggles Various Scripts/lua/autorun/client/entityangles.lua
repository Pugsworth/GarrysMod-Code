local cvarEnable = CreateClientConVar("entityangles_enable", 1, true, false);

local locallen = 8;
local worldlen = 4;
local gaplen   = 2;

local wforward = Vector(1, 0, 0);
local wright   = Vector(0, 1, 0);
local wup      = Vector(0, 0, 1)

local ang;
local pos;
local forward;
local right;
local up;

function drawAngles()
	local ent = LocalPlayer():GetEyeTrace().Entity;
	if IsValid(ent) and not ent:IsWorld() and not ent:IsPlayer() then
		ang 	= ent:GetAngles();
		pos     = ent:GetPos();
		forward = ang:Forward();
		right   = ang:Right();
		up      = ang:Up();

		-- local angles
		render.DrawLine(pos, pos + forward * locallen, Color(255, 0, 0), false);
		render.DrawLine(pos, pos + right   * locallen, Color(0, 255, 0), false);
		render.DrawLine(pos, pos + up      * locallen, Color(0, 0, 255), false);
		-- world angles
		render.DrawLine(pos + wforward * (locallen + gaplen), pos + wforward * (locallen + gaplen + worldlen), Color(255, 0, 0), false);
		render.DrawLine(pos + wright   * (locallen + gaplen), pos + wright   * (locallen + gaplen + worldlen), Color(0, 255, 0), false);
		render.DrawLine(pos + wup      * (locallen + gaplen), pos + wup      * (locallen + gaplen + worldlen), Color(0, 0, 255), false);
	end
end

if cvarEnable:GetInt() >= 1 then
	hook.Add("PostDrawOpaqueRenderables", "Entity.Angles", drawAngles);
end

cvars.AddChangeCallback("entityangles_enable", function(cvar, old, new)
	if tonumber(new) >= 1 then
		hook.Add("PostDrawOpaqueRenderables", "Entity.Angles", drawAngles);

	else
		hook.Remove("PostDrawOpaqueRenderables", "Entity.Angles");
	end
end);
