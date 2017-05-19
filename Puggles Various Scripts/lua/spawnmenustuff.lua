include("spawnmenustuff_positionspawnicon.lua");

PANEL = {}

AccessorFunc( PANEL, "m_strModel", 		"Model" )
AccessorFunc( PANEL, "m_pOrigin", 		"Origin" )
AccessorFunc( PANEL, "m_bCustomIcon", 	"CustomIcon" )

function PANEL:Init()

	self:SetSize( 650, 502 );
	self:SetTitle( "Icon Editor" )
	--==--
	self.iconlist = {}
	--==--
	
	local pnl = self:Add( "Panel" )
		pnl:SetSize( 400, 400 )
		pnl:Dock( FILL )
		pnl:DockMargin( 0, 0, 4, 0 )
	
			self.AnimList = pnl:Add( "DListView" )
				self.AnimList:AddColumn( "name" )
				self.AnimList:Dock( FILL )
				self.AnimList:SetSize( 200, 300 )
				self.AnimList:SetMultiSelect( true )
				self.AnimList:SetHideHeaders( true )
				
		local pnl = pnl:Add( "Panel" )
			pnl:Dock( BOTTOM )
			pnl:SetTall( 140 )
			
			self.SkinList = pnl:Add( "DListView" )
				self.SkinList:AddColumn( "name" )
				self.SkinList:Dock( LEFT )
				self.SkinList:SetSize( 100, 100 )
				self.SkinList:SetMultiSelect( true )
				self.SkinList:SetHideHeaders( true )
				
			self.BodyList = pnl:Add( "DListLayout" )
				self.BodyList:Dock( FILL )		
