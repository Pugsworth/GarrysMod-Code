local PANEL = {}

function PANEL:Init ()
	self:SetItemHeight (20)

	self.SortKey = ""
	
	self.Icon = vgui.Create ("QuickToolImage", self)
	self.Icon:SetSize (16, 16)
	
	self.Text = vgui.Create ("DLabel", self)
	self.Text:SetText ("")
end

function PANEL:DoClick ()
end

function PANEL:GetItemHeight ()
	return self.ItemHeight
end

function PANEL:GetText ()
	return self.Text:GetText ()
end

function PANEL:IsHighlighted ()
	return self.Highlighted
end
	
function PANEL:OnCursorExited ()
	self.Depressed = false
	self:InvalidateLayout ()
end

function PANEL:OnMousePressed ()
	self.Depressed = true
	self:InvalidateLayout ()
end

function PANEL:OnMouseReleased ()
	self.Depressed = false
	self:InvalidateLayout ()
	
	self:DoClick ()
end
	
function PANEL:Paint (w, h)
	if self.Hovered or self.Highlighted then
		draw.RoundedBox (4, 0, 0, w, self.ItemHeight, Color (128, 128, 255, 192))
	else
		draw.RoundedBox (4, 0, 0, w, self.ItemHeight, Color (128, 128, 128, 192))
	end
end

function PANEL:PerformLayout ()
	local w = self:GetWide ()
	local h = self:GetItemHeight ()

	self:SetTall (h + 2)
	local offset = 0
	if self.Depressed then
		offset = 1
	end
	
	self.Text:SetPos (20 + offset, 0 + offset)
	self.Text:SetSize (w, h)
	
	self.Icon:SetPos (2 + offset, 2 + offset)
end

function PANEL:SetHighlighted (highlighted)
	self.Highlighted = highlighted
end
	
function PANEL:SetIcon (icon)
	self.Icon:SetImage (icon)
end

function PANEL:SetItemHeight (height)
	self.ItemHeight = height
end

function PANEL:SetSortKey (sortkey)
	self.SortKey = sortkey
end

function PANEL:SetText (text)
	self.Text:SetText (text)
end

vgui.Register ("QuickToolMenuItem", PANEL, "Panel")