local arBadWeapons = {["weapon_crowbar"] = true, ["weapon_physcannon"] = true, ["weapon_frag"] = true}; -- if VERSION is <= 140122, then we can't drop these weapons
local tblNonPickupWeapons = {};

local function removeweapon(e)
	tblNonPickupWeapons[e] = nil;
end

local function dropweapon(ply, cmd, args)
	local wep = ply:GetActiveWeapon();
	if IsValid(wep) then
		if VERSION <= 140122 and arBadWeapons[wep:GetClass()] then
			local vDir = ply:GetAimVector();

			if wep:IsScripted() then
				wep:OnDrop();
			end
			
			local nClip1 = wep:Clip1();
			local nClip2 = wep:Clip2();
			
			ply:StripWeapon(wep:GetClass());

			local e = ents.Create(wep:GetClass());
			e:SetPos(ply:GetShootPos());
			e:SetCollisionGroup(COLLISION_GROUP_WEAPON);
			e:Spawn();

			e:CallOnRemove("DropWeapon.CleanupCache", removeweapon);

			if clip1 and clip1 > -1 then
				e:SetClip1(clip1);
			end
			if clip2 and clip2 > -1 then
				e:SetClip2(clip2);
			end

			local phys = e:GetPhysicsObject();
			if IsValid(phys) then
				phys:ApplyForceCenter(vDir * (phys:GetMass() * 400)); -- source uses 400 velocity as the default weapon throw velocity
			end

			tblNonPickupWeapons[e] = CurTime() + 1.0;
		else
			ply:DropWeapon(wep);
		end
	end
end

local tblCmdCache = concommand.GetTable();
local arCmds = {"dropprimary", "dropweapon", "drop"};
for i = 1, #arCmds do
	local cmd = arCmds[i];

	-- if tblCmdCache[cmd] then
	-- 	MsgC(Color(255, 75, 75), "WARNING: ");
	-- 	MsgC(Color(180, 180, 200), cmd, " is already registered, not adding command.");
	-- 	MsgN("");
	-- else
		concommand.Add(cmd, dropweapon);
	-- end
end

if VERSION <= 140122 then
	hook.Add("PlayerCanPickupWeapon", "DropWeapon.DisableImmediatePickup", function(ply, wep)
		if tblNonPickupWeapons[wep] then
			if tblNonPickupWeapons[wep] < CurTime() then
				tblNonPickupWeapons[wep] = nil;
				return true;
			else
				return false;
			end
		end
	end);
end
