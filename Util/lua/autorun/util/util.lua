-- SHARED
for i, v in ipairs({'table', 'string', 'number', 'function'}) do
	local name = string.format("is%s", v);
	if not _G[name] then -- don't overwrite existing ones
		_G[name] = function(var) return type(var) == v; end
	end
end

-- misc functions
function util.CreateDirIfMissing(dir, pathid)
	if file.Exists(dir, pathid or "GAME") then return end

	file.CreateDir(dir);
end

function Return(...)
	local args = {...};
	return (function() return unpack(args); end);
end

function True()		return true;	end
function False()	return false;	end
function Nil()		return nil;		end

function printf(str, ...)
	print(string.format(str, ...));
end

function default(inp, default)
	return inp ~= nil and inp or default;
end

-- utility function to find what enums contain <searchStr>
local function LookupEnum(searchStr, enum)
	assert(type(searchStr) == "string");

	local ret = {};
	local maxlength = 0;
	local bmatched = false

	for k, v in pairs(_G) do
		if searchStr == nil or k:lower():find(searchStr:lower()) and type(v) == "number" then
			bmatched = true;
		end

		if bmatched then
			if not enum or v == enum then
				ret[#ret + 1] = {k, v};
				maxlength = math.max(maxlength, #k);
			end
		end

		bmatched = false;
	end

	table.sort(ret, function(a, b)

		if a[2] ~= b[2] then
			return a[2] < b[2];
		end

		return a[1] < b[1];

	end);

	for i = 1, #ret do
		print(string.format("%s %s= %i", ret[i][1], string.rep(" ", maxlength - #ret[i][1]), ret[i][2]));
	end

end

concommand.Add("lua_lookupenum", function(ply, cmd, args)
	LookupEnum(args[1], tonumber(args[2]));
end);

-- two simple methods for benchmarking a function
-- shouldn't be taken as absolute speed or with definitive accuracy assumption
-- results are relative only to results produced by this function
function Benchmark(func, times, bUseTime)
	if type(times) == "boolean" then
		bUseTime = times;
		times = 1e4;
	end

	if bUseTime then

		local MAX_TIME = 300 -- 5 minutes
		local start = SysTime();
		local iterations = 0;
		local reason = "finished successfully";

		printf("Benchmark starting for (%s)", tostring(func));

		while SysTime() - start < times do
			if SysTime() - start < MAX_TIME then
				reason = "timed out";
				break;
			end

			func();
			iterations = iterations + 1;
		end

		printf("Benchmark (%s) %s with %i executions in %g seconds", tostring(func), reason, iterations, SysTime() - start);

	else

		times = times or 1e4; -- 10,000
		printf("Benchmark starting for (%s)", tostring(func));
		local starttime = SysTime();

		for i = 1, times do
			func();
		end

		local endtime = SysTime() - starttime;
		printf("Benchmark (%s) finished in: %s seconds", tostring(func), endtime);

	end
end

-- if obj is a string, wrap it in quotes, otherwise return tostring(obj)
-- mostly useful for printing
function util.stringify(obj)

	if isstring(obj) then
		return obj:stringify();
	end

	return tostring(obj);

end

function util.pointcircle(count, xr, yr, func, ...)

	local pi = math.pi;
	local slice = pi / count;



	for i = 0, count do

		local slice = pi / count;
		local vec = Vector(math.sin(slice * i) * xr, math.cos(slice * i) * yr, 0);

		func(..., vec);

	end

end

local COL_HI = Color(255, 160, 160);

function util.printLines(path, nstart, nrange, nopstart, noprange)

	if not path then return false; end

	local bhighlight = nopstart ~= nil;

	local text = file.Read(path, "GAME");

	local endline = nstart + ((nrange or 1) - 1);
	local nopendline = nopstart + ((noprange or 1) - 1);

	local i = 1;
	for line in string.gmatch(text, "(.-)\r?\n") do
		if i >= nstart and i <= endline then
			if bhighlight and i >= nopstart and i <= nopendline then
				MsgC(COL_HI, i); MsgC(COL_HI, '| ');
				MsgC(COL_HI, line); MsgN('');
			else
				Msg(i); Msg('| '); -- line number
				MsgN(line); -- line
			end
		end

		i = i + 1;
	end

end

--[[
	performs a trace and returns an array of every hit result
	{
		{TraceRes},
		...
	}
--]]
local TRACE_MAX_DISTANCE = 256^2; -- limit maximum traces incase runaway trace
function util.MultiTrace(tracedata, nHitEnd_callback)
	-- INQUIRE: do intersecting objects cause a trace to report the
	-- end at the start of the next object?

	local callback = nil;
	local nHitEnd = nil;

	if type(nHitEnd_callback) == "function" then
		callback = nHitEnd_callback;
	else
		nHitEnd = tonumber(nHitEnd) or 2;
	end

	local bFirst = true;
	local dist = 0;
	local nHit = 0;
	local traceres = {};
	local res = {};

	local start = vector_origin;
	local endpos = vector_origin;
	local filter = {};

	while true do

		-- if a trace was already perfomed
		-- take the results and create new tracedata that will
		-- continue the trace
		if not bFirst then

			-- start = traceres.
			-- endpos = traceres.

			-- Fraction
			-- FractionLeftSolid
			-- StartSolid
			-- HitWorld
			-- HitSky
			-- HitPos
			-- HitNonWorld
			-- Entity

			tracedata.start = start;
			tracedata.endpos = endpos;
			tracedata.filter = filter;

		else
			bFirst = false;
		end

		tracedata.output = traceres;

		util.TraceLine(tracedata);

		if traceres.Hit then
			nHit = nHit + 1;

			ret[#res + 1] = traceres;

			if callback then -- break if callback told us or if we reached the maximum number of hit objects
				if callback(traceres, nHit) then
					break;
				end
			else
				if nHit >= nHitEnd then
					break;
				end
			end

		end

		if dist >= TRACE_MAX_DISTANCE then
			break;
		end

	end

	return res;

end

function util.QuickMultiTrace(origin, dir, filter)

	local td = {
		start = origin,
		endpos = origin + dir,
		filter = filter
	};

	return util.MultiTrace(td);

end
