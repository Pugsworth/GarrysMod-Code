local self = {}
QuickTool.ActionTree = QuickTool.MakeConstructor (self)

local gmod_tool = nil

function self:ctor (...)
	self.Children = nil
	self.Description = nil
	
	self.Type = "none"
	self.EscapeKey = nil
	self.UpKey = nil
	self.Command = nil
	self.Tool = nil
end

-- Serialization
function self:Deserialize (node)
	self.Description = node.description
	
	if node.keys then
		self.Type = "tree"
		self.Children = {}
		self.EscapeKey = node.escapekey or self.EscapeKey
		self.UpKey = node.upkey or self.UpKey
		for key, childnode in pairs (node.keys) do
			local child = QuickTool.ActionTree ()
			self.Children [key:lower ()] = child
			child:SetEscapeKey (self:GetEscapeKey ())
			child:SetUpKey (self:GetUpKey ())
			
			if type (childnode) == "table" then
				child:Deserialize (childnode)
			else
				ErrorNoHalt ("Error in quicktool_hotkeys: " .. self.Description .. " has invalid children.")
			end
		end
	elseif node.command then
		self.Type = "command"
		self.Command = node.command
	elseif node.tool then
		self.Type = "tool"
		self.Tool = node.tool
	end
end

function self:Serialize ()
	-- TODO: Implement this properly
	local node = {}
	if self.Type == "tree" then
		node.Children = {}
		for k, child in pairs (self.Children) do
			node.Children [k] = child:Serialize ()
		end
	end
	
	return node
end

function self:CanUseTool ()
	if self.Type == "tool" then
		gmod_tool = gmod_tool or weapons.Get ("gmod_tool")
		if not gmod_tool then
			return false
		end
		local tool = gmod_tool.Tool [self.Tool]
		return tool ~= nil
	end
	return false
end

function self:Clear ()
	self.Type = "none"
	self.Children = nil
end

function self:GetChild (key)
	if not self.Children then
		return nil
	end
	return self.Children [key:lower ()]
end

function self:GetChildren ()
	return self.Children
end

function self:GetCommand ()
	return self.Command
end

function self:GetDescription ()
	if self.Description == nil and self.Type == "tool" then
		gmod_tool = gmod_tool or weapons.Get ("gmod_tool")
		if not gmod_tool then
			return self.Tool
		end
		self.Tooltable = self.Tooltable or gmod_tool.Tool [self.Tool]
		if self.Tooltable then
			return self.Tooltable.Name
		end
		return self.Tool
	end
	return self.Description
end

function self:GetEscapeKey ()
	return self.EscapeKey
end

function self:GetType ()
	return self.Type
end

function self:GetUpKey ()
	return self.UpKey
end

function self:RunAction ()
	if self.Type == "tool" then
		RunConsoleCommand ("gmod_tool", self.Tool)
		RunConsoleCommand ("gmod_toolmode", self.Tool)
		
		local tool = weapons.GetStored ('gmod_tool').Tool [self.Tool];
		if tool then
			local cp = controlpanel.Get (self.Tool)
			if not cp:GetInitialized () then
				cp:FillViaTable (
					{
						Name = self.Tool,
						Text = tool.Name or "#" .. self.Tool,
						Controls = tool.ConfigName or self.Tool,
						Command = tool.Command or "gmod_tool " .. self.Tool,
						ControlPanelBuildFunction = tool.BuildCPanel
					}
				)
			end
			
			spawnmenu.ActivateToolPanel (1, cp)
		end
	elseif self.Type == "command" then
		-- RunConsoleCommand does not allow multiple commands to be chained with semicolons.
		LocalPlayer ():ConCommand (self.Command)
	end
end

function self:SetDescription (description)
	self.Description = description
end

function self:SetEscapeKey (key)
	self.EscapeKey = key
end

function self:SetUpKey (key)
	self.UpKey = key
end