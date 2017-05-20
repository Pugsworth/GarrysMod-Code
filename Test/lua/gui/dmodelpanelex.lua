function drawCross(origin, size, angles, color)

	render.DrawLine(origin - angles:Forward() * size, origin + angles:Forward() * size, color, false)
	render.DrawLine(origin - angles:Right() * size, origin + angles:Right() * size, color, false)
	render.DrawLine(origin - angles:Up() * size, origin + angles:Up() * size, color, false)

end

function calculateScreenAABB(vertices)
	local left, top, right, bottom = math.huge, math.huge, 0, 0

	for i = 1, #vertices do
		local sVert = vertices[i]:ToScreen()

		left   = math.min(left,   sVert.x)
		top    = math.min(top,    sVert.y)
		right  = math.max(right,  sVert.x)
		bottom = math.max(bottom, sVert.y)
	end

	return {x = left, y = top, width = right - left, height = bottom - top}

end


local PANEL = {}

AccessorFunc( PANEL, "m_fAnimSpeed",	"AnimSpeed" )
AccessorFunc( PANEL, "Entity",			"Entity" )
AccessorFunc( PANEL, "vCamPos",			"CamPos" )
AccessorFunc( PANEL, "fFOV",			"FOV" )
AccessorFunc( PANEL, "vLookatPos",		"LookAt" )
AccessorFunc( PANEL, "aLookAngle",		"LookAng" )
AccessorFunc( PANEL, "colAmbientLight",	"AmbientLight" )
AccessorFunc( PANEL, "colColor",		"Color" )
AccessorFunc( PANEL, "bAnimated",		"Animated" )

--[[---------------------------------------------------------
	Name: Init
-----------------------------------------------------------]]
function PANEL:Init()

	self.Entity = nil
	self.LastPaint = 0
	self.DirectionalLight = {}
	self.FarZ = 4096

	self:SetCamPos( Vector( 50, 50, 50 ) )
	self:SetLookAt( Vector( 0, 0, 40 ) )
	self:SetFOV( 70 )

	self:SetText( "" )
	self:SetAnimSpeed( 0.5 )
	self:SetAnimated( false )

	self:SetAmbientLight( Color( 50, 50, 50 ) )

	self:SetDirectionalLight( BOX_TOP, Color( 255, 255, 255 ) )
	self:SetDirectionalLight( BOX_FRONT, Color( 255, 255, 255 ) )

	self:SetColor( Color( 255, 255, 255, 255 ) )

end

--[[---------------------------------------------------------
	Name: SetDirectionalLight
-----------------------------------------------------------]]
function PANEL:SetDirectionalLight( iDirection, color )
	self.DirectionalLight[ iDirection ] = color
end

--[[---------------------------------------------------------
	Name: SetModel
-----------------------------------------------------------]]
function PANEL:SetModel( strModelName )

	-- Note - there's no real need to delete the old 
	-- entity, it will get garbage collected, but this is nicer.
	if ( IsValid( self.Entity ) ) then
		self.Entity:Remove()
		self.Entity = nil
	end

	-- Note: Not in menu dll
	if ( !ClientsideModel ) then return end

	self.Entity = ClientsideModel( strModelName, RENDER_GROUP_OPAQUE_ENTITY )
	if ( !IsValid( self.Entity ) ) then return end

	self.Entity:SetNoDraw( true )

	-- Try to find a nice sequence to play
	local iSeq = self.Entity:LookupSequence( "walk_all" )
	if ( iSeq <= 0 ) then iSeq = self.Entity:LookupSequence( "WalkUnarmed_all" ) end
	if ( iSeq <= 0 ) then iSeq = self.Entity:LookupSequence( "walk_all_moderate" ) end

	if ( iSeq > 0 ) then self.Entity:ResetSequence( iSeq ) end

end

--[[---------------------------------------------------------
	Name: GetModel
-----------------------------------------------------------]]
function PANEL:GetModel()

	if ( !IsValid( self.Entity ) ) then return end

	return self.Entity:GetModel()

end

--[[---------------------------------------------------------
	Name: DrawModel
-----------------------------------------------------------]]
function PANEL:DrawModel()
	local curparent = self
	local rightx = self:GetWide()
	local leftx = 0
	local topy = 0
	local bottomy = self:GetTall()
	local previous = curparent
	while( curparent:GetParent() != nil ) do
		curparent = curparent:GetParent()
		local x, y = previous:GetPos()
		topy = math.Max( y, topy + y )
		leftx = math.Max( x, leftx + x )
		bottomy = math.Min( y + previous:GetTall(), bottomy + y )
		rightx = math.Min( x + previous:GetWide(), rightx + x )
		previous = curparent
	end
	render.SetScissorRect( leftx, topy, rightx, bottomy, true )
	self.Entity:DrawModel()
	render.SetScissorRect( 0, 0, 0, 0, false )
