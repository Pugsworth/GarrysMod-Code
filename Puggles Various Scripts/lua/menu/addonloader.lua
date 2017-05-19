if not file.Exists("lua/menu/addons/", "GAME") then
	-- file.CreateDir("addons");
	return;
end

local foundfiles
for i = 1, #foundfiles do
	include("menu/addons/" .. foundfiles[i]);	
end
