local PANEL = {}

local gmod_tool = nil

function PANEL:Init ()
	self:SetTitle ("Tool search")

	self:SetSize (200, ScrH ())
	self:MakePopup ()

	self:SetDeleteOnClose (false)
	self:SetMouseInputEnabled (true)
	self:SetKeyboardInputEnabled (true)

	self.btnClose:Remove ()
	self.btnClose = nil

	self:SetPaintBackgroundEnabled (true)
	self:SetPaintBorderEnabled (true)

	self.HighlightedName = nil

	-- track max width for displayed items
	self.m_maxItemWidth = self:GetWide()

	-- Textbox
	self.Searchbox = vgui.Create ("DTextEntry", self)
	self.Searchbox.OnLoseFocus = function (self)
		self:RequestFocus () -- force focus to searchbox
	end
	self.Searchbox.AllowInput = function (self, val) -- return 'true' to disallow
		return val == '`' -- TODO: refine
	end
	self.Searchbox:SetPos (0, 0)
	self.Searchbox:SetWide (self:GetWide ())

	self.Searchbox.OnKeyCodeTyped = function (textbox, key)
		if key == KEY_UP then
			self:SelectPrevious ()

		elseif key == KEY_DOWN then
			self:SelectNext ()

		elseif key == KEY_TAB then
			self:SetVisible (false)

		elseif key == KEY_ENTER then
			if self.Menu:GetHighlightedItem () then
				self:OnItemChosen (self.Menu:GetHighlightedItem ().Name)
			else
				self:SetVisible (false)
			end

		elseif key == KEY_ESCAPE then
			self:SetVisible (false)
			gui.HideGameUI ()
		end
	end

	self.Searchbox.OnTextChanged = function (textbox)
	-- TODO: debounce and throttle
		self:Search (textbox:GetText ())
	end

	-- Menu
	self.Menu = vgui.Create ("QuickToolMenu", self)
	self.Menu:SetPos (0, self.Searchbox:GetTall () + 4)

	-- Callbacks
	self.Item_DoClick = function (item)
		self:OnItemChosen (item.Name)
	end

	self:Reposition ()
end

function PANEL:Clear ()
	self.Searchbox:SetText ("")
	self:Search (self.Searchbox:GetText ())
end

function PANEL:OnItemChosen (name)
	RunConsoleCommand ("gmod_tool", name)
	RunConsoleCommand ("gmod_toolmode", name)

	spawnmenu.ActivateTool (name)

	self:SetVisible (false)
end

function PANEL:Paint (w, h)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawOutlinedRect(0, 0, w, h)
end

function PANEL:PerformLayout ()
	-- self.Menu:SetSize (self:GetWide (), self:GetTall ())
	self.Menu:SetSize(self.m_maxItemWidth, self:GetTall())
end

function PANEL:Remove ()
	self:SetVisible (false)

	debug.getregistry ().Panel.Remove (self)
end

function PANEL:Reposition ()
	self:SetPos ((ScrW () - self:GetWide ()) * 0.5, (ScrH () - self.Searchbox:GetTall ()) * 0.5)
end

function PANEL:RequestFocus ()
	self.Searchbox:RequestFocus ()
end

local function MatchAll (str, tofind)
	for word in string.gmatch (str, "([^%s]+)") do
		if not tofind:lower ():find (word) then
			return false
		end
	end
	return true
end

local function getToolTabName(category, toolname)

	local tabs = spawnmenu.GetTools() -- good name

	for i, tab in ipairs(tabs) do

		if not tab.Items then continue end

		for j, cat in ipairs(tab.Items) do

			if cat.ItemName == category then
				return language.GetPhrase(string.gsub(tab.Label, "#", "", 1))
			end

		end

	end

	return ""

end

function PANEL:Search (text)
	self.Menu:Clear ()

	text = text:lower ():gsub ("*", ".*")
	gmod_tool = gmod_tool or weapons.Get ("gmod_tool")
	if not gmod_tool then
		return
	end
	local tools = gmod_tool.Tool

	local found = {}
	for name, tool in pairs (tools) do
		local toolname = tool.Name or name;
		if toolname [1] == "#" then
			toolname = language.GetPhrase (toolname:sub (2))
		end

		local cat = tool.Category

		if MatchAll (text, tostring (cat) .. toolname) then
			found [#found + 1] = {cat, toolname, name}
		end
	end

	table.sort (found, function(a, b)
		local aa, bb = a [2], b [2];
		return aa:lower () < bb:lower ()
			and #aa < #bb
	end)

	local maxWidth = 0

	local ScrH = ScrH ()
	local h = 0
	for k = 1, #found do
		local category, toolname, name = unpack (found [k])
		-- local item = self.Menu:AddItem (tools [name].Name or name)

		-- TODO: get tab name
		--  currently, the only way to get the name of the tab that the tool resides
		--  is to loop through every single tab and category and compare the tool name
		--  to the current one
		--  ... to every single entry in the search results
		-- ... here goes ...
		local tabname = getToolTabName(category, toolname)

		local itemText = category and string.format ("[%s][%s] %s", tabname, category, toolname) or toolname;
		local item = self.Menu:AddItem ( itemText )

		item.Name = name
		item:SetIcon ("icon16/wrench.png")
		item.DoClick = self.Item_DoClick

		surface.SetFont("Default")
		local tw, th = surface.GetTextSize(itemText)

		maxWidth = math.max(maxWidth, item:GetWide() + tw)
		h = h + item:GetTall ()

		if name == self.HighlightedName then
			self.Menu:SetHighlightedItemIndex (k)
		end
		if h > ScrH * 0.5 then
			break
		end
	end

	if not self.Menu:GetHighlightedItem () then
		self.Menu:SetHighlightedItemIndex (1)
		self.HighlightedName = self.Menu:GetHighlightedItem () and self.Menu:GetHighlightedItem ().Name
	end

	self.m_maxItemWidth = maxWidth
end

function PANEL:SelectNext ()
	local item = self.Menu:HighlightNext ()
	if not item then
		self.HighlightedName = nil
		return
	end

	self.HighlightedName = item.Name
end

function PANEL:SelectPrevious ()
	local item = self.Menu:HighlightPrevious ()
	if not item then
		self.HighlightedName = nil
		return
	end

	self.HighlightedName = item.Name
end

function PANEL:SetVisible (visible)
	if visible then
		self:Clear ()
		self:RequestFocus ()
	end
	debug.getregistry ().Panel.SetVisible (self, visible)
end

vgui.Register ("QuickToolSearch", PANEL, "DFrame")
