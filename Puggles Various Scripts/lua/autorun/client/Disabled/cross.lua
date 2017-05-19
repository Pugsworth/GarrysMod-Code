local CrosshairVar = CreateClientConVar("cl_DrawCrosshair", 1, FCVAR_ARCHIVE); -- Temporary name


function surface.DrawRotatedTexture( x, y, w, h, angle, cx, cy )
    cx, cy = cx or w / 2,cy or w / 2
    if( cx == w / 2 and cy == w / 2 ) then
        surface.DrawTexturedRectRotated( x, y, w, h, angle )
    else
        local vec = Vector( w / 2 - cx, cy - h / 2, 0 )
        vec:Rotate( Angle(180, angle, - 180) )
        surface.DrawTexturedRectRotated( x - vec.x, y + vec.y, w, h, angle )
    end
end

timer.Create( "PaintDelay", 0, 1, function() -- Run when the player actually starts rendering anything.
	-- gets the center of the screen
	local x = ScrW() / 2;
	local y = ScrH() / 2;
	local center = {};
	local size = {};
	local plr = LocalPlayer();
	local p;
	local LastWeapon = "";
	local matched = false;

	-- Set crosshair defaults.
	--{ x, y, width*, height*, rotation } * of clip
	local LargeCircle 		= {96, 96, 32, 32, 0};
	local PartCircle		= {96, 96, 32, 16, 0}
	local PartCircleR		= {96, 96, 16, 32, 0}
	local SmallCircle 		= {48, 48, 16, 16, 0};
	local PartSmallCircle	= {48, 48, 16, 8, 0};
	local Cross 			= {80, 14, 16, 16, 0};
	local SmallCross 		= {80, 14, 10, 4, 0};
	local SpySapper 		= {16, 68, 6, 6, 0};
	local PartMedic 		= {16, 80, 10, 10, 0};
	local HalfMedic 		= {16, 80, 16, 5, 0};
	local Medic 			= {16, 80, 16, 16, 0};
	local ScoutPistol 		= {16, 15, 16, 16, 0};
	local Dot 				= {16, 15, 5, 5, 0};

	-- Make the default table
	local Weapons = {
		-- shotgun
		["shotgun"] = LargeCircle, -- Large Cirlce
		-- gmod
		["phys"] = SmallCircle, -- Small Circle
		["_superphys"] = Cross, -- Cross
		["tool"] = Dot,
		-- smg, rilfes
		["smg"] = SmallCross, -- Spy Sapper
		["mp5"] = SmallCross,
		["mpk"] = SmallCross,
		["ar2"] = HalfMedic, -- Part Medic
		["irifle"] = HalfMedic,
		-- explosives
		["frag"] = SmallCircle,
		["nade"] = SmallCircle,
		["rpg"] = SmallCircle,
		-- melee
		["crowbar"] = PartSmallCircle, -- Scout Pistol
		-- pistols
		["pistol"] = ScoutPistol,
		["glock"] = ScoutPistol,
		["fiveseven"] = ScoutPistol,
		["357"] = Dot, -- Dot
		["deagle"] = Dot,
		-- heal
		["health"] = SpySapper,
		["heal"] = SpySapper,
		};

	local cvarcrosshair = 0
	cvars.AddChangeCallback("crosshair", function(name, old, new)
		cvarcrosshair = tonumber(new)
	end)


	local crosshair = surface.GetTextureID( "tf2crosshairs" );
	-- draw the crosshair
	hook.Add( "HUDPaint", "crosshair", function()
		if (cvarcrosshair != 1) or (not CrosshairVar:GetBool()) then return end

		-- if the player isn't valid, or his/her weapon, or if the player is dead
		//TODO: This needs a serious re-write
		if( IsValid( plr ) and IsValid( plr:GetViewModel() ) and plr:GetActiveWeapon() and plr:GetViewModel() and plr:Alive() and !LocalPlayer():ShouldDrawLocalPlayer()) then
			if weapons.Get(plr:GetActiveWeapon():GetClass()) then
			    DrawCrosshair = weapons.Get(plr:GetActiveWeapon():GetClass()).DrawCrosshair
			else
			    DrawCrosshair = true
			end
			if not DrawCrosshair then return end

			-- p = string.lower( plr:GetActiveWeapon():GetModel() );
			p = string.lower( plr:GetViewModel():GetModel() );

			-- if weapon..., then set texture to...
			if LastWeapon != p then
				//LocalPlayer():ChatPrint("Changed to [" .. tostring(p).. "], From [" .. tostring(LastWeapon) .. "]");
				matched = false;
				for weapon, data in pairs( Weapons ) do
					if string.find( p, weapon ) then center.x, center.y, size.x, size.y, rotation, matched = data[1], data[2], data[3], data[4], data[5], true;
					elseif not matched then center.x, center.y, size.x, size.y, rotation = 80, 14, 16, 16, 0; -- default cross
					end
				end
				LastWeapon = p;
			end
			surface.SetDrawColor( 255, 255, 255, 255 );
			surface.SetTexture( crosshair );

			-- Scissor the rest of the texture to only show the crosshair I want.
			render.SetScissorRect( x - size.x, y - size.y, x + size.x, y + size.y, true );
				-- surface.DrawTexturedRect( (ScrW() / 2) - center.x, (ScrH() / 2) - center.y, 128, 128, 128, 128 );
				surface.DrawRotatedTexture( (ScrW() / 2), (ScrH() / 2), 128, 128, rotation, center.x, center.y )
			render.SetScissorRect( 0, 0, 0, 0, false );
		end
	end )

	local info = {
		{"Player", 					function(a) return IsValid(a) end};
		{"Alive", 					function(a) return a:Alive() end};
		{"ShouldDrawLocalPlayer", 	function(a) return a:ShouldDrawLocalPlayer() end};
		{"Weapon", 					function(a) return a:GetActiveWeapon() end};
		{"View Model", 				function(a) return a:GetViewModel():GetModel() end};
	}

	/*
	hook.Add("HUDPaint", "test", function()
		surface.SetDrawColor(Color(50, 50, 50))

		local ow, oh = 332, 96
		local ox, oy = 64, (ScrH() - oh) - 128

		draw.RoundedBox(4, ox, oy, ow, oh, Color(25, 25, 25, 230))


		for i = 1, #info do
			draw.DrawText(info[i][1] .. ":     " .. tostring(info[i][2](LocalPlayer())), "HudSelectionText", ox + 8, oy + 8 + ((i - 1) * 16), color_white, 0)
		end
	end)
	*/

end )
--[[
local CrosshairSettings = {};
local DrawSettings = function()

	CrossSettings.Menu = vgui.Create( "DFrame" );
	CrossSettings.Menu:SetDeleteOnClose( false );
	CrossSettings.Menu:SetSize( 240, 320 );
	CrossSettings.Menu:Center();
	CrossSettings.Menu:MakePopup();
	CrossSettings.Menu:SetVisible( false );
	CrossSettings.Menu:SetScreenLock( true );

	CrossSettings.Tabs = vgui.Create( "DPropertySheet", CrossSettings.Menu );
	CrossSettings.Tabs:Dock( FILL );

	local CrossSettings.SheetOne = vgui.Create( "DPanel" );
	CrossSettings.SheetOne:Dock( FILL );
	//local Sheetone = CrossSettings.Tabs:AddSheet( "Settings",  )

	concommand.Add( "Crosshair_OpenSettings", function() CrosshairSettings.Menu:SetVisible( true ) end );
end

timer.Simple( 0, DrawSettings )
]]--