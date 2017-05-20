local me = LocalPlayer();

if g_frznragdoll then
	g_frznragdoll:Remove();
end

g_frznragdoll = ClientsideModel(me:GetModel(), RENDERGROUP_BOTH);

local rag = g_frznragdoll;

rag:SetPos(me:GetPos());
rag:SetAngles(me:GetAngles());
rag:ResetSequence(me:GetSequence());

-- local ent = ents.Create("prop_dynamic");
-- local ent = ents.CreateClientProp(me:GetModel());
-- ent:SetModel(me:GetModel());
-- ent:SetPos(pos);

-- local angle = (pos - me:GetPos()):Angle();
-- ent:SetAngles(Angle(0, angle.y - 180, 0));
-- ent:Spawn();
-- ent:NextThink(math.huge);
-- ent.AutomaticFrameAdvance = false;
-- ent:SetPlaybackRate(0);
-- ent:ResetSequence(me:GetSequence());

-- -- timer.Simple(1, function()
-- -- 	for i = 0, rag:GetPhysicsObjectCount() - 1 do

-- -- 	    local phys = rag:GetPhysicsObjectNum(i);
-- -- 	    local b = rag:TranslatePhysBoneToBone(i);
-- -- 	    local pos, ang = ent:GetBonePosition(b);

-- -- 	    phys:SetPos(pos);
-- -- 	    phys:SetAngles(ang);

-- -- 	    if string.sub(rag:GetBoneName(b), 1, 4) == "prp_" then
-- -- 	        phys:EnableMotion(true);
-- -- 	    else
-- -- 	        phys:EnableMotion(false);
-- -- 	    end

-- -- 	    phys:Wake()
-- -- 	end

-- -- 	ent:Remove()
-- -- end)

-- rag.test = ent;
