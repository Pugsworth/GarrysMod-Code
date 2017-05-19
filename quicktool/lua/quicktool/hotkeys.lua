if QuickTool.HotkeyMenu then
	QuickTool.HotkeyMenu:Remove ()
end

QuickTool.Hotkeys = QuickTool.ActionTree ()
QuickTool.HotkeyMenu = nil

function QuickTool.LoadHotkeys ()
	QuickTool.Hotkeys:Clear ()
	
	local data = file.Read ("data/quicktool_hotkeys.txt", "GAME") or ""
	QuickTool.Hotkeys:Deserialize (util.KeyValuesToTable (data))
end

function QuickTool.SaveHotkeys ()
	file.Write ("quicktool_hotkeys.txt", util.TableToKeyValues (QuickTool.Hotkeys.Serialize ()))
end

QuickTool.LoadHotkeys ()

-- Menu
function QuickTool.CreateHotkeyMenu ()
	if QuickTool.HotkeyMenu and QuickTool.HotkeyMenu:IsValid () then
		return QuickTool.HotkeyMenu
	end

	QuickTool.HotkeyMenu = vgui.Create ("QuickToolHotkeys")
	return QuickTool.HotkeyMenu
end

function QuickTool.CloseHotkeyUI ()
	if not QuickTool.HotkeyMenu or not QuickTool.HotkeyMenu:IsValid () then
		return
	end
	QuickTool.HotkeyMenu:SetVisible (false)
end

function QuickTool.OpenHotkeyUI ()
	QuickTool.CreateHotkeyMenu ():SetVisible (true)
end

concommand.Add ("quicktool_hotkey", function ()
	QuickTool.OpenHotkeyUI ()
end)

concommand.Add ("quicktool_hotkey_toggle", function ()
	if QuickTool.HotkeyMenu and QuickTool.HotkeyMenu:IsValid () then
		if QuickTool.HotkeyMenu:IsVisible () then
			QuickTool.CloseHotkeyUI ()
		else
			QuickTool.OpenHotkeyUI ()
		end
	else
		QuickTool.OpenHotkeyUI ()
	end
end)

concommand.Add ("quicktool_hotkey_close", function ()
	QuickTool.CloseHotkeyUI ()
end)