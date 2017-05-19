local TOOL_CLASS 		= "tool_measuringstick";
local TOOL_LANG_NAME 	= "#tool.tool_measuringstick.name";
local TOOL_LANG_DESC 	= "#tool.tool_measuringstick.desc";
local TOOL_LANG_HELP 	= "#tool.tool_measuringstick.help";
local TOOL_LANG_0 		= "#tool.tool_measuringstick.0";
local TOOL_LANG_1 		= "#tool.tool_measuringstick.1";

TOOL.ClientConVar = {
	ignorez = "false",
	alwaysshow = "false",
	snapworld = "true",
	snapdistance = "8",
}

AccessorFunc(TOOL, "m_istartpoint", "StartPoint"); // set point based on index
AccessorFunc(TOOL, "m_iendpoint", "EndPoint"); // for use with vgui panel when selecting

local function SnapVector(vec, mul)

	if not vec then return end

	local x = mul * math.Round(vec.x / mul);
	local y = mul * math.Round(vec.y / mul);
	local z = mul * math.Round(vec.z / mul);
	
	return Vector(x, y, z);
end

local function RoundVector(vec, decimals)

	if not vec then return end

	local x = math.Round(vec.x, decimals);
	local y = math.Round(vec.y, decimals);
	local z = math.Round(vec.z, decimals);

	return Vector(x, y, z);

end

local function ToStringVector(vec)

	if not vec then return "" end

	return string.format("%g, %g, %g", vec.x, vec.y, vec.z);
end

surface.CreateFont("MeasuringStick_Distance", {font = "Arial", size = 54, weight = 500});
surface.CreateFont("MeasuringStick_Vector",   {font = "Arial", size = 24, weight = 500});

local tbllanguages = {
	{"name", "Measuring Stick"},
	{"help", "Left click for first point, Shift Left Click for second point"},
	{"desc", "Measure points across geometry"},
	{"0", "Left click for first point, Right Click for second point, Reload to make a trace from the surface normal"},
	{"1", "1"}
}

for i = 1, #tbllanguages do
	local lang = tbllanguages[i];
	language.Add(string.format("tool.%s.%s", TOOL_CLASS, lang[1]), lang[2]);
end

function TOOL:Init()
	self.points = {};
	self.Distance = 0;

	self:SetupUI();
end


function TOOL:DrawToolScreen(w, h)

	local width = w * 0.8;
	local height = h * 0.8;

	cam.Start2D()

		render.Clear(0, 0, 0, 255);

		if self:GetPoint(1) and self:GetPoint(2) then
			draw.SimpleText(ToStringVector(RoundVector(self:GetPoint(1), 3)), "MeasuringStick_Vector", w/2, h/2 - 86, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
			draw.SimpleText(ToStringVector(RoundVector(self:GetPoint(2), 3)), "MeasuringStick_Vector", w/2, h/2 - 56, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);

			draw.SimpleText(ToStringVector(self:GetPoint(1) - self:GetPoint(2)), "MeasuringStick_Vector", w/2, h/2 + 56, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
		end

		draw.SimpleText(math.Round(self.Distance, 4), "MeasuringStick_Distance", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
		-- the trace is 16th of a unit off for some reason

	cam.End2D()

end

function TOOL.BuildCPanel(panel)

	panel:AddControl("Header", {Text = TOOL_LANG_NAME, Description = TOOL_LANG_DESC});

	panel.pnlMeasuringStick = vgui.Create("DMeasuringStick");
	panel.pnlMeasuringStick:Dock(FILL);
	panel:AddItem(panel.pnlMeasuringStick);
	

	panel.pnlMeasuringStick.OnStartChanged = function(panel, index)
		panel:SetStartPoint(index);
	end
	panel.pnlMeasuringStick.OnEndChanged = function(panel, index)
		panel:SetEndPoint(index);
	end

end


function TOOL:SetPoint(index, vector)
	self.points[index] = SnapVector(vector, 8);
	self:OnPointChanged(index);
end

function TOOL:GetPoint(index)
	return self.points[index];
end

function TOOL:OnPointChanged(index)
	if not self:GetPoint(1) or not self:GetPoint(2) then return end
	self.Distance = self:GetPoint(1):Distance(self:GetPoint(2));
end

function TOOL:LeftClick(trace)
	self:SetPoint(1, trace.HitPos);
	return true; -- return 'true' to show the tool effect
end

function TOOL:RightClick(trace)
	self:SetPoint(2, trace.HitPos);
	return true; -- return 'true' to show the tool effect
end

function TOOL:Reload(trace)

	local normtrace = util.TraceLine({start = trace.HitPos, endpos = trace.HitPos + trace.HitNormal * 8192, filter = LocalPlayer()});
	if normtrace.Hit then
		self:SetPoint(1, trace.HitPos);
		self:SetPoint(2, normtrace.HitPos);			
	end
	return true;

end

function TOOL:SetupUI()

	local function DrawCross(origin, size, colour, ignorez)
		render.DrawLine(origin - Vector(size, 0, 0), origin + Vector(size, 0, 0), colour, not ignorez);
		render.DrawLine(origin - Vector(0, size, 0), origin + Vector(0, size, 0), colour, not ignorez);
		render.DrawLine(origin - Vector(0, 0, size), origin + Vector(0, 0, size), colour, not ignorez);
	end

	hook.Add("PostDrawTranslucentRenderables", "MeasuringStick.Drawing", function()
		if not self or not self.points then return end

		for i = 1, #self.points do
			local point = self.points[i];

			DrawCross(point, 5, i % 2 == 0 and Color(210, 65, 65) or Color(65, 210, 65), LocalPlayer():GetPos():Distance(point) >= 512 and false or true);

			if i % 2 == 0 then -- check for the end point because it's more likely that the start will exist 
				if not self.points[i-1] then return end

				render.DrawLine(point, self.points[i-1], Color(65, 65, 210), true);

			end

		end
	end);
	
end

