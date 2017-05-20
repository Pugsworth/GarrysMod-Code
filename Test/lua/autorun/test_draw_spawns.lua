local netStr = "info_player_start_visualize";

if SERVER then

    util.AddNetworkString(netStr);
    
    -- local plyCache = {};
    -- local spawnsCache = {};
    -- local needsUpdate = false;
    
    -- local function spawnsChanged()
    --     return needsUpdate;
    -- end
    
    net.Receive(netStr, function(len, ply)
        local spawns = ents.FindByClass("info_player_start");
        
        -- local plyCacheID = plyCache[ply:SteamID()] or 1;
        -- local recCacheID = net.ReadUInt(16);
        
        -- they have the most current information
        -- if not spawnsChanged() and cacheID == clientCacheID then
        --     return;
        -- end
        
        net.Start(netStr)
        -- net.WriteUInt(cacheID, 16);
        net.WriteUInt(#spawns, 8);
        
        for i = 1, #spawns do
            local spawn = spawns[i];
            -- local eid = spawn:EntIndex();
            
            -- if not spawnsCache[eid] then
            --    needsUpdate = true;
            -- end
            
            net.WriteVector(spawn:GetPos());
            net.WriteAngle(spawn:GetAngles());
            net.WriteBool(bit.band(spawn:GetSpawnFlags(), 1) == 1);
        end
        
        net.Send(ply);
    end);
    
end


if CLIENT then

    -- local cacheID = 0;

    local player_spawns = {};
    local model = "models/editor/playerstart.mdl";
    local cmodels = {};
    local mins, maxs = Vector(-16, -16, 0), Vector(16, 16, 72);
    
    local function cleanupCModels()
        for i = 1, #cmodels do
            SafeRemoveEntity(cmodels[i]);
        end
        
        cmodels = {};
    end

    net.Receive(netStr, function(len, ply)
        -- cacheID = net.ReadUInt(16);
        local count = net.ReadUInt(8);
        local spawns = {};
        
        cleanupCModels();
        
        for i = 1, count do
            local spawn = {position = net.ReadVector(), rotation = net.ReadAngle(), isMaster = net.ReadBool()};
            spawns[i] = spawn;
            
            local cmdl = ClientsideModel(model, RENDERGROUP_BOTH);
            cmodels[#cmodels + 1] = cmdl;
            cmdl:SetNoDraw(true);
            cmdl:SetPos(spawn.position);
            cmdl:SetAngles(spawn.rotation);
            
        end
        
        player_spawns = spawns;
    end);
    
    local convar = CreateConVar("cl_draw_spawns", 0, {FCVAR_ARCHIVE}, "Draws info_player_start in the world.");
    local COLOR_HIGHLIGHT = Color(240, 240, 80);
    local function drawSpawns()
    
        if convar:GetBool() == false then
            return;
        end
    
        for i = 1, #player_spawns do
            local spawn = player_spawns[i];
            
            local cmdl = cmodels[i];
            if IsValid(cmdl) then
                cmdl:DrawModel();
            end
            
            render.DrawWireframeBox(spawn.position, spawn.rotation, mins, maxs, spawn.isMaster and COLOR_HIGHLIGHT or color_white, true);
        end
    
    end
    
    cvars.AddChangeCallback("cl_draw_spawns", function(_convar, oldValue, newValue)
        local nv, ov = tonumber(newValue), tonumber(oldValue);
        if nv > 0 and ov < 1 then
            -- request spawns from server
            net.Start(netStr)
            -- net.WriteUInt(cacheID, 16);
            net.SendToServer();
            
            hook.Add("PostDrawTranslucentRenderables", netStr, drawSpawns);
        elseif nv < 0 and ov > 0 then
            cleanupCModels();
            hook.Remove("PostDrawTranslucentRenderables", netStr);
        end
    end, "cl_draw_spawns");
    
end
