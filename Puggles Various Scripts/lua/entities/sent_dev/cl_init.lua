include('shared.lua')

function ENT:Initialize()
	self:SetRenderMode(RENDERMODE_TRANSALPHA);
	self:SetColor(Color(255, 255, 255, 150));

	self.models = {};

	self:SetCount(9);
	self:SetCModel("models/props_combine/combine_light002a.mdl");
	self:SetDistance(8);
	self:SetPitch(0);
	self:SetYaw(0);
	self:SetRoll(0);
	self:SetSnap(false);
	self:SetSnapDegrees(0);

	local mdl = self:GetCModel();
	for i = 1, self:GetCount() do
		local ent = ents.CreateClientProp(mdl);
		ent:Spawn();
		ent:SetNoDraw(true);

		table.insert(self.models, ent);
	end

	self.realpos = self:GetPos();
end

function ENT:Draw()

	local icount = self:GetCount();
	local angper = 360 / icount;

	local strMdl = self:GetCModel();

	local entang  = self:GetAngles();
	local up      = entang:Up();
	local right   = entang:Right();
	local forward = entang:Forward();

	local distance = self:GetDistance();

	local editang = self:GetCMAngles();

	for i = 0, icount - 1 do

		local pos = Vector(
			math.sin(math.rad(i * angper)) * distance,
			math.cos(math.rad(i * angper)) * distance,
			0
		);
		
		local ent = self.models[i + 1];
		if ent and IsValid(ent) then
			if ent:GetModel() ~= strMdl and strMdl ~= "" then
				ent:SetModel(strMdl);
			end

			local ang       = self:GetAngles();
			local up		= ang:Up();
			local right		= ang:Right();
			local forward	= ang:Forward();

			local cmangs    = ent:GetAngles();
			local cmup      = cmangs:Up();
			local cmright   = cmangs:Right();
			local cmforward = cmangs:Forward();

		-- ang:RotateAroundAxis(cmright, editang.p);
		-- ang:RotateAroundAxis(cmforward, editang.r);

		-- ang:RotateAroundAxis(up, (-90 + (i * angper))); -- 'face' towards the center
		-- editang.y = (-90 + (i * angper));
		-- local ang = self:LocalToWorldAngles(editang);


		ang:RotateAroundAxis(cmright,   editang.p);
		ang:RotateAroundAxis(cmup,      -90 + (i * angper));
		ang:RotateAroundAxis(cmforward, editang.r);
		
			ent:SetPos(self:LocalToWorld(pos) + (up * 64));
			ent:SetAngles(ang);

			ent:DrawModel();
		end

	end
	
	self:DrawModel();

end

function ENT:ChangeModels()

	local ileft = self:GetCount() - #self.models;

	if ileft < 0 then -- negative, remove models
		for i = 1, math.abs(ileft) do
			local ent = table.remove(self.models, 1);
			ent:Remove();
		end

	elseif ileft > 0 then -- positive, add models
		local mdl = self:GetCModel();
		for i = 1, ileft do
			local ent = ClientsideModel(mdl, RENDERGROUP_BOTH);
			ent:Spawn();
			ent:SetNoDraw(true);

			table.insert(self.models, ent);
		end
	end

end

function ENT:Think()

	if #self.models ~= self:GetCount() then
		self:ChangeModels();
	end

end

function ENT:OnRemove()
	
	for i = 1, #self.models do

		local ent = self.models[i];
		if ent and IsValid(ent) then
			ent:Remove();
		end

	end

	self.models = {};

end
