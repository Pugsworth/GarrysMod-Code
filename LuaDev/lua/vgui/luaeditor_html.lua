local PANEL = {};

function PANEL:Init()

	-- proxy to syntactically call javascript functions
	self.proxy = setmetatable({html = self, queue = {}, m_bReady = false}, {
		__index = function(self, key)
			local f = (function(data)
				if data then
					self:Call(string.format('Lua_%s("%s")', key, util.TableToJSON(data)));
				else
					self:Call(string.format('Lua_%s()', key));
				end
			end);

			if not self.m_bReady then
				return function(...)
					self.queue[#self.queue+1] = {f, ...};
				end
			end

			return f;
		end
	});

	self.proxy.OnReady = function()
		for i = 1, #self.queue do
			local t = self.queue[i];

			t[1](unpack(t, 2));
		end
	end;

	-- cached variables from html state
	self.vars = {
		contents = "",
		theme = "",
		mode = ""
	};

	self.events = {};

	self:AddFunction("lua", "invoke", function(name, data)
		if self.events[name] then
			self.events[name](self, name, data);
		end
	end);

	self:OpenURL("asset://garrysmod/data/LuaDev/aceeditor/index.html");

	self.proxy:CacheThemes();
	self.proxy:CacheModes();
end

------------
-- Events --
------------

function PANEL:AddEvent(eventName, func)
	local event = self.events[eventName];

	if event then
		if not event.contains(func) then
			table.insert(event, func);
		end
	end
end

function PANEL:RemoveEvent(eventName, func)
	local event = self.events[eventName];

	if event then
		local index = event.indexOf(func)
		if not index then return nil; end

		return table.remove(event, index);
	end
end

--------------
-- Contents --
--------------

function PANEL:SetContents(contents)
	htmlobj:SetContents(contents);
end

function PANEL:GetContents()
	return self.vars['content'];
end

------------
-- Syntax --
------------

function PANEL:SetSyntax(name)
	htmlobj:SetSyntax(name);
end

function PANEL:GetSyntax()
	return self.vars['syntax'];
end

-----------
-- Theme --
-----------

function PANEL:SetTheme(name)
	htmlobj:SetTheme(name);
end

function PANEL:GetTheme()
	return self.vars['theme'];
end

vgui.Register("luaeditor_html", PANEL, "DHTML");
