
local function math_vectorAngles(forward, up)
    local angles = Angle(0, 0, 0);

    local left = up:Cross(forward);
    left:Normalize();

    local xydist = math.sqrt(forward.x * forward.x + forward.y * forward.y);

    -- enough here to get angles?
    if xydist > 0.001 then
        angles.y = math.deg(math.atan2(forward.y, forward.x));
        angles.p = math.deg(math.atan2(-forward.z, xydist));
        angles.r = math.deg(math.atan2(left.z, (left.y * forward.x) - (left.x * forward.y) ));
    else
        angles.y = math.deg(math.atan2(-left.x, left.y));
        angles.p = math.deg(math.atan2(-forward.z, xydist));
        angles.r = 0;
    end

    return angles;
end

function ENT:DrawCSModels()
end

