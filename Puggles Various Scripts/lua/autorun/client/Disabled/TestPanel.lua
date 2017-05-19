local PANEL = {}

function PANEL:Init()
    self:SetTitle( "Out favourite colour is?" )
    
    local Base = vgui.Create( "DPanel", self )
    Base:SetWide( 256 )
    
    self.Base = Base
    
    -- local Circle - vgui.Create( "DColorCircle", self )
    
    -- self.Circle = Circle
    
    local List = vgui.Create( "DMultiChoice", Base )
    List:AddChoice( "Red" )
    List:AddChoice( "Blue" )
    List:AddChoice( "Yellow" )
    List:AddChoice( "Green" )
    
    self.List = List
    
    local Box = vgui.Create( "DTextEntry", Base )
    Box:SetEditable( false )
    
    self.Box = Box
    
    self:Invalidate()
    self:SetupEvents()
    
    self:SetEntryValue( "Colour is nil." )
    
    self:MakePopup()
    self:Center()
    
    
end

function PANEL:Invalidate()

	local padding = 5
	
    self.Base:SetPos( padding, 43 + padding )
	self.Base:SetTall( padding + self.Box:GetTall() + padding )
	
	self.Box:SetPos( padding, padding )
	self.Box:SetWide( self.Base:GetWide() - padding - padding )
	
	self.List:SetPos( padding, 43 + padding )
	self.List:SetWide( self.Base:GetWide() - padding - padding )
	
	local X, Y = self.Base:GetPos()
	
	self:SetWide( self.Base:GetWide() + 5 + 5 )
	self:SetTall( Y + self.Base:GetTall() + 5 )
	
end

function PANEL:SetupEvents()

	local form = self
	
	local Box = self.Box
	
	function self.List:OnSelect( index, value, data )
	
		Box:SetText( "Colour is " .. value )
		
	end
	
end

function PANEL:PerformLayout()

	self.BaseClass.PerformLayout( self )
	
	self.Invalidate()
	
end
    
function PANEL:GetEntryValue()
 
	return self.Box:GetValue()
 
end
 
function PANEL:SetEntryValue( Text )
 
	self.Box:SetValue( Text )
 
end
    
vgui.Register( "TestPanel", PANEL, "DFrame" )

local function OpenMenu()
 
	vgui.Create( "TestPanel" )
 
end
concommand.Add( "OpenTestPanel", OpenMenu )