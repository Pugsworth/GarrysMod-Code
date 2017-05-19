-- slightly edited skin file to take advantage of the original gwen skin
include("skins/gwendefault.lua");


--[[
-- Utility and Helper functions
--]]

-- fetch the list of sandscapes by reading scripts/soundscapes_manifest.txt
local soundscape_manifest_path = "scripts/soundscapes_manifest.txt";
local function getSoundscapeFileList()
    if (not file.Exists(soundscape_manifest_path, "GAME")) then Error("Soundscape manifest doesn't exist!"); return false; end

    local manifest = file.Read(soundscape_manifest_path, "GAME")
    local ret = {};

    local pattern = '%s*"file"%s*"(.-)"';
    for m in string.gmatch(manifest, pattern) do
        ret[#ret + 1] = m;
    end

    return ret;
end

local function getSoundscapesFromFile(soundscapefile)
    -- it doesn't seem required to strip comments
    local soundscape_contents = file.Read(soundscapefile, "GAME");
    -- KeyValuesToTable requires a root node, so we must inject our own
    local parsed = util.KeyValuesToTable("\"Injected Parsing Helper\"\n{" .. soundscape_contents .. "\n}");

    local ret = {};
    for k, v in pairs(parsed) do
        ret[#ret + 1] = k;
    end

    return ret;
end

local function playSoundscape(name)
    -- first we have to stop all soundscapes
    -- there isn't a way to save/restore state, so this is destructive
    RunConsoleCommand("cl_soundscape_flush");

    -- since it takes a second or so to stop playing sounds, wait to play the new soundscape
    if not timer.Start("soundscape_browser.timer") then
        timer.Create("soundscape_browser.timer", 1, 1, function()
            print("Playing soundscape: " .. name);
            RunConsoleCommand("playsoundscape", name);
        end);
    end
end


--[[
-- Panels
--]]

--
-- Taken from my DIconBrowserX control
--

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
local pnlTextBar = vgui.Register("DTextBar", {

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
local pnlTextBarOverlay = vgui.Register("DTextBarOverlay", {
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

        self.overlay:SetZPos(99);
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

}, "DTextBar");



local pnlSS_ctrls = vgui.RegisterTable({
    Init = function(self)
        -- AccessorFunc(self, "m_SoundscapeFile", "File");
        -- AccessorFunc(self, "m_Soundscapes", "Soundscapes");

        self.m_SoundscapeFile = "";

        self.pnlDivider = self:Add("DVerticalDivider");
        self.pnlTextBar = self:Add("DTextBarOverlay");
        self.pnlSoundscapeList = self:Add("DListView");
        self.pnlSoundscapeControls = self:Add("Panel");

        self.pnlDivider:SetTop(self.pnlSoundscapeList);
        self.pnlDivider:SetBottom(self.pnlSoundscapeControls);
        self.pnlDivider.m_DragBar:SetPaintBackground(true);
        -- self.pnlDivider:DockPadding(0, 0, 0, 0);
        self.pnlDivider:DockMargin(1, 1, 1, 1);

        self.pnlTextBar:Dock(TOP);
        self.pnlDivider:Dock(FILL);

        self.pnlDivider:SetDividerHeight(4);
        self.pnlDivider:SetTopHeight(self:GetTall() * (3 / 4));
        self.pnlDivider:SetTopMin(100);
        self.pnlDivider:SetTopHeight(9999);
        self.pnlDivider:SetBottomMin(50);

        self.pnlTextBar:SetPlaceholderText("Soundscape Name");
        self.pnlTextBar:SetReadOnly(true);
        self.pnlTextBar:SetImage("icon16/page_copy.png");

        self.pnlSoundscapeList:SetMultiSelect(false);
        self.pnlSoundscapeList:AddColumn("Soundscapes");

        do -- controls region

            local panel = self.pnlSoundscapeControls;

            panel.btnPlay = panel:Add("DImageButton");
            panel.btnStop = panel:Add("DImageButton");
            panel.btnPlay:SetImage("icon16/control_play.png");
            panel.btnStop:SetImage("icon16/control_stop.png");
            panel.btnPlay:SetSize(16, 16);
            panel.btnStop:SetSize(16, 16);
            panel.btnStop:SetPos(21, 0);

            panel.btnPlay.DoClick = function(this)
                local line = self.pnlSoundscapeList:GetSelectedLine();
                if line then
                    playSoundscape(self.pnlSoundscapeList:GetLine(line):GetColumnText(1));
                end
            end

            panel.btnStop.DoClick = function(this)
                RunConsoleCommand("cl_soundscape_flush");
            end

        end


        self.pnlTextBar.DoClick = function(this)
            local text = string.Trim(this:GetText());

            if string.Trim(text) ~= "" then
                this:SetEnabled(false);

                this:ShowOverlay("Copied to clipboard!", function(that)
                    this:SetEnabled(true);
                end);

                SetClipboardText(text);
            end
        end

        self.pnlSoundscapeList.DoDoubleClick = function(this, rowid, row)
            self:OnSelected(rowid, row, true);
        end
        self.pnlSoundscapeList.OnRowSelected = function(this, rowid, row)
            self.pnlTextBar:SetText(row:GetColumnText(1));
            self:OnSelected(rowid, row, false);
        end
    end,

    PerformLayout = function(self, width, height)
        -- self.pnlSoundscapeList:SetTall(height * (2 / 3));
        -- self.pnlSoundscapeControls:SetTall(height * (1 / 3));
    end,

    -- set the file to load soundscape lists from
    SetFile = function(self, soundscape_file)
        self.m_SoundscapeFile = soundscape_file;
        print("Attempting population from: " .. self.m_SoundscapeFile);
        self:populateList();
    end,

    GetFile = function(self)
        return self.m_SoundscapeFile;
    end,

    OnSelected = function(self, rowid, row, dblclk)
        -- Override me!
    end,

    -- populate the soundscape list from the file
    populateList = function(self)
        local list = getSoundscapesFromFile(self.m_SoundscapeFile);
        self.pnlSoundscapeList:Clear();

        for i = 1, #list do
            -- self.m_SoundScapes[#self.m_Soundscapes + 1] = list[i];
            self.pnlSoundscapeList:AddLine(list[i]);
        end

        self.pnlSoundscapeList:SortByColumn(1, false);
    end
}, "Panel");

local pnlSS_browser = vgui.RegisterTable({
    Init = function(self)
        --[[
        self.pnlTree = self:Add("DTree");
        self.pnlTree.OnNodeSelected = function(self, node) end
        self.pnlTree.OnClick = function(self, node) print("Node clicked: " .. tostring(node)); end
        --]]
        self.pnlManifestList = self:Add("DListView");
        self.pnlManifestList:Dock(FILL);
        self.pnlManifestList:SetMultiSelect(false);
        self.pnlManifestList:AddColumn("Manifest");
        self.pnlManifestList.OnRowSelected = function(this, rowid, row)
            self:OnSelected(rowid, row);
        end
        self.pnlManifestList.OnRowRightClick = function(self, rowid, row)
            local menu = DermaMenu();
            menu:AddOption("Copy", function() SetClipboardText(row:GetColumnText(1)) end);
            menu:Open();
        end
    end,

    OnSelected = function(self, rowid, row)
        -- Override me!
    end,

    PopulateManifest = function(self, list)
        self.pnlManifestList:Clear();

        for i = 1, #list do
            self.pnlManifestList:AddLine(list[i]);
        end

        self.pnlManifestList:SortByColumn(1, false);
    end
}, "Panel");


--[[
-- Main Panel
--]]

local PANEL = {};

function PANEL:Init()
    self.init = true;

    -- panels
    self.pnlDivider  = vgui.Create("DHorizontalDivider", self);
    self.pnlBrowser  = vgui.CreateFromTable(pnlSS_browser);
    self.pnlControls = vgui.CreateFromTable(pnlSS_ctrls);

    self.pnlDivider:Dock(FILL);
    self.pnlDivider:DockPadding(0, 0, 0, 0);
    self.pnlDivider:DockMargin(2, 2, 2, 2);
    self.pnlDivider:SetLeft(self.pnlBrowser);
    self.pnlDivider:SetRight(self.pnlControls);
    self.pnlDivider.m_DragBar:SetPaintBackground(true);

    self.pnlDivider:SetDividerWidth(4);
    self.pnlDivider:SetLeftMin(200);
    self.pnlDivider:SetRightMin(100);
    -- self.pnlDivider:SetLeftWidth(300);

    self.pnlBrowser.OnSelected = function(this, rowid, row)
        self:OnManifestSelected(row);
    end
    self.pnlControls.OnSelected = function(this, rowid, row, dblclk)
        self:OnSoundscapeSelected(row, dblclk);
    end

    -- fields

    self.soundscapeManifest = {};

end

function PANEL:PerformLayout(width, height)
    -- dirty hack to 50:50 the widths on init
    if self.init then
        self.pnlDivider:SetLeftWidth(width / 2);
        self.init = nil;
    end
end

function PANEL:LoadManifest()
    local list = getSoundscapeFileList();

    self.pnlBrowser:PopulateManifest(list);
end

function PANEL:OnManifestSelected(row)
    -- Override me!
    print("Manifest Selected: " .. row:GetColumnText(1));
    self.pnlControls:SetFile(row:GetColumnText(1));
end

function PANEL:OnSoundscapeSelected(row, dblclk)
    -- Override me!
    print("Soundscape Selected: " .. row:GetColumnText(1) .. " - " .. tostring(dblclk));
    playSoundscape(row:GetColumnText(1));
end

vgui.Register("DSoundscapeBrowser", PANEL, "Panel");


--[[
-- Open Command
--]]

local instance;
concommand.Add("vgui_show_soundscape_browser", function(ply, cmd, args)

    if IsValid(instance) then
        if not instance:IsVisible() then
            instance:SetVisible(true);
            instance:MakePopup();
        end
        return false;
    end

    local frame = vgui.Create("DFrame");
    local browser = frame:Add("DSoundscapeBrowser");
    browser:Dock(FILL);

    frame:SetTitle("Soundscape Browser");
    frame:SetSizable(true);
    frame:SetScreenLock(true);
    frame:SetSize(ScrW() / 2, ScrH() / 2);

    frame:SetSkin("GWENDefault");

    frame:SetDeleteOnClose(false);

    frame:Center();
    frame:MakePopup();

    instance = frame;

    -- begin loading process
    browser:LoadManifest();

end);


--[[
    Bugs:
    TODO:
        Use a tree for the manifest to split by path (usually game, but make a default folder)*
        Soundscape left, right, and double click all share the same callback
        Save selection, position, sizes of panel with cookies?







    * concept for splitting:

    local str = "scripts/soundscapes/ep2/soundscapes_outland2.txt";
    local spl = string.Split(str, '/');

    -- remove common paths to get the hierarchy going
    if spl[1] == "scripts" then table.remove(spl, 1); end
    if spl[1] == "soundscapes" then table.remove(spl, 1); end

    for i = 1, #spl do
        print(spl[i]);
    end



--]]
