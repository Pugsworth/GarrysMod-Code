local PANEL = {}

function PANEL:Init ()
	self:SetItemHeight (2)
	
	self.SortKey = ""
end

function PANEL:Paint (w, h)
end

vgui.Register ("QuickToolMenuSpacer", PANEL, "QuickToolMenuItem")