if true then return false; end

print("Init replace_pickups");
print(string.format("SERVER: %s, CLIENT: %s", SERVER, CLIENT));

local pickups = {
	["item_healthkit"]  = "sent_healthkit",
	["item_healthvial"] = "sent_healthvial",
	["item_battery"]    = "sent_battery"
};

local queue = {};

local function replaceEntity(old, new_class)
	print(string.format("[%s%s]Replacing [%i]%s with %s", SERVER and "S" or "", CLIENT and "C" or "", old:EntIndex(), old:GetClass(), new_class));

	old:SetCollisionGroup(COLLISION_GROUP_DEBRIS);

	local ent = ents.Create(new_class);
	ent:SetPos(old:GetPos());
	ent:SetAngles(old:GetAngles());
	ent:SetName(ent:GetName());

	ent:Spawn();
	ent:Activate();

	ent:SetVelocity(old:GetVelocity());

	// old:Remove();

	queue[#queue+1] = old;
end

timer.Simple(20, function()
	print("queue cull running...");

	for i, v in ipairs(queue) do
		if IsValid(v) then
			v:Remove();
		end
	end
end);

--[[
hook.Add("InitPostEntity", "replace_pickups", function()
	timer.Simple(10, function() -- one second delay because ???

		local cur_ents = ents.GetAll();

		for i = 1, #cur_ents do
			local ent = cur_ents[i];

			if IsValid(ent) and ent:CreatedByMap() then
				local new_class = pickups[ent:GetClass()];

				if new_class then
					replaceEntity(ent, new_class)
				end
			end
		end

	end);
end);
--]]

hook.Add("OnEntityCreated", "replace_pickups", function(ent)
	if IsValid(ent) then
		local new_class = pickups[ent:GetClass()];

		if new_class then
			replaceEntity(ent, new_class);
		end
	end
end);
--]]
