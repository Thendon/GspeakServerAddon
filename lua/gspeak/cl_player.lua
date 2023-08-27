include("gspeak/sh_player.lua")

local meta = FindMetaTable("Player")
meta.hearable = false --if hearable by localplayer
meta.volume = 0.0 --teamspeak volume
meta.failed = false --gspeak initialization failed Todo: Refactor 

function meta:GetAudioSourceRange()
	print(tostring(self) .. " " .. self:GetTalkmode() .. " " .. gspeak:GetTalkmodeRange(self:GetTalkmode()))
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
	return { self };
end

function meta:GetTeamspeakName()
	local result = hook.Run("Gspeak.OverridePlayerName", self)
	if result != nil then
		return result
	end

	if gspeak.settings.nickname then return self:Nick() end
	return self:GetName()
end

--override this only for local player which results in faster visuals for near players 
function meta:SetTalking(talking)
	self:SetNW2Bool("Talking", talking)
end

function gspeak:IsPlayerAlive(ply)
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

hook.Add("EntityNetworkedVarChanged", "gspeak_playerNetworkVarChanged", function(ent, name, prev, now)
	if (name != "TsId") then return end

	gspeak.io:RemoveHearable(prev)
	--gspeak.io:RemoveHearable(now)
end)

hook.Add("EntityRemoved", "gspeak_playerDisconnected", function(ent)
	if (!ent:IsPlayer()) then return end

	gspeak.io:RemoveHearable(ent:GetTsId())
end)

--stupid solution should be easier
-- function gspeak:UpdatePlayers()
-- 	for k, v in pairs(player.GetAll()) do
-- 		if !v:IsPlayer() then continue end
-- 		gspeak:NoDoubleEntry( v, gspeak.cl.players)
-- 	end
-- end

--pretty stupid solution, maybe not necessary
-- hook.Add("Think", "gspeak_update_playerlist", function()
-- 	if !gspeak.cl.TS.inChannel then return end

-- 	local now = CurTime()
--     if updatePlayerCooldown > now then return end

-- 	gspeak:UpdatePlayers()
-- 	updatePlayerCooldown = now + 10
-- end)

-- net.Receive("gspeak_name_change", function( len )
-- 	local name = net.ReadString()
-- 	if gspeak.cl.TS.connected then gspeak.io:SendName(name) end
-- end)