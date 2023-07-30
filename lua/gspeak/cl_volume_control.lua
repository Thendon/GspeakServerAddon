//************************************************************//
//							GSPEAK HOOKS
//************************************************************//

local dead_circle = {}
local dead_slot = 1

function initDeadCircle()
	local dead_dist = 150
	local dead_vec = Vector(dead_dist, 0, 0)
	local dead_angl = Angle(0,22.5,0)
	table.insert(dead_circle, Vector(dead_vec.x, dead_vec.y, dead_vec.z))
	dead_vec:Rotate(dead_angl*8)
	table.insert(dead_circle, Vector(dead_vec.x, dead_vec.y, dead_vec.z))
	dead_vec:Rotate(dead_angl*4)
	table.insert(dead_circle, Vector(dead_vec.x, dead_vec.y, dead_vec.z))
	dead_vec:Rotate(dead_angl*8)
	table.insert(dead_circle, Vector(dead_vec.x, dead_vec.y, dead_vec.z))
	dead_vec:Rotate(dead_angl*2)
	table.insert(dead_circle, Vector(dead_vec.x, dead_vec.y, dead_vec.z))
	dead_vec:Rotate(dead_angl*8)
	table.insert(dead_circle, Vector(dead_vec.x, dead_vec.y, dead_vec.z))
	dead_vec:Rotate(dead_angl*4)
	table.insert(dead_circle, Vector(dead_vec.x, dead_vec.y, dead_vec.z))
	dead_vec:Rotate(dead_angl*8)
	table.insert(dead_circle, Vector(dead_vec.x, dead_vec.y, dead_vec.z))
	dead_vec:Rotate(dead_angl)
	table.insert(dead_circle, Vector(dead_vec.x, dead_vec.y, dead_vec.z))
	dead_vec:Rotate(dead_angl*8)
	table.insert(dead_circle, Vector(dead_vec.x, dead_vec.y, dead_vec.z))
	dead_vec:Rotate(dead_angl*4)
	table.insert(dead_circle, Vector(dead_vec.x, dead_vec.y, dead_vec.z))
	dead_vec:Rotate(dead_angl*8)
	table.insert(dead_circle, Vector(dead_vec.x, dead_vec.y, dead_vec.z))
	dead_vec:Rotate(dead_angl*2)
	table.insert(dead_circle, Vector(dead_vec.x, dead_vec.y, dead_vec.z))
	dead_vec:Rotate(dead_angl*8)
	table.insert(dead_circle, Vector(dead_vec.x, dead_vec.y, dead_vec.z))
	dead_vec:Rotate(dead_angl*4)
	table.insert(dead_circle, Vector(dead_vec.x, dead_vec.y, dead_vec.z))
	dead_vec:Rotate(dead_angl*8)
	table.insert(dead_circle, Vector(dead_vec.x, dead_vec.y, dead_vec.z))
end

function getDeadSlot()
	dead_slot = dead_slot + 1
	if (dead_slot >= table.Count(dead_circle)) then
		dead_slot = 1
	end
	return  dead_slot
end

initDeadCircle()

--called by cpp
function gspeak.SetPlayerTeamspeakData(ent_id, volume, talking)
	local ply = Entity(ent_id)
	if !gspeak:player_valid(ply) then 
		gspeak:ConsoleWarning("set teamspeak data of invalid player " .. ent_id)
		return
	end

	ply.volume = volume
	ply.talking = talking
end

--triggered by cpp in gs_sendPos & gs_delPos. Not sure why but seems to be used for 
--filtering which player mouths should be animated (immersion?)
function gspeak.setHearable(ent_id, bool)
	local ply = Entity(ent_id)
	if !gspeak:player_valid(ply) then 
		gspeak:ConsoleWarning("set hearable of invalid player " .. ent_id)
		return
	end

	ply.hearable = bool
end

function gspeak:ts_talking( trigger )
	LocalPlayer().talking = trigger
	gspeak.cl.start_talking = trigger
	net.Start("ts_talking")
		net.WriteBool( trigger )
	net.SendToServer()
end

function handleLocalPlayer()
	local playerFor = ply:GetForward()
	local playerUp = ply:GetUp()
	gspeak.io:SetLocalPlayer(playerFor, playerUp)
	
	local check = gspeak.io:IsTalking()
	if check and !gspeak.cl.start_talking then
		gspeak:ts_talking( true )
	elseif !check and gspeak.cl.start_talking then
		gspeak:ts_talking( false )
	end
end

function handlePlayer(ply)
	local ts_id_ply = gspeak:get_tsid(ply)
	local ply_alive = gspeak:player_alive(ply)
	if ply.alive != ply_alive then
		ply.alive = ply_alive
		if !ply_alive then
			ply.dead_slot = getDeadSlot()
		end
	end
	if ts_id_ply == 0 then continue end
	local talkmode = gspeak:get_talkmode( ply )

	local distance, distance_max, playerPos
	if gspeak.settings.dead_chat and !client_alive and !ply_alive and !gspeak.cl.dead_muted then
		distance = 100
		distance_max = 1000
		playerPos = dead_circle[ply.dead_slot]
	elseif ( client_alive or gspeak.settings.dead_alive ) and ply_alive then
		distance, playerPos = gspeak:get_distances(ply)
		distance_max = gspeak:get_talkmode_range(talkmode)
	else
		continue
	end

	if distance < distance_max then
		gspeak.io:SetPlayer(ts_id_ply, gspeak:calcVolume( distance, distance_max ), ply:EntIndex(), playerPos, false)
	end
