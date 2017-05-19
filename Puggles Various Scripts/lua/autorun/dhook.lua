--[[

  						dhook

		Small wrapper library for easy developing with hooks

		by Pugsworth under GPLv2

--]]

dhook = dhook or {stored = {}};

---------------------------------------------------------------------------
-- Utility function to check if the given name and unique is a valid hook
---------------------------------------------------------------------------

local function isvalidhook(name, unique) -- TODO: this is awful

	if not dhook.stored[name] or not dhook.stored[name][unique] then
		error("dhook error: hook ", tostring(name), ": ", tostring(unique), " doesn't exist", 2);
	end

end

----------------------------------------------------
-- Utility function to perform action on all hooks
----------------------------------------------------

-- helper function to quickly loop over all hooks and run a function on them
local function loophooks(func)

	for name, tab in pairs(dhook.stored) do
		for unique, extra in pairs(tab) do

			func(name, unique, extra);

		end
	end

end

---------------------------
-- Messaging abstraction
---------------------------

local function headermessage(message)

	local text = "dhook: ", message;	
	local ilength = #text;

	MsgC(Color(120, 200, 255),
		"\n\n",
		string.rep("-", ilength + 2),
		" ", text,
		string.rep("-", ilength + 2),
		"\n\n");

end

local function debugmessage(...)
	-- if GetConVarNumber("developer") < 1 then return end
	MsgN("dhook: ", ...);
end

local function message(...)
	MsgN(...);
end

--------------
-- Add hooks
--------------
function dhook.add(name, unique, func)

	--[[if type(unique) ~= "string" then
		error("dhook error: bad argument #2 (string expected, got ", type(unique), ")"); -- TODO: Better error handling
	end--]]

	if type(func) ~= "function" then
		error("dhook error: bad argument #3 (function expected, got ", type(func), ")");
	end

	if not dhook.stored[name] then
		dhook.stored[name] = {};
	end

	hook.Add(name, unique, func);
	dhook.stored[name][unique] = {func = func, enabled = true, inserttime = CurTime()};
	debugmessage("added hook ", tostring(name), ": ", tostring(unique));

end
------------------
--	Remove hooks
------------------
function dhook.remove(name, unique)

	--[[if type(unique) ~= "string" then
		error("dhook error: bad argument #2 (string expected, got ", type(unique), ")");
	end--]]

	isvalidhook(name, unique);

	hook.Remove(name, unique);
	dhook.stored[name][unique] = nil;

	-- TODO: remove empty name tables

	debugmessage("removed hook ", tostring(name), ": ", unique); 

end

-------------------
-- Disable hooks
-------------------
function dhook.disable(name, unique)

	isvalidhook(name, unique);

	if not dhook.stored[name][unique].enabled then return end

	hook.Remove(name, unique);
	dhook.stored[name][unique].enabled = false;
	debugmessage("disabled hook ", tostring(name), ": ", unique);

end

------------------
-- Enable hooks
------------------
function dhook.enable(name, unique)
	
	isvalidhook(name, unique);

	if dhook.stored[name][unique].enabled then return end

	hook.Add(name, unique, dhook.stored[name][unique].func);
	dhook.stored[name][unique].enabled = true;
	debugmessage("enabled hook ", tostring(name), ": ", unique);

end

------------------------
--	Print stored hooks
------------------------
function dhook.print() -- TODO: better printing

	headermessage("Printing ", (SERVER and "Server" or "Client"), " hooks");
	
	for name, tab in pairs(dhook.stored) do
		Msg("\n");

		for key, data in pairs(tab) do
			
			col = data.enabled and Color(50, 180, 50, 255) or Color(180, 50, 50, 255);
			MsgC(col, name, ": ", key, "\t\t", "Enabled: ", tostring(data.enabled), "\n");

		end

	end

end

-------------------------
--	List hooks by match
-------------------------

function dhook.find()

	debugmessage("Find is still wip.");

end

-----------------------------------------------
--	Find and display information about a hook
-----------------------------------------------

