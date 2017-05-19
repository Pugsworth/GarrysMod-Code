if QuickTool.SearchUI then
	QuickTool.SearchUI:Remove ()
end
QuickTool.SearchUI = nil

function QuickTool.CreateSearchUI ()
	if QuickTool.SearchUI and QuickTool.SearchUI:IsValid () then
		return QuickTool.SearchUI
	end

	local self = vgui.Create ("QuickToolSearch")
	QuickTool.SearchUI = self
	return self
end

function QuickTool.CloseSearchUI ()
	if not QuickTool.SearchUI or not QuickTool.SearchUI:IsValid () then
		return
	end
	QuickTool.SearchUI:SetVisible (false)
end

function QuickTool.OpenSearchUI ()
	QuickTool.CreateSearchUI ():SetVisible (true)
end

concommand.Add ("quicktool_search", function ()
	QuickTool.OpenSearchUI ()
end)