local pntEnts = {}

function Cubic3DBezier(vPoint1, vPoint2, vPoint3, vPoint4, t) --thanks Wikipedia
    local x = vPoint1.x * (1 - t)^3 + 3 * vPoint2.x * t * (1 -t)^2 + 3 * vPoint3.x * t^2 * (1 -t) + vPoint4.x * t^3
    local y = vPoint1.y * (1 - t)^3 + 3 * vPoint2.y * t * (1 -t)^2 + 3 * vPoint3.y * t^2 * (1 -t) + vPoint4.y * t^3
    local z = vPoint1.z * (1 - t)^3 + 3 * vPoint2.z * t * (1 -t)^2 + 3 * vPoint3.z * t^2 * (1 -t) + vPoint4.z * t^3
    return Vector(x, y, z)
end

for k, v in pairs( ents.FindByClass( "prop_physics" ) ) do //FindByModel is broken clientside
    if ( not v:GetModel() == "models/props_junk/watermelon01.mdl" ) then return end // so we need to find by class, then filter by model
    pntEnts[k] = v
end

local points = {}
for i = 1, 100 do
    points[i] = Cubic3DBezier( pntEnts[1]:GetPos(), pntEnts[2]:GetPos(), pntEnts[3]:GetPos(), pntEnts[4]:GetPos(), i / 100 )
end

hook.Add("PostDrawTranslucentRenderables", "Bezier", function()
    render.SetMaterial(Material("cable/cable2"))
    render.StartBeam(#points + 1)
    for k, v in pairs(points) do
        render.AddBeam(v, 5, k, color_white )
    end
    render.EndBeam()
end )
