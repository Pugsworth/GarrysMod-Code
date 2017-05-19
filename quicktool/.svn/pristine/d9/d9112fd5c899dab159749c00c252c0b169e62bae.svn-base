QuickTool = QuickTool or {}

function QuickTool.MakeConstructor (metatable)
	metatable.__index = metatable
	return function (...)
		local object = {}
		setmetatable (object, metatable)
		object:ctor (...)
		return object
	end
end

include ("quicktool/actiontree.lua")
include ("quicktool/hotkeys.lua")
include ("quicktool/search.lua")

include ("quicktool/ui/imagecacheentry.lua")
include ("quicktool/ui/imagecache.lua")
include ("quicktool/ui/quicktoolimage.lua")
include ("quicktool/ui/quicktoolmenuitem.lua")
include ("quicktool/ui/quicktoolmenuspacer.lua")
include ("quicktool/ui/quicktoolhotkeymenuitem.lua")
include ("quicktool/ui/quicktoolmenu.lua")
include ("quicktool/ui/quicktoolsearch.lua")
include ("quicktool/ui/quicktoolhotkeys.lua")