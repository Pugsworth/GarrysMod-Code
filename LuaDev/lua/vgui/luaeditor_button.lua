local PANEL = {};

AccessorFunc(PANEL, "m_bHighlight", "Highlight", FORCE_BOOL);

function PANEL:Init()

	self.m_Image = nil;

end

function PANEL:UpdateColours(skin)

	local styleColor = skin.Colours.Button.Normal;

	if self:GetDisabled()					then styleColor = skin.Colours.Button.Disabled; end
	if self.Depressed or self.m_bSelected	then styleColor = skin.Colours.Button.Down; end
	if self.Hovered or self:GetHighlight()  then styleColor = skin.Colours.Button.Hover; end

	return self:SetTextStyleColor(styleColor);

end

function PANEL:Paint(width, height)

	-- surface.SetDrawColor(self:GetTextStyleColor());
	-- surface.DrawRect(0, 0, width, height);
	surface.SetDrawColor(color_black);
	surface.DrawOutlinedRect(0, 0, width, height);

	return false;

end

vgui.Register("luaeditor_button", PANEL, "DButton");
