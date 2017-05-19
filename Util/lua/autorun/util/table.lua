function table.makeLookup(tbl)

	for i = #tbl, 1, -1 do
		tbl[tbl[i]] = true;
		tbl[i] = nil;
	end

	return tbl;

end

----------------
-- functional --
----------------

local funcmappings = {
	["+"] = function() end,
	["-"] = function() end,
	["*"] = function() end,
	["/"] = function() end,
	["%"] = function() end,
	["^"] = function() end,
}

local function getIterator(obj) end
local function toFunction(obj)

	if type(obj) == "string" then
		if funcmappings[obj] then
			return funcmappings[obj];
		end
	elseif type(obj) == "function" then
		return obj;
	end

end

-- for each element, replace if return value is not nil
function table.map(self, func)

    local mapped = {};

    for k, v in next, self do
        mapped[k] = func(v, k);
    end

    return mapped;

end

-- iterates table
function table.forEach(self, func)
    for k, v in next, self do
        func(v, k);
    end

    return self; -- allow for chaining
end
-- select = table.forEach; -- we don't need pointless aliases I think

-- for each element, keeps if return is not nil
function table.filter(self, comparator)

    local filtered = {};

    for k, v in next, self do
        if comparator(v, k) ~= nil then
            filtered[k] = v;
        end
    end

    return filtered;

end
-- folds function between i and i+1 element and places at i index
function table.fold() end
function table.foldr() end

-- takes list and returns until predicate is false
function table.takeWhile(self, comparator)

    local taken = {};

    for k, v in next, self do
        if comparator(v, k) == false then
            return taken;
        end
        taken[k] = v;
    end

    return taken; -- return the copy even if it's a clone of the table

end

-- takes list and drops until predicate is false
function table.dropWhile(self, comparator)

    local bDropNoMore = false;
    local taken = {};

    for k, v in next, self do
        if bDropNoMore == true then
            taken[k] = v;
        elseif comparator(v, k) == false then
            bDropNoMore = true;
        end
    end

    return taken;

end

-- takes two or more arrays and returns an array of the nth index of each array. length is the smallest length of inputs
-- this doesn't really make sense on non-array tables.
function table.zip(...) -- ar2, no... now an ar3, sure, plenty of times

    local lists = {...};
    local shortestLength = math.huge;
    local zipped = {}; -- final zipped version

    local i = 1;
    while i < 1e5 do
        local current = {};

        for j = 1, #lists do
            local list  = lists[j];
            local v     = list[i];

            if v == nil then
                return zipped; -- if any are nil on this iteration, we are 1 iteration over
            end

            current[#current+1] = v;
        end

        zipped[i] = current;

        i = i + 1;
    end

    return zipped;

end

-- now do the opposite of zip
-- visit each iteration and build a new array
-- return unpack(all)
function table.unzip() end

-- reverses table
function table.reverse(self)

    local reversed = {};
    local len = #self;

    for i = len, 1, -1 do
        reversed[len-(i-1)] = self[i];
    end

    return reversed;

end

-- flattens multi-dimensional array to single dimension
-- function table.flatten(self)

    -- local flattened = {};

    -- for i = 1, #self do
        -- local v = self[i];
        -- if type(v) == "table" then
            -- local recur = table.flatten(v);
            -- flattened = 
        -- end
    -- end

    -- return flattened;

-- end

-- returns true when all of the values pass the test
function table.all(self, comparator)

    for k, v in next, self do
        if comparator(self, k, v) == false then
            return false;
        end
    end

end
-- returns true when any value passes the test
function table.any(self, comparator)

    for k, v in next, self do
        if comparator(self, k, v) == true then
            return true;
        end
    end

end

-- returns slice
function table.slice()
end

-- return value:signature() for each value that is a function
function table.signatures(self)
    local ret = {};

	for name, thing in pairs(self) do
		if isfunction(thing) then
			local sig = thing:signature();
			if sig != "C" then
				ret[#ret+1] = sig;
			end
		end
	end

	table.sortHuman(ret);

	return ret;

end

function table.sortHuman(self, bDescending)
	local tbl = self;
	table.sort(tbl, function(left, right)
		return string.lower(left) > string.lower(right);
	end);

	if bDescending then
		local rev = {};
		for i = #tbl, 0, -1 do
			rev[#rev] = tbl[i];
		end
		return rev;
	end

	return tbl;
end
