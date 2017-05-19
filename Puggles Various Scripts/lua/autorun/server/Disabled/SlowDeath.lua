--[[
CreateClientConVar("sv_slowdeath", 0, false, false);

if game.SinglePlayer() then

	if GetConVarNumber("sv_slowdeath") == 0 then return end

	hook.Add("DoPlayerDeath", "SlowDeath", function()

		OldTimeScale = GetConVarNumber("host_timescale");
		RunConsoleCommand("host_timescale", 0.3);

	end);

	hook.Add("PlayerSpawn", "FastSpawn", function()

		if math.Round(GetConVarNumber("host_timescale"), 1) == 0.3 then
			RunConsoleCommand("host_timescale", OldTimeScale);
		end

	end);

end
--]]