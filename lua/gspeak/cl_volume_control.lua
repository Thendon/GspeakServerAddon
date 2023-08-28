gspeak.hearablePlayers = gspeak.hearablePlayers or {}
gspeak.gspeakEntities = gspeak.gspeakEntities or {}

local deadCircle = {}
local deadCircleIndex = 1

local function initDeadCircle()
	local deadDist = 150
	local deadVec = Vector(deadDist, 0, 0)
	local deadAng = Angle(0,22.5,0)
	table.insert(deadCircle, Vector(deadVec.x, deadVec.y, deadVec.z))
	deadVec:Rotate(deadAng*8)
	table.insert(deadCircle, Vector(deadVec.x, deadVec.y, deadVec.z))
	deadVec:Rotate(deadAng*4)
	table.insert(deadCircle, Vector(deadVec.x, deadVec.y, deadVec.z))
	deadVec:Rotate(deadAng*8)
	table.insert(deadCircle, Vector(deadVec.x, deadVec.y, deadVec.z))
	deadVec:Rotate(deadAng*2)
	table.insert(deadCircle, Vector(deadVec.x, deadVec.y, deadVec.z))
	deadVec:Rotate(deadAng*8)
	table.insert(deadCircle, Vector(deadVec.x, deadVec.y, deadVec.z))
	deadVec:Rotate(deadAng*4)
	table.insert(deadCircle, Vector(deadVec.x, deadVec.y, deadVec.z))
	deadVec:Rotate(deadAng*8)
	table.insert(deadCircle, Vector(deadVec.x, deadVec.y, deadVec.z))
	deadVec:Rotate(deadAng)
	table.insert(deadCircle, Vector(deadVec.x, deadVec.y, deadVec.z))
	deadVec:Rotate(deadAng*8)
	table.insert(deadCircle, Vector(deadVec.x, deadVec.y, deadVec.z))
	deadVec:Rotate(deadAng*4)
	table.insert(deadCircle, Vector(deadVec.x, deadVec.y, deadVec.z))
	deadVec:Rotate(deadAng*8)
	table.insert(deadCircle, Vector(deadVec.x, deadVec.y, deadVec.z))
	deadVec:Rotate(deadAng*2)
	table.insert(deadCircle, Vector(deadVec.x, deadVec.y, deadVec.z))
	deadVec:Rotate(deadAng*8)
	table.insert(deadCircle, Vector(deadVec.x, deadVec.y, deadVec.z))
	deadVec:Rotate(deadAng*4)
	table.insert(deadCircle, Vector(deadVec.x, deadVec.y, deadVec.z))
	deadVec:Rotate(deadAng*8)
	table.insert(deadCircle, Vector(deadVec.x, deadVec.y, deadVec.z))
end

--(1-1) % 3 = 0 + 1 = 1
--(2-1) % 3 = 1 + 1 = 2
--(3-1) % 3 = 2 + 1 = 3
--(4-1) % 3 = 0 + 1 = 1
local function getDeadCirclePosition(index)
	local index0 = index - 1
	local circleIndex0 = index0 % #deadCircle
	local circleIndex = circleIndex0 + 1
	return deadCircle[circleIndex]
end

local function getCurrentDeadCirclePosition()
	getDeadCirclePosition(deadCircleIndex)
	deadCircleIndex = deadCircleIndex + 1
end

local function resetDeadCircleIndex()
	deadCircleIndex = 1
end

initDeadCircle()

--called by cpp
-- function gspeak.SetPlayerTeamspeakData(tsId, volume, talking)
-- 	--local ply = Entity(ent_id)
-- 	gspeak:FindPlayerByTsId(tsId)

-- 	if !gspeak:player_valid(ply) then 
-- 		gspeak.ConsoleWarning("set teamspeak data of invalid player " .. ent_id)
-- 		return
-- 	end

-- 	ply.volume = volume
-- 	ply.talking = talking
-- end

--removed!!!
--triggered by cpp in gs_sendPos & gs_delPos. Not sure why but seems to be used for 
--filtering which player mouths should be animated (immersion?)
-- function gspeak.setHearable(ent_id, bool)
-- 	gspeak.ConsoleLog("set hearable of " .. ent_id .. " to " .. tostring(bool))
-- 	local ply = Entity(ent_id)
-- 	--ent = Entity(ent_id)
-- 	--if !gspeak:validGspeakEntity(ent) then
-- 	if !gspeak:player_valid(ply) then 
-- 		gspeak.ConsoleWarning("set hearable of invalid player " .. ent_id)
-- 		return
-- 	end

