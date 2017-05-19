local format = string.format;
local trim = string.Trim;

-- TODO: version, author, etc
-- make sure whatever "chatcommand" module is there is something that can be compatible
require("chatcommand");
if not chatcommand then
    MsgC(Color(255, 100, 100, 255), "chatcommand module not found, chatcommands won't be available!\n");
end

luadev = luadev or {};

MsgC(Color(255, 255, 100), "Luarun Initalized\n");


-------------
-- Convars --
-------------

-- TODO: Implement a custom config command?
-- E.G. ld_config <key> <value>
local convars = {
    ["config"] = {
        ["pp_verbosity"] = {0, FCVAR_ARCHIVE, "The verbosity level of pretty printing."},
        ["return_symbol"] = {"@", FCVAR_ARCHIVE, "The symbol to indicate where 'return' should start.\n - This allows some setup before operating on the code.\n - E.G. ld_pp local things = {} table.forEach(ents.FindByClass('func_*'), function(v) things[#things+1]=v end) @things"}
    }
};

for k, v in next, convars.config do
    local cvar = CreateConVar("ld_s_" .. k, unpack(v));
    convars[k] = cvar;
end


----------------------------
-- Sandboxed global table --
----------------------------

local sandboxed_G = {};
local cmd = CLIENT and "ld_dump_globalsm" or "ld_dump_globals";
concommand.Add(cmd, function(ply, cmd, args)
    PrintTable(sandboxed_G);
end);

-----------------------
-- utility functions --
-----------------------

local function findPlayerByName(name)
    local plys = player.GetAll();

    for i = 1, #plys do
        if plys[i]:Name():lower():find(name) then
            return plys[i];
        end
    end
end

local function findEntity(name, bPlayerFirst)
    local ent;

    if bPlayerFirst then
        ent = findPlayerByName(name); -- playername > entity name | entity class
    end

    if not IsValid(ent) then
        local ents = ents.GetAll();

        for i = 1, #ents do
            local e = ents[i];
            if e.GetName and e:GetName():lower():find(name) then
                ent = e;
                break;
            elseif e:GetClass():lower():find(name) then
                ent = e;
                break;
            end
        end
    end

    return ent;
end

local function getTable(var)
    -- ehhhhh
    local err = false;

    if not var then
        err = true;

    elseif ispanel(var) then
        return var;

    -- ugly hack because whatever nonsense ispanel and the garryui is doing in C
    -- DPanel is a table for a panel, but not a panel "object", which causes errors
    elseif var.ThisClass and var.Valid == DPanel.Valid then
        return var;

    elseif var.GetTable and var:GetTable() then
        return var:GetTable();

    elseif type(var) ~= "table" then
        err = true;
    end

    if err then
        print("expected table, got " .. type(var));
        return nil;
    end

    return var;

end

-- TODO: should be its own thing
local stringify = string.stringify or 
function(...)
    local len = select('#', ...);
    local first, rest = (select(1, ...)), select(2, ...);

    if first == nil then
        first = "nil";
    elseif type(first) == "string" then
        first = string.format('"%s"', first); -- wrap quotes around strings
    end

    if len == 1 then
        return first;
    end

    return first, stringify(rest);
end

local function human_sort(a, b)

    --[[
    number
    boolean
    angle
    vector
    entity
    table
    function
    --]]

    return a < b;

end

local VECTOR_ONE = Vector(1, 1, 1);

local funcs = {
    {"findsphere", function(size, f)
        if type(size) == "function" then
            f = size;
            size = 256;
        end

        -- f = f or print;
        size = size or 256;

        local found = ents.FindInSphere(there, size);
        if f then
            for i = 1, #found do
                f(found[i]);
            end
        else
            return found;
        end
    end},
    {"findbox", function(size, f)
        if type(size) == "function" then
            f = size;
            size = 256;
        end

        -- f = f or print;
        size = size or 256;

        local mins  = there - VECTOR_ONE * size;
        local maxs  = there + VECTOR_ONE * size;
        local found = ents.FindInBox(mins, maxs);

        if f then
            for i = 1, #found do
                f(found[i]);
            end
        else
            return found;
        end
    end},
    {"Ply", function(name, f)
        local ent = findPlayerByName(name);
        if IsValid(ent) then
            if f and type(f) == "function" then
                f(ent);
            else
                return ent;
            end
        end

        return NULL;
    end}

}

-----------------
-- Environment --
-----------------

local function SetupFunctions(env)
    for i = 1, #funcs do
        local t = funcs[i];
        local func = t[2];
        debug.setfenv(func, env);
        env[t[1]] = func;
    end
end

local function SetupVariables(ply)
    local trace = ply:GetEyeTrace();

    local env = {
        __index = function(self, key)

            if sandboxed_G[key] then return sandboxed_G[key]; end
            if _G[key] then return _G[key]; end

            if string.sub(key, 1, 2) == "E_" then -- macro style finding entity by id
                local ent = Entity(string.sub(key, 3, -1));

                -- if IsValid(ent) then
                return ent; -- we still want to return NULL
                -- end
            end

            local ent = findEntity(key, true);
            if IsValid(ent) then
                return ent;
            end

            return nil;
        end,
        __newindex = sandboxed_G;
    };

    local vars = {};
    setmetatable(vars, env);
    vars.me    = ply;
    vars.this  = trace.Entity;
    vars.there = trace.HitPos;
    vars.here  = ply:GetPos();
    vars.trace = trace;
    vars.wep   = ply:GetActiveWeapon();

    SetupFunctions(vars);

    return vars;
