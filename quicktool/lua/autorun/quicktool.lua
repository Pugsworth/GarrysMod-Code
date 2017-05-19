if CLIENT then
	include ("quicktool/cl_init.lua")

	concommand.Add ("quicktool_reload", function ()
		include ("autorun/quicktool.lua")
	end)
elseif SERVER then
	include ("quicktool/sv_init.lua")
end