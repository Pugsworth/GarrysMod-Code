local dependencies = {};

MsgC(Color(255, 175, 120), "Initalizing utilities...\n");

local files = file.Find("lua/autorun/util/*.lua", "GAME");

for i = 1, #files do

	local f = files[i];
	local str = string.format("util/%s", f);

	include(str);
	print(string.format("Loaded %s", str));

end

-- manage dependencies with util libraries (i.e. entity needs vector and angle util first)
function util.dependancy(name)
	dependencies[name] = {loaded = false};
end
