local PANEL = {}

function PANEL:Init ()
	self.HighlightedIndex = 0
	self.ItemClass = "QuickToolMenuItem"
end

function PANEL:AddItem (text)
	text = text or ""
	
	local item = vgui.Create (self.ItemClass)
	item:SetText (text)
	
	DPanelList.AddItem (self, item)
	
	return item
end

function PANEL:AddSpacer ()
	local spacer = vgui.Create ("QuickToolMenuSpacer")
	DPanelList.AddItem (self, spacer)
	return spacer
end

function PANEL:Clear ()
	DPanelList.Clear (self, true)
	self.HighlightedIndex = 0
end

function PANEL:GetHighlightedItemIndex ()
	return self.HighlightedIndex
end

function PANEL:GetHighlightedItem ()
	return self:GetItems () [self.HighlightedIndex]
end

function PANEL:GetItem (index)
	return self:GetItems () [index]
end

function PANEL:GetItemClass ()
	return self.ItemClass
end

function PANEL:GetItemCount ()
	return #self:GetItems ()
end

function PANEL:HighlightNext ()
	if self:GetItemCount () == 0 then
		return nil
	end
	local highlightedIndex = self.HighlightedIndex + 1
	if highlightedIndex > self:GetItemCount () then
		highlightedIndex = 1
	end
	self:SetHighlightedItemIndex (highlightedIndex)
	return self:GetHighlightedItem ()
end

function PANEL:HighlightPrevious ()
	if self:GetItemCount () == 0 then
		return nil
	end
	local highlightedIndex = self.HighlightedIndex - 1
	if highlightedIndex <= 0 then
		highlightedIndex = self:GetItemCount ()
	end
	self:SetHighlightedItemIndex (highlightedIndex)
	return self:GetHighlightedItem ()
end

function PANEL:Paint (w, h)
end

function PANEL:SetHighlightedItemIndex (index)
	if self:GetItems () [self.HighlightedIndex] then
		self:GetItems () [self.HighlightedIndex]:SetHighlighted (false)
	end
	self.HighlightedIndex = index
	if self:GetItems () [self.HighlightedIndex] then
		self:GetItems () [self.HighlightedIndex]:SetHighlighted (true)
	else
		self.HighlightedIndex = 0
	end
end

function PANEL:SetItemClass (class)
	self.ItemClass = class
end

function PANEL:Sort ()
	self:SortByMember ("SortKey", false)
end

vgui.Register ("QuickToolMenu", PANEL, "DPanelList")