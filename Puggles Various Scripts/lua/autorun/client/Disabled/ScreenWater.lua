local watervar = CreateConVar( "cl_screenwater", 1, FCVAR_ARCHIVE ) 

nextbubble = nil

local me
local pos


-- if GetMountableContent()['Team Fortress 2'].mounted then
-- 	tex = 'effects/water_warp_2fort'
-- else
	tex = 'models/shadertest/predator'
-- end

function WaterEffect()
	if not me then me = LocalPlayer() me.waterAmount = 0 end
	pos = me:GetPos() + Vector( 0, 0, 50 )
	
	if me.waterAmount > 0 then
		
		DrawMaterialOverlay( tex, me.waterAmount )
		
		function bubbletime()
		if me:WaterLevel() <= 2 then return end
		local em = ParticleEmitter( pos )
			for i = 1, math.Rand( 1, 8 ) do
			bubble = em:Add( "effects/bubble", pos )
				if bubble then
					bubble:SetColor( 255, 255, 255, 255 )
					bubble:SetVelocity( Vector( math.Rand( -10, 10 ), math.Rand( -10, 10 ), math.Rand( -15, 0 ) ) )
					bubble:SetDieTime( 3 )
					bubble:SetLifeTime( 0 )
					bubble:SetStartSize( math.Rand( 4, 8 ) )
					bubble:SetEndSize( 1 )
					bubble:SetGravity( Vector( 0, 0, 60 ) )
				end
				em:Finish()
			end
		end

		if ( math.Round( CurTime() ) == nextbubble ) or ( nextbubble == nil ) then
			bubbletime()
			nextbubble = math.Round( CurTime() ) + math.random( 1, 3 )
		end
		
		if bubble then
			local contents = util.PointContents( bubble:GetPos() )
			if not ( contents == ( CONTENTS_TRANSLUCENT or CONTENTS_WATER ) ) then 
				bubble:SetColor( 255, 255, 255, 0 )
			end
		end
	end
	
	if watervar:GetInt() == 1 and me:WaterLevel() >= 3 then
		me.waterAmount = 0.25
	elseif watervar:GetInt() == 0 or me:WaterLevel() < 3 then
		if me.waterAmount >= 0.20 then
			me.waterAmount = 0.20
		end
		
		me.waterAmount = math.Clamp( me.waterAmount - RealFrameTime() * 0.07, 0, 1 )
		if me.waterAmount < 0 then me.waterAmount = 0 end
	end
end

local function ClearWater()
	if me.waterAmount > 0 then me.waterAmount = 0 end
end



hook.Add( "PlayerSpawn", "ClearWaterAponDeath", ClearWater )
hook.Add( "HUDPaintBackground", "aWaterEffect", WaterEffect )


--[[
CreateConVar( "WaterSlowDown", true )

local function SlowPlayerInWater( ply )
local p_DefaultWalk = 
local p_DefaultRun = 
	for _, v in pairs( player.GetAll() ) do
		if ply:WaterLevel() > 0 then
			GAMEMODE:SetPlayerSpeed( ply,  )
		else
			GAMEMODE:SetPlayerSpeed( ply, p_DefaultWalk, p_DefaultRun )
		end
	end
end
--]]