do return end
local meta = FindMetaTable('Player')
meta.ccmd = meta.ConCommand

local blacklist = {
	'retry',
	'say',
	'exit',
	'quit',
	'bind',
	'exec',
	'_restart',
	'reload'
}

function meta:ConCommand(str)
	args = string.Explode(' ', str)
	if table.HasValue(blacklist, args[1]) then
		self:ccmd('say [' .. args[1] .. '] blacklisted.')
		return false
	end
	self:ccmd(str)
end