-- package.path = package.path .. ";C:\\Program Files (x86)\\lua\\library\\?.lua";

-- require("point");

local getinfo = debug.getinfo;

local _fDummy = function() end
local meta = debug.getmetatable(_fDummy) or {};

debug.setmetatable(_fDummy, meta);

meta.__index = meta;

-- methods

-- nparams          int
-- namewhat         string?
-- what             string
-- currentline      int
-- isvararg         bool
-- short_src        string path
-- linedefined      int
-- func             function pointer
-- source           string path
-- lastlinedefined  int
-- nups             int
-- istailcall       bool

local function getPath(info)

    local src = info.source;

    return (string.gsub(src, "@", ""));

end

-- returns the source code if it can be read
function meta:src(bSigOnly, bIncludeFile)

    local info = getinfo(self);

    if info.what == "C" then return "C"; end

    local path = getPath(info);
    local text;
    if gmod then
        text = file.Read(path, "GAME");
    else
        text = io.open(path, "r"):read("*a");
    end

    local startline, endline = info.linedefined, info.lastlinedefined;
    if not startline or not endline then return false; end

    local ret = {};

    if bIncludeFile then
        ret[#ret + 1] = info.source .. ':' .. startline;
    end

    local i = 1;
    for line in string.gmatch(text, "(.-)\r?\n") do
        if i >= startline and i <= endline then
            if bSigOnly then
                ret[#ret + 1] = string.match(line, "((%w+)(%.%w+)*?(%([^%)]-%)))");
                break
            end

            ret[#ret + 1] = line;
        end

        i = i + 1;
    end

    return table.concat(ret, '\n');

end

function meta:signature()

    return self:src(true, false);

end

-- returns the filepath if it can be read
function meta:file()
    return getPath(getinfo(self));
end

-- alias for debug.getinfo
function meta:info()
    return getinfo(self);
end

-- javascript-like binding of functions
function meta:bind(parent, ...)
    local parent = parent
    if parent == nil then
        return function(...)
            local args = {...};
            return self(unpack(args));
        end
    else
        return function(...)
            local args = {...};
            return self(parent, unpack(args));
        end
    end
end

-- detouring
--[[
do

    -- detours function with new function, backs up the old and makes sure it can't be lost
    -- use super() to call original
    local detoured = {};
    function meta:detour(new)

        -- if detoured[self] then
        -- detoured[self] = new
        return (function(...)
            local _ENV = {
                super = function(...)
                    return self(...);
                end
            };

            return new(...);
        end);

    end

    -- restore the original function
    -- should each level of detoured function be stored and restorable?
    function meta:restore(level)
    end

end
--]]

-- for k, v in pairs(package) do print(k, v); end
-- local a = {var = 12, func = function(self, ...) print(self.var, ...); end};

-- a:func()
-- a.func:bind(a, 1, 2, 3, "test")()


-- print = print:detour(function(...)
--     super("test", ...);
-- end);

-- print(1, 2, 3);
