-- local bingame = false -- TOOL and false or true;
-- local TOOL = TOOL or {};

-- local tag = "dev";


-- TOOL.Category		= "Developer Testing";
-- TOOL.Name			= "Developer Testing";
-- TOOL.Command		= nil;
-- TOOL.ConfigName		= nil;


-- AccessorFunc(TOOL, "m_sSavedModel", "SavedModel", FORCE_STRING);

-- function TOOL:Init()

-- 	if CLIENT then
-- 		language.Add("tool." .. tag .. ".name", "Developer Testing");
-- 		language.Add("tool." .. tag .. ".help", "Developer Testing");

-- 		language.Add("tool.tool_" .. tag .. ".name", "Developer Testing");
-- 		language.Add("tool.tool_" .. tag .. ".desc", "Developer Testing");
-- 	end

-- 	self:SetSavedModel("models/props_c17/oildrum001.mdl");

-- 	self:MakeGhostEntity(self:GetSavedModel(), vector_origin, Angle(0, 0, 0));

-- end

-- -- TOOL.ClientConVar[""]
-- function TOOL:LeftClick(trace)

-- 	if CLIENT then return true end

-- 	local ent = ents.Create("prop_physics");
-- 	ent:SetModel(self:GetSavedModel());
-- 	ent:SetPos(trace.HitPos);
-- 	ent:SetAngles(Angle(0, 0, 0));
-- 	ent:Spawn();

-- 	undo.Create("Developer Test");
-- 	undo.AddEntity(ent);
-- 	undo.SetPlayer(self:GetOwner());
-- 	undo.Finish();

-- 	return true; -- return 'true' to show the tool effect

-- end

-- function TOOL:RightClick(trace)

-- 	if CLIENT then return true end

-- 	local ent = trace.Entity;

-- 	if IsValid(ent)
-- 		and ent ~= game.GetWorld()
-- 			and util.IsValidProp(ent:GetModel()) then

-- 		self:SetSavedModel(ent:GetModel());		

-- 		return true;
-- 	end

-- end

-- function TOOL:Think()
	
-- 	if CLIENT then return end

-- 	if not IsValid(self.GhostEntity) or not self.GhostEntity or self.GhostEntity:GetModel() ~= self:GetSavedModel() then
-- 		self:MakeGhostEntity(self:GetSavedModel(), vector_origin, Angle(0, 0, 0));
-- 	end

-- 	self:UpdateGhostEntity();

-- end

-- function TOOL.BuildCPanel(self, panel)

-- 	panel:AddControl("Header", {Text = "#tool." .. tag .. ".name", Description = "#tool." .. tag .. ".help"});

-- 	panel:AddControl("Label", {Text = self:GetSavedModel()});
									
-- end

-- if false then
-- 	weapons.Get("gmod_tool").Tool["tool_" .. tag] = TOOL;
-- end

-- --[[
-- scripted_tools = {}
-- function scripted_tools.Register(name, tab)

-- 	weapons.Get("gmod_tool").Tool[name] = tab;

-- end
-- --]]