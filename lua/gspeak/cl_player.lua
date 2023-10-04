include("gspeak/sh_player.lua")

local meta = FindMetaTable("Player")

function meta:InitializeGspeak()
	self.isHearable = false --if hearable by localplayer
	self.volume = 0.0 --teamspeak volume
	self.failed = false --gspeak initialization failed Todo: Refactor 
	self.isTalking = false --additional early clientside talking detection

	if (self != LocalPlayer()) then
		self:SetNW2VarProxy("TsId", function(ent, key, prev, now) 
			if (prev == nil) then return end
			gspeak:RemovePlayer(ent)
		end)
	end

	self:SetNW2VarProxy("Talking", function(ent, key, prev, now)
		ent:SetTalking(now)
	end)
end

function meta:GetAudioSourceRange()
	return gspeak:GetTalkmodeRange(self:GetTalkmode())
end

function meta:GetAudioSourcePosition()
	return self:EyePos()
end

function meta:IsGspeakEntity()
	return true
end

function meta:VoiceEffect()
	return gspeak.voiceEffects.None
end

function meta:GetSpeakers()
	return { self }
end

function meta:GetTeamspeakName()
	local result = hook.Run("Gspeak.OverridePlayerName", self)
	if result != nil then
		return result
	end

	if gspeak.settings.nickname then return self:Nick() end
	return self:GetName()
end

function gspeak:IsPlayerAlive(ply)
	local result = hook.Run("Gspeak.OverridePlayerAlive", ply)
	if result != nil then
		return result
	end

	if !ply:Alive() then return false end

	if GAMEMODE_NAME == "terrortown" then
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

hook.Add("EntityRemoved", "gspeak_playerDisconnected", function(ent)
	if (!ent:IsPlayer()) then return end
	if (ent == LocalPlayer()) then return end

	gspeak:RemovePlayer(ent)
end)

hook.Add("OnEntityCreated", "gspeak_playerCreated", function (ent)
	if (!ent:IsPlayer()) then return end
	
	ent:InitializeGspeak()
end)

-- local chill = 0
-- local chillMax = 0

-- hook.Add("Think", "gspeak_playerPVSthink", function()
-- 	chill = chill + 1
-- 	if (chill < chillMax) then return end
-- 	chill = 0
	
-- 	for i, ply in ipairs(player.GetAll()) do
-- 		local tsid = ply:GetTsId()
-- 		local talking = ply:IsTalking()
-- 		local talkmode = ply:GetTalkmode()

-- 		--print(tostring(ply:EntIndex()) .. " " .. tostring(tsid) .. " " .. tostring(talking) .. " " .. tostring(talkmode))
-- 	end
-- 	--print()
-- end)

-- net.Receive("gspeak_name_change", function( len )
-- 	local name = net.ReadString()
-- 	if gspeak.cl.TS.connected then gspeak.io:SendName(name) end
-- end)