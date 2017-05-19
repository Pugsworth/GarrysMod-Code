function DrawFps()
	if not ( NXSize and NYSize and BColor ) then
		return 
	end  
	-- if not args[1] or not args[1]:type() == "number" then
		-- local mode = 1
	-- else
		-- local mode = args[1]
	-- end
	
	draw.RoundedBox( 6, ScrW() / NXSize:GetValue(), ScrH() / NYSize:GetValue(), Color( BColor:GetColor() ) or Color() )
	--surface.CreateFont( "coolvetica", 32, 400, true, true, "large" )
    local struc = {}
    struc.pos = {}
    struc.pos[1] = 82
    struc.pos[2] = 98
    struc.color = Color(0,0,0,255)
    struc.text = math.Round( 1 / FrameTime() )
    struc.font = "HUDNumber5"
    struc.xalign = TEXT_ALIGN_LEFT
    struc.yalign = TEXT_ALIGN_CENTER
    draw.Text( struc )
	
end

function HideFps()
	Base:Close()
end

timer.Create( "Think", 0.1, 0, function()
	if not ( CBox and BColor and CBox:IsVisible() and BColor:IsVisible() ) then
		return
	end
	CBox:SetColor( BColor:GetColor() )
end )


function FpsMenu()
	Base:SetVisible( true )
end

timer.Create( "CheckVGUI", 0.1, 0, function()	
	if vgui then
		Base = vgui.Create( "DFrame" )
		Base:SetVisible( false )
		-- Base:SetSizeable( false )
		Base:SetSize( 150, 175 )
		Base:Center()
		Base:MakePopup()
		Base:SetTitle( "FPS Menu" )
		
		local BTitle = vgui.Create( "DLabel", Base )
		BTitle:SetText( "Position" )
		BTitle:SizeToContents()
		BTitle:SetPos( 25, 32 )
		
		NXSize = vgui.Create( "DNumberWang", Base )
		NXSize:SetMax( 32 )
		NXSize:SetMin( 0 )
		NXSize:SetValue( 0 )
		NXSize:SetDecimals( 0 )
		NXSize:SizeToContents()
		NXSize:SetPos( BTitle.x + 60, BTitle.y - 2 )
		
		NYSize = vgui.Create( "DNumberWang", Base )
		NYSize:SetMax( 32 )
		NYSize:SetMin( 0 )
		NYSize:SetValue( 0 )
		NYSize:SetDecimals( 0 )
		NYSize:SizeToContents()
		NYSize:SetPos( BTitle.x + 92, BTitle.y - 2 )
		
		BColor = vgui.Create( "DColorMixer" , Base )
		BColor:SetPos( 15, 60 )
		BColor:SetSize( 100, 100 )
		BColor:SetColor( Color( 255, 0, 0, 255 ) )
		
		
		CBox = vgui.Create( "DColouredBox", Base )
		CBox:SetPos( BColor:GetWide() + 17, BColor.y )
		CBox:SetSize( 25, 25 )
		CBox:SetColor( Color( 255, 255, 255, 255 ) )
		timer.Destroy( "CheckVGUI" )
	end
	
end )

hook.Add( "HUDPaint", "HUD_Fps", DrawFps )

concommand.Add( "fps_menu", FpsMenu )
concommand.Add( "showfps", DrawFps )
concommand.Add( "hidefps", HideFps )