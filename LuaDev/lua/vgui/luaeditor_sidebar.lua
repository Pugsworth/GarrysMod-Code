local PANEL = {};

AccessorFunc(PANEL, "m_iItemMargin", "ItemMargin", FORCE_NUMBER);

function PANEL:Init()

	self.canvas = self:Add("DPanel");
	self.canvas:Dock(FILL);

	self:SetItemMargin(0);

end

function PANEL:AddPanel(panel)

	if type(panel) == "string" then
		panel = self.canvas:Add(panel);
	else
		panel:SetParent(self.canvas);
	end

	-- panel:Dock(TOP);

	self:InvalidateLayout();

	return panel;

end

function PANEL:PerformLayout(width, height)

	local items = self.canvas:GetChildren();

	local canvasWidth = self.canvas:GetWide();

	local y = 0;

	for i = 1, #items do
		local pnl = items[i];

		pnl:SetPos(1, y);
		pnl:SetWide(canvasWidth - 2);

		y = y + pnl:GetTall() + self:GetItemMargin();
	end

	print("[Sidebar] PerformLayout ", y, " - ", #items);

end

function PANEL:AddLabel(text)

	local lbl = vgui.Create("DLabel");
	lbl:SetText(text);

	return self:AddPanel(lbl);

end

function PANEL:AddButton(label, image, callback)

	if type(image) == "function" then
		callback = image;
		image = nil;
	end

	local btn = vgui.Create("luaeditor_button");

	if image then
		btn:SetImage(image);
	end
	
	btn:SetText(label);
	btn:SetSize(0, 22);

	btn.DoClick = callback;

	return self:AddPanel(btn);

end

function PANEL:AddDivider(height)

	local pnl = vgui.Create("Panel");
	pnl:SetTall(height);

	return self:AddPanel(pnl);

end

function PANEL:AddDropDown(label, data)

	--[[
	data = {
		{label, callback(self)}[,]
	}
	--]]

	local btn = vgui.Create("luaeditor_button");
	btn:SetText(label);
	btn.DoClick = function(self)
		local menu = DermaMenu();

		for i = 1, #data do
			menu:AddOption(unpack(data[i]));
		end

		menu:Open();
	end

	return self:AddPanel(btn);

end

function PANEL:AddCombo(choices, callback)

	--[[
	choices = {
		{label, data{any}}[,]
	}
	--]]

	local box = vgui.Create("DComboBox");

	for i = 1, #choices do
		local choice = choices[i];

		local value = choice[1];
		local data = choice[2];
		
		box:AddChoice(value, data);
	end

	return self:AddPanel(box);

end

vgui.Register("luaeditor_sidebar", PANEL, "DPanel");
