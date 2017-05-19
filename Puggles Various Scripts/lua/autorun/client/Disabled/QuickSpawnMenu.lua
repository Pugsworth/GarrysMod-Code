local QSM_IconSize = CreateClientConVar( "QSM_IconSize", 64, true, false )
local QSM_IconPanel, QSM_Icon, QSM_Menu, QSM_Base, QSM_IconSlider, QSM_TextAdd, QS_Clear, QSM_Add, QSM_Refresh, QSM_Prop, TempProp

local function Read()
	TempProp = glon.decode( file.Read( "qsm/spawnlist.txt" ) )
	-- if not ( type( TempProp ) == "table" or TempProp ) then TempProp[1]=nil end
	-- print( type( TempProp ) )
	for k, v in pairs( TempProp ) do  
		 QSM_Prop[ tonumber( k ) ] = v  
	end
end

local function Write( t )
	if not file.IsDir( "qsm" ) then
		file.CreateDir( "qsm" )
	end 
	file.Write( "qsm/spawnlist.txt", glon.encode( t ) )
end


local function CreatePanelList()
	QSM_IconPanel = vgui.Create( "DPanelList", QSM_Base ) 
	QSM_IconPanel:EnableVerticalScrollbar() 
	QSM_IconPanel:EnableHorizontal( true ) 
	QSM_IconPanel:SetPadding( 2 )
	QSM_IconPanel:SetPos( 15, 60 )
	QSM_IconPanel:SetDrawBackground(false)
    QSM_IconPanel.Paint = function( self )
        surface.SetDrawColor( 100, 100, 100, 255 )
        surface.SetTexture()
        surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
    end
	//QSM_IconPanel:SetSize( 452, 132 ) //452, 132


 	if #QSM_Prop > 14 then
		QSM_IconPanel:SetSize( 465, 130 )
	else
		QSM_IconPanel:SetSize( 452, 132 )
	end

	function UpdateIcons()
		Read()
		QSM_IconPanel:Remove()
		CreatePanelList()
	end
     
    local function RebuildAll()
		local Items = QSM_IconPanel:GetItems()
		for k, v in pairs( Items ) do
			v:RebuildSpawnIcon()
		end
	end
	if not QSM_Prop then return end
	for k, v in ipairs( QSM_Prop ) do
		QSM_Icon = vgui.Create( "SpawnIcon" )
		QSM_Icon:SetModel( v )
		QSM_Icon:SetToolTip( k .." -- ".. v )
		-- QSM_Icon:SetIconSize( QSM_IconSlider:GetValue() )
		QSM_Icon:SetIconSize( QSM_IconSize:GetInt() )
		QSM_Icon.DoClick = function()    
			surface.PlaySound( "ui/buttonclickrelease.wav" )  
			RunConsoleCommand( "gm_spawn", v ) end 
		QSM_Icon.OpenMenu = function()
			QSM_Menu = DermaMenu()
			QSM_Menu:AddOption( "Copy to Clipboard", function() SetClipboardText( v ) end )
			local SubMenu = QSM_Menu:AddSubMenu( "Re-Render", function() QSM_Icon:RebuildSpawnIcon() end )
				SubMenu:AddOption( "This Icon", function() QSM_Icon:RebuildSpawnIcon() end )
				SubMenu:AddOption( "All Icons", function() RebuildAll() end )
			local QSM_SpawnMenu = QSM_Menu:AddSubMenu( "Spawn Multiple", function() 
				Derma_StringRequest( "Spawn request.", "How many do you want to spawn at once?", "10", function( text ) 
				if type( tonumber( text ) ) != "number" then GAMEMODE:AddNotify( "Please enter a correct numerical value.", NOTIFY_ERROR, 5 ) return end
				for i = 1, tonumber( text )  do
					RunConsoleCommand( "gm_spawn", v ) end  end )
			end )
				for x = 1, 10, 1 do  
					QSM_SpawnMenu:AddOption( tostring( x ), function()  
						for i = 1, x do  
							RunConsoleCommand( "gm_spawn", v )  
						end  
					end )  
				end  
			QSM_Menu:AddSpacer()
			QSM_Menu:AddOption( "Delete", function()
				-- local TempProp = table.Copy( QSM_Prop )
				//print( "Before removal." )
				//PrintTable( QSM_Prop )
				table.remove( QSM_Prop, tonumber( k ) )
				Write( QSM_Prop )
				//print( "After removal." )
				//PrintTable( QSM_Prop )
				chat.AddText( Color( 255, 20, 20 ), "Deleted Prop: " .. v )
				chat.PlaySound()
				
				UpdateIcons()
			end )
			QSM_Menu:Open()
		end
        QSM_IconPanel:AddItem( QSM_Icon )
	end 
end