end

--[[---------------------------------------------------------
	Name: OnMousePressed
-----------------------------------------------------------]]
function PANEL:Paint( w, h )

	if ( !IsValid( self.Entity ) ) then return end

	local x, y = self:LocalToScreen( 0, 0 )

	self:LayoutEntity( self.Entity )

	local ang = self.aLookAngle
	if ( !ang ) then
		ang = (self.vLookatPos-self.vCamPos):Angle()
	end

	cam.Start3D( self.vCamPos, ang, self.fFOV, x, y, w, h, 5, self.FarZ )

	render.SuppressEngineLighting( true )
	render.SetLightingOrigin( self.Entity:GetPos() )
	render.ResetModelLighting( self.colAmbientLight.r/255, self.colAmbientLight.g/255, self.colAmbientLight.b/255 )
	render.SetColorModulation( self.colColor.r/255, self.colColor.g/255, self.colColor.b/255 )
	render.SetBlend( self.colColor.a/255 )

	for i=0, 6 do
		local col = self.DirectionalLight[ i ]
		if ( col ) then
			render.SetModelLighting( i, col.r/255, col.g/255, col.b/255 )
		end
	end

	self:DrawModel()

	local ang = self.Entity:GetAngles()

	local mins, maxs = self.Entity:GetModelBounds()
	local vCenter = mins + ((maxs - mins) / 2)

	-- OBBCenter
	drawCross(self.Entity:LocalToWorld(vCenter), 10, ang, Color(255, 87, 91))
	drawCross(self.Entity:GetPos(), 5, ang, Color(200, 253, 87))

	drawCross(self.Entity:LocalToWorld(maxs), 5, ang, color_white)
	drawCross(self.Entity:LocalToWorld(mins), 5, ang, color_black)
	-- print(self.Entity:OBBMins())
	-- print(self.Entity:LocalToWorld(self.Entity:OBBMins()))
	-- drawCross(Color(83, 241, 235))

	-- clockwise from top, starting wtih maxs
	local corners = {
		-- top
		maxs,
		Vector(mins.x, maxs.y, maxs.z),
		Vector(mins.x, mins.y, maxs.z),
		Vector(maxs.x, mins.y, maxs.z),

		-- bottom
		Vector(maxs.x, maxs.y, mins.z),
		Vector(mins.x, maxs.y, mins.z),
		mins,
		Vector(maxs.x, mins.y, mins.z)
	}

	local rect = calculateScreenAABB(corners)

	for i = 1, #corners do
		local vert = corners[i]
		-- print(i, vert)
		drawCross(self.Entity:LocalToWorld(vert), 2, ang, Color(83, 241, 235))
	end
	
	render.SuppressEngineLighting( false )
	cam.End3D()

	surface.SetDrawColor(color_white)
	print(rect.x, rect.y, rect.width, rect.height)
	surface.DrawOutlinedRect(rect.x, rect.y, rect.width, rect.height)

	self.LastPaint = RealTime()

end

--[[---------------------------------------------------------
	Name: RunAnimation
-----------------------------------------------------------]]
function PANEL:RunAnimation()
	self.Entity:FrameAdvance( ( RealTime() - self.LastPaint ) * self.m_fAnimSpeed )
end

--[[---------------------------------------------------------
	Name: RunAnimation
-----------------------------------------------------------]]
function PANEL:StartScene( name )

	if ( IsValid( self.Scene ) ) then
		self.Scene:Remove()
	end

	self.Scene = ClientsideScene( name, self.Entity )

end

--[[---------------------------------------------------------
	Name: LayoutEntity
-----------------------------------------------------------]]
function PANEL:LayoutEntity( Entity )

	--
	-- This function is to be overriden
	--

	if ( self.bAnimated ) then
		self:RunAnimation()
	end

	Entity:SetAngles( Angle( 0, RealTime() * 10 % 360, 0 ) )

end

function PANEL:OnRemove()
	if ( IsValid( self.Entity ) ) then
		self.Entity:Remove()
	end
end

--[[---------------------------------------------------------
	Name: GenerateExample
-----------------------------------------------------------]]
function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )

	local ctrl = vgui.Create( ClassName )
	ctrl:SetSize( 300, 300 )
	ctrl:SetModel( "models/error.mdl" )

	PropertySheet:AddSheet( ClassName, ctrl, nil, true, true )

end

derma.DefineControl( "DModelPanelEx", "A panel containing a model", PANEL, "DButton" )
