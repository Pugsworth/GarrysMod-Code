local WRAP_PANEL_R = {
	Base = "DPanel",
	Init = function(self)
		self.left  = self:Add("DCheckBoxLabel");
		self.right = self:Add("DCheckBoxLabel");
		self.padding = 1;
		self.gapsize = 8;
	end,
	PerformLayout = function(self, pw, ph)
		local padding, gapsize = self.padding, self.gapsize;
		self.left:SizeToContents(false, true);
		self.right:SizeToContents(false, true);

		local lw, lh = self.left:GetSize();
		local rw, rh = self.right:GetSize();

		self.left:SetPos(padding, padding);

		local w, h = lw + (gapsize), padding;
		if pw < lw + rw + (gapsize) then
			w = padding;
			h = lh + (padding * 2);
		end

		self.right:SetPos(w, h);
		self:SetTall(h + self.right:GetTall() + padding);
	end
};

local POINT_PANEL_R = {
	Base = "DPanel",
	Init = function(self)
		self.lvStart = self:Add("DListView");
		self.lvStart:AddColumn(""); -- single column
		self.lvStart:SetHideHeaders(true);
		self.lvStart:SetSortable(false);
		self.lvStart:Dock(LEFT);
		
		self.lvEnd = self:Add("DListView");
		self.lvEnd:AddColumn(""); -- single column
		self.lvEnd:SetHideHeaders(true);
		self.lvEnd:SetSortable(false);
		self.lvEnd:Dock(RIGHT);
	end,
	AddPoint = function(self)
		local line = self.lvStart:AddLine("");
		line:SetColumnText(1, "Point " .. line:GetID()); -- banni concat
		return line:GetID();
	end,
	PerformLayout = function(self, w, h)
		local hw = w / 2;

		self.lvStart:SetPos(0, 0);
		self.lvStart:SetWide(hw - 1);

		self.lvEnd:SetPos(hw + 2, 0);
		self.lvEnd:SetWide(hw - 1);

		self:SetTall(64);
	end
};

local ACTION_PANEL_R = {
	Base = "DPanel",
	Init = function(self)
		self.btnDelete = self:Add("DButton");
		self.btnDelete:SetText("Delete");

		self.btnDeleteAll = self:Add("DButton");
		self.btnDeleteAll:SetText("Delete All");

		self.btnView = self:Add("DButton");
		self.btnView:SetText("View");
	end,
	PerformLayout = function(self, w, h)
		local hw = w / 2;

		self.btnView:SetSize(w, 21);
		self.btnView:SetPos(0, 0);

		self.btnDelete:SetSize(hw - 2, 21);
		self.btnDelete:SetPos(0, 21);

		self.btnDeleteAll:SetSize(hw - 2, 21);
		self.btnDeleteAll:SetPos(hw + 4, 21);

		self:SetTall(21*2);
	end
};

local PANEL = {};

-- AccessorFunc(PANEL, "", "");

function PANEL:Init()
	self.BaseClass.Init(self);

	self.points = {};
	self:SetSpacing(0);
	-- self:SetAutoSize(true);

	local pnlHelpContainer = vgui.Create("DPanel");
	pnlHelpContainer:SetTall(64);

	self.lblHelp = pnlHelpContainer:Add("DLabel");
		self.lblHelp:Dock(FILL);
		self.lblHelp:SetText([[\n\n-- TODO: Help text --\n\n]]);

	self.pnlHelp = self:Add("DCollapsibleCategory");
		self.pnlHelp:SetContents(pnlHelpContainer);
		self.pnlHelp:SetLabel("Help");
		self:AddItem(self.pnlHelp);


	self.wrappanel = vgui.CreateFromTable(WRAP_PANEL_R);
		self:AddItem(self.wrappanel);
		self.wrappanel.left:SetText("Always Show");
		self.wrappanel.left:SetDark(true);
		self.wrappanel.left:SetConVar("tool_measuringstick_alwaysshow");

		self.wrappanel.right:SetText("Ignore Z");
		self.wrappanel.right:SetDark(true);
		self.wrappanel.right:SetConVar("tool_measuringstick_ignorez");

	self.cbAlwaysShow = self.wrappanel.left;
	self.cbIgnoreZ = self.wrappanel.right;

	self.cbSnap = self:Add("DCheckBoxLabel");
		self:AddItem(self.cbSnap);
		self.cbSnap:DockMargin(5, 0, 0, 1);
		self.cbSnap:SetText("Snap to World");

	self.slSnapDistance = self:Add("DNumSlider");
		self:AddItem(self.slSnapDistance);
		self.slSnapDistance:DockMargin(0, 0, 0, 2);
		self.slSnapDistance:SetText("Snap Distance");
		self.slSnapDistance:SetMin(1);
		self.slSnapDistance:SetMax(128);
		self.slSnapDistance:SetDecimals(0);
		self.slSnapDistance:SetConVar("tool_measuringstick_snapdistance");

	self.pnlPointContainer = vgui.Create("DPanel");
		self.pnlPointContainer:DockPadding(1, 1, 1, 0);
		self:AddItem(self.pnlPointContainer);

	self.pnlPoints = vgui.CreateFromTable(POINT_PANEL_R, self.pnlPointContainer);
		for i = 1, 10 do self.pnlPoints:AddPoint(); end
		self.pnlPoints:Dock(TOP);
		self.pnlPoints:DockMargin(1, 2, 1, 0);

		self.pnlPoints.lvStart.OnRowSelected = function(lineid, line)
			self:OnStartChanged(lineid);
		end

		self.pnlPoints.lvEnd.OnRowSelected = function(lineid, line)
			self:OnEndChanged(lineid);
		end

	self.pnlActions = vgui.CreateFromTable(ACTION_PANEL_R, self.pnlPointContainer);
		self.pnlActions:Dock(BOTTOM);
		self.pnlActions:DockMargin(1, 0, 1, 2);

end

function PANEL:PerformLayout(w, h)
	self.BaseClass.PerformLayout(self, w, h);
	self.pnlPointContainer:SizeToChildren(false, true);
	self:SizeToChildren(false, true);
end

function PANEL:AddPoints()
end

function PANEL:RemovePoint(index)
	if index == #self.points then

	end
	table.remove(self.points, index);
end

function PANEL:SelectStart()
end

function PANEL:SelectEnd()
end

function PANEL:OnStartChanged() end -- Override

function PANEL:OnEndChanged() end -- Override

--[[
function PANEL:Think()
end
--]]


vgui.Register("DMeasuringStick", PANEL, "DPanelList");
