local FadeTime = CreateConVar( "bw_FadeTime", 10, FCVAR_REPLICATED )
local Wait = CreateConVar( "bw_Wait", 25, FCVAR_REPLICATED )
local NextDropTime = CreateConVar( "sv_WeaponDrop_Delay", 0.5, FCVAR_REPLICATED )
local AllowDrop = CreateConVar( "sv_WeaponDrop_Enabled", 1, FCVAR_REPLICATED )

// Burst_Weapons_Tab = {}
local random = math.random
local Weapons = {}
local tab = {} // Burst_Weapons_Tab
local Entities = ""
local Times = ""
local NextDrop = CurTime()

hook.Add( "DoPlayerDeath", "BurstWeapons", function( plr, attack, dmginfo )
	--create a table of all the weapons the player has before they actually die.
	if #plr:GetWeapons() <= 0 then return end

	Weapons[ plr:GetName() ] = plr:GetWeapons()

	for k, v in pairs( Weapons[ plr:GetName() ] ) do

		local ent = ents.Create( v:GetClass() )
		-- I made it so the weapons all form in a circle around the player.
		-- What I didn't actually do was make the weapons drop randomly... that's an awesome side effect.
		-- This function does look like arse, though.
		ent:SetPos(plr:GetShootPos() +
			Vector(
				math.sin( math.rad(k * (360 / #Weapons[ plr:GetName() ])) ) * 64,
				math.cos( math.rad(k * (360 / #Weapons[ plr:GetName() ])) ) * 64,
				0
		   ))
		ent:DrawShadow( false )
		ent:Spawn()
		if IsValid( ent:GetPhysicsObject() ) then
			ent:GetPhysicsObject():EnableMotion( false )

			table.insert( tab, {Entity = ent, EntryTime = CurTime(), Player = plr} )
			-- combine all the weapons' entindex together so that we don't waste networking on larger datatypes.
			Entities = Entities .. ent:EntIndex() .. " "
		else
			ent:Remove()
		end
	end
	-- clientside shrinking
	umsg.Start( "StartShrink" )
		umsg.String( string.Trim( Entities ) )
		umsg.Float( CurTime() )
	umsg.End()

	Entities = ""
end )

function entFadeThink( tab )
	for k, v in pairs( tab ) do
		if IsValid(v.Entity) then
			--set how long to wait and when to remove
			local Pause = v.EntryTime + Wait:GetInt()
			local End = Pause + FadeTime:GetInt()
			if End <= CurTime() then

				if v.Entity.PickedUp == true then
					tab[k] = nil
					v.Entity.PickedUp = nil;
				else
					v.Entity:Remove()
				end
				--neat little visual cue when the weapon has been removed
				local effectdata = EffectData()
                        effectdata:SetOrigin( v.Entity:GetPos() )
                        effectdata:SetNormal( Vector( 0, 0, 1 ) )
                        effectdata:SetMagnitude( 2 )
                        effectdata:SetScale( 4 )
                        effectdata:SetRadius( 10 )
                util.Effect( "inflator_magic", effectdata )

				--remove the weapon from the table
				tab[k] = nil
			end
		end
	end
end

-- we don't want them to pick up the weapon as soon as they drop it do we?
-- function DisableWeaponPickup( plr, ent, delay )
-- 	local Delay = CurTime() + delay;
-- check the time of creation and if someone has picked up the weapon
-- we don't want the weapon to disappear when someone has actually picked it up, do we?
hook.Add( "PlayerCanPickupWeapon", "PickupDelay", function( ply, wep )
	for k, v in pairs(tab) do
		local ent = v.Entity;
		local Delay = v.EntryTime + 1;
		local plr = v.Player;

		if (plr == ply) and (ent == wep) and (CurTime() < Delay) then
			//ent:SetNWBool('PickedUp', ent.PickedUp);
			return false
		end

		if CurTime() > Delay then
			for k, v in pairs(tab) do
				if wep == v.Entity then
					wep.PickedUp = true;
					break;
				end
			end
		end
	end
end )

	-- timer.Simple( delay, function()
	-- 	hook.Remove( "PlayerCanPickupWeapon", "PickupDelay" )
	-- 	//hook.Add( "PlayerCanPickupWeapon", "PickupDelay", function() return true end )
	-- end )
-- end

-- drop a single weapon at a time
concommand.Add( "DropWeapon", function( ply )
	if ( not IsValid( ply ) or not IsValid( ply:GetActiveWeapon() ) or not ply:Alive() ) then return end

	local wep, wep_class = ply:GetActiveWeapon(), ply:GetActiveWeapon():GetClass()
	--make sure they can't spam this
	if NextDrop <= CurTime() then
		local ent = ents.Create( wep_class )
			ent.PickedUp = false;
		ply:StripWeapon( wep_class )

		//DisableWeaponPickup( ply, ent, 1 )

		ent:SetPos( ply:GetShootPos() )
		ent:DrawShadow( false )
		ent:Spawn()

		local entid = ent:EntIndex()
		--'throw' the weapon
		if IsValid( ent:GetPhysicsObject() ) then
			ent:GetPhysicsObject():SetMass( 10 )
			ent:GetPhysicsObject():ApplyForceCenter( ply:GetAimVector() * 3500 + Vector( 15, 0, 0 ) )

			umsg.Start( "StartShrink" )
				umsg.String( tostring(entid) )
				umsg.Float( CurTime() )
			umsg.End()

			table.insert( tab, {Entity = ent, EntryTime = CurTime(), Player = ply} )
			-- set the next time the player is allowed to throw
			-- TODO: make this local to the player
			NextDrop = CurTime() + NextDropTime:GetInt()
		else
			ent:Remove()
		end
	end
end )

hook.Add( "Think", "SentFade", function() entFadeThink( tab ) end )