----------
-- VGUI --
----------

local instance = nil;

local function CreateEditor(data)

	if instance and IsValid(instance) then
		instance:MakePopup();
		return;
	end

	local frame = vgui.Create("DFrame");
	frame:SetCookieName("luaeditor");
	frame:SetTitle("Lua Editor");
	frame:SetDeleteOnClose(false);
	frame:SetDraggable(true);
	frame:SetSizable(true);
	frame:SetMinWidth(256);
	frame:SetMinHeight(128);

	local w, h = unpack(frame:GetCookie("Size", '680,420'):Split(','));
	frame:SetSize(w, h);

	local xf, yf = unpack(frame:GetCookie("Position", '0.5,0.5'):Split(','));
	frame:SetPos((ScrW() * xf) - (w / 2), (ScrH() * yf) - (h / 2));

	frame.luaeditor = frame:Add("luaeditor");
	frame.luaeditor:Dock(FILL);

	instance = frame;

end


concommand.Add("ld_openeditor", function(ply, cmd, args)

	if not IsValid(ply) then return; end

	local bForce = false;
	if table.HasValue(args, "reload") then
		bForce = true;
		print("Reloading Lua Editor...");
	end

	CreateEditor(args, bForce);

	print(instance);

	instance:Show();
	instance:MakePopup();

end);
