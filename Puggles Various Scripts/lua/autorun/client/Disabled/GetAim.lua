timer.Simple(0, function() -- I shouldn't have to do this.
	local ToClip = CreateConVar( "ToClipboardByDefault", 1, FCVAR_ARCHIVE )
	local NOTIFY_SOUND = "buttons/bell1.wav"
	local clipped = false
	local me = LocalPlayer()
	local ALLOW_CURSOR = 1

	local function notify(sound, text)
		me:EmitSound(sound, 100, 100)
		if text then
			me:ChatPrint(text)
		end
	end

	local commands = {
		['GetEntity'] = function(ply, cmd, args)
			local tr
			if not args[2] then
				tr = args[1] == ALLOW_CURSOR and ply:GetEyeTrace() or ply:GetEyeTraceNoCursor()
			else
				tr = args[2]
			end

			if tr.HitNonWorld then
				local c = false
				local info = tostring(tr.Entity)

				if info != '' then
					if input.IsKeyDown(KEY_LSHIFT) or ToClip == 1 then
						c = true
						SetClipboardText(info)
					end
					notify(NOTIFY_SOUND, c and info .. ' copied to clipboard' or info)
					c = false
				end
			end
		end,

		['GetMaterial'] = function(ply, cmd, args)
			local tr
			if not args[2] then
				tr = args[1] == ALLOW_CURSOR and ply:GetEyeTrace() or ply:GetEyeTraceNoCursor()
			else
				tr = args[2]
			end

			if tr.HitNonWorld then
				local c = false
				local info = tostring(tr.Entity:GetMaterial())

				if info != '' then
					if input.IsKeyDown(KEY_LSHIFT) or ToClip == 1 then
						c = true
						SetClipboardText(info)
					end
					notify(NOTIFY_SOUND, c and info .. ' copied to clipboard' or info)
					c = false
				end
			end
		end,

		['GetModel'] = function(ply, cmd, args)
			local tr
			if not args[2] then
				tr = args[1] == ALLOW_CURSOR and ply:GetEyeTrace() or ply:GetEyeTraceNoCursor()
			else
				tr = args[2]
			end

			if tr.HitNonWorld then
				local c = false
				local info = tostring(tr.Entity:GetModel())

				if info != '' then
					if input.IsKeyDown(KEY_LSHIFT) or ToClip == 1 then
						c = true
						SetClipboardText(info)
					end
					notify(NOTIFY_SOUND, c and info .. ' copied to clipboard' or info)
					c = false
				end
			end
		end,

		['SpawnModel'] = function(ply, cmd, args)
			local tr
			if not args[2] then
				tr = args[1] == ALLOW_CURSOR and ply:GetEyeTrace() or ply:GetEyeTraceNoCursor()
			else
				tr = args[2]
			end


			if tr.HitNonWorld then
				if tr.Entity:GetModel() then
					me:ConCommand('gm_spawn ' .. tostring(tr.Entity:GetModel()))
					notify(NOTIFY_SOUND)
				end
			end
		end
	}


	/*---------------------------------------------------------------
		name: Add Commands
		description: Loop through given table and create commands
	-----------------------------------------------------------------*/
	do
		for con, func in pairs(commands) do
			concommand.Add(con, func)
		end
	end

	if true then return end
	
	----------------------
	-- Get-Object Panel --
	----------------------

	local w, h, pad = 256, 256, 10
	local PANEL = vgui.Create('DPanel')
		PANEL:SetSize(256, 256)
		PANEL:SetPos(ScrW() - w - pad, ScrH() - h - pad * 2)
		PANEL:SetVisible(false)
		PANEL.Paint = function(self)
			surface.SetDrawColor(Color(100, 100, 100, 244))
				surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(Color(80, 80, 80, 255))
				surface.DrawOutlinedRect(0, 0, w, h)
		end

	PANEL.btnModel = vgui.Create('DButton', PANEL)
		PANEL.btnModel:SetText('Model:')
		PANEL.btnModel:Dock(TOP)
		PANEL.btnModel.DoClick = function(self) SetClipboardText(self:GetText()) notify(NOTIFY_SOUND, self:GetText() .. ' copied to the cliboard.') end

	PANEL.btnMaterial = vgui.Create('DButton', PANEL)
		PANEL.btnMaterial:SetText('Material:')
		PANEL.btnMaterial:Dock(TOP)
		PANEL.btnMaterial.DoClick = function(self) SetClipboardText(self:GetText()) notify(NOTIFY_SOUND, self:GetText() .. ' copied to the cliboard.') end

	PANEL.btnEntity = vgui.Create('DButton', PANEL)
		PANEL.btnEntity:SetText('Entity:')
		PANEL.btnEntity:Dock(TOP)
		PANEL.btnEntity.DoClick = function(self) SetClipboardText(self:GetText()) notify(NOTIFY_SOUND, self:GetText() .. ' copied to the cliboard.') end

	function PANEL.SetInfo(self)
		local ent = me:GetEyeTrace().Entity
		PANEL.btnModel:SetText(ent:GetModel())
		PANEL.btnMaterial:SetText(ent:GetMaterial())
		PANEL.btnEntity:SetText(tostring(ent))
	end

	function PANEL.ANIMATE(self, t)
		local done = false
		local pos = {0, 0}

		self:SetVisible(tobool(t))
		done = tobool(t)
		gui.EnableScreenClicker(done)
	end



	local isdown = false
	hook.Add('GUIMousePressed', 'GetPanel', function(mc)
		isdown = mc == MOUSE_RIGHT and true or false
		if PANEL:IsVisible() then
			if isdown then
				local tr = util.TraceLine( util.GetPlayerTrace( me, me:GetCursorAimVector() ) )

				PANEL.DMenu = DermaMenu()
					PANEL.DMenu:AddOption('Get Model', 	function() commands.GetModel(me, 'Get', {ALLOW_CURSOR, tr}) end)
					PANEL.DMenu:AddOption('Get Material', function() commands.GetMaterial(me,'Get', {ALLOW_CURSOR, tr}) end)
					PANEL.DMenu:AddOption('Get Entity', function() commands.GetEntity(me, 'Get', {ALLOW_CURSOR, tr}) end)
					PANEL.DMenu:AddSpacer()
					PANEL.DMenu:AddOption('Spawn Model', function() commands.SpawnModel(me, 'Get', {ALLOW_CURSOR, tr}) end)
				PANEL.DMenu:Open()
			else
				PANEL:SetInfo()
			end
		end
	end)

	

	concommand.Add('+Get_Menu', function(ply, cmd, args) PANEL:ANIMATE(1) end) // 1 = open
	concommand.Add('-Get_Menu', function(ply, cmd, args) PANEL:ANIMATE(0) if PANEL.DMenu and PANEL.DMenu:IsVisible() then PANEL.DMenu:Hide() end end) // 0 = close

	//For development purpose
	concommand.Add('dev_remove_panel', function() PANEL:Remove() end)
end)
