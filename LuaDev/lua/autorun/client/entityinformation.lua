local trim = string.Trim;
local format = string.format;
local lowercase = string.lower;

local COLOR_WARNING = Color(240, 75, 75);
local SND_NOTIFY_DEFAULT = "buttons/bell1.wav";

local CVars = {
    notifysound = CreateClientConVar("entinfo_notifysound", SND_NOTIFY_DEFAULT, true, false),
    clipboardalways = CreateClientConVar("entinfo_clipboardalways", "0", true, false)
};

local commands = {
    ["color"]                  = function(e) local c = e:GetColor(); return "Color", format("%i, %i, %i, %i", c.r, c.g, c.b, c.a); end,
    [{"entity", "ent"}]        = function(e) return e; end,
    [{"entid", "id"}]          = function(e) return e:EntIndex() end,
    [{"position", "pos", "p"}] = function(e) return "Vector", e:GetPos(); end,
    [{"angle", "ang", "a"}]    = function(e) return "Angle", e:GetAngles(); end,
    ["name"]                   = function(e) return e:GetName(); end,
    ["model"]                  = function(e) return e:GetModel(); end,
    ["class"]                  = function(e) return e:GetClass(); end,
    [{"material", "mat", "m"}] = function(e) return e:GetMaterial(); end,
    [{"materials", "mats"}]    = function(e) return table.concat(e:GetMaterials(), "\n"); end,
    ["spawn"]                  = function(e) RunConsoleCommand("gm_spawn", e:GetModel()); end
    -- currently, you cannot get the physicsobject clientside
    -- [{"mass", "weight"}]       = function(e) local phys = e:GetPhysicsObject(); if IsValid(phys) then return phys:GetMass(); end end
    -- ["copy"]                   = function() return true; end
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
    local snd = CVars.notifysound:GetString(SND_NOTIFY_DEFAULT);
    surface.PlaySound(snd);
end

concommand.Add("entinfo", function(ply, cmd, args, str)
    if not args or #args == 0 or string.Trim(args[1]) == "" then
        Msg("Specify an argument.\nCurrent commands: ");

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

        table.sort(list);
        Msg(table.concat(list, ", "), "\n\n");

        return;
    end

    local bshouldcopy = input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT);
    local HitEnt = LocalPlayer():GetEyeTrace().Entity;

    local cliptbl = {};
    local bsuccess = false;

    for i = 1, #args do
        local arg = tostring(args[i]);
        local cmd = getcommand(arg);
        if arg == "copy" then -- hmmm
            bshouldcopy = true;
        elseif cmd then
            if IsValid(HitEnt) and not HitEnt:IsWorld() then
                local var1, var2 = cmd(HitEnt);

                if var1 and var1 ~= "" then
                    local str;
                    if var2 then
                        str = format("%s %s", tostring(var1), tostring(var2));
                    else
                        str = tostring(var1);
                    end

                    chat.AddText(str);
                    table.insert(cliptbl, tostring(var2 or var1));

                    bsuccess = true; -- success, a command has executed and displayed information
                end
            end
        else
            MsgC(COLOR_WARNING, "EntInfo: invalid argument \"", arg, "\"\n");
        end
    end

    if bsuccess then
        notify();

        if CVars.clipboardalways:GetBool() or bshouldcopy then
            chat.AddText("Copied to Clipboard");
            SetClipboardText(table.concat(cliptbl, "\n"));
        end
    end
end);
