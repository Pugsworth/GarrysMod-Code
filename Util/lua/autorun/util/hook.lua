local cmd = string.format("hook_removeall_%s", CLIENT and "c" or "s");

concommand.Add(cmd, function(ply, cmd, args)
	if not IsValid(ply) then return; end

	local arg = args[1];
	local hooks = hook.GetTable();

	for name, tab in pairs(hooks) do
		for uid, func in pairs(tab) do

			if tostring(uid):lower() == arg:lower() then
				hook.Remove(name, uid);
				print(string.format("Removed hook ['%s']['%s']", name, uid));
			end

		end
	end

end);
