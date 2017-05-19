include("shared.lua");

function ENT:Initialize()
	self.m_vParticlePos = Vector(-3.26, 1.60, 14.43);
	self.m_eParticle = NULL;
end

function ENT:Draw()

	self:DrawModel();

	if self:GetActive() then
		local light = DynamicLight(self:EntIndex());

		if light then
			light.Pos = self:LocalToWorld(self.m_vParticlePos + Vector(0, 0, 1));
			light.r = 225;
			light.g = 251;
			light.b = 255;
			light.Brightness = 1;
			light.Size = 256;
			light.Decay = 256 * 5;
			light.Style = 12;
			light.DieTime = CurTime() + 0.1;
		end
	end

end

function ENT:OnRemove()
	if IsValid(self.m_eParticle) then
		-- do something
	end
end
