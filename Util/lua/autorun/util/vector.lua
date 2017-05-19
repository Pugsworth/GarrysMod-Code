local meta = FindMetaTable("Vector");

---------------
-- constants --
---------------

vector_up 		= Vector(0, 0, 1);
vector_right 	= Vector(0, 1, 0);
vector_forward 	= Vector(1, 0, 0);

function meta:Snap(mul)

	local x = mul * math.Round(self.x / mul);
	local y = mul * math.Round(self.y / mul);
	local z = mul * math.Round(self.z / mul);

	return Vector(x, y, z);

end

function meta:SnapTo(x, y, z)

	x = x or self.x;
	y = y or self.y;
	z = z or self.z;

	return Vector(x, y, z);

end

function meta:SetCom(component, value)

	local nv = Vector(0, 0, 0):Set(self);

	for m in string.gmatch(string.lower(component), "[xyz]") do
		nv[m] = value;
	end

	return nv;

end


do

	local components = {'X', 'Y', 'Z'};

	for i = 1, 3 do
		local com = components[i];

		meta["Set" .. com] = function(self, value)
			self[string.lower(com)] = value;

			return self;
		end
	end


end


function meta:tostring(fmt)
	return string.format(fmt, self[1], self[2], self[3]);
end
