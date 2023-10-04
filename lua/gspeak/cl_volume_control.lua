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

local function handleLocalPlayer()
	local ply = LocalPlayer()
	
	--ply.alive = gspeak:IsPlayerAlive(ply)

	local playerFor = ply:GetForward()
	local playerUp = ply:GetUp()
	gspeak.io:SetLocalPlayer(playerFor, playerUp)
	
	local talking = gspeak.io:IsTalking()
	if (talking != ply:IsTalking()) then
		LocalPlayer():SetTalking(talking)
	end
end

local function handlePlayer(ply)
	local tsId = ply:GetTsId()
	if (tsId == 0) then return end
	local success, volume, talking = gspeak.io:GetHearableData(tsId)
	if (!success) then return end
	ply.volume = volume
	ply:SetTalking(talking)
end

function gspeak:GetAudioListenerPosition()
	return LocalPlayer():EyePos()
end

local function getEffect(ent, sourcePos, listenerPos)
	local effect = ent:VoiceEffect()

	if (LocalPlayer():WaterLevel() == 3 || ent:WaterLevel() == 3) then
		effect = gspeak.voiceEffects.Water
	end

	local tr = util.TraceLine({
		start = listenerPos,
		endpos = sourcePos,
		mask = MASK_NPCWORLDSTATIC,
	})
	if (tr.Hit) then
		effect = gspeak.voiceEffects.Wall
	end

	return effect
end

local function registerGspeakEntity(ent)
	gspeak:NoDoubleEntry(ent, gspeak.gspeakEntities)
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

function gspeak:GetEntityDebugInfo(ent)
	return handleEntity(ent)
end

net.Receive("player_hears_player", function(len)
	local entId = net.ReadInt(32)
	local state = net.ReadBool()
	local proximity = net.ReadBool()

	gspeak.ConsoleLog("hear player hook sends " .. tostring(entId) .. " " .. tostring(state) .. " "  .. tostring(proximity))

	gspeak.hearablePlayers[entId] = state
end)

hook.Add("EntityRemoved", "gspeak_entityRemoved", function(ent)
	if !gspeak:IsGspeakEntity(ent) then return end
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

function gspeak:calcVolume( distance, distance_max )
	return 1 - distance / distance_max
end

function gspeak:ChangeTalkmode( talkmode )
	if talkmode <= #gspeak.settings.distances.modes then
		gspeak.cl.settings.talkmode = talkmode
	else
		gspeak.cl.settings.talkmode = 1
	end
	LocalPlayer():SetTalkmode(talkmode)
	
	gspeak:ChatPrint("mode: ", gspeak.cl.color.green, gspeak.settings.distances.modes[gspeak.cl.settings.talkmode].name)
end

function gspeak:RemovePlayer(ply)
	local tsid = ply:GetTsId()
	print("remove player " .. tostring(ply) .. " " .. tsid .. " " .. tostring(ply.isHearable))

	if (tsid == nil) then return end

	ply.isHearable = false 

	if (!gspeak.io:RemoveHearable(tsid)) then
		gspeak.ConsoleError("failed to remove hearable player " .. tostring(ply) .. " " .. tsid)
		return
	end
end

hook.Add("Think", "gspeak_volume_control", function()
	--TODO use EyePos()
	--gspeak.clientPos = GetAudioListenerPosition() --LocalPlayer():GetPos() + gspeak:get_offset(LocalPlayer())

	if !gspeak.cl.TS.inChannel then return end

	handleLocalPlayer()

	local loudestHearableOfPlayer = {}

	resetDeadCircleIndex()

	for i, ent in ipairs(gspeak.gspeakEntities) do
		if (ent == LocalPlayer()) then continue end

		local isHearable, volume, pos, effect = handleEntity(ent)

		if (!isHearable) then continue end

		local speakers = ent:GetSpeakers()
		for i, ply in ipairs(speakers) do
			if (ply == LocalPlayer()) then continue end

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
		if (ply == LocalPlayer()) then continue end

		handlePlayer(ply)

		local hearable = loudestHearableOfPlayer[ply]
		local isHearable = hearable != nil

		if !isHearable then
			if (ply.isHearable) then
				gspeak:RemovePlayer(ply)
			end
			continue
		end
		
		if (!gspeak.io:SetHearable(ply:GetTsId(), hearable.volume, hearable.pos, hearable.effect)) then
			gspeak.ConsoleError("failed to set player hearable " .. tostring(ply))
			continue
		end
		
		ply.isHearable = true
	end
end)