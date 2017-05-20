if true then return false; end -- disable script

local data = {
	triggers = {

	}
};

local color_white = Color(255, 255, 255, 255);
local angle_zero = Angle(0, 0, 0);

local hasInit = false;

function init()

	updateTriggers();
	hasInit = true;

end

if not hasInit then
	init();
end

function updateTriggers()

	local triggers = ents.FindByClass("trigger_changelevel");
	data.triggers = {};

	for i, ent in ipairs(triggers) do

		local trigger_data = {
			entindex = ent:EntIndex(),
			position = ent:GetPos(),
			bounds = { ent:GetModelBounds() },
		};

		table.insert(data.triggers, trigger_data);
	end

end


local function drawCorners(bounds)
	-- render.DrawSphere();
end

local function drawCenter(pos)

	render.DrawWireframeSphere(pos, 8, 4, 8, color_white, true);

end


local function drawDebug()

	render.SetColorMaterial();

	for i, v in ipairs(data.triggers) do

		local bounds = v.bounds

		drawCorners(bounds);

		render.DrawWireframeBox(v.position, angle_zero, bounds.mins, bounds.maxs, color_white, true);

		drawCenter(v.position);

	end

end

hook.Add("PostDrawTranslucentRenderables", "debug.showtransition", drawDebug);

hook.Add("InitPostEntity", "debug.showtransition", init);