/*

	This kind of works but they don't move their stupid mouths. So fuck off.

			self.Scenes = pnl:Add( "DTree" )
				self.Scenes:Dock( BOTTOM )
				self.Scenes:SetSize( 200, 200 )
				self.Scenes.DoClick = function( _, node )
				
					if ( !node.FileName ) then return end
					local ext = string.GetExtensionFromFilename( node.FileName );
					if( ext != "vcd" ) then return end
					
					self.ModelPanel:StartScene( node.FileName );
					MsgN( node.FileName )
				
				end
				
				local materials = self.Scenes.RootNode:AddFolder( "Scenes", "scenes/",	true );
					materials:SetIcon( "icon16/photos.png" )
					
*/

	local ModelLoader = self:Add( "DDrawer" )
		ModelLoader:SetDrawBackground( true )
		ModelLoader:SetOpenSize( 300 )
				
		self.Models = ModelLoader:Add( "DFileBrowser" )
			self.Models:Dock( FILL )
			self.Models:SetName( "Models" )
			self.Models:SetPath( "models/" )
			self.Models:SetModels( true )
			self.Models:SetFiles( "*.mdl" )
			self.Models:DockMargin( 4, 4, 4, 4 )
			self.Models.OnSelect = function( _, path )
			
				ModelLoader:Close()
				self:SetModel( path )
				self:Refresh()
			
			end
			
			
	local pnl = self:Add( "Panel" )
	pnl:SetSize( 400, 400 )
	pnl:Dock( RIGHT )
	
		local bg = pnl:Add( "DImage" )
		bg:SetImage( "vgui/gradient-r" )
		bg:Dock( TOP )
		bg:SetSize( 400, 400 )
		bg:SetAlpha( 0.5 )
		bg:SetMouseInputEnabled( true )
		bg:DockMargin( 0, 0, 0, 4 )
	
			self.ModelPanel = bg:Add( "DAdjustableModelPanel" )
			self.ModelPanel:Dock( FILL )
	
		local pnl2 = pnl:Add( "Panel" )
		pnl2:SetSize( 400, 64 )
		pnl2:Dock( FILL )
		
			self.SpawnIcon = pnl:Add( "SpawnIcon" )
			self.SpawnIcon.DoClick = function() self:RenderIcon() end
			
			local BestGuess = pnl2:Add( "DImageButton" )
				BestGuess:SetImage( "icon32/wand.png" )
				BestGuess:SetStretchToFit( false )
				BestGuess:SetDrawBackground( true )
				BestGuess.DoClick = function() self:BestGuessLayout() end
				BestGuess:Dock( LEFT )
				BestGuess:DockMargin( 0, 0, 0, 0 )
				BestGuess:SetWide( 50 )	
				
			local FullFrontal = pnl2:Add( "DImageButton" )
				FullFrontal:SetImage( "icon32/hand_point_090.png" )
				FullFrontal:SetStretchToFit( false )
				FullFrontal:SetDrawBackground( true )
				FullFrontal.DoClick = function() self:FullFrontalLayout() end
				FullFrontal:Dock( LEFT )
				FullFrontal:DockMargin( 2, 0, 0, 0 )
				FullFrontal:SetWide( 50 )
				
			local Above = pnl2:Add( "DImageButton" )
				Above:SetImage( "icon32/hand_property.png" )
				Above:SetStretchToFit( false )
				Above:SetDrawBackground( true )
				Above.DoClick = function() self:AboveLayout() end
				Above:Dock( LEFT )
				Above:DockMargin( 2, 0, 0, 0 )
				Above:SetWide( 50 )
				
				local Right = pnl2:Add( "DImageButton" )
				Right:SetImage( "icon32/hand_point_180.png" )
				Right:SetStretchToFit( false )
				Right:SetDrawBackground( true )
				Right.DoClick = function() self:RightLayout() end
				Right:Dock( LEFT )
				Right:DockMargin( 2, 0, 0, 0 )
				Right:SetWide( 50 )
				
				local OpenModel = pnl2:Add( "DImageButton" )
					OpenModel:SetImage( "icon32/folder.png" )
					OpenModel:SetStretchToFit( false )
					OpenModel:SetDrawBackground( true )
					OpenModel.DoClick = function() ModelLoader:Open() end
					OpenModel:Dock( RIGHT )
					OpenModel:DockMargin( 2, 0, 4, 0 )
					OpenModel:SetWide( 50 )			
				
				local Picker = pnl2:Add( "DImageButton" )
					Picker:SetImage( "icon32/color_picker.png" )
					Picker:SetStretchToFit( false )
					Picker:SetDrawBackground( true )
					Picker.DoClick = function() 
					
						self:SetVisible( false )
						
						util.worldpicker.Start( function( tr )
					
							self:SetVisible( true )
							
							if ( !IsValid( tr.Entity ) ) then return end
						
							self:SetFromEntity( tr.Entity )
					
							end )
					 end
					Picker:Dock( RIGHT )
					Picker:DockMargin( 2, 0, 0, 0 )
					Picker:SetWide( 50 )		
									
							
		local pnl3 = pnl2:Add( "Panel" )
		pnl3:SetSize( 400, 20 )
		pnl3:Dock( TOP )
		pnl3:DockMargin( 0, 0, 0, 4 )
		pnl3:MoveToBack()
		
			self.AnimTrack = pnl3:Add( "DSlider" )
				self.AnimTrack:Dock( FILL )
				self.AnimTrack:SetNotches( 100 )
				self.AnimTrack:SetTrapInside( true )
				self.AnimTrack:SetLockY( 0.5 )
			
			self.AnimPause = pnl3:Add( "DImageButton" )
				self.AnimPause:SetImage( "icon16/control_pause_blue.png" )
				self.AnimPause:SetStretchToFit( false )
				self.AnimPause:SetDrawBackground( true )
				self.AnimPause:SetIsToggle( true )
				self.AnimPause:SetToggle( false )
				self.AnimPause:Dock( LEFT )
				self.AnimPause:SetWide( 32 )
				
				
	ModelLoader:MoveToFront()
	
end

