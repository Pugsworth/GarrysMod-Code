-- local PANEL = {};
___PANEL = {};
local PANEL = ___PANEL;
PANEL.frame = vgui.Create("DFrame");
PANEL.model = PANEL.frame:Add("DAdjustableModelPanel");
PANEL.wangpanel = PANEL.frame:Add("DPanel");
PANEL.number = PANEL.wangpanel:Add("DNumSlider");
PANEL.button = PANEL.wangpanel:Add("DButton");

PANEL.frame:SetSize(500, 300);
PANEL.frame:Center();
PANEL.frame:MakePopup();

PANEL.model:SetSize(256, 256);
PANEL.model:Dock(LEFT);
PANEL.model:SetFOV(54);
PANEL.model:SetModel("models/weapons/v_physcannon.mdl");
PANEL.model.LayoutEntity = function() end;
PANEL.model:SetCamPos(Vector(20, -6, -2));
PANEL.model:SetLookAng(Angle(15, -4, 0));
-- PANEL.model:SetCamPos(PANEL.model.Entity:GetPos() - Vector(0, 0, 8))
-- PANEL.model:SetModel("models/props_c17/FurnitureBathtub001a.mdl");

PANEL.model.PaintOver = function(self, w, h)
	surface.SetDrawColor(Color(0, 0, 0));
	surface.DrawOutlinedRect(0, 0, w, h);
end

PANEL.wangpanel:Dock(RIGHT);
PANEL.wangpanel:SetWide(128);
//PANEL.wangpanel:SizeToChildren();

PANEL.number:SetText("balls");
PANEL.number:SetMinMax(0, 10);
PANEL.number:SetDark(true);
PANEL.number:SizeToContents();

PANEL.button:SetText("GetPos");
PANEL.button.DoClick = function(self)
	print(PANEL.model:GetCamPos());
	print(PANEL.model:GetLookAng());
end



concommand.Add("debug_removepanels", function()
	for k, v in pairs(PANEL) do
		if IsValid(v) then
			v:Remove();
		end
	end
end)