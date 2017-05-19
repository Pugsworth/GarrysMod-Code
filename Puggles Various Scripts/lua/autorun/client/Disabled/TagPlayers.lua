-- local TagPlayers_Enabled = CreateClientConVar( "TagPlayers_Enabled", 1, true, false )
-- local TagPlayers_Dist = CreateClientConVar( "TagPlayers_Distance", 1, true, false )
-- local TagPlayers_Speed = CreateClientConVar( "TagPlayers_Speed", 0, true, false )
-- local TagPlayers_Rank = CreateClientConVar( "TagPlayers_Rank", 0, true, false )
-- local TagPlayers_Weapon = CreateClientConVar( "TagPlayers_Weapon", 0, true, false )

-- local allys = {
-- 	["npc_citizen"] = true,
-- 	["npc_barney"] = true,
-- 	["npc_kleiner"] = true,
-- 	["npc_magnusson"] = true,
-- 	["npc_eli"] = true,
-- 	["npc_vortigaunt"] = true,
-- 	["npc_alyx"] = true,
-- 	["npc_dog"] = true
-- 	}

-- hook.Add( "HUDPaint", "TagPlayers", function()
-- 	if TagPlayers_Enabled:GetInt() == 1 then

-- 		for _, v in pairs( ents.GetAll() ) do

-- 			if ( v:IsPlayer() or ( v:IsNPC() and allys[v:GetClass()] ) ) then

-- 				if( v ~= LocalPlayer() ) then
-- 					local bonepos, boneang = v:GetBonePosition(v:LookupBone('ValveBiped.Bip01_Head1'))
-- 					local PlayerPos = (bonepos + Vector(0, 0, 12)):ToScreen()

-- 					if v:IsNPC() then
-- 						continue
-- 						//draw.SimpleText( v:GetClass(), "DefaultFixedOutline", PlayerPos.x, PlayerPos.y - 60, Color( 250, 250, 250, 255 ), TEXT_ALIGN_CENTER )
-- 						//draw.SimpleText( "Distance: " .. math.Round( v:GetPos():Distance( LocalPlayer():GetPos() ) ), "DefaultSmallDropShadow", PlayerPos.x, PlayerPos.y - 47, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
-- 					else
-- 						draw.SimpleText( v:Name(), "DefaultFixedOutline", PlayerPos.x, PlayerPos.y - 32, Color( 250, 250, 250, 255 ), TEXT_ALIGN_CENTER )
-- 						draw.SimpleText( v:Health(), "DefaultSmallDropShadow", PlayerPos.x, PlayerPos.y - 22, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
-- 					end

-- 					local fortri = { { }, { }, { } }
-- 					-- local backtri = { { }, { }, { } }
-- 					local fortri = {
-- 							{// tip
-- 								x = PlayerPos.x, 
-- 								y = PlayerPos.y
-- 							},

-- 							{// top right
-- 								x =PlayerPos.x - 5, 
-- 								y =PlayerPos.y - 10
-- 							},

-- 							{// top left
-- 								x =PlayerPos.x + 5, 
-- 								y =PlayerPos.y - 10
-- 							}  
-- 						}
-- 					--[[
-- 					fortri[1]["x"] = PlayerPos.x
-- 					fortri[1]["y"] = PlayerPos.y - 13

-- 					fortri[2]["x"] = PlayerPos.x - 20
-- 					fortri[2]["y"] = PlayerPos.y - 29.5

-- 					fortri[3]["x"] = PlayerPos.x + 20
-- 					fortri[3]["y"] = PlayerPos.y - 29.5
-- 					]]--

-- 					-- backtri[1]["x"] = PlayerPos.x
-- 					-- backtri[1]["y"] = PlayerPos.y - 12

-- 					-- backtri[2]["x"] = PlayerPos.x - 21
-- 					-- backtri[2]["y"] = PlayerPos.y - 29

-- 					-- backtri[3]["x"] = PlayerPos.x + 21
-- 					-- backtri[3]["y"] = PlayerPos.y - 29
-- 					surface.SetTexture()
-- 					-- surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
-- 					-- surface.DrawPoly( backtri )

-- 					if v:IsNPC() then
-- 						continue
-- 						//surface.SetDrawColor( Color( 20, 255, 20, 255 ) )
-- 					else
-- 						surface.SetDrawColor( team.GetColor( v:Team() ) )
-- 					end

-- 					surface.DrawPoly( fortri )
-- 				end
-- 			end
-- 		end
-- 	end
-- end )