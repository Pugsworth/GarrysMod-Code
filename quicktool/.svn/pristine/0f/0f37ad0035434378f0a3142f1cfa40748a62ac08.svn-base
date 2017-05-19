local PANEL = {}

--[[
	This uses a cache of the materials used instead of recreating them each time a new image control is created.
]]

function PANEL:Init ()
	self:SetTall (4)
	
	self.SortKey = ""
	self.Image = nil
end

function PANEL:GetImage ()
	return self.Image
end

function PANEL:Paint (w, h)
	if self.Image then
		local image = QuickTool.ImageCache:GetImage (self.Image)
		image:Draw ((self:GetWide () - image:GetWidth ()) * 0.5, (self:GetTall () - image:GetHeight ()) * 0.5)
	end
end

function PANEL:SetImage (image)
	self.Image = image
end

vgui.Register ("QuickToolImage", PANEL, "Panel")