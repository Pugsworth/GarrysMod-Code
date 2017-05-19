module("chatcommand", package.seeall); -- GARRY!!

if SERVER then
	util.AddNetworkString("chat.addtext");

	VERSION = "1.1";

	local commands = {};
	local DELIMS_COMMAND = "!./"; -- single character delimiters
	local DELIMS_ARGUMENTS = ",";
	local PATTERN_COMMAND = string.format("^[%s]([^%%s]+)", DELIMS_COMMAND:gsub("(.)", "%%%1")); -- TODO: better pattern
	local PATTERN_ARGUMENTS = string.format("%%s*([^%s]+)", DELIMS_ARGUMENTS);


	function getCommands()
		return table.Copy(commands);
	end

	function add(cmd, callback)
		local t = type(cmd);

		if t == "table" then
			for i = 1, #cmd do
				commands[cmd[i]] = callback;
			end
		elseif t == "string" then
			commands[cmd] = callback;
		else
			error("string or table expected, got " .. t, 2);
		end
	end

	function remove(cmd)
		local t = type(cmd);

		if t == "table" then
			for i = 1, #cmd do
				commands[cmd[i]] = nil;
			end
		elseif t == "string" then
			commands[cmd] = nil;
		else
			error("string or table expected, got " .. t, 2);
		end
	end

	local function chatprint(...)
		local len = select('#', ...);
		net.Start("chat.addtext");

			net.WriteUInt(len, 8);

			for i = 1, len do
				local v = (select(i, ...));
				net.WriteType(v);
			end

		net.Broadcast();
	end

	concommand.Add("chatcommand", function(ply, cmd, args, raw)
		if commands[args[1]] then
			PrintTable(args);
			print(raw);
			commands[args[1]](ply, args, raw);
		end
	end);

	hook.Add("PlayerSay", "ChatCommands", function(ply, text, bteamchat)
		if IsValid(ply) and ply:IsAdmin() then
			local s, e, cmd = text:find(PATTERN_COMMAND);

			if s then
				-- local cmd = string.sub(text, s, e);
				local args = {};

				for m in string.gmatch(string.sub(text, e+1, -1), PATTERN_ARGUMENTS) do
					table.insert(args, m);
				end

				if commands[cmd] then
					local bshouldblock = hook.Run("ChatCommand", ply, args);
					local bshowtext;

					if not bshouldblock then
						bshowtext = commands[cmd](ply, args, string.sub(text, e+1, -1):Trim());
					end

					if bshowtext == false then
						-- chatprint(ply, ": ", Color(255, 255, 0), unpack(args));
						return "";
					end
				end
			end
		end
	end);

else

	net.Receive("chat.addtext", function()
		local len = net.ReadUInt(8);
		local tblText = {Color(0, 152, 234, 255), "[ChatCommand] "};

		for i = 1, len do
			local t = net.ReadUInt(8);
			local v = net.ReadType(t);

			if t == TYPE_ENTITY and IsValid(v) then
				if v:IsPlayer() then
					table.insert(tblText, v);
				end
			elseif t == TYPE_STRING then
				table.insert(tblText, v);

			elseif t == TYPE_TABLE and IsColor(v) then
				table.insert(tblText, v);
			elseif t == TYPE_INVALID then
				MsgC(Color(255, 100, 100, 255), "[Warning] invalid type sent in chat.addtext");
			end
		end

		chat.AddText(table.concat(tblTextm " "));
	end);
end

---------------------
-- example command --
---------------------
if SERVER then

	add("chatcommand", function(ply, args)
		ply:ChatPrint("Chatcommand version: " .. VERSION);
	end);

end
