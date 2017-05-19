if SERVER then
	include("tool_measuringstick/init.lua");
	AddCSLuaFile("tool_measuringstick/shared.lua");
	AddCSLuaFile("tool_measuringstick/ui.lua");
	AddCSLuaFile("tool_measuringstick/cl_init.lua");
elseif CLIENT then
	include("tool_measuringstick/shared.lua");
	include("tool_measuringstick/ui.lua");
	include("tool_measuringstick/cl_init.lua");
end
