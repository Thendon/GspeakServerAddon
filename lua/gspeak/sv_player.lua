//************************************************************//
//				Thirdparty Addon Support WIP
//************************************************************//
include("gspeak/sh_player.lua")

local meta = FindMetaTable("Player")

meta.hearablePlayers = {}

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

hook.Add("OnEntityCreated", "gspeak_onPlayerCreated", function(ent)
	if (!ent:IsPlayer()) then return end

	ent:SetNW2Int("TsId", 0)
    ent:SetNW2Bool("Talking", false)
    ent:SetNW2Int("Talkmode", 1)
end)