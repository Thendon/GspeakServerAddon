//************************************************************//
//				Thirdparty Addon Support WIP
//************************************************************//
include("gspeak/sh_player.lua")

local meta = FindMetaTable("Player")
local overrideProximityVoice = false

function meta:InitializeGspeak()
	if (overrideProximityVoice) then
		self.hearablePlayers = {}
	end

	self:SetNW2Int("TsId", 0)
    self:SetNW2Bool("Talking", false)
    self:SetNW2Int("Talkmode", 1)
	self:SetNW2Bool("Muted", false)
	self:SetNW2Bool("SpeechMode", false)
end

function meta:SetHearPlayer(ply, state, proximity)
	if (self.hearablePlayers[ply] == nil) then
		self.hearablePlayers[ply] = {
			state = false,
			proximity = false
		}
	end

	if (self.hearablePlayers[ply].state != state || self.hearablePlayers[ply].proximity != proximity) then
		net.Start("player_hears_player")
			net.WriteInt(ply:EntIndex(), 32)
			net.WriteBool(state)
			net.WriteBool(proximity)
			--net.WriteInt(effect)
			--net.WriteFloat(volume)
		net.Send(self)
		self.hearablePlayers[ply].state = state
		self.hearablePlayers[ply].proximity = proximity
	end
end

function meta:RemoveHearablePlayer(ply)
	self.hearablePlayers[ply] = nil
end

hook.Add("OnEntityCreated", "gspeak_onPlayerCreated", function(ent)
	if (!overrideProximityVoice) then return end
	if (!ent:IsPlayer()) then return end

	ent:InitializeGspeak()
end)

hook.Add("EntityRemoved", "gspeak_onPlayerRemoved", function(ent)
	if (!overrideProximityVoice) then return end
	if (!ent:IsPlayer()) then return end

	for i, ply in ipairs(player.GetAll()) do
		ply:RemoveHearablePlayer(ent)
	end
end)

hook.Add("OnGamemodeLoaded", "gspeak_checkOverrideProximity", function()
	overrideProximityVoice = hook.Call("Gspeak.OverrideProximity")

	if (!overrideProximityVoice) then return end

	--not realy working as predicted:
	-- * is called each frame
	-- * by default returns always (true, false)
	hook.Add( "Think", "gspeak_canHearPlayersVoiceCheck", function()
		for i, listener in ipairs(player.GetAll()) do
			for i, talker in ipairs(player.GetAll()) do
				if (talker == listener) then
					continue 
				end

				local listenerHearsTalker, proximity = hook.Run("PlayerCanHearPlayersVoice", listener, talker)
				if (listenerHearsTalker == nil) then
					return
				end

				listener:SetHearPlayer(talker, listenerHearsTalker, proximity)
			end
		end
	end)
end)