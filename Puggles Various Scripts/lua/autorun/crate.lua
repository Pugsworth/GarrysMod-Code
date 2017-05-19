if SERVER then

    function SpawnCrate(ply, cmd, args)
        local tr = ply:GetEyeTrace()

        local ent = ents.Create("item_item_crate" )
            ent:SetKeyValue("ItemClass", args[1] or "sent_ball")
            ent:SetKeyValue("ItemCount", args[2] or 1)
            ent:SetPos(tr.HitPos)
        ent:Spawn()
    	
    	undo.Create("Crate")
    	   undo.AddEntity(ent)
    	   undo.SetPlayer(ply)
    	undo.Finish()
    end

    concommand.Add("Crate", SpawnCrate);

end

if CLIENT then

    language.Add('Undone_Crate', 'Undone Crate');

end