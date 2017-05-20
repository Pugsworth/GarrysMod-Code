local HULL = {
	VIEW          = Vector(0, 0, 64),		-- VEC_VIEW (m_vView)
	DUCK_VIEW     = Vector(0, 0, 28),		-- VEC_DUCK_VIEW(m_vDuckView)

	HULL_MIN      = Vector(-16, -16, 0),	-- VEC_HULL_MIN (m_vHullMin)
	HULL_MAX      = Vector(16,  16,  72),	-- VEC_HULL_MAX (m_vHullMax)

	DUCK_HULL_MIN = Vector(-16, -16, 0),	-- VEC_DUCK_HULL_MIN (m_vDuckHullMin)
	DUCK_HULL_MAX = Vector(16,  16,  36)	-- VEC_DUCK_HULL_MAX(m_vDuckHullMax)
}


function Resize(ply, scale, extra)
	ply:SetModelScale(scale, 0.5);

	ply:SetHull(HULL.HULL_MIN * scale, HULL.HULL_MAX * scale);
	ply:SetHullDuck(HULL.DUCK_HULL_MIN * scale, HULL.DUCK_HULL_MAX * scale);

	ply:SetViewOffset(HULL.VIEW * scale);
	ply:SetViewOffsetDucked(HULL.DUCK_VIEW * scale);

	if extra then
		ply:SetJumpPower(200 * scale);
		ply:SetStepSize(18 * scale);
	end
end

local meta = FindMetaTable("Player");
meta.Resize = Resize;