end

function handleHearableRadio(ent, playerIndex, radioIndex)
	local radio_ent = Entity(radioIndex)

	if !ent or !IsValid(ent) or !ent:IsRadio() or
		!radio_ent or !IsValid(radio_ent) or !radio_ent:IsRadio() then
		gspeak.io:RemovePlayer(playerIndex, true, radioIndex)
		return
	end

	if !gspeak:player_alive(LocalPlayer()) and !gspeak.settings.dead_alive then
		gspeak.io:RemovePlayer(playerIndex, true, radioIndex)
		return
	end

	local distance = gspeak:get_distances(v_radio_ent)
	local distance_max = v_radio_ent.range
	if distance > distance_max then
		gspeak.io:RemovePlayer(playerIndex, true, radioIndex)
	end
end

function handleHearablePlayer(ply, playerIndex)
	if !ply or !IsValid(ply) or !ply:IsPlayer() then
		gspeak.io:RemovePlayer(v, false)
		return 
	end

	if v_ent.ts_id == 0 then
		gspeak.io:RemovePlayer(playerIndex, false)
		return
	end

	local local_alive = gspeak:player_alive(LocalPlayer())

	if gspeak:player_alive(ply) then
		if ( !local_alive and !gspeak.settings.dead_alive ) then
			gspeak.io:RemovePlayer(playerIndex, false)
		else
			local distance = gspeak:get_distances(v_ent)
			local talkmode = gspeak:get_talkmode(v_ent);
			local distance_max = gspeak:get_talkmode_range(talkmode)
			if distance > distance_max then
				gspeak.io:RemovePlayer(playerIndex, false)
			end
		end
	else
		if !gspeak.settings.dead_chat or local_alive or gspeak.cl.dead_muted then
			gspeak.io:RemovePlayer(playerIndex, false)
		end
	end
end

function gspeak:get_offset(ply)
	if !gspeak:player_alive(ply) then return gspeak.cl.player.dead end
	if ply:Crouching() then	return gspeak.cl.player.crouching end
	if IsValid(ply:GetVehicle()) then return gspeak.cl.player.vehicle end
	return gspeak.cl.player.standing
end

function gspeak:get_distances( ent )
	local ent_pos = ent:GetPos()
	if ent:IsPlayer() then ent_pos = ent_pos + gspeak:get_offset(ent)	end
	local pos = gspeak.clientPos or LocalPlayer():GetPos()
	ent_pos:Sub(pos)
	ent_pos = ent_pos * Vector(1,1,1 / gspeak.settings.distances.heightclamp)
	local distance = Vector(0,0,0):Distance(ent_pos)

	return distance, ent_pos
end

function gspeak:calcVolume( distance, distance_max )
	return 1 - distance / distance_max
end

function gspeak:change_talkmode( talkmode )
	if talkmode <= #gspeak.settings.distances.modes then
		gspeak.cl.settings.talkmode = talkmode
	else
		gspeak.cl.settings.talkmode = 1
	end
	net.Start( "ts_talkmode" )
		net.WriteInt( gspeak.cl.settings.talkmode, 32 )
	net.SendToServer()
	chat.AddText( gspeak.cl.color.red, "[Gspeak]",  gspeak.cl.color.black, " mode: ", gspeak.cl.color.green, gspeak.settings.distances.modes[gspeak.cl.settings.talkmode].name )
end

function gspeak:get_talkmode( ply )
	if ply == LocalPlayer() then return gspeak.cl.settings.talkmode end
	--if !ply:Alive() then return 2 end //Thendon make dead chat talkmode //i think i already did?
	return ply.talkmode
	--return gspeak.settings.def_mode
end

hook.Add("Think", "gspeak_volume_control", function()
	gspeak.clientPos = LocalPlayer():GetPos() + gspeak:get_offset(LocalPlayer())

	if !gspeak.cl.TS.inChannel then return end
	--Add player entitys to C++ Struct of hearable Players
	gspeak.hearable = gspeak.io:GetHearables()

	handleLocalPlayer()

	for k, v in pairs(gspeak.cl.players) do
		if !IsValid(v) then
			table.remove(gspeak.cl.players, k)
			continue
		end
		
		if ply == LocalPlayer() then continue end

		handlePlayer(v)
	end
	--Check C++ Struct if hearable player must be removed
	for k, v in pairs(gspeak.hearable) do
		local ent = Entity(v.ent_id)

		if (v.radio) then
			handleHearableRadio(ent, v.ent_id, v.radio_id)
		else
			handleHearablePlayer(ent, v.ent_id)
	end
end)
