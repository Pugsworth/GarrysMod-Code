local meta = FindMetaTable("Angle");

function meta:Snap(mul)

	mul = mul % 360;

	local p = mul * math.Round(self.p / mul);
	local y = mul * math.Round(self.y / mul);
	local r = mul * math.Round(self.r / mul);

	return Angle(p, y, r);

end

function meta:SnapTo()
end

function meta:Set(component, value)
end