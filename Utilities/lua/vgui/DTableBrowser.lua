if true then return false; end

-- slightly edited skin file to take advantage of the original gwen skin
include("skins/gwendefault.lua");

-- a label with the looks of a dpanel
local pnlLabelPanel = vgui.RegisterTable({

	Init = function(self)
		self:SetContentAlignment(5);
	end,
	Paint = function(self, w, h)
		local skin = self:GetSkin();
		skin.tex.Panels.Highlight(0, 0, w, h, self.m_bgColor);
	end,

}, "DLabel");

-- textentry with button on right
local pnlTextBar = vgui.RegisterTable({

	Init = function(self)
		self.m_bReadOnly = false;
		self.m_bPlaceholderEnabled = false;

		self:SetTall(24);

		self.textBar = self:Add("DTextEntry");
		self.textBar:Dock(FILL);
		self.textBar:SetUpdateOnType(true);
		self.textBar:SetHistoryEnabled(true);
		self.textBar:DockMargin(1, 1, 1, 1);
		self.textBar:SetDrawBorder(false);

		self.textBar.AllowInput = function(this, value)
			return self:GetReadOnly(); -- a+ garry, you understand basic logic
		end
		self.textBar.orig_OnKeyCodeTyped = self.textBar.OnKeyCodeTyped;
		self.textBar.OnKeyCodeTyped = function(this, keyCode) -- b+ garry, you give us a :OnKeyCode event without the ability to override anything
			if self:GetReadOnly() then
				local bCtrlDown = input.IsKeyDown(KEY_LCONTROL) or input.IsKeyDown(KEY_RCONTROL);
				local bShiftDown = input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT);

				-- is this only good for US keyboards?
				if (bCtrlDown and (keyCode == KEY_V or keyCode == KEY_X)) or -- no pasting
				 	(bShiftDown and keyCode == KEY_INSERT) or -- no pasting
				 	(keyCode == KEY_DELETE or keyCode == KEY_BACKSPACE) then -- no deleting

					-- probably isn't garry's fault that AllowInput isn't called for these,
					-- but it's his fault that he didn't write this this duct tape fix
					-- although, he could have just fixed it in-engine
					return true
				end
			end

			return this.orig_OnKeyCodeTyped(this, keyCode);
		end

		self.textBar.OnValueChange = function(this, value)

			if string.Trim(value) == "" then
				self.placeholder:SetVisible(self.m_bPlaceholderEnabled);
			else
				self.placeholder:SetVisible(false);
			end

			self:OnType(value, false);
		end
		self.textBar.OnEnter = function(this)
			self.textBar:AddHistory(this:GetText());
			self:OnType(self:GetText(), true);
		end

		self.placeholder = self.textBar:Add("DLabel");
		self.placeholder:Dock(FILL);
		self.placeholder:DockMargin(4, 1, 1, 1);
		self.placeholder:SetPaintBackground(false);
		self.placeholder:SetHighlight(false);
		-- self.placeholder:SetDisabled(true);
		-- self.placeholder:SetDark(true); -- another good one by garry; override disabled colors
		self.placeholder.UpdateColours = function(this, skin)
			this:SetTextStyleColor(Color(150, 150, 150));
		end
		self.placeholder:SetContentAlignment(4);

		self.btn = self:Add("DImageButton")
		self.btn:SetSize(24, 24);
		self.btn:Dock(RIGHT);
		self.btn:DockMargin(1, 1, 1, 1);
		self.btn:SetDrawBackground(true);
		self.btn:SetStretchToFit(false);
		self.btn:SetImage("icon16/cross.png");
		self.btn.DoClick = function(this)
			self:DoClick();
		end
	end,

	SetEnabled = function(self, bEnabled, ...)
		-- self.BaseClass.SetEnabled(self, bEnabled, ...); -- this causes a stack overflow for some stupid reason
		-- self.m_bEnabled = bEnabled;
		self.m_bDisabled = not bEnabled;
		self.btn:SetEnabled(bEnabled);

		self:InvalidateLayout();
	end,

	SetImage = function(self, strImage, strBackup)
		self.btn:SetImage(strImage, strBackup);
	end,
	GetImage = function(self)
		return self.btn:GetImage();
	end,

	SetPlaceholderText = function(self, text)
		self.placeholder:SetText(text);
		self.m_bPlaceholderEnabled = string.Trim(text) == "" and false or true;
	end,
	GetPlaceholderText = function(self)
		return self.placeholder:GetText();
	end,

	SetReadOnly = function(self, bReadOnly)
		self.m_bReadOnly = bReadOnly;
	end,
	GetReadOnly = function(self)
		return self.m_bReadOnly;
	end,

	SetText = function(self, value)
		self.textBar:SetValue(value);
	end,
	GetText = function(self)
		return self.textBar:GetValue();
	end,

	ClearText = function(self)
		self:SetText(""); -- this calls the textentry's SetValue which calls OnValueChanged which calls this class' OnType
	end,

	OnType = function(self, text, bEnter)
		-- override me
	end,

	DoClick = function(self)
		-- override me
	end
}, "DPanel");