end

function luadev.getSnapshot(ply)
    return SetupVariables(ply);
end

-- TODO: look for specific symbol to allow for specifying that everything
-- after the symbol is to be "returned"
-- string.format("%s return %s", before, after)
local function RunLua(str, env, bshouldreturn)
    Msg("> "); MsgN(str); -- echo the command back

    str = format("%s%s", bshouldreturn == false and "" or "return ", trim(str));
    local ret = CompileString(str, "LuaRun", false);

    if type(ret) ~= "function" then
        error(ret, 2);
    end

    debug.setfenv(ret, env);
    return ret();
end

-----------------------
-- wrapper functions --
-----------------------

local function ld_run()
    -- do nothing
end

local function ld_print(...)
    print(...);
end

local function ld_table(a)
    a = getTable(a);
    if not a then return; end
    if #a == 0 and next(a) == nil then return print("Empty Table"); end

    PrintTable(a);
end

local function ld_keys(a)
    a = getTable(a);

    if #a == 0 and next(a) == nil then return print("Empty Table"); end
    if not a then return; end

    -- sort the keys because unsorted is never useful
    local sorted_keys = {};
    local max_len = 0;

    for k, v in pairs(a) do
        max_len = math.max(max_len, #tostring(k));
        table.insert(sorted_keys, {k, v});
    end

    table.sort(sorted_keys, function(a, b) return tostring(a[1]):lower() < tostring(b[1]):lower(); end);

    for i = 1, #sorted_keys do
        local k, v = unpack(sorted_keys[i]);
        local len = #tostring(k);

        v = stringify(v);

        print( format("%s%s = %s", k, string.rep(" ", max_len - len), v) );
    end

    sorted_keys = nil; -- allow gc to cleanup the garbage

end

-- TODO: Separate into own module
local function ld_pp(...)
    if select('#', ...) == 1 then
        local arg = select('1', ...);

        if isfunction(arg) then
            ld_print(arg:src(false, convars.pp_verbosity:GetInt() > 0)); 

        elseif isstring(arg) then
            ld_print(string.format("\"%s\"", arg));

        elseif IsColor(arg) then
            ld_print(string.format("Color(%i, %i, %i, %i)", arg.r, arg.g, arg.b, arg.a or 255));

        elseif isvector(arg) then
            ld_print(string.format("Vector(%g, %g, %g)", arg[1], arg[2], arg[3]));

        elseif isentity(arg) and arg:IsWeapon() then
            local p = arg:GetOwner() or arg:GetParent();
            if IsValid(p) and p:IsPlayer() then
                ld_print(string.format("┌ %s\n└-> %s", tostring(p), tostring(arg)));
            else
                ld_print(tostring(arg));
            end

        elseif istable(arg) then
            ld_table(arg);

        else
            ld_print(tostring(arg));
        end
    else
        ld_print(...);
    end
end

------------------
-- autocomplete --
------------------

-- Now this is going to be tricky
-- not only am I going to have to find a reliable and optimised way to fetch
-- fields and keys, I have to make it work with the luadev environment system.
--
-- One idea is to cache the environment on the first autocomplete request for
-- purely autocompletion reasons. Then, throw it away on enter so an updated
-- environment is used.
-- Another idea is to cache the last environment and just use that.
-- That will work. However, I can foresee a couple issues with age.
-- If a reference changes, the environment won't update unless the object
-- referenced is changes.
--
-- How do I do stuff like indexing?
-- How do I differentiate between . and :?
local function autocomplete(cmd, args)
    return string.format("%s %s", cmd, completed);
end


--------------
-- commands --
--------------

-- TODO: shared?
local commands = {
    {"ld_run",      "l",              SERVER,   ld_run,  false},
    {"ld_print",    {"print", "p"},   SERVER,   ld_print      },
    {"ld_pp",       "pp",             SERVER,   ld_pp         },
    {"ld_table",    "table",          SERVER,   ld_table      },
    {"ld_keys",     "keys",           SERVER,   ld_keys       },

    {"ld_m",        "lm",             CLIENT,   ld_run,  false},
    {"ld_printm",   {"printm", "pm"}, CLIENT,   ld_print      },
    {"ld_ppm",      "ppm",            CLIENT,   ld_pp         },
    {"ld_tablem",   {"tablem", "tm"}, CLIENT,   ld_table      },
    {"ld_keysm",    {"keysm",  "km"}, CLIENT,   ld_keys       }
}

-- TODO: autocompletion

for i = 1, #commands do
    local tab = commands[i];

    if tab[3] then -- if SERVER or CLIENT

        local func = function(ply, cmd, args, raw)
            local tr = trim(raw);
            if tr == "" then return; end

            tab[4]( RunLua(tr, SetupVariables(ply), tab[5]) );
        end

        local cmd = tab[1];

        concommand.Add(cmd, func, autocomplete);

        if chatcommand and SERVER then
            chatcommand.add(tab[2], function(ply, args, raw) func(ply, nil, args, raw); end);
        end

    end

end


--[[
 TODO:
    Ability to save state between initialization
        If re-executed or possibly if crashed/changed map, save the state of the sandboxed
        environment to at least preserve for inspection. If "loading" is possible, try to load
        anything recoverable.
        Recoverable items might include:
            * value types
            * reference containers for value types - if restorable (Vector, Angle, Matrix, etc)
            * functions (Will require a change to allow functions to be cached somewhere as the source)
            * Mesh, Material, Texture (Gated behind a command? Could get annoying.)
 --]]