function PANEL:SetDefaultLighting()

	self.ModelPanel:SetAmbientLight( Color( 255*0.3, 255*0.3, 255*0.3 ) )
	
	self.ModelPanel:SetDirectionalLight( 0, Color( 255*0.2, 255*0.2, 255*0.2 ) )
	self.ModelPanel:SetDirectionalLight( 1, Color( 255*1.3, 255*1.3, 255*1.3 ) )
	self.ModelPanel:SetDirectionalLight( 2, Color( 255*0.2, 255*0.2, 255*0.2 ) )
	self.ModelPanel:SetDirectionalLight( 3, Color( 255*0.2, 255*0.2, 255*0.2 ) )
	self.ModelPanel:SetDirectionalLight( 4, Color( 255*2.3, 255*2.3, 255*2.3 ) )
	self.ModelPanel:SetDirectionalLight( 5, Color( 255*0.1, 255*0.1, 255*0.1 ) )

end

function PANEL:BestGuessLayout()

	local ent = self.ModelPanel:GetEntity()
	local pos = ent:GetPos()
	
	local tab = PositionSpawnIcon( ent, pos )
	
	if ( tab ) then
		self.ModelPanel:SetCamPos( tab.origin )
		self.ModelPanel:SetFOV( tab.fov )
		self.ModelPanel:SetLookAng( tab.angles )
	end

end

function PANEL:FullFrontalLayout()

	local ent = self.ModelPanel:GetEntity()
	local pos = ent:GetPos()
	local campos = pos + Vector( -200, 0, 0 )
	
	self.ModelPanel:SetCamPos( campos )
	self.ModelPanel:SetFOV( 45 )
	self.ModelPanel:SetLookAng( (campos * -1):Angle() )
	
end

function PANEL:AboveLayout()

	local ent = self.ModelPanel:GetEntity()
	local pos = ent:GetPos()
	local campos = pos + Vector( 0, 0, 200 )
	
	self.ModelPanel:SetCamPos( campos )
	self.ModelPanel:SetFOV( 45 )
	self.ModelPanel:SetLookAng( (campos * -1):Angle() )
	
end

function PANEL:RightLayout()

	local ent = self.ModelPanel:GetEntity()
	local pos = ent:GetPos()
	local campos = pos + Vector( 0, 200, 0 )
	
	self.ModelPanel:SetCamPos( campos )
	self.ModelPanel:SetFOV( 45 )
	self.ModelPanel:SetLookAng( (campos * -1):Angle() )
	
end

function PANEL:Refresh()

	self.ModelPanel:SetModel( self:GetModel() )
	self.ModelPanel.LayoutEntity = function() self:UpdateEntity( self.ModelPanel:GetEntity() )  end
	
	local ent = self.ModelPanel:GetEntity()
	local pos = ent:GetPos()
	
	local tab = PositionSpawnIcon( ent, pos )
	
	self:BestGuessLayout();		
	self:FillAnimations( ent )
	self:SetDefaultLighting()

end

function PANEL:UpdateEntity( ent )

	ent:SetEyeTarget( self.ModelPanel:GetCamPos() )
	
	if ( self.AnimTrack:GetDragging() ) then
	
		ent:SetCycle( self.AnimTrack:GetSlideX() )
		self.AnimPause:SetToggle( true )
		
	else
		
		self.AnimTrack:SetSlideX( ent:GetCycle() )
		
	end
	
	if ( !self.AnimPause:GetToggle() ) then
		ent:FrameAdvance( FrameTime() )		
	end
	--==--
	local str = tostring(self.ModelPanel:GetFOV()) .. " - " .. tostring(self.ModelPanel:GetCamPos()) .. " - " .. tostring(self.ModelPanel:GetLookAng()) .. "[" .. tostring(self.ModelPanel.Entity:GetPos()) .. "]";
	self:SetTitle(str);
	--==-- 1.9, 2.2, -1.2 - 4.5, 175.5, 0
end