-- above textbar with fadeout notification
local pnlTextBarOverlay = vgui.RegisterTable({
	Init = function(self)
		self.m_fOverlayFadeTime = 0.250;
		self:SetPaintBackground(false);

		self.overlay = self:Add(pnlLabelPanel);
		self.overlay:Dock(FILL);
		self.overlay:DockMargin(3, 3, 3, 3);
		self.overlay:Hide(); -- hide overlay by default
	end,
	SetOverlayFadeTime = function(self, time)
		self.m_fOverlayFadeTime = time;
	end,
	GetOverlayFadeTime = function(self)
		return self.m_fOverlayFadeTime;
	end,
	SetOverlayText = function(self, text)
		self.overlay:SetText(text);
	end,
	GetOverlayText = function(self)
		return self.overlay:GetText();
	end,
	ShowOverlay = function(self, text, fCallback)
		if text then
			self:SetOverlayText(text);
		end

		self.overlay:Show();
		self.overlay:SetAlpha(255);

		self.overlay:AlphaTo(0, self.m_fOverlayFadeTime, 1, function(animData, pnl)
			pnl:Hide();

			if isfunction(fCallback) then
				fCallback(self);
			end
		end);
	end,
	IsOverlayVisible = function(self)
		return self.overlay:IsVisible();
	end

}, "DIconBrowserX_TextBar");


local PANEL = {}

function PANEL:Init()
	self:SetSkin("GWENDefault");

	self.searchBar = self:Add("DIconBrowserX_TextBar");
	self.searchBar:Dock(TOP);
	self.searchBar:SetPlaceholderText("Search Icons...");
	self.searchBar.DoClick = function(this)
		this:ClearText();
	end

	self.iconBar = self:Add("DIconBrowserX_TextBarOverlay");

	self.iconBar:Dock(TOP);
	self.iconBar:SetEnabled(false);
	self.iconBar:SetPlaceholderText("<Icon name>");
	self.iconBar:SetImage("icon16/page_copy.png");
	self.iconBar:SetReadOnly(true);
	self.iconBar.DoClick = function(this)
		local text = string.Trim(this:GetText());

		print("text");

		if string.Trim(text) ~= "" then
			this:SetEnabled(false);
			self.icons:SetEnabled(false);

			self.iconBar:ShowOverlay("Copied to clipboard!", function(that)
				this:SetEnabled(true);
				self.icons:SetEnabled(true);
			end);

			SetClipboardText(text);
		end
	end

	self.icons = self:Add("DIconBrowser");
	self.icons:Dock(FILL);
	self.icons:DockMargin(1, 1, 1, 1);

	self.icons.OnChange = function(this)
		self.iconBar:SetText(this:GetSelectedIcon());
		self.iconBar:SetEnabled(not self.iconBar:IsOverlayVisible());
	end

	self.searchBar.OnType = function(this, query)
		self.icons:FilterByText(query)
	end

end

function PANEL:PerformLayout(w, h)
	-- self.searchBar:SetTall(24);
	-- self.iconBar:SetTall(24);
end

vgui.Register("DIconBrowserX", PANEL, "DPanel");


local function CreateIconBrowser()

	local frame = vgui.Create("DFrame");
	frame:SetTitle("Icon Browser");
	frame:SetSizable(true);
	frame:SetScreenLock(true);
	frame:SetSize(ScrW() / 4, ScrH() / 4);

	frame:SetSkin("GWENDefault");

	local icons = frame:Add("DIconBrowserX");
	icons:Dock(FILL);

	frame:Center();
	frame:MakePopup();

end

concommand.Add("vgui_show_tablebrowser", CreateIconBrowser);


--[[
	Final issues

	Bug:

	TODO:
		Everything
]]
