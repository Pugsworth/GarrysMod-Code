local teams = {
	{"Developers", Color(147, 147, 255)},
	{"Owners", Color(207, 90, 255)}
};


local function Capitalize(str)
	return string.gsub(str, "(%l)(%w+)", function(a, b) return a:upper() .. b:lower() end);
end

local function SetTeams()
	local players = player.GetAll();
	for i = 1, #players do
		local ply = players[i];
		local usergroup = ply:GetUserGroup();
		
		if not msteams.IsDefault(usergroup) then
			local capitalizedTeam = Capitalize(usergroup);
			print(capitalizedTeam);

			if msteams.IsValid(capitalizedTeam) then
				msteams.SetTeam(ply, capitalizedTeam);
				print(ply, capitalizedTeam);
			end
		end
	end

	msteams.SaveTeams();
	msteams.SaveDB();

end

SetTeams();
--[[
local i_lastPlayerCount = 0;
timer.Create("AutoTeams.Timer", 30, 0, function()
	print("Checking Teams...");
	if #player.GetAll() ~= i_lastPlayerCount then
		SetTeams();
	end
end)
;
--]]
