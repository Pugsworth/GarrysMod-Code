--[[
	string metatable scope
--]]
do
	local meta = getmetatable(""); -- FindMetaTable("String");

	-- string format operator %
	-- "test %s" % "string" = "test string"
	meta.__mod = function(left, right)
		if istable(right) then
			return string.format(left, unpack(right));

		elseif isstring(right) or isnumber(right) then
			return string.format(left, right);
		end
	end

	-- string case operator ^
	-- "test string" ^ string.CASE_BOUNDRY_UPPER = "Test String"
	local enums = {
		{"CASE_ALL_UPPER", string.upper},
		{"CASE_ALL_LOWER", string.lower},

		{"CASE_BOUNDRY_UPPER", function(str)
			return string.gsub(str, "(%l)(%w+)", function(a, b)
				return string.upper(a) .. b;
			end);
		end},
		{"CASE_BOUNDRY_LOWER", function(str)
			return string.gsub(str, "(%l)(%w+)", function(a, b)
				return string.lower(a) .. b;
			end);
		end}
	};

	-- add enums to string table
	for i = 1, #enums do
		string[enums[i][1]] = i;
	end

	meta.__pow = function(left, right)
		if enums[right] then
			return enums[right][2](left);
		end
	end

	-- -"test string" = "gnirts tset"
	meta.__unm = string.reverse;
	-- "test string" - "test" = " string"
	meta.__sub = function(left, right) return left:gsub(right, ""); end
	-- "test string" * 3 = "test stringtest stringtest string"
	meta.__mul = function(left, right) if not isnumber(right) then return left; end return string.rep(left, right); end

	-- meta.__div = function(left, right) end

end

function string.stringify(str)

	return string.format('"%s"', str);

end
