AddCSLuaFile();

if SERVER then return; end

if G_LD_TEST then G_LD_TEST:Remove(); end
G_LD_TEST = nil; -- just clear it if reloaded

concommand.Add("ld_test", function(ply, cmd, args, raw)
    if IsValid(ply) then
        local env = luadev.getSnapshot(ply)
        showBox(env);
    end
end);

function showBox(env)
    -- local pnl = (G_LD_TEST or createGUI(env))
    local pnl = createGUI(env);
    pnl:Show();
    pnl:MakePopup();
end

function createGUI(env)
    local frame = vgui.Create("DFrame");
    frame:SetSize(480, 320);
    frame:SetSizable(true);
    -- frame:SetDeleteOnClose(false);
    frame:Center();

    -- local scrollbar = frame:Add("DScrollPanel");
    -- scrollbar:Dock(FILL);

    -- local pEnvList = vgui.Create("DTextEntry");
    -- scrollbar:AddItem(pEnvList);
    local pEnvList = frame:Add("DTextEntry");
    pEnvList:Dock(FILL);
    function pEnvList:AllowInput()
        return true;
    end;
    pEnvList:SetMultiline(true);
    pEnvList:SetVerticalScrollbarEnabled(true);
    -- pEnvList:SetTall(9999);

    -- local text = util.TableToJSON(getmetatable(env), true);
    local text = table.ToString(getmetatable(env), "luadev", true);
    text = string.gsub(text, '\t', '   ');
    pEnvList:SetText(text);

    -- local count = 0;
    -- for m in string.gmatch(text, '\n') do
        -- count = count + 1;
    -- end

    -- local w, h = surface.GetTextSize('W');
    -- print(w, h);

    -- pEnvList:SetTall(count * h);


    G_LD_TEST = frame;
    return frame;
end
