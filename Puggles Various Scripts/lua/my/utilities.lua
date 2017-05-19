-- SHARED
for k, v in pairs({'table', 'string', 'number', 'function'}) do
	_G["is%s" .. v] = function(var) return type(var) == v; end
end

function util.TransformTableValues(tbl)
	for i = #tbl, 1, -1 do
		tbl[tbl[i]] = true;
		tbl[i] = nil;
	end
	return tbl;
end

--[[
	string metatable scope
--]]
do
	local meta = getmetatable(""); -- FindMetaTable("String");
	meta.__mod = function(left, right)
		if istable(right) then
			return string.format(left, unpack(right));

		elseif isstring(right) or isnumber(right) then
			return string.format(left, right);
		end
	end
	
	local enums = {
		{"CASE_ALL_UPPER", string.upper},
		{"CASE_ALL_LOWER", string.lower},

		{"CASE_BOUNDRY_UPPER", function(str)
			return string.gsub(str, "(%l)(%w+)", function(a, b)
				return table.concat({string.upper(a), b});
			end);
		end},
		{"CASE_BOUNDRY_LOWER", function(str)
			return string.gsub(str, "(%w+)", function(a)
				return table.concat({string.lower(a:sub(1, 1)), a:sub(2)});
			end);
		end}
	};
	for i = 1, #enums do
		string[enums[i][1]] = i;
	end

	meta.__pow = function(left, right)
		if enums[right] then
			return enums[right][2](left);
		end
	end

	meta.__unm = string.reverse;
	meta.__sub = function(left, right) return left:gsub(right, ""); end
	meta.__mul = function(left, right) if not isnumber(right) then return left; end return string.rep(left, right); end
	-- meta.__div = function(left, right) end

end

-- misc functions
function CreateDirIfMissing(dir, pathid)
	if file.Exists(dir, pathid or "GAME") then return end

	file.CreateDir(dir);
end

function Return(...)
	return (function() return ...; end);
end

function printf(str, ...)
	print(string.format(str, ...));
end

function default(inp, default)
	return IsValid(inp) and inp or default;
end

function incr(val, by)
	val = val + (by or 1);
	return val;
end

function decr(val, by)
	val = val - (by or 1);
	return val;
end

function LookupEnum(sPrefix, enum)
	for k, v in pairs(_G) do
		if k:lower():find("^" .. sPrefix:lower()) then
			if enum and v == enum then
				print(k, v);
			end
			print(k, v);
		end
	end
end

function Benchmark(func, times)
	times = times or 1e4; -- 10,000
	prinf("Benchmark starting for (%s)", tostring(func));
	local starttime = SysTime();

	for i = 1, times do
		func();
	end

	local endtime = SysTime() - starttime;
	printf("Benchmark (%s) finished in: %s seconds", tostring(func), endtime);
end

if SERVER then

	local function isValidConstraintEntity(ent)
		if not IsValid(ent) then return false; end
		if ent:IsPlayer() then return false; end
		if ent == game.GetWorld() then return true; end
		return true;
	end

	function rope(ent1, ent2, addlength, rigid)
		if isValidConstraintEntity(ent1) and isValidConstraintEntity(ent2) then
			return constraint.Rope(ent1, ent2, 0, 0, vector_origin, vector_origin, ent1:GetPos():Distance(ent2:GetPos()), addlength, 0, 4, 'cable/rope', rigid);
		end 
		return nil;
	end

	--[[
		Player Resize scope
	--]]
	do
		local HULL = {
			VIEW          = Vector(0, 0, 64),		-- VEC_VIEW (m_vView)
			DUCK_VIEW     = Vector(0, 0, 28),		-- VEC_DUCK_VIEW(m_vDuckView)		
			
			HULL_MIN      = Vector(-16, -16, 0),	-- VEC_HULL_MIN (m_vHullMin)
			HULL_MAX      = Vector(16,  16,  72),	-- VEC_HULL_MAX (m_vHullMax)
			
			DUCK_HULL_MIN = Vector(-16, -16, 0),	-- VEC_DUCK_HULL_MIN (m_vDuckHullMin)
			DUCK_HULL_MAX = Vector(16,  16,  36)	-- VEC_DUCK_HULL_MAX(m_vDuckHullMax)
		}


		function Resize(ply, scale, extra)
			ply:SetModelScale(scale, 0.5);
			
			ply:SetHull(HULL.HULL_MIN * scale, HULL.HULL_MAX * scale);
			ply:SetHullDuck(HULL.DUCK_HULL_MIN * scale, HULL.DUCK_HULL_MAX * scale);
			
			ply:SetViewOffset(HULL.VIEW * scale);
			ply:SetViewOffsetDucked(HULL.DUCK_VIEW * scale);
			
			if extra then
				ply:SetJumpPower(200 * scale);
				ply:SetStepSize(18 * scale);
			end
		end

		local meta = FindMetaTable("Player");
		meta.Resize = Resize;
	end

else -- CLIENT
end
