local convars = {}

convars.hud = CreateClientConVar( "fohud_enable", 1, true, false )
convars.crosshair = CreateClientConVar( "fohud_crosshair", 1, true, false )
convars.ping = CreateClientConVar( "fohud_ping", 1, true, false )
convars.fps = CreateClientConVar( "fohud_fps", 1, true, false )
convars.fps_smoothed = CreateClientConVar( "fohud_fps_smoothed", 1, true, false )


local colrs = {}

colrs.blue = Color( 0, 200, 255, 220 )
colrs.red = Color( 200, 40, 40, 220 )
colrs.green = Color( 90, 222, 0, 220 )
colrs.white = Color( 220, 220, 220, 220 )
colrs.yellow = Color( 222, 222, 0, 220 )

  ///////////////////
 //Local variables//
///////////////////
local padding = 12
local fFrames = 0
local fPing = 0
	
  ////////////////
 //Create Fonts//
////////////////

surface.CreateFont( "monofont", 10, 700, true, false, "monofont1" )
surface.CreateFont( "monofont", 20, 700, true, false, "monofont2" )
surface.CreateFont( "monofont", 30, 700, true, false, "monofont3" )
surface.CreateFont( "monofont", 40, 700, true, false, "monofont4" )

  /////////////////////
 //Drawing functions//
/////////////////////
local hud = {}

function hud:DrawText( x, y, color, font, text, bool )
	
	surface.SetFont( font )
	local width, height = surface.GetTextSize( text )
	
	surface.SetTextColor( color )
	if bool then
		surface.SetTextPos( x - width, y )
	else
		surface.SetTextPos( x, y )
	end
	surface.DrawText( text )
	
end

function hud:Drawpegs( w, x, y, color )

    local hp = math.Clamp( LocalPlayer():Health(), 0, 100 )
	local ap = math.Clamp( LocalPlayer():Armor(), 0, 100 )
	local eh = LocalPlayer():GetEyeTrace().Entity or nil
	
    local tick = surface.GetTextureID( "glow_compass_tick" )
	
	surface.SetDrawColor( Color( color.r, color.g, color.b, 200 ) )
	surface.SetTexture( tick )
	
	if w == 1 then
	
		if LocalPlayer():Alive() then
			for i = 1, math.Clamp( hp / 2.7, 1, 100 ) do
				if not ( hp >= 1 ) then return end
				surface.DrawTexturedRect( x + 11 + ( i * 8 ), y + 38, 8, 32 )
			end
		end
		
	elseif w == 2 then
	
		if LocalPlayer():Alive() then
			for i = 1, math.Clamp( ap / 2.7, 1, 100 ) do
				if not ( ap >= 1 ) then return end
				surface.DrawTexturedRect( ScrW() - x - 11 - ( i * 8 ), y + 38, 8, 32 )
			end
		end
		
	elseif w == 3 then
		
		if LocalPlayer():Alive() or eh != nil then
			for i = 1, math.Clamp( eh:Health() / 3.2, 1, 1000 ) do
				if not ( eh:Health() >= 1 ) then return end
				surface.DrawTexturedRect( x - 8 + ( i * 8 ), y, 8, 32 )
			end
		end
		
	end
	
end

function hud:DrawHealth( x, y, color )
	
	local health = surface.GetTextureID( "glow_health_bar" )

	surface.SetTexture( health )
	surface.SetDrawColor( color )
	surface.DrawTexturedRect( x, y, 512, 256 )

	hud:Drawpegs( 1, x, y, color )
	
	hud:DrawText( x + 25, y, color, "monofont3", "HP", false )
	
end

function hud:DrawArmor( x ,y, color )
	
	local armor = surface.GetTextureID( "glow_armor_bar" )

	surface.SetTexture( armor )
	surface.SetDrawColor( color )
	surface.DrawTexturedRect( ScrW() - 386, y, 512, 256 )

	hud:Drawpegs( 2, x, y, color )
	
	hud:DrawText( ScrW() - x - 20, y, color, "monofont3", "AR", true )
	
end

function hud:DrawBuff( x, y, color )

	local buff = surface.GetTextureID( "armor_tick" )
	
	surface.SetDrawColor( color )
	surface.SetTexture( buff )
	surface.DrawTexturedRect( ScrW() - 900, y + 20, 32, 32 )
	