function dhook.getHookInformation(name, unique)

	isvalidhook(name, unique);

	local func = dhook.stored[name][unique].func;

	if not func then error("dhook: function not valid", 2); end
	if type(func) ~= "function" then error(string.format("dhook: [getHookInfomation] function invalid (expected \"function\" got %s)", type(func)), 2); end

	local info = debug.getinfo(func);

	if info == nil then return; end
	if info.what ~= "Lua" then return; end -- TODO: inform user

	if string.sub(info.source, 1, 1) == "@" then -- is file

		local sfile = select(3, string.find(info.source, "(lua/.+)"));

		if not sfile then return; end

		local f = file.Open(sfile, "r", "GAME");
		if f then
			
			local sfilecontents = f:Read(f:Size());
			local tbl = string.Split(sfilecontents, "\n"); -- TODO: line feed os dependent
			local pre, post = info.linedefined, info.lastlinedefined;
			local tdesired = {};

			for i = 1, #tbl do
				
				if i > pre-1 and i < post+1 then
					table.insert(tdesired, tbl[i]);
				end
				
			end

			headermessage("information on hook ", name, ": ", unique);

			MsgC(Color(255, 255, 255), "Name: ");
			MsgC(Color(200, 200, 200), #info.namewhat > 0 and info.namewhat or ("Anonymous [" .. tostring(info.func) .. "]"), "\n");

			MsgC(Color(255, 255, 255), "Source:\n");
			MsgC(Color(200, 200, 200), string.Trim(table.concat(tdesired, "\n")));
			MsgN("");
			f:Close();
			
		end

	end

end

-------------------------------------
-- Convert existing hooks to dhook
-------------------------------------
function dhook.convert(ply, cmd, args)

	local name = args[1];
	local bispat = args[2] == '1' and true or false;
	local buniqueid = args[3];

	debugmessage(string.format("Attempting to convert %s Hooks", name or "all"));

	for hname, tab in pairs(hook.GetTable()) do
		if name and #name > 0 and hname ~= name then
			continue;
		end
		
		Msg("\n");

		if type(tab) ~= 'table' then
			continue;
		end

		for key, func in pairs(tab) do

			dhook.add(hname, key, func);

			-- hook.Remove(hname, key, func);		

		end		
	end

end

-----------------------------------------------------------
-- Utility function to perform action on specific hook(s)
-----------------------------------------------------------

-- 3 functions require the same general code with a different end function call
-- so let's localize the general function and accept that function as an argument
local function performspecific(func, ply, cmd, args, str) -- TODO: better name
	-- purpose:     remove named hooks
	-- arguments:   <name or unique> [unique] [toggleexpression]

	local sname;
	local sunique;
	local btogexp = false;

	if #args == 0 then
		return;

	elseif #args == 1 then
		sunique = args[1];

	elseif #args == 2 then
		if args[2] == "1" then
			sunique = args[1];
			btogexp = true;
		else
			sname = args[1];
			sunique = args[2];
		end

	elseif #args == 3 then
		sname = args[1];
		sunique = args[2];
		btogexp = args[3] == "1" and true or false;

	end

	if not sname and sunique then
		loophooks(function(_name, _unique)

			if btogexp then
				if tostring(_unique):lower():find(sunique) then
					func(_name, _unique);
				end

			else
				if _unique == sunique then
					func(_name, _unique);
				end
			end

		end);

	else
		func(sname, sunique);
	end

end

-----------------------------------------------------
--	Utility function to perform action on last hook
-----------------------------------------------------

local function performlast(func, ply, cmd, args, str) -- TODO: better name, I'm awful at these

	local last = {name = "", unique = "", time = 0};

	loophooks(function(name, unique, extra)

		if extra.inserttime > last.time then -- time counts upwards, so we get the highest one to signify the latest
			last = {name = name, unique = unique, time = extra.inserttime};
		end

	end);

	if last.name ~= "" then
		debugmessage(last.name, ": ", last.unique);
		func(last.name, last.unique);
	end

end

-- table for the functions of each state.
-- needed due to each state needing a separeate concommand, but using the same code
local cmdfuncs = {
	--                                  due to how varargs work, you can only forward them at the end of the arguments
	["remove"]      =   function(...)   performspecific(dhook.remove, ...); 	end,
	["remove_all"]  =   function()      loophooks(dhook.remove); 				end,
	["remove_last"] =   function(...)   performlast(dhook.remove, ...); 		end,

	["enable"]      =   function(...)   performspecific(dhook.enable, ...); 	end,
	["enable_all"]  =   function()      loophooks(dhook.enable); 				end,
	["enable_last"] =   function(...)   performlast(dhook.enable, ...); 		end,
	
	["disable"]     =   function(...)   performspecific(dhook.disable, ...); 	end,
	["disable_all"] =   function()      loophooks(dhook.disable); 				end,
	["disable_last"]=   function(...)   performlast(dhook.disable, ...); 		end,

	["print"] 		=	dhook.print,

	["convert"]		=	dhook.convert,

	["find"]		= 	dhook.find,
	["information"] = 	function(...) performspecific(dhook.getHookInformation, ...); end
};

-- generate the needed console command for each state
for strcmd, func in pairs(cmdfuncs) do

	concommand.Add(string.format("%s%s%s", "dhook_", (SERVER and "sv_" or ""), strcmd), func);

end

/*
--[[
	TODO:
		convert:
			one at a time

		find:
			both dhook and default

		Colours:
			Use a global colour scheme

		Abstract:
			printing and debugging


-- local t = {};
local t = table.Copy(dhook.stored.HUDPaint);

function astoar(tab, breverse)
	
	local t = {};
	
	for k, v in pairs(tab) do
		if breverse then
			t[v[1]] = v[2];
		else
			table.insert(t, {k, v});
		end
	end
	
	return t;
	
end

local t = astoar(t);

table.sort(t, function(a, b) local na, nb = a[2].enabled and 1 or 0, b[2].enabled and 1 or 0 return na < nb end);


table.foreach(t, function(k, v)
	
	local unique = v[1];
	local data = v[2]
	
	col = data.enabled and Color(70, 160, 70) or Color(160, 70, 70);

	MsgC(col, unique, " - ", data.enabled);
	Msg("\n");
	
end);

--[.[
local t = astoar(t, true);
table.foreach(t, function(k, v)
	
	col = v.enabled and Color(118, 138, 136, 255) or Color(145, 58, 31, 255);
	
	MsgC(col, k, v.enabled);
	Msg("\n");
	
end);

--[.[

table.sort(t, function(a, b) return a.enabled end);


for key, data in pairs(t) do

	col = data.enabled and Color(118, 138, 136, 255) or Color(145, 58, 31, 255);
	MsgC(col, "Think :", key, "\t\t", "Enabled: " .. tostring(data.enabled), "\n");

end--].]

*/
--]]