function PANEL:FillAnimations( ent )

	self.AnimList:Clear()

	for k, v in SortedPairsByValue( ent:GetSequenceList() ) do
	
		local line = self.AnimList:AddLine( string.lower( v ) )
		
		line.OnSelect = function()
		
			ent:ResetSequence( v )
			ent:SetCycle( 0 )
		
		end
	
	end
	
	
	self.SkinList:Clear()
	
	for k=0, ent:SkinCount()-1 do
	
		local line = self.SkinList:AddLine( "Skin " .. k )
		
		line.OnSelect = function()
		
			ent:SetSkin( k )
			
			if ( self:GetOrigin() ) then
				self:GetOrigin():SkinChanged( k )
			end
			
			-- If we're not using a custom, change our spawnicon
			-- so we save the new skin in the right place...
			if ( !self:GetCustomIcon() ) then
				self.SpawnIcon:SetModel( self.SpawnIcon:GetModelName(), k, self.SpawnIcon:GetBodyGroup() )
			end
			
		end	
	
	end
	
	self.BodyList:Clear()
	
	for k=0, ent:GetNumBodyGroups()-1 do
	
		if ( ent:GetBodygroupCount( k ) <= 1 ) then continue end
		
		local combo = self.BodyList:Add( "DComboBox" )
							
			for l=0, ent:GetBodygroupCount( k )-1 do
				combo:AddChoice( ent:GetBodygroupName( k ) .. " " .. l, function()	
				
						-- Body Group Changed..
						ent:SetBodygroup( k, l ) 
						
						if ( self:GetOrigin() ) then
							self:GetOrigin():BodyGroupChanged( k, l )
						end
						
						-- If we're not using a custom, change our spawnicon
						-- so we save the new skin in the right place...
						if ( !self:GetCustomIcon() ) then
							self.SpawnIcon:SetBodyGroup( k, l )
							self.SpawnIcon:SetModel( self.SpawnIcon:GetModelName(), self.SpawnIcon:GetSkinID(), self.SpawnIcon:GetBodyGroup() )
						end
					
					end )
			end
			
			combo:ChooseOptionID( ent:GetBodygroup( k )+1 )

			combo.OnSelect = function( pnl, index, value, data )
				data()	
			end	
	
	end
	
	
	

end


function PANEL:RenderIcon()
	
	local ent = self.ModelPanel:GetEntity()
	--==--
	// local cent = ClientsideModel("models/error.mdl", RENDERGROUP_BOTH);
	--==--
	local tab = {}
	tab.ent		= ent
	
	tab.cam_pos = self.ModelPanel:GetCamPos()
	tab.cam_ang = self.ModelPanel:GetLookAng()
	tab.cam_fov = self.ModelPanel:GetFOV()
	
	self.SpawnIcon:RebuildSpawnIconEx( tab )
	--==--
	for k, v in pairs(self.iconlist) do
		if IsValid(cent) then
			cent:Remove()
		end
		local cent = ClientsideModel(v:GetModelName(), RENDER_GROUP_OPAQUE_ENTITY);
			cent:SetNoDraw(true);

			cent:SetEyeTarget(self.ModelPanel:GetCamPos());
			local iSeq = cent:LookupSequence(ent:GetSequenceName(ent:GetSequence()));
			if iSeq > 0 then
				cent:ResetSequence(iSeq);
				cent:SetCycle(self.AnimTrack:GetSlideX());
			else
				cent:ResetSequence(0);
				cent:SetCycle(self.AnimTrack:GetSlideX());
			end


		tab.ent = cent
		v.Icon:RebuildSpawnIconEx(tab);
	end
	--==--

end

