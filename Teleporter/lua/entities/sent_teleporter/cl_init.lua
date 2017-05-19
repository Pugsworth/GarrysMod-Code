include("shared.lua");
include("cl_render.lua");

include("vgui/prop_targetselect.lua");

function ENT:Initialize()
end

function ENT:Think()
    if self:GetTeleportSequence() == self.TSEQUENCE.ANIM then

        self:FrameAdvance();

        local pose = 65 * math.abs(math.sin(RealTime() * 4));

        self:SetPoseParameter("blendstates", pose);
        self:InvalidateBoneCache();

    end
end

function ENT:Draw()
    self:DrawModel();
end

--[[
function ENT:DrawPortal(origin, ang, scale)

	local nSegments = self.m_iPortalQuality * scale

	-- render.SetMaterial(self.m_mat_rt_Camera);
	--[[
	mesh.Begin(MATERIAL_POLYGON, nSegments);

		local slice = (math.pi * 2) / nSegments;
		local rx, rz = 20, 30;
		local x, z, u, v = 0, 0, 0, 0;

		for i = 1, nSegments do
		    local s = math.sin(i * slice);
		    local c = math.cos(i * slice);

		    x = x + (rx * c);
		    z = z + (rz * s);
		    u = (1 + c) / 2;
		    v = (1 + s) / 2;

			local pos = Vector(x + rx/2, 0, z - rz*1.5);

			mesh.Position(pos);
			mesh.TexCoord(0, u, v);
			mesh.Normal(ang:Forward());
			mesh.AdvanceVertex();
		end
	--]]
	--[[
	local matrix = Matrix();
	matrix:Translate(origin);
	matrix:Rotate(Angle(0, ang.y, 0));

	cam.PushModelMatrix(matrix);
	-- mesh.End();

	render.DrawQuadEasy(vector_origin, Vector(1, 0, 0), 64, 64, color_white, 0);
	cam.PopModelMatrix();
	--]

	cam.Start3D2D(origin, ang, 0.1);

	render.PushFilterMin(TEXFILTER.ANISOTROPIC);
	render.PushFilterMag(TEXFILTER.ANISOTROPIC);

	render.ClearStencil();
	render.SetStencilEnable(true);

	render.SetStencilTestMask(1);
	render.SetStencilWriteMask(1);

		render.SetStencilCompareFunction(STENCIL_ALWAYS);
		render.SetStencilPassOperation(STENCILOPERATION_INCR);
		render.SetStencilFailOperation(STENCILOPERATION_KEEP);
		render.SetStencilZFailOperation(STENCILOPERATION_KEEP);

			render.DrawQuadEasy(vector_origin, Vector(-1, 0, 0), 640, 64, color_white, 0);

		render.SetStencilReferenceValue(1);
		render.SetStencilCompareFunction(STENCIL_EQUAL);

			render.SetMaterial(self.m_mat_rt_Camera);
			render.DrawScreenQuad();

	render.SetStencilEnable(false);

	render.PopFilterMin();
	render.PopFilterMag();

	cam.End3D2D();
end

function ENT:Draw()

	local pos = self:GetPos() + self:GetUp() * 64;
	local ang = (LocalPlayer():GetPos() - self:GetPos()):Angle();
	-- ang:RotateAroundAxis(self:GetUp(), -90);

	self:DrawModel();
	self:DrawPortal(pos, ang, 2);

end

hook.Add("PostDrawOpaqueRenderables", "DrawTeleporters", function()
	for i, v in ipairs(ents.FindByClass("sent_teleporter")) do
		local pos = v:GetPos() + v:GetUp() * 64;

		v:DrawPortal(pos, v:GetAngles());
	end
end)
--]]
