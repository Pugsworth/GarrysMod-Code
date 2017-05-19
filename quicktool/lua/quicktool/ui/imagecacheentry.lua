local self = {}
QuickTool.ImageCacheEntry = QuickTool.MakeConstructor (self)

function self:ctor (image)
	self.Image = image
	self.Material = Material (image)
	
	if string.find (self.Material:GetShader (), "VertexLitGeneric") or
		string.find (self.Material:GetShader (), "Cable") then
		local baseTexture = self.Material:GetString ("$basetexture")
		if baseTexture then
			local newMaterial = {
				["$basetexture"] = baseTexture,
				["$vertexcolor"] = 1,
				["$vertexalpha"] = 1
			}
			self.Material = CreateMaterial (image .. "_DImage", "UnlitGeneric", newMaterial)
		end
	end
	
	self.Width = self.Material:GetTexture ("$basetexture"):Width ()
	self.Height = self.Material:GetTexture ("$basetexture"):Height ()
end

function self:Draw (x, y, r, g, b, a)
	surface.SetMaterial (self.Material)
	surface.SetDrawColor (r or 255, g or 255, b or 255, a or 255)
	surface.DrawTexturedRect (x or 0, y or 0, self.Width, self.Height)
end

function self:GetHeight ()
	return self.Height
end

function self:GetSize ()
	return self.Width, self.Height
end

function self:GetWidth ()
	return self.Width
end