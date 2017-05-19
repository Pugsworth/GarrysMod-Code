local PANEL = {}
 
local mat = Material( "pp/blurscreen" )
 
function PANEL:Init()
I = 0
end

function PANEL:Paint()  
    local x, y = self:ScreenToLocal( 0, 0 )
	
    -- matBlurScreen:SetMaterialFloat( "$blur", 5 )
	
	if( I < 5 ) then I = I + 0.05 end
	for i = 0.25, 0.75, 0.25 do
		mat:SetMaterialFloat( "$blur", ( 1 ) )
		
		surface.SetMaterial( mat )
		surface.SetDrawColor( 255, 255, 255, 255 )
		
		render.UpdateScreenEffectTexture()
     
		surface.DrawTexturedRect( x, y, ScrW(), ScrH() )
	end
	
	-- render.UpdateScreenEffectTexture()
	
	surface.SetDrawColor( 100, 100, 100, 50 )
    surface.DrawRect( x, y, ScrW(), ScrH() )
	
	local w, h = self:GetSize()
	surface.SetDrawColor( 10, 10, 10, 220 )
	surface.DrawRect( 0, 0, w, 22 )
	
	-- surface.SetDrawColor( 100, 100, 100, 150 )
	-- surface.DrawRect( 0, 0, w, 5 )
	
    // Border
    surface.SetDrawColor( 50, 50, 50, 255 )
    surface.DrawOutlinedRect( 0, 0, self:GetWide(), self:GetTall() )
     
    return true
	
end
 
vgui.Register( "DFrameTransparent", PANEL, "DFrame" )