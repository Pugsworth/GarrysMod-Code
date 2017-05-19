concommand.Add("bot_kick_all", function(ply, cmd, args)
    for k, v in pairs(player.GetBots()) do
        v:Kick("Bot")
    end
end)
concommand.Add("bot_add", function(ply, cmd, args)
	local count = args[i] or 1;
    for i = 1, args[1] do
        RunConsoleCommand("bot");
    end
end)
