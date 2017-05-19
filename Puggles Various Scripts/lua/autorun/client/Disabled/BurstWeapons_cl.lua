local tab = {}
local EntryTime
//local scale = 1
//local Pause
//local End
local FadeTime
local Wait

function Getumsg( um )
	if not LocalPlayer() then return end

	scale = 1
	FadeTime = GetConVarNumber( "bw_FadeTime" )
	Wait = GetConVarNumber( "bw_Wait" )
	--obtain the string of weapon entityindex's
	local entstring = um:ReadString()
	-- print("String", entstring)
	-- table.foreach(string.Explode( " ", entstring), print)
	EntryTime = um:ReadFloat()
	--Setting Entity() doesn't work on this frame, so set it on next frame
	timer.Simple(0, function()
		--get each index from the string
		for k, v in pairs( string.Explode( " ", entstring ) ) do
			--insert the entity that belongs to that index into a table
			table.insert( tab, Entity( v ) )
			--set the vars local to the entity for compatibility
			Entity( v ).scale = scale
			Entity( v ).EntryTime = EntryTime
		end
	end )
end

function centFadeThink()
	if ( not tab ) or ( not Wait ) or ( not FadeTime ) then return end
	--cycle through the table
	for k, v in pairs( tab ) do
		if v and IsValid(v) and v.EntryTime then
			-- print("Valid", v, v.EntryTime)
			v.Pause = v.EntryTime + Wait
			v.End = v.Pause + FadeTime
			--if the model is supposed to be gone, remove it from the client table
			if v.End <= CurTime() then
				tab[k] = nil
			end

			if v.Pause <= CurTime() then
				--scale the model in fadetime
				v.scale = Lerp( (CurTime() - v.Pause) / FadeTime, 1, 0 )
				v:SetModelScale( v.scale, 0 )
			end
		end
	end
end

hook.Add( "Think", "CentFade", function() centFadeThink() end )
usermessage.Hook( "StartShrink", Getumsg )