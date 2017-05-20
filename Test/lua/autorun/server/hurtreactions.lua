local format = string.format;

local sounds = {};

local function CombineFilenamePath(path, tbl)

    local ret = {};
    local len = #ret;

    for i = 1, #tbl do
        ret[len+i] = path .. tbl[i]; -- concat pls
    end

    return ret;

end

local function ResolvePath(path)

    if path:find('\\') then
        path = path:gsub('\\', '/');
    end

    -- strip 'sound(s)' from beginning of path because EmitSound uses path relative to the sound/ directory
    -- it's actually faster to gsub regardless if we know it contains the text than to check and then gsub
    path = path:gsub('^/?sound[s]?/', '');

    if path:sub(-1, -1) ~= '/' then
        return format('%s/', path);
    end

    return path;

end

local function ResolveFilePattern(pattern)

    if pattern:find('%*$') then
        return format("%s.wav", pattern);
    else
        return pattern;
    end

end

local function MergeArrays(a, b) -- easy way to merge an array without creating an abundance of tables
    local len = #a;
    for i = 1, #b do
        a[len+i] = b[i];
    end
end

local function FindSounds(tbl)

    local ret = {}; -- temporary return table for all the paths
    local path = ResolvePath(tbl[1]);

    local searchstring;

    for i = 2, #tbl do -- start at 2 because 1 is the path
        searchstring = format("sound/%s%s", path, ResolveFilePattern(tbl[i]));

        -- check if file exists if it's a direct path. Otherwise, file.Find it.
        if file.Exists(searchstring, "GAME") then
            ret[#ret+1] = searchstring:sub(7); -- if a sound was found, 'sound/' shouldn't be included
        else
            MergeArrays(ret, CombineFilenamePath(path, file.Find(searchstring, "GAME")));
            -- because CombineFilenamePath returns a new array, we have to merge ret so the end result is a 1 Dimensional array of string paths.
            -- this most definitely can be optimised, but I cannot think of a good way that wouldn't introduce lots of bulky code
        end
    end

    return ret;

end

function AddReactionSound(name, paths)

    local tblsound = {};

    for hitbox, tblpaths in pairs(paths) do

        local ret = {};

        if hitbox == "merge" then
            ret = tblpaths;

        elseif istable(tblpaths[1]) then
            for i = 1, #tblpaths do
                MergeArrays(ret, FindSounds(tblpaths[i]));
            end

        else
            ret = FindSounds(tblpaths);
        end

        tblsound[hitbox] = ret;

    end

    sounds[#sounds+1] = {name, tblsound};

    table.sort(sounds, function(a, b) return #a[1] > #b[1] end);

end

--[[-----------------------------------------------
    Data Format:

        {
            [hitbox] = sounddata,
            pain     = sounddata,
            [merge]  = mergedata
        }

        Hitbox: (optional)
            It is the hitbox associated with the sounds.
            It can be any of: leg, arm, gut, chest, or head.

        Sounddata: (required)
            sounddata consists of a table that contains either a table for each path, or the path table itself (if only one path is needed).
            e.g.
            {path, sound1, sound2, ...}
            or
            {{path, sound1, sound2}, {path2, sound1, ...}}

            The first index, of the path table, is the path to use. The path can be relative to the root or the sounds directory. The rest are the patterns to search for the sounds in the path.
            The pattern can be just the sound prefix, the sound prefix with a wildcard, or the sound prefix with wildcard and extension. (file.Find format)
            i.e. "sound" or "sound*" or "sound*.wav"

        Pain: (required)
            'pain' is a generic sound emitted with a random chance (20% default) or if no hitbox is found.

        Merge: (optional)
            If the 'merge' key exists, then every consecutive hitbox after the first are to be merged with the first hitbox.
            I.E. {'gut', 'chest'} getting hit in the chest would make the gut sound play


    Look below for more examples.
--]]-----------------------------------------------

AddReactionSound("female", { -- female citizen/rebel
    pain = {"sound/vo/npc/female01/", "pain*.wav"},
    leg  = {"sound/vo/npc/female01/", "myleg*.wav"},
    arm  = {"sound/vo/npc/female01/", "myarm*.wav"},
    gut  = {"sound/vo/npc/female01/", "hitingut*.wav", "mygut*.wav"},
    merge = {"gut", "chest"}
});

AddReactionSound("male", { -- male citizen/rebel
    pain = {"sound/vo/npc/male01/", "pain*.wav"},
    leg  = {"sound/vo/npc/male01/", "myleg*.wav"},
    arm  = {"sound/vo/npc/male01/", "myarm*.wav"},
    gut  = {"sound/vo/npc/male01/", "hitingut*.wav", "mygut*.wav"},
    merge = {"gut", "chest"}
});

-- an abstraction for multiple definitions in a single function call might be better
-- but these are only called once
AddReactionSound("police", { -- metropolice
    pain = {"sound/npc/metropolice", "pain*.wav"}
});

AddReactionSound("combine_soldier", {
    pain = {"sound/npc/combine_soldier/", "pain*.wav"}
});
AddReactionSound("combine_super_soldier", { -- "elite" combine solder
    pain = {"sound/npc/combine_soldier/", "pain*.wav"}
});

AddReactionSound("zombie_soldier", { -- zombine
    pain = {"sound/npc/zombine/", "zombine_pain*.wav"}
});

AddReactionSound("barney", {
    pain = {"sound/vo/npc/barney/", "ba_pain*.wav"}
});

AddReactionSound("zombie", {
    pain = {"sound/npc/zombie/", "zombie_pain*.wav"}
});

AddReactionSound("monk", {
    pain = {"sound/vo/ravenholm/", "monk_pain*.wav"}
});

AddReactionSound("alyx", {
    pain = {"sound/vo/npc/alyx/", "hurt*.wav"}
});

AddReactionSound("hostage", { -- css hostage
    pain = {"sound/hostage/hpain/", "hpain*.wav"}
});

AddReactionSound("breen", {
    pain = {"sound/vo/citadel/",
        "br_youneedme.wav",
        "br_youfool.wav", 
        "br_playgame_a.wav", 
        "br_no.wav"
    }
});
AddReactionSound("gman", {
    pain = {"sound/vo/outland_02/junction/",
        "gman_mono01.wav", -- doctor freeman
        "gman_mono04.wav", -- mmm
        "gman_mono10.wav", -- breathing
        "gman_mono13.wav", -- appraisal
        "gman_mono15.wav", -- extract
        "gman_mono24.wav", -- breathing
        "gman_mono27.wav", -- restrictions
        "gman_mono28.wav", -- mmm
        "gman_mono29.wav", -- well
        "gman_mono30.wav", -- now
        "gman_mono34.wav", -- prepare for unforeseen consequences
    }
});

AddReactionSound("eli", {
    pain = {"sound/vo/outland_11a/silo/",
        "eli_silo_chuckles02.wav",
        "eli_silo_chuckles04.wav",
    }
});

AddReactionSound("soldier_stripped", {
    pain = {"sound/ambient/animal/",
        "snake1.wav",
        "snake2.wav",
        "snake3.wav",
    }
});

AddReactionSound("kleiner", {
    pain = {
        {"sound/vo/k_lab/",
            "kl_ahhhh.wav",
            "kl_dearme.wav",
            "kl_excellent.wav",
            "kl_fiddlesticks.wav",
            "kl_hedyno01.wav", -- lammar
            "kl_hedyno02.wav", -- hedy
            "kl_hedyno03.wav",
            "kl_heremypet01.wav"
        },
        {"sound/vo/k_lab2/",
            "kl_greatscott.wav",
            "kl_lamarr.wav"
        },
        {"sound/vo/outland_11a/silo/",
            "kl_silo_hm.wav"
        },
        {"vo/outland_12a/launch/",
            "kl_launch_awe01.wav",
            "kl_launch_awe05.wav",   -- yes
            "kl_launch_check05.wav", -- did you do that
            "kl_launch_sigh.wav"
        },
        {"vo/trainyard/",
            "kl_morewarn01.wav",
        }
    }
});



local player_data = {}; -- stop cluttering the player table; this should be a helper library
local convars = {
    enable      = CreateConVar("hurtreactions_enable",          "1",  {FCVAR_ARCHIVE}, "Enable/Disable reactions sounds"),
    painchance  = CreateConVar("hurtreactions_chance",          0.2,  {FCVAR_ARCHIVE}, "Percent chance (0 - 1) for generic reaction"), -- 20% chance
    minpaindmg  = CreateConVar("hurtreactions_mingenericpain",  15,   {FCVAR_ARCHIVE}, "Minimum pain for a generic sound"), -- slighlty higher than a pistol shot to chest
    sndinterval = CreateConVar("hurtreactions_interval",        3,    {FCVAR_ARCHIVE}, "Interval between reactions") -- 3 seconds minimum between sounds per player
};

-- translate hitboxes to simple names for sound mapping
-- i.e. arms will play the same sounds regardless of being left or right
local tblhitboxes = {
    [HITGROUP_HEAD]       = 'head',
    [HITGROUP_CHEST]      = 'chest',
    [HITGROUP_STOMACH]    = 'gut',

    [HITGROUP_LEFTARM]    = 'arm',
    [HITGROUP_RIGHTARM]   = 'arm',

    [HITGROUP_LEFTLEG]    = 'leg',
    [HITGROUP_RIGHTLEG]   = 'leg'
};

function GetReaction(hitbox, tbl, damage) -- TODO: cleanup logic

    if damage <= convars.minpaindmg:GetInt() then
        local painchance = convars.painchance:GetFloat();
        if painchance ~= 0.0 and math.random() <= painchance then
            return 'pain';
        end
    end

    if not tblhitboxes[hitbox] then
        return 'pain';
    else

        local strhitbox = tblhitboxes[hitbox];

        if not strhitbox then
            return "pain";
        else

            if not tbl[strhitbox] then

                if tbl['merge'] then
                    local tblmerge = tbl['merge'];
                    local default = tblmerge[1];

                    for i = 2, #tblmerge do
                        if strhitbox == tblmerge[i] then
                            return default;
                        end
                    end

                end

            else
                return strhitbox;
            end

        end

    end

    return 'pain';

end

hook.Add('ScalePlayerDamage', 'PlayerDamage', function(ply, hitbox, dmginfo)

    if convars.enable:GetBool() == false or not IsValid(ply) then
        return;
    end

    if player_data[ply] then
        if player_data[ply].nextreaction > CurTime() then
            return;
        end
    else
        player_data[ply] = {}; -- no data on player so assume a sound has never been played (shouldn't have), then create the data
    end

    local plymdl = ply:GetModel();
    local mdlname = plymdl:sub(plymdl:find('/[^/]+$')); -- extract model name from path

    local snd;
    for i = 1, #sounds do

        local name, tbl = sounds[i][1], sounds[i][2];

        if mdlname:find(name) then
            reaction = GetReaction(hitbox, tbl, dmginfo:GetDamage());
            local size = #tbl[reaction];
            snd = tbl[reaction][math.random(1, size)];
            break;
        end

    end

    if snd then
        ply:EmitSound(snd);
    end

    player_data[ply].nextreaction = CurTime() + convars.sndinterval:GetInt();

end);

hook.Add('PlayerDisconnected', 'PlayerDamage', function(ply)
    player_data[ply] = nil;
end);