end

function hud:DrawAmmo( x, y, color )
	if( not LocalPlayer():Alive() or not ValidEntity( LocalPlayer():GetActiveWeapon() ) ) then return end
	
	local wep = LocalPlayer():GetActiveWeapon()
	local clip = wep:Clip1() or -1
	local clipmax = wep:GetPrimaryAmmoType()
	local alt =	wep:GetSecondaryAmmoType()
	
	local text = clip .. "/" .. LocalPlayer():GetAmmoCount( clipmax )
	
	-- surface.SetFont( font )
	-- surface.SetTextColor( color )
	-- surface.SetTextPos( ScrW() + ( x - 50 - ( width ) ), y + 80 )
	-- surface.DrawText( text )

	hud:DrawText( ScrW() + ( x - 50 ), y + 80, color, "monofont3", text, true )

end

function hud:DrawCrosshair( color )
	
	local trdata = {}
	trdata.start = LocalPlayer():GetShootPos()
	trdata.endpos = LocalPlayer():GetAimVector() * 10^10
	trdata.filter = LocalPlayer()					
	
	local tr = util.TraceLine( trdata )
	
	local trp = tr.HitPos:ToScreen()
	
	local x = trp.x
	local y = trp.y
	
	local glow_crosshair = surface.GetTextureID( "fo3_glow_crosshair" )
	local glow_crosshair_filled = surface.GetTextureID( "fo3_glow_crosshair_filled" )
	
	if ( tr.Entity:IsNPC() ) or ( tr.Entity:IsPlayer() ) then

		surface.SetTexture( glow_crosshair_filled )
	else
		surface.SetTexture( glow_crosshair )
	end
	surface.SetDrawColor( color )
	surface.DrawTexturedRect( ( x ) - 32, ( y ) - 16, 64, 32 )
	
end

function hud:DrawFps( w, x, y, color )

	local smooth = w
	
	local fps = ( 1 / RealFrameTime() )
	-- local timescalecorrection = fps * GetConVar( "host_timescale" ):GetFloat()
	fFrames = math.Clamp( fFrames + ( ( fps - fFrames ) * 0.03 ), 1, 9999 )
	
	local right = surface.GetTextureID( "glow_right" )

	if fFrames then
		hud:DrawText( ScrW() - 20 - padding, 30 + padding, color, "monofont2", "Fps: " .. math.Round( fFrames ), true )
		surface.SetDrawColor( color )
		surface.SetTexture( right )
		surface.DrawTexturedRect( ScrW() - 256 - padding, padding, 256, 128 )
	end

end

function hud:DrawPing( w, x, y, color )

	local smooth = w
	
	local ping = LocalPlayer():Ping()
	fPing = math.Clamp( fPing + ( ( ping - fPing ) * 0.03 ), 1, 9999 )
	
	local left = surface.GetTextureID( "glow_left" )

	if fPing then
		hud:DrawText( 20 + padding, 30 + padding, color, "monofont2", "Ping: " .. math.Round( fPing ), false )
		surface.SetDrawColor( color )
		surface.SetTexture( left )
		surface.DrawTexturedRect( padding, padding, 256, 128 )
	end

end


function _R.Angle.NormalizeAngle()
	self.p = math.NormalizeAngle( self.p )
	self.y = math.NormalizeAngle( self.y )
	self.r = math.NormalizeAngle( self.r )
	return self
end
 
local OldDiff = math.AngleDifference
function math.AngleDifference( a, b )
	if( ( type( a ) and type( b ) ) == "number" ) then 
		local ret = 0
		ret = OldDiff( a, b )
		return ret
	else
		local ret = Angle()
		ret.p = OldDiff( a.p, b.p )
		ret.y = OldDiff( a.y, b.y )
		ret.r = OldDiff( a.r, b.r )
		return ret
	end
	
end