-- 	--ent.gspeak.hearable = state
-- 	ply.hearable = bool
-- end

function gspeak:ts_talking( trigger )
	LocalPlayer():SetTalking(trigger)
	gspeak.cl.start_talking = trigger
	net.Start("ts_talking")
		net.WriteBool( trigger )
	net.SendToServer()
end

local function handleLocalPlayer()
	local ply = LocalPlayer()
	
	--ply.alive = gspeak:IsPlayerAlive(ply)

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

-- local function handlePlayer(ply)
-- 	local plyAlive = gspeak:IsPlayerAlive(ply)
-- 	if ply.alive != plyAlive then
-- 		--alive state changed => must have died recently
-- 		ply.alive = plyAlive
-- 		if !plyAlive then
-- 			ply.nextDeadSlot = getDeadSlot()
-- 		end
-- 	end

-- 	if !ply.ts_id or ply.ts_id == 0 then return end
-- 	local talkmode = gspeak:get_talkmode( ply )

-- 	local distance, distance_max, playerPos
-- 	if gspeak.settings.deadHearsDead and !LocalPlayer().alive and !ply.alive and !gspeak.cl.deadMuted then
-- 		distance = 100
-- 		distance_max = 1000
-- 		playerPos = deadCircle[ply.nextDeadSlot]
-- 	elseif ( LocalPlayer().alive or gspeak.settings.deadHearsAlive ) and ply.alive then
-- 		distance, playerPos = gspeak:get_distances(ply)
-- 		distance_max = gspeak:GetTalkmodeRange(talkmode)
-- 	else
-- 		return
-- 	end

-- 	if distance < distance_max then
-- 		gspeak.io:SetPlayer(ply.ts_id, gspeak:calcVolume( distance, distance_max ), ply:EntIndex(), playerPos, false)
-- 	end
-- end

function gspeak:GetAudioListenerPosition()
	return LocalPlayer():EyePos()
end

local function getEffect(ent, sourcePos, listenerPos)
	local effect = ent:VoiceEffect()

	if (LocalPlayer():WaterLevel() == 3 || ent:WaterLevel() == 3) then
		effect = VoiceEffect.Water
	end

	local tr = util.TraceLine({
		start = listenerPos,
		endpos = sourcePos,
		mask = MASK_NPCWORLDSTATIC,
	})
	if (tr.Hit) then
		effect = VoiceEffect.Wall
	end

	return effect
end

local function registerGspeakEntity(ent)
	gspeak:NoDoubleEntry(ent, gspeak.gspeakEntities)
	--table.insert(gspeak.gspeakEntities, ent)
end

local function unregisterGspeakEntity(ent)
	local toBeRemoved = {}

	for i, regEnt in ipairs(gspeak.gspeakEntities) do
		if !IsValid(regEnt) || regEnt == ent then
			table.insert(toBeRemoved, i)
		end
	end

	for i, index in ipairs(toBeRemoved) do
		table.remove(gspeak.gspeakEntities, index)
	end
end

function gspeak:IsGspeakEntity(ent)
	return ent != nil && IsValid(ent) && ent:IsGspeakEntity()
end

local deadIndex = 1

local function handleEntity(ent)
	if (!gspeak:IsGspeakEntity(ent)) then
		gspeak.ConsoleWarning(tostring(ent) .. " is no gspeak entity")
		unregisterGspeakEntity(ent)
		return
	end

	local entIndex = ent:EntIndex()

	--basic override by third party addons
	if (ent:IsPlayer() && gspeak.hearablePlayers[entIndex]) then
		--TODO (currently always true)
	end

	--handle dead players ...
	if (ent:IsPlayer() && !gspeak:IsPlayerAlive(ent)) then
		-- ... when dead
		if (gspeak.settings.deadHearsDead && !gspeak.cl.deadMuted && !gspeak:IsPlayerAlive(LocalPlayer())) then
			return true, gspeak.cl.settings.deadVolume, getCurrentDeadCirclePosition(), gspeak.voiceEffects.None
		-- ... when alive
		else
			return false
		end
	end

	--handle alive players when dead
	if (!gspeak.settings.deadHearsAlive && !gspeak:IsPlayerAlive(LocalPlayer())) then 
		return false 
	end

	local listenerWorldPos = gspeak:GetAudioListenerPosition()
	local maxDistance = ent:GetAudioSourceRange()
	local worldPos = ent:GetAudioSourcePosition()
	local localPos = worldPos - listenerWorldPos
	local distance = localPos:Length()
	local volume = 1.0
	if (maxDistance > 0.0) then
		volume = 1.0 - (distance / maxDistance)
	end
	local hearable = volume > 0.0

	if (!hearable) then
		return false
	end

	local effect = getEffect(ent, worldPos, listenerWorldPos)
	return true, volume, localPos, effect
