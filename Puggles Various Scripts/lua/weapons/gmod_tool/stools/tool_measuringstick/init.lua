function TOOL:Init()

end

function TOOL:LeftClick(trace)
	if game.SinglePlayer() then self.Weapon:CallOnClient("PrimaryAttack", "") end -- Garry!!!!!!!

	return true;
end

function TOOL:RightClick(trace)
	if game.SinglePlayer() then self.Weapon:CallOnClient("SecondaryAttack", "") end -- Garry!!!!!!!

	return true;
end

function TOOL:Reload(trace)
	if game.SinglePlayer() then self.Weapon:CallOnClient("Reload", "") end -- Garry!!!!!!!

	return true;
end

function TOOL:Think()

end

