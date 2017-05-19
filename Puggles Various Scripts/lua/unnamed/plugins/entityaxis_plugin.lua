PLUGIN.Name        = "Entity axis";
PLUGIN.Description = "Show local and world axis of entity";
PLUGIN.Author      = "Pugsworth";
PLUGIN.Version     = 1.0;


function PLUGIN:Load()
	self.RegisterHookCommand("+showentityaxis", "PostDrawOpaqueRenderables");
	self.AddCvar("entityaxis_enable", 0, true);
	self.RegisterHookCvar("entityaxis_enable", "PostDrawOpaqueRenderables", 0, true);
end
function PLUGIN:Unload() end

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

function PLUGIN.Hook.PostDrawOpaqueRenderables(bdepth, bskybox)
	local ent = LocalPlayer():GetEyeTrace().Entity;
	if IsValid(ent) and not ent:IsWorld() and not ent:IsPlayer() then
		ang 	= ent:GetAngles();
		pos     = ent:GetPos();
		forward = a:Forward();
		right   = a:Right();
		up      = a:Up();

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
