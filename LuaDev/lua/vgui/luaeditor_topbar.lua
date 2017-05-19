local PANEL = {};

function PANEL:Init()
	-- self.BaseClass:Init();


end

--[[
function PANEL:AddPanel(panel)
	self.BaseClass:AddPanel(panel);
	return panel;
end
--]]

function PANEL:AddButton(label, image, callback, tooltip)

	if type(image) == "function" then
		callback = image;
		image = nil;
	end

	local btn = vgui.Create("luaeditor_button");

	if image then
		btn:SetImage(image);
	end

	btn:SetTooltip(tooltip);
	btn:SetText(label);
	-- btn:SetTall(12);

	btn:SetContentAlignment(5);
	-- btn:SizeToContents();
	-- btn:SetTextInset(16, 0);
	-- btn:SetWide(btn:GetWide() + 10);

	btn.DoClick = callback;
	self:AddPanel(btn);
	return btn;

end

function PANEL:AddDivider(width)

	local pnl = vgui.Create("DPanel");
	pnl:SetWide(width);
	self:AddPanel(pnl);
	return pnl;

end

function PANEL:AddCombo(choices)

	local box = vgui.Create("DComboBox");

	for i = 1, #choices do
		local choice = choices[i];

		local value = choice[1];
		local data = choice[2];

		box:AddChoice(value, data);
	end

	self:AddPanel(box);
	return box;

end

function PANEL:PerformLayout(width, height)
	self.BaseClass.PerformLayout(self, width, height);
	print("[Topbar] PerformLayout");
end

function PANEL:DockMargin(left, top, right, bottom)
	self.pnlCanvas:DockMargin(left, top, right, bottom);
end

function PANEL:DockPadding(left, top, right, bottom)
	self.pnlCanvas:DockPadding(left, top, right, bottom);
end

vgui.Register("luaeditor_topbar", PANEL, "DHorizontalScroller");
