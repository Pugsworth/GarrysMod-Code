-- local bhopenabled = false
-- local bhop = false

concommand.Add('bhop', function(ply, cmd, args)
	bhopenabled = not bhopenabled
	-- if not bhopenabled then
	-- 	LocalPlayer():ConCommand('-jump')
	-- end
end)

-- hook.Add('Think', 'Think.BunnyHop', function()
-- 	if bhopenabled and not bhop then
-- 		LocalPlayer():ConCommand('-jump')
-- 		return
-- 	end

-- 	if LocalPlayer():IsOnGround() and input.IsKeyDown(KEY_SPACE) then
-- 		bhop = true
-- 		LocalPlayer():ConCommand('+jump')
-- 	else
-- 		bhop = false
--     end
-- end)

hook.Add('CreateMove', 'BunnyHopFoolery', function(cmd)
	if bhopenabled and LocalPlayer():IsOnGround() then
		//cmd:SetButtons(cmd:GetButtons() | IN_JUMP)
	end
end)

