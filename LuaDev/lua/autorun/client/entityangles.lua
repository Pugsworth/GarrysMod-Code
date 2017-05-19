local CVARS = {
	enable = CreateClientConVar("entityangles_enable", 1, true, false),
	maxDistance = CreateClientConVar("entityangles_maxdistance", 1024, true, false),
	hideWithHud = CreateClientConVar("entityangles_maxdistance", 0, true, false),
	onlyWithGmodWeapons = CreateClientConVar("entityangles_onlygmodweapons", 1, true, false)
};

local MAX_DISTANCE = 0x100000 -- 1024^2

local locallen = 8;
local worldlen = 4;
local gaplen   = 2;

local wforward = Vector(1, 0, 0);
local wright   = Vector(0, 1, 0);
local wup      = Vector(0, 0, 1);

local ang;
local pos;
local forward;
local right;
local up;

local pnlHUD;

local function isHudVisible()

	if not pnlHUD then
		pnlHUD = GetHUDPanel();
	end

	return pnlHUD:IsVisible();

end

local gmodweps = {
	[-1] = false,
	["weapon_physgun"] = true,
	["gmod_tool"] = true
};


local function drawAngles()
	if CVARS.hideWithHud:GetBool() and isHudVisible() == false then return; end
	local me = LocalPlayer();
	local wep = me:GetActiveWeapon();
	if CVARS.onlyWithGmodWeapons:GetBool() and (not IsValid(wep) or gmodweps[wep:GetClass()] ~= true) then return; end

	local ent = me:GetEyeTrace().Entity;
	if IsValid(ent) and not ent:IsWorld() and not ent:IsPlayer() then

		if ent:GetPos():DistToSqr(me:EyePos()) > MAX_DISTANCE then return end

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

--[[
		local mins, maxs = ent:WorldSpaceAABB();
		local pos = (mins + maxs) / 2;
		pos.z = mins.z;
		render.DrawWireframeSphere(pos, 2, 5, 5, color_white, false);
]]


		-- new idea
		-- calculate point using trace that starts within model and uses the exit point as the new starting point
	end
end

-- initialize with hook active if convar is enabled
if CVARS.enable:GetBool() then
	hook.Add("PostDrawOpaqueRenderables", "Entity.Angles", drawAngles);
end

cvars.AddChangeCallback(CVARS.enable:GetName(), function(cvar, old, new)
	if tonumber(new) >= 1 then
		hook.Add("PostDrawOpaqueRenderables", "Entity.Angles", drawAngles);
	else
		hook.Remove("PostDrawOpaqueRenderables", "Entity.Angles");
	end
end);

cvars.AddChangeCallback(CVARS.maxDistance:GetName(), function(cvar, old, new)
	MAX_DISTANCE = tonumber(new) ^ 2;
end);
