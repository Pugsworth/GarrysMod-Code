local PANEL = {}

function PANEL:Init ()
	self:SetSize (200, ScrH ())
	self:MakePopup ()
	
	self:SetDeleteOnClose (false)
	self:SetMouseInputEnabled (true)
	self:SetKeyboardInputEnabled (true)
	
	self.btnClose:Remove ()
	self.btnClose = nil
	self.lblTitle:Remove ()
	self.lblTitle = nil
	
	self:SetPaintBackgroundEnabled (true)
	self:SetPaintBorderEnabled (true)

	self.ActionTree = nil
	self.TreeStack = {}
	
	-- Input textbox
	self.TextEntry = vgui.Create ("DTextEntry", self)
	self.TextEntry:SetMouseInputEnabled (true)
	self.TextEntry:SetKeyboardInputEnabled (true)
	self.TextEntry:SetAllowNonAsciiCharacters (true)
	self.TextEntry:SetSize (0, 0)
	
	self.TextEntry.OnEnter = function (textbox)
		self:SetVisible (false)
	end
	
	self.TextEntry.OnKeyCodeTyped = function (textbox, key)
		if key == KEY_TAB then
			timer.Simple (0.001,
				function ()
					if textbox:IsValid () then
						textbox:RequestFocus ()
					end
				end
			)
		elseif key == KEY_ESCAPE then
			self:SetVisible (false)
			gui.HideGameUI ()
		end
	end
	
	self.TextEntry.OnTextChanged = function (textbox)
		if text == "" then
			return
		end
		self:OnKeyPressed (self.TextEntry:GetText ())
		self.TextEntry:SetText ("")
	end
	
	-- Menu
	self.Menu = vgui.Create ("QuickToolMenu", self)
	self.Menu:SetItemClass ("QuickToolHotkeyMenuItem")
	
	-- Callbacks
	function self.Item_DoClick (item)
		self:OnKeyPressed (item.Key)
	end
end

function PANEL:Clear ()
	self.TreeStack = {}
	self.Menu:Clear ()
end

function PANEL:OnKeyPressed (key)
	if not self.ActionTree then return end

	local child = self.ActionTree:GetChild (key)
	if child then
		self:PushActionTree (child)
	else
		if self.ActionTree:GetUpKey ():lower () == key:lower () then
			self:PopActionTree ()
		elseif self.ActionTree:GetEscapeKey () and self.ActionTree:GetEscapeKey ():lower () == key:lower () then
			self:SetVisible (false)
		end
	end
	if key == "ESC" then
		self:SetVisible (false)
		gui.HideGameUI ()
		return
	end
end

function PANEL:Paint (w, h)
end

function PANEL:PerformLayout ()
	self.Menu:SetSize (self:GetWide (), self:GetTall ())
end

function PANEL:PopActionTree ()
	self.TreeStack [#self.TreeStack] = nil
	self:SetActionTree (self.TreeStack [#self.TreeStack])
end

function PANEL:PushActionTree (tree)
	self.TreeStack [#self.TreeStack + 1] = tree
	self:SetActionTree (tree)
end

function PANEL:Reposition (itemsAboveCrosshair)
	self:SetPos ((ScrW () - self:GetWide ()) * 0.5, ScrH () * 0.5 - 22 * (itemsAboveCrosshair - 0.5))
end

function PANEL:RequestFocus ()
	self.TextEntry:RequestFocus ()
end
	
function PANEL:Remove ()
	self:SetVisible (false)
	debug.getregistry ().Panel.Remove (self)
end
	
function PANEL:SetActionTree (tree)
	self.Menu:Clear ()
	
	if not tree then return end
	
	if tree:GetType () == "tree" then
		self.ActionTree = tree
		for k, child in pairs (tree:GetChildren ()) do
			local item = self.Menu:AddItem ()
			item:SetKey (k)
			item:SetActionTree (child)
			item.DoClick = self.Item_DoClick
		end
		
		-- Escape menu item
		local item = self.Menu:AddItem ()
		local escapeKey = self.ActionTree:GetEscapeKey ()
		item:SetKey (escapeKey and escapeKey or "ESC")
		item:SetSortKey ("!1")
		item:SetText ("Escape")
		item.DoClick = self.Item_DoClick
		
		-- Up menu item
		if #self.TreeStack > 1 then
			local item = self.Menu:AddItem ()
			item:SetKey (self.ActionTree:GetUpKey ())
			item:SetSortKey ("!2")
			item:SetText ("Up")
			item.DoClick = self.Item_DoClick
			self:Reposition (2)
		else
			self:Reposition (1)
		end
		self.Menu:AddSpacer ():SetSortKey ("!z")
		
		self.Menu:Sort ()
	elseif tree:GetType () == "none" then
		self.ActionTree = tree
		
		-- Escape menu item
		local item = self.Menu:AddItem ()
		local escapeKey = self.ActionTree:GetEscapeKey ()
		item:SetKey (escapeKey and escapeKey or "ESC")
		item:SetSortKey ("!1")
		item:SetText ("Escape")
		item.DoClick = self.Item_DoClick
		
		self:Reposition (1)
		self.Menu:Sort ()
	else
		self:SetVisible (false)
		tree:RunAction ()
	end
end

function PANEL:SetVisible (visible)
	if visible then
		self:Clear ()
		self:RequestFocus ()
		
		self:PushActionTree (QuickTool.Hotkeys)
	end
	debug.getregistry ().Panel.SetVisible (self, visible)
end

vgui.Register ("QuickToolHotkeys", PANEL, "DFrame")