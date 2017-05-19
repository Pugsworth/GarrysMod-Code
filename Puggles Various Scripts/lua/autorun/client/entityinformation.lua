local trim = string.Trim;
local format = string.format;
local lowercase = string.lower;

local CVars = {
    notifysound = CreateClientConVar("entinfo_notifysound", "buttons/bell1.wav", true, false),
    clipboardalways = CreateClientConVar("entinfo_clipboardalways", "0", true, false)
};
local COLOR_WARNING = Color(240, 75, 75);

local commands = {
    color     = function(e) local c = e:GetColor(); return "Color", format("%i, %i, %i, %i", c.r, c.g, c.b, c.a); end,
    [{"entity", "ent"}]    = function(e) return e; end,
    [{"position", "pos", "p"}]  = function(e) return "Vector", e:GetPos(); end,
    [{"angle", "ang", "a"}]     = function(e) return "Angle", e:GetAngles(); end,
    model     = function(e) return e:GetModel(); end,
    class     = function(e) return e:GetClass(); end,
    [{"material", "mat", "m"}]  = function(e) return e:GetMaterial(); end,
    [{"materials", "mats"}] = function(e) return table.concat(e:GetMaterials(), "\n"); end,
    spawn     = function(e) RunConsoleCommand("gm_spawn", e:GetModel()); end
};

local function getcommand(arg)
    local arg = lowercase(arg);

    for cmd, func in pairs(commands) do

        if type(cmd) == "table" then
            for j = 1, #cmd do
                if arg == lowercase(cmd[j]) then
                    return func;
                end
            end

        elseif arg == lowercase(cmd) then
            return func;
        end

    end

    return func;
end

local function notify()
    local snd = CVars.notifysound:GetString();
    surface.PlaySound(snd);
end

concommand.Add("entinfo", function(ply, cmd, args, str)
    if not args or #args == 0 or string.Trim(args[1]) == "" then
        Msg("Specify a command.\nCurrent commands: ");
        local list = {};
        for k, v in pairs(commands) do
            if type(k) == "table" then
                local ret = {};
                for i = 2, #k do
                    ret[#ret+1] = k[i];
                end
                list[#list + 1] = format("%s[%s]", k[1], table.concat(ret, ", "));
            else
                list[#list + 1] = k;
            end
        end
        Msg(table.concat(list, ", "), "\n\n");
        return;
    end

    local bshiftdown = input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT);
    local HitEnt = LocalPlayer():GetEyeTrace().Entity;

    local cliptbl = {};
    local bsuccess = false;

    for i = 1, #args do
        local arg = tostring(args[i]);
        local cmd = getcommand(arg);
        if cmd then
            if IsValid(HitEnt) and not HitEnt:IsWorld() then
                local var1, var2 = cmd(HitEnt);

                if var1 and var ~= "" then
                    local str;
                    if var2 then
                        str = format("%s %s", tostring(var1), tostring(var2));
                    else
                        str = tostring(var1);
                    end

                    chat.AddText(str);
                    table.insert(cliptbl, var2 or var1);

                    bsuccess = true; -- success, a command has executed and displayed information
                end
            end
        else
            MsgC(COLOR_WARNING, "EntInfo: invalid argument \"", arg, "\"\n");
        end
    end

    if bsuccess then
        notify();

        if CVars.clipboardalways:GetBool() or bshiftdown then
            chat.AddText("Copied to Clipboard");
            SetClipboardText(table.concat(cliptbl, "\n"));
        end
    end
end);