local function CreateVGUI()
	Read()
    QSM_Base = vgui.Create( "DFrameTransparent" )
    QSM_Base:SetSize( 485, 240 )
    QSM_Base:SetPos( ScrW( ) / 2 - QSM_Base:GetWide( ) / 2, ScrH( ) / 2 - QSM_Base:GetTall( ) / 2 )
    QSM_Base:SetTitle( "Quick Spawn Menu" )
    QSM_Base:SetVisible( false )
    QSM_Base:SetSizable( true )
    QSM_Base:SetDeleteOnClose( false )
    QSM_Base:ShowCloseButton( true )
    QSM_Base:MakePopup()

	QSM_IconSlider = vgui.Create( "DNumSlider", QSM_Base )
    QSM_IconSlider:SetPos( 15, 200 )
    QSM_IconSlider:SetText( "Icon Size" )
    QSM_IconSlider:SetWide( 360 )
    QSM_IconSlider:SetMin( 10 )
    QSM_IconSlider:SetMax( 128 )
    QSM_IconSlider:SetDecimals( 0 )
    QSM_IconSlider:SetValue( 64 )
	QSM_IconSlider:SetConVar( "QSM_IconSize" )
	-- QSM_IconSlider.ValueChanged = function( panel, value )
		-- QSM_Icon:SetIconSize( value )
	-- end
	
	QSM_TextAdd = vgui.Create( "DTextEntry", QSM_Base )
    QSM_TextAdd:SetSize( 375, 20 )
    QSM_TextAdd:SetPos( 15, 30 )
    QSM_TextAdd:SetText( "" )
    QSM_TextAdd.OnEnter = function()
        local model = Model( QSM_TextAdd:GetValue() )
        if not util.IsValidProp( model ) then
            GAMEMODE:AddNotify( "Either the model isn't cached or the model path isn't correct", NOTIFY_ERROR, 5 )
            return 
        end
        local TempProp = table.Copy( QSM_Prop )
        table.insert( TempProp, #QSM_Prop + 1, QSM_TextAdd:GetValue() )
        Write( TempProp )
        QSM_TextAdd:SetText( "" )
        QSM_TextAdd:KillFocus()
        UpdateIcons()
    end
    
	QSM_Clear = vgui.Create( "DButton", QSM_Base )
	QSM_Clear:SetSize( 60, 23 )
	QSM_Clear:SetPos( 410, 205 )
	QSM_Clear:SetText( "Clear >" )
	QSM_Clear.DoClick = function()
		QSM_Menu = DermaMenu()
			QSM_Menu2 = QSM_Menu:AddSubMenu( "All props", function() RunConsoleCommand( "gmod_cleanup" ) end )
				QSM_Menu2:AddOption( "Admin", function() RunConsoleCommand( "gmod_admin_cleanup" ) end )
			QSM_Menu:AddOption( "Decals", function() RunConsoleCommand( "r_cleardecals" ) end )
			QSM_Menu:AddOption( "Spawnlist", function() 
				gui.EnableScreenClicker( true )
				Derma_Query( "This will clear the current spawn list, this is permanent.", "Are you sure?",
					"Yes", function() table.Empty( QSM_Prop ) Write( QSM_Prop ) end,
					"Cancel", function() end )
				gui.EnableScreenClicker( false )
			end )
			QSM_Menu:Open()
	end
	
    local QSM_Add = vgui.Create( "DButton", QSM_Base )
    QSM_Add:SetSize( 70, 20 )
    QSM_Add:SetPos( 400, 30 )
    QSM_Add:SetText( "Add Model" )
    QSM_Add.DoClick = function()
		local model = Model( QSM_TextAdd:GetValue() )
		if not util.IsValidModel( model ) then
			GAMEMODE:AddNotify( "Either the model isn't cached or the model path isn't correct", NOTIFY_ERROR, 5 )
			--GAMEMODE:AddNotify( "There was a problem with validating the model, either it is not a valid model or hasn't been cached yet.", NOTIFY_ERROR, 5 )
			--timer.Simple( 1.5, function() GAMEMODE:AddNotify( "Try spawning the model first to cache it.", NOTIFY_ERROR, 5 ) end )
			--GAMEMODE:AddNotify( "Please verify your model path again, or try spawning the model first.", NOTIFY_ERROR, 5 )
			--GAMEMODE:AddNotify( "Either the model isn't cached or the model path isn't correct", NOTIFY_ERROR, 5 )
			return 
		end
		local TempProp = table.Copy( QSM_Prop )
        table.insert( TempProp, #QSM_Prop + 1, QSM_TextAdd:GetValue() )
		Write( TempProp )
		QSM_TextAdd:SetText( "" )
        QSM_TextAdd:KillFocus()
		UpdateIcons()
    end
	local QSM_Refresh = vgui.Create( "DImageButton", QSM_Base )
    QSM_Refresh:SetSize( 10, 10 )
    QSM_Refresh:SetPos( 440, 4 )
    QSM_Refresh:SetImage( "gui/silkicons/arrow_refresh.vtf" )
    QSM_Refresh:SizeToContents()
    QSM_Refresh:SetToolTip( "Reload the spawn-list." )
    QSM_Refresh.DoClick = function() UpdateIcons() end
end

timer.Simple( 0, function()
	if vgui then
	if not QSM_Prop then QSM_Prop = {} end
	if not TempProp then TempProp = {} end
		CreateVGUI()
		if not file.Exists( "qsm/spawnlist.txt" ) then Write( QSM_Prop ) end
	end
end )

concommand.Add( "+Quick_spawn",  function()
	CreatePanelList()
    QSM_Base:SetVisible( true )
end )

concommand.Add( "-Quick_spawn",  function()
    if QSM_TextAdd:HasFocus() then return end
	    -- QSM_Base:SetVisible( false )
	    QSM_Base:Close()
	if not ( QSM_Menu and QSM_Menu:IsVisible() ) then
		return      
	end
	QSM_Menu:Hide()
end )