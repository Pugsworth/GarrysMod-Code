timer.Simple(0, function()


	local function GetMaterialsToFix(tblpaths)

		local ret = {};
		local matpath;

		for k, v in ipairs(tblpaths) do

			matpath = string.format("materials/%s/*.vmt", v:gsub("^[\\/]?materials[\\/]?(.+)[\\/]*$", "%1"));

			for i, j in ipairs((file.Find(matpath, "GAME"))) do
				ret[#ret+1] = string.format("%s/%s", v, j:gsub("%.vmt", ""));
			end

		end

		return ret;

	end

	local bFixed = false;
	local function FixMaterials(var, old, new)

		if bFixed or tonumber(new) == 0 then return end

		local materials = GetMaterialsToFix({
			"shadertest",
			"dev",
			"debug"
		});

		for k, v in ipairs(materials) do
			Material(v);
		end

		print(string.format("Fixed: %u materials", #materials));

		bFixed = true;

	end


	local cmds = {
		"vcollide_wireframe",
		"mat_wireframe"
	};
	for k, v in ipairs(cmds) do
		local callbacks = cvars.GetConVarCallbacks(v);
		if callbacks == nil or table.Count(callbacks) == 0 then
			cvars.AddChangeCallback(v, FixMaterials);
		end
	end
end);