function PANEL:SetIcon( icon )

	local model = icon:GetModelName()
	self:SetOrigin( icon )
	
	self.SpawnIcon:SetSize( icon:GetSize() )
	self.SpawnIcon:InvalidateLayout( true )
	
	if ( !model || model == "" ) then
	
		self:SetModel( "error.mdl" )
		self.SpawnIcon:SetSpawnIcon( icon:GetIconName() )
		self:SetCustomIcon( true )
		
	else
	
		self:SetModel( model )
		self.SpawnIcon:SetModel( model, icon:GetSkinID() )
		self:SetCustomIcon( false )
	
	end

end

--==--
function PANEL:SetIconList(list)
	if type(list) == "table" then
		self.iconlist = list;
		self:SetIcon(list[1]);
	end
end
--==--

function PANEL:SetFromEntity( ent )

	if ( !IsValid( ent ) ) then return end
	
	self:SetModel( ent:GetModel() )
	self:Refresh()

end

vgui.Register( "IconEditor", PANEL, "DFrame" )

hook.Add( "SpawnlistOpenGenericMenu", "SpawnlistOpenGenericMenu", function( canvas )

	local selected = canvas:GetSelectedChildren()

	local function doLoop(func)
		for k, v in pairs(selected) do
			func(v);
		end
	end

	local menu = DermaMenu()

	menu:AddOption("Copy to Clipboard", function()
		local str = ""
		doLoop(function(v)
			str = str .. v:GetModelName() .. (k == table.Count(selected) and "" or "\n");
		end)
		SetClipboardText(str)
	end)

	local submenu = menu:AddSubMenu( "Re-Render Icons", function()
		doLoop(function(v)
			v:RebuildSpawnIcon();
		end)
	end);
		submenu:AddOption( "All Icons", function() canvas:RebuildAll() end )

	menu:AddOption("Edit Icons", function() 
		editor = vgui.Create("IconEditor")
			editor:SetIconList(selected)
			editor:Refresh()
			editor:MakePopup()
			editor:Center()
	end);

	local ChangeIconSize = function(w, h)
		doLoop(function(v)
			v:SetSize(w, h) 
			v:InvalidateLayout(true)
			canvas:OnModified()
			canvas:Layout()
			v:SetModel(v:GetModelName(), v:GetSkinID() or 0, v:GetBodyGroup())
		end)
	end

	local submenu = menu:AddSubMenu("Resize");
		local sub64 = submenu:AddSubMenu("64 (default)", function() ChangeIconSize(64, 64 ) end);
			sub64:AddOption("64 x 128", function() 		ChangeIconSize(64, 128 ) end);
			sub64:AddOption("64 x 256", function() 		ChangeIconSize(64, 256 ) end);
			sub64:AddOption("64 x 512", function() 		ChangeIconSize(64, 512 ) end);
		local sub128 = submenu:AddSubMenu("128",function() ChangeIconSize(128, 128) end);
			sub128:AddOption("128 x 64", function() 	ChangeIconSize(128, 64 ) end);
			sub128:AddOption("128 x 256", function() 	ChangeIconSize(128, 256) end);
			sub128:AddOption("128 x 512", function() 	ChangeIconSize(128, 512) end);
		local sub256 = submenu:AddSubMenu("256",function() ChangeIconSize(256, 256) end);
			sub256:AddOption("256 x 64", function() 	ChangeIconSize(256, 64 ) end);
			sub256:AddOption("256 x 128", function() 	ChangeIconSize(256, 128) end);
			sub256:AddOption("256 x 512", function() 	ChangeIconSize(256, 512) end);
		local sub512 = submenu:AddSubMenu("512",function() ChangeIconSize(512, 512) end);
			sub512:AddOption("512 x 64", function() 	ChangeIconSize(512, 64 ) end);
			sub512:AddOption("512 x 128", function() 	ChangeIconSize(512, 128) end);
			sub512:AddOption("512 x 256", function() 	ChangeIconSize(512, 256) end);
		
	menu:AddSpacer()

	menu:AddOption( "Delete", function() 
		doLoop(function(v)
			v:Remove()
		end)
		hook.Run( "SpawnlistContentChanged" ) 
	end)

	menu:Open()
end)
