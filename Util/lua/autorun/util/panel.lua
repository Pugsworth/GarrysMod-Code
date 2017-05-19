if SERVER then return; end

local meta = FindMetaTable("Panel");

---------------------------------
-- panel debugging/development --
---------------------------------
vgui.debug = {
	panels = (vgui.debug and vgui.debug.panels) or setmetatable({}, {__mode = "kv"}),
	detors = {}
}

function vgui.debug.Create(...)
	local pnl = vgui.Create(...);
	table.insert(vgui.debug.panels, pnl);
	return pnl;
end

function vgui.debug.CreateFromTable(...)
	local pnl = vgui.CreateFromTable(...);
	table.insert(vgui.debug.panels, pnl);
	return pnl;
end

function vgui.debug.CleanupPanels()
	printf("Cleaning %i panels", #vgui.debug.panels);
	
	for i = #vgui.debug.panels, 1, -1 do
		local pnl = vgui.debug.panels[i];
		if pnl then
			pnl:Remove();
			vgui.debug.panels[i] = nil;
		end
	end
end

concommand.Add("vgui_debug_cleanuppanels", vgui.debug.CleanupPanels);


vgui.debug.detor = {
	Add = function(self, ...)
		local pnl = super(self, ...);
		table.insert(vgui.debug.panels, pnl);
		return pnl;
	end
};

-- scope for function detor to minimize unnecessary collision
function vgui.debug.StartDebug(class)

	if vgui.debug.DebugStarted then
		vgui.debug.EndDebug();
		print("vgui debug started without ending the previous session, has an error occured?");
	end

	vgui.debug.DebugStarted = true;

	local detored = vgui.debug.detors;

	for name, detFunc in pairs(vgui.debug.detor) do
		
		local oldFunc = meta[name];
		if not detored[meta] then
			detored[meta] = {};
		end

		if not detored[meta][name] then
			detored[meta][name] = oldFunc;
		end

		local env = debug.getfenv(detFunc);
		env.super = oldFunc;
		debug.setfenv(detFunc, env);

		meta[name] = detFunc;
	end

end

function vgui.debug.EndDebug()

	vgui.debug.DebugStarted = false;

	local detored = vgui.debug.detors;

	for name, detFunc in pairs(vgui.debug.detor) do

		if detored[meta] and detored[meta][name] then
			local oldFunc = detored[meta][name];
			detored[meta][name] = nil;

			meta[name] = oldFunc;
		end
	end

end

--------------------
-- Meta functions --
--------------------
