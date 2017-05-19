local Regen_Health_Enabled 	= 	CreateConVar( "regen_health_enabled", 1, FCVAR_ARCHIVE )
local Regen_Health_Max 		= 	CreateConVar( "regen_health_max", 100, FCVAR_ARCHIVE )
local Regen_Health_Delay 	= 	CreateConVar( "regen_health_delay", 1, FCVAR_ARCHIVE )
local Regen_Health_Amount 	= 	CreateConVar( "regen_health_amount", 1, FCVAR_ARCHIVE )
local Regen_Health_Pause 	= 	CreateConVar( "regen_health_pause", 5, FCVAR_ARCHIVE )

local Regen_Armor_Enabled 	= 	CreateConVar( "regen_armor_enabled", 1, FCVAR_ARCHIVE )
local Regen_Armor_Max 		= 	CreateConVar( "regen_armor_max", 200, FCVAR_ARCHIVE )
local Regen_Armor_Delay 	= 	CreateConVar( "regen_armor_delay", 0.1, FCVAR_ARCHIVE )
local Regen_Armor_Amount 	= 	CreateConVar( "regen_armor_amount", 1, FCVAR_ARCHIVE )
//local Regen_Armor_Pause 	= 	CreateConVar( "Regen_Armor_Pause", 5, FCVAR_ARCHIVE )

hook.Add( "Think", "RegenThink", function()
	for k, ply in pairs( player.GetAll() ) do

		if !ply:Alive() then return end

		if not ply.lastdamage then ply.lastdamage = CurTime() end
		if not ply.nextheal_health then ply.nextheal_health = CurTime() end
		if not ply.nextheal_armor then ply.nextheal_armor = CurTime() end


		if ply.lastdamage <= CurTime() then
			--gain health
			if( ply.nextheal_health <= CurTime() and ply:Health() < Regen_Health_Max:GetInt() ) then
				if Regen_Health_Enabled:GetInt() == 1 then
					if (ply:Armor() >= Regen_Armor_Max:GetInt()) or (Regen_Armor_Enabled:GetInt() == 0) then
						ply:SetHealth( ply:Health() + math.Clamp( Regen_Health_Amount:GetInt(), 1, 100 ) )
						ply.nextheal_health = CurTime() + Regen_Health_Delay:GetFloat()
					end
				end
			end
			--gain armor
			if( ply.nextheal_armor <= CurTime() and ply:Armor() < Regen_Armor_Max:GetInt() ) then
				if Regen_Armor_Enabled:GetInt() == 1 then
					ply:SetArmor( ply:Armor() + math.Clamp( Regen_Armor_Amount:GetInt(), 1, 100 ) )
					ply.nextheal_armor = CurTime() + Regen_Armor_Delay:GetFloat()
				end
			end
		end
	end
end )

--when the player takes damage, set the time
hook.Add( "EntityTakeDamage", "PlyTakeDamage", function( ent, dmginfo )
	if( ent:IsPlayer() and ent:Alive() ) then
		if dmginfo:GetDamage() > 0 then
			ent.lastdamage = CurTime() + Regen_Health_Pause:GetInt()
		end
	end
end )

----
--Todo
----
--[[
Accelerate amount
Gaining health while regenerating accelerates faster
Factor regen pause on delay and amount Armor
When there is armor, make health not decrease
]]--