end

net.Receive("player_hears_player", function(len)
	local entId = net.ReadInt(32)
	local state = net.ReadBool()
	local proximity = net.ReadBool()

	gspeak.ConsoleLog("hear player hook sends " .. tostring(entId) .. " " .. tostring(state) .. " "  .. tostring(proximity))

	gspeak.hearablePlayers[entId] = state
end)

hook.Add("EntityRemoved", "gspeak_entityRemoved", function(ent)
	unregisterGspeakEntity(ent)

	--reregister faulty on remove call
	--https://github.com/Facepunch/garrysmod-issues/issues/4675
	timer.Simple(0, function()
        if IsValid(ent) then
			registerGspeakEntity(ent)
        end
    end)
end)

hook.Add("OnEntityCreated", "gspeak_entityCreated", function(ent)
	if !gspeak:IsGspeakEntity(ent) then return end
	registerGspeakEntity(ent)
end)

local function scanAllEntities()
	for i, ent in ipairs(ents.GetAll()) do
		if !gspeak:IsGspeakEntity(ent) then continue end
		registerGspeakEntity(ent)
	end
end
scanAllEntities()

--hook.Add("PlayerSpawn", "gspeak_playerSpawn", playerSpawned)

-- local function handleHearableRadio(ent, playerIndex, radioIndex)
-- 	local radio_ent = Entity(radioIndex)

-- 	if !ent or !IsValid(ent) or !ent:IsRadio() or
-- 		!radio_ent or !IsValid(radio_ent) or !radio_ent:IsRadio() then
-- 		gspeak.io:RemovePlayer(playerIndex, true, radioIndex)
-- 		return
-- 	end

-- 	if !gspeak:IsPlayerAlive(LocalPlayer()) and !gspeak.settings.deadHearsAlive then
-- 		gspeak.io:RemovePlayer(playerIndex, true, radioIndex)
-- 		return
-- 	end

-- 	local distance = gspeak:get_distances(radio_ent)
-- 	local distance_max = radio_ent.range
-- 	if distance > distance_max then
-- 		gspeak.io:RemovePlayer(playerIndex, true, radioIndex)
-- 	end
-- end

-- local function handleHearablePlayer(ply, playerIndex)
-- 	if !ply or !IsValid(ply) or !ply:IsPlayer() then
-- 		gspeak.io:RemovePlayer(playerIndex, false)
-- 		return 
-- 	end

-- 	if ply.ts_id == 0 then
-- 		gspeak.io:RemovePlayer(playerIndex, false)
-- 		return
-- 	end

-- 	local localAlive = gspeak:IsPlayerAlive(LocalPlayer())

-- 	if gspeak:IsPlayerAlive(ply) then
-- 		if ( !localAlive and !gspeak.settings.deadHearsAlive ) then
-- 			gspeak.io:RemovePlayer(playerIndex, false)
-- 		else
-- 			local distance = gspeak:get_distances(ply)
-- 			local talkmode = gspeak:get_talkmode(ply);
-- 			local distance_max = gspeak:GetTalkmodeRange(talkmode)
-- 			if distance > distance_max then
-- 				gspeak.io:RemovePlayer(playerIndex, false)
-- 			end
-- 		end
-- 	else
-- 		if !gspeak.settings.deadHearsDead or localAlive or gspeak.cl.deadMuted then
-- 			gspeak.io:RemovePlayer(playerIndex, false)
-- 		end
-- 	end
-- end

-- function gspeak:get_offset(ply)
-- 	if !gspeak:IsPlayerAlive(ply) then return gspeak.cl.player.dead end
-- 	if ply:Crouching() then	return gspeak.cl.player.crouching end
-- 	if IsValid(ply:GetVehicle()) then return gspeak.cl.player.vehicle end
-- 	return gspeak.cl.player.standing
-- end

