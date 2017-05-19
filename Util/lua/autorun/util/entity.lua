local meta = FindMetaTable("Entity");

util.Entity = {}; -- utility functions for entities that shouldn't be on the entity metatable

local function GetOwner(ent)
    return (ent.CPPIGetOwner and ent:CPPIGetOwner()) or ent:GetNWEntity("Owner", NULL); -- I'm still confused about ownership
end

function util.Entity.RemoveSimilar(self, tblOpt, bowned) -- tblOpt - single parameter 'type' takes space/comma delimited types ("model,class")
    if not tblOpt or type(tblOpt) ~= "table" then return; end

    local tblFound = {};

    string.gsub(tblOpt.type, "([^%s,]+)", function(t)
        if t == "model" then
            table.Add(tblFound, ents.FindByModel(self:GetModel()));
        elseif t == "class" then
            table.Add(tblFound, ents.FindByClass(self:GetClass()));
        end
    end);

    local owner = GetOwner(self);
    local cRemoved = 0;

    for i = 1, #tblFound do
        local ent = tblFound[i];
        if not IsValid(ent) then continue; end
        local entOwner = GetOwner(ent);

        if bowned then -- if true, then only remove same owner props, excluding nil owners
            if entOwner ~= nil and entOwner == owner then
                SafeRemoveEntity(ent);
                cRemoved = cRemoved + 1;
            end
        else
            if entOwner == nil or entOwner == game.GetWorld() then
                SafeRemoveEntity(ent);
                cRemoved = cRemoved + 1;
            end
        end
    end

    return cRemoved;
end

-- we want to cache the table so we aren't needlessly re-creating it each time, unlike garrycode
local REMOVETYPE_MODEL = {type = "model"};
local REMOVETYPE_CLASS = {type = "class"};
function util.Entity.RemoveSimilarModel(self, bowned)
    util.Entity.RemoveSimilar(self, REMOVETYPE_MODEL, bowned);
end

function util.Entity.RemoveSimilarClass(self, bowned)
    util.Entity.RemoveSimilar(self, REMOVETYPE_CLASS, bowned);
end


function meta:MoveBy(vec, blocal)
    self:SetPos(blocal and self:LocalToWorld(vec) or (self:GetPos() + vec));
end

function meta:RotateBy(ang, blocal)
    local entang = self:GetAngles();

    entang:RotateAroundAxis(blocal and entang:Forward() or Vector(0, 1, 0), ang.p);
    entang:RotateAroundAxis(blocal and entang:Right() or Vector(0, 0, 1), ang.y);
    entang:RotateAroundAxis(blocal and entang:Up() or Vector(1, 0, 0), ang.r);

    self:SetAngles(entang);
end

function meta:SnapPos(...)
    local pos = self:GetPos();
    self:SetPos(pos:Snap(...));
end

function meta:SnapAngles(...)
    local ang = self:GetAngles();
    self:SetAngles(ang:Snap(...));
end

-- acts as an alias for
-- e1 and IsValid(e1) or e2
--[[ Doesn't work because it converts the return value to a boolean
function meta.__lt(left, right)

    if type(left) ~= "Entity" and
        type(right) ~= "Entity" then
        return nil;
    end

    if right and IsValid(right) then
        return right;
    end

    return left;

end
--]]
