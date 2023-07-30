AddCSLuaFile()

function gspeak:GetName( ply )
	if gspeak.settings.nickname then return ply:Nick() end
	return ply:GetName()
end

function gspeak:player_alive(ply)
	local result = hook.Run("Gspeak.OverridePlayerAlive", ply)
	if result != nil then
		return result
	end

	if !ply:Alive() then return false end

	if gspeak.terrortown then
		if ( ply:IsSpec() or GetRoundState() == ROUND_POST ) then return false end
	end

	//************************************************************//
	//usage exampe of Gspeak.OverridePlayerAlive hook for terrortown:
	//************************************************************//
	//	hook.Add("Gspeak.OverridePlayerAlive", "Gspeak.TerrortownPlayerAlive", function()
	//		return !ply:Alive() or ply:IsSpec() or GetRoundState() == ROUND_POST
	//	end)
	//************************************************************//

	return true
end

--stupid solution should be easier
function gspeak:UpdatePlayers()
	for k, v in pairs(player.GetAll()) do
		if !v:IsPlayer() then continue end
		gspeak:NoDoubleEntry( v, gspeak.cl.players)
	end
end

-- net.Receive("gspeak_name_change", function( len )
-- 	local name = net.ReadString()
-- 	if gspeak.cl.TS.connected then gspeak.io:SendName(name) end
-- end)