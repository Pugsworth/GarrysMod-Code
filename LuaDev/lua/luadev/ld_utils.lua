AddCSLuaFile();

local Storage = {};
luadev._storage = {};
function luadev.getStorage(key, kind, force_new)
    if not luadev._storage[key] or force_new == true then
        luadev._storage[key] = Storage.new(key, kind or TYPE_STRING);
    end

    local sto = luadev._storage[key];

    return sto;
end

function luadev.listStorage()
    return table.Copy(luadev._storage);
end

-- Metatable
local mt_storage = {};

function mt_storage.get(self)
    return self.value;
end

function mt_storage.set(self, value)
    self.value = value;
    return self.value;
end

function mt_storage.toggle(self)
    if self._type ~= TYPE_BOOL then return self.value; end

    self.value = not self.value;
    return self.value;
end
mt_storage.__index = mt_storage;
-- mt_storage.__newindex = false;

-- Class
function Storage.new(name, kind)
    local this = setmetatable({
        value = nil,
        _name = name,
        _type = kind
    }, mt_storage);


    return this;
end



-- Utils

if CLIENT then

    local cursorVar = luadev.getStorage("cursor", TYPE_BOOL);

    function luadev.toggleCursor()
        local cur = cursorVar:toggle();
        gui.EnableScreenClicker(cur);
    end

    concommand.Add("ld_togglecursor", function(ply, cmd, args)
        luadev.toggleCursor();
    end);

end
