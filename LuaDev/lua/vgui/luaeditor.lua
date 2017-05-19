local PANEL = {};

function PANEL:Init()

	---
	-- panels
	---
	local le_html = vgui.Create("luaeditor_html");

	local le_sidebar = vgui.Create("luaeditor_sidebar");
	le_sidebar:DockPadding(2, 2, 2, 2);
	le_sidebar:SetItemMargin(2);

	local le_topbar = self:Add("luaeditor_topbar");
	le_topbar:SetTall(22);
	le_topbar:DockPadding(10, 10, 10, 10);
	le_topbar:Dock(TOP);

	local le_divider = self:Add("DHorizontalDivider");
	le_divider:Dock(FILL);
	le_divider:SetDividerWidth(4);
	le_divider:SetLeftMin(60);
	le_divider:SetRightMin(120);
	le_divider:SetLeftWidth(120);
	le_divider.m_DragBar.Paint = function(this, w, h)
		surface.SetDrawColor(101, 100, 105, 255);
		surface.DrawRect(0, 0, w, h);
	end
	
	le_divider:SetLeft(le_sidebar);
	le_divider:SetRight(le_html);


	---
	-- controls
	---

	-- sidebar

	le_sidebar:AddDivider(22);
	
	le_sidebar:AddButton("Save", function(this) end);
	le_sidebar:AddButton("Load", function(this) end);
	le_sidebar:AddButton("Open", function(this) end);

	le_sidebar:AddDivider(22);

	le_sidebar:AddButton("Open From URL", function(this) end);

	le_sidebar:AddDropDown("Pastebin", {
		{"Upload",   function(this) end},
		{"Download", function(this) end},
		{"Settings", function(this) end}
	});

	le_sidebar:AddDivider(22);

	-- theme selector
	le_sidebar:AddCombo({
			{"Theme 1", 1},
			{"Theme 2", 2},
			{"Theme 3", 3}
		},
		function(this, value, data)
			le_html:SetTheme(data.theme);
		end
	);

	-- syntax selector
	le_sidebar:AddCombo({
			{"Syntax 1", 1},
			{"Syntax 2", 2},
			{"Syntax 3", 3},
			{"Syntax 4", 4}
		},
		function(this, value, data)
			le_html:SetSyntax(data.mode);
		end
	);


	-- topbar

	local btn = le_topbar:AddButton("Menu",		"icon16/cog.png",		function(this) end, "Open the menu");
	btn:SetWide(120);
	btn:SetContentAlignment(4);
	-- le_topbar:AddDivider(48);
	le_topbar:AddButton("Run",		"icon16/bullet_go.png",	function(this) end, "Execute clientside"):SetHighlight(true);
	le_topbar:AddButton("Server",	"icon16/server.png",	function(this) end, "Execute serverside");
	le_topbar:AddButton("Clients",	"icon16/group.png",		function(this) end, "Execute on all connected clients");
	le_topbar:AddButton("Shared",	"icon16/world.png",		function(this) end, "Execute on all clients and server");

end

vgui.Register("luaeditor", PANEL, "DPanel");


----------
-- Keys --
----------

-- function html:OnKeyCodePressed(keycode)

-- 	if keycode == KEY_K and input.IsKeyDown(KEY_LCONTROL) then
-- 		self:Call("Lua_OpenKeybindings")
-- 	end

-- end


-- frame:MakePopup();


--]]
