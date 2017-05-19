require("io");

ofileWrite = ofileWrite or file.Write;

function file.Write(...)
    local args = {...};

    if args[1] ~= game.GetMap():lower() .. ".txt" or not io then return ofileWrite(...); end

    local smap = game.GetMap():lower();
    local sgatesystem = GetConVar("stargate_group_system"):GetBool() and "gatespawner_group_maps" or "gatespawner_maps";

    local luapath = "lua/data/" .. sgatesystem .. "/" .. smap;
    
    if file.Exists(luapath .. ".lua", "GAME") then -- io.exists doesn't seem to be functioning properly
        local bsuccess = io.rename(luapath .. ".lua", luapath .. ".lua.backup"); -- TODO: variable

        print((bsuccess and "Success renaming: " or "Failed renaming: ") .. "\"" .. luapath .. ".txt.backup\"");
    end

    local f = io.open(luapath .. ".lua", "w");
        f:write(args[2]);
    f:close();
    
end