-- --TODO dont return length
-- function gspeak:get_distances( ent )
-- 	local ent_pos = ent:GetPos()
-- 	--TODO use EyePos()
-- 	if ent:IsPlayer() then ent_pos = ent_pos + gspeak:get_offset(ent)	end
-- 	--TODO use EyePos()
-- 	local pos = gspeak.clientPos or LocalPlayer():GetPos()
-- 	ent_pos:Sub(pos)
-- 	--ent_pos = ent_pos * Vector(1,1,1 / gspeak.settings.distances.heightclamp)
-- 	ent_pos.z = ent_pos.z * (1 / gspeak.settings.distances.heightclamp)
-- 	local distance = ent_pos:Length()

-- 	return distance, ent_pos
-- end

function gspeak:calcVolume( distance, distance_max )
	return 1 - distance / distance_max
end

function gspeak:ChangeTalkmode( talkmode )
	if talkmode <= #gspeak.settings.distances.modes then
		gspeak.cl.settings.talkmode = talkmode
	else
		gspeak.cl.settings.talkmode = 1
	end
	net.Start( "ts_talkmode" )
		net.WriteInt( gspeak.cl.settings.talkmode, 32 )
	net.SendToServer()
	
	gspeak:ChatPrint("mode: ", gspeak.cl.color.green, gspeak.settings.distances.modes[gspeak.cl.settings.talkmode].name)
	--gspeak:ChatPrint( " mode: ", gspeak.cl.color.green, gspeak.settings.distances.modes[gspeak.cl.settings.talkmode].name )
end

-- function gspeak:get_talkmode( ply )
-- 	if ply == LocalPlayer() then return gspeak.cl.settings.talkmode end
-- 	--if !ply:Alive() then return 2 end //Thendon make dead chat talkmode //i think i already did?
-- 	--return ply.talkmode
-- 	return ply:GetTalkmode()
-- 	--return gspeak.settings.def_mode
-- end

hook.Add("Think", "gspeak_volume_control", function()
	--TODO use EyePos()
	--gspeak.clientPos = GetAudioListenerPosition() --LocalPlayer():GetPos() + gspeak:get_offset(LocalPlayer())

	if !gspeak.cl.TS.inChannel then return end
	--Add player entitys to C++ Struct of hearable Players
	--gspeak.hearable = gspeak.io:GetHearables()
	handleLocalPlayer()

	local loudestHearableOfPlayer = {}

	resetDeadCircleIndex()

	for i, ent in ipairs(gspeak.gspeakEntities) do
		if (ent == LocalPlayer()) then continue end

		local isHearable, volume, pos, effect = handleEntity(ent)

		if (!isHearable) then continue end

		local speakers = ent:GetSpeakers()
		for i, ply in ipairs(speakers) do
			local loudestHearable = loudestHearableOfPlayer[ply]

			if (loudestHearable && loudestHearable.volume > volume) then continue end

			loudestHearableOfPlayer[ply] = { 
				volume = volume,
				pos = pos,
				effect = effect
			}
		end
	end

	for i, ply in ipairs(player.GetAll()) do
		local hearable = loudestHearableOfPlayer[ply]
		local isHearable = hearable != nil

		if !isHearable then
			if (ply.isHearable) then
				gspeak.io:RemoveHearable(ply:GetTsId())
			end
			continue
		end

		gspeak.io:SetHearable(ply:GetTsId(), hearable.volume, hearable.pos, hearable.effect)
	end

	-- for k, ply in pairs(gspeak.cl.players) do
	-- 	if !IsValid(ply) then
	-- 		table.remove(gspeak.cl.players, k)
	-- 		continue
	-- 	end
		
	-- 	if ply == LocalPlayer() then continue end

	-- 	handlePlayer(ply)
	-- end
	--Check C++ Struct if hearable player must be removed
	-- for k, v in pairs(gspeak.hearable) do
	-- 	local ent = Entity(v.ent_id)

	-- 	if (ent.radio) then
	-- 		handleHearableRadio(ent, v.ent_id, v.radio_id)
	-- 	else
	-- 		handleHearablePlayer(ent, v.ent_id)
	-- 	end
	-- end
end)

-- net.Receive("ts_ply_talking", function( len )
-- 	ply = net.ReadEntity()
-- 	ply.talking = net.ReadBool()
-- end)

-- net.Receive("ts_ply_talkmode", function ( len )
-- 	ply = net.ReadEntity()
-- 	ply.talkmode = net.ReadInt( 32 )
-- 	--ply.range = net.ReadInt( 32 )
-- end)