function hud:DrawCompass( z, y, color )

	-- if not CompassPanel then
		-- CompassPanel = vgui.Create( "DPanel" )
		-- CompassPanel:SetPos( 34, ScrH() - 156 + padding + 65 )
		-- CompassPanel:SetSize( 330, 64 )
	-- end
	
	local cbar = surface.GetTextureID( "glow_compass_tick" )
	
	-- CompassPanel.Paint = function( self )
		if not LocalPlayer():Alive() then return end
		render.SetScissorRect( 30, 0, 360,  ScrH(), true )
		draw.TexturedQuad( {
			x = -1028 + ( 1028 * ( ( ( LocalPlayer():EyeAngles().y + 62 ) % 360 ) / 360 ) ),
			y = ScrH() - 156 + padding + 65,
			w = 2058,
			h = 64,
			color = colrs.blue,
			texture = surface.GetTextureID( "glow_compass" )
		} )
		
		
		local FOV = GetConVar( "fov_desired" ):GetFloat()
		for _, v in pairs( ents.GetAll() ) do
			if( v:IsNPC() or v:IsPlayer() ) and ( v != LocalPlayer() ) then 
				local PosDiff = ( LocalPlayer():GetPos() - v:GetPos() ):Angle()
				local AngDiff = LocalPlayer():EyeAngles()
				local Diff = math.NormalizeAngle( math.AngleDifference( AngDiff, PosDiff ).y + 180 )
				-- local Scale = 20 - math.Clamp( LocalPlayer():GetPos():Distance( v:GetPos())/100, 4, 16 )
				local X = ( 175 + ( 128 * ( Diff / ( FOV - 30 ) ) ) )
				-- surface.DrawCircle( X, self:GetTall() / 2, Scale, colrs.green )
				surface.SetDrawColor( color )
				surface.SetTexture( cbar )
				surface.DrawTexturedRect( X, ( ScrH() - 156 + padding ) + 70, 8, 32 )
				
			end
		end
		render.SetScissorRect( 0, 0, 0, 0, false )
	-- end	
end

function hud:DrawEnemyBar( x, y, color )
	
	if not ( LocalPlayer():GetEyeTrace().Entity:IsNPC() or LocalPlayer():GetEyeTrace().Entity:IsPlayer() ) then return end
	
	local bar = surface.GetTextureID( "glow_enemy_health" )
	surface.SetDrawColor( color )
	surface.SetTexture( bar )
	surface.DrawTexturedRect( ScrW() / 2 - 190, ScrH() - 100, 512, 64 )
	
	hud:Drawpegs( 3, ScrW() / 2 - 132 , y + 41, color )

end

local function DrawTheHud()
	if( FrameTime() == 0 ) then return end
	if not ( convars.hud:GetInt() == 1 ) then return end
	if not LocalPlayer():Alive() then return end
	
	local x = padding
	local y = ScrH() - 156 + padding
	local clr = colrs.blue
	hud:DrawHealth( x, y, clr )
	if LocalPlayer():Health() > 100 then
		hud:DrawBuff( x, y, clr )
	end
	
	hud:DrawCompass( x, y, clr )
	hud:DrawArmor( x, y, clr )
	hud:DrawAmmo( x, y, clr )
	hud:DrawEnemyBar( x, y, colrs.red )
	
	if not ( convars.crosshair:GetInt() == 1 ) then return end
	
	hud:DrawCrosshair( clr )
	
	if not ( convars.fps:GetInt() == 1 ) then return end
	
	hud:DrawFps( 1, x, y, clr )
	
	if not ( convars.ping:GetInt() == 1 ) then return end
	
	hud:DrawPing( 1, x, y, clr )

end

-- timer.Create( "compass", 1, 0, function()
	-- if not ( LocalPlayer():Alive() ) then return end
		-- hud:DrawCompass()
	-- timer.Destroy( "compass" )
-- end )

local function hidehud( name )
	if not ( convars.hud:GetInt() == 1 ) then return end
	
	for k, v in pairs{ "CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo" } do
		if name == v then return false end
	end

end

if convars.hud:GetInt() == 1 then
	hook.Add( "HUDPaint", "FOHud", DrawTheHud )
	hook.Add( "HUDShouldDraw", "hidehud", hidehud )
end

cvars.AddChangeCallback("fohud_enable", function(cvar, old, new)
	if new == 0 then
		hook.Remove("HUDPaint", "FOHud")
		hook.Remove("HUDShouldDraw", "hidehud")
	elseif new == 1 then
		hook.Add( "HUDPaint", "FOHud", DrawTheHud )
		hook.Add( "HUDShouldDraw", "hidehud", hidehud )
	end
end)