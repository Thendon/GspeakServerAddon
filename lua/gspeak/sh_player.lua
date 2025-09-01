local meta = FindMetaTable("Player")

function meta:IsGspeakEntity()
	return true
end

function meta:IsTalking()
	if (self:IsMuted()) then return false end

	if CLIENT then 
		if (self == LocalPlayer()) then return self.isTalking end
		if (self.isHearable) then return self.isTalking end
	end
	return self:GetNW2Bool("Talking")
end

function meta:GetTalkmode()
	return self:GetNW2Int("Talkmode")
end

function meta:GetTsId()
	return self:GetNW2Int("TsId")
end

function meta:IsHoldingSpeech()
	return self:GetNW2Bool("SpeechMode")
end

function meta:IsMuted()
	return self:GetNW2Bool("Muted")
end

function meta:SetTalking(talking)
	if CLIENT then
		self.isTalking = talking
		if (self == LocalPlayer()) then
			net.Start("ts_talking")
				net.WriteBool( talking )
			net.SendToServer()
		end
		return
	end
	self:SetNW2Bool("Talking", talking)
end

function meta:SetTalkmode(talkmode)
	if CLIENT then
		if self != LocalPlayer() then return end
		net.Start( "ts_talkmode" )
			net.WriteInt( talkmode, 32 )
		net.SendToServer()
		return 
	end
	self:SetNW2Int("Talkmode", talkmode)
end

function meta:SetTsId(tsId)
	if CLIENT then
		if self != LocalPlayer() then return end
		net.Start( "ts_id" )
			net.WriteInt( tsId, 32 )
		net.SendToServer()
		return 
	end
	gspeak.ConsoleLog("assign " .. tostring(self) .. " teamspeak clientId " .. tostring(tsId))
	self:SetNW2Int("TsId", tsId)
end

if SERVER then
	function meta:StartSpeech(state)
		self:SetNW2Bool("SpeechMode", true)
	end
	
	function meta:StopSpeech(state)
		self:SetNW2Bool("SpeechMode", false )
	end
	
	function meta:Mute()
		self:SetNW2Bool("Muted", true )
	end
	
	function meta:Unmute()
		self:SetNW2Bool("Muted", false )
	end
	
	function meta:KickTs()
		net.Start("ts_kick")
		net.Send(self);
	end

	net.Receive("ts_id", function( len, ply )
		ply:SetTsId(net.ReadInt( 32 ))
	end)
	
	net.Receive("ts_talking", function( len, ply )
		ply:SetTalking(net.ReadBool())
	end)
	
	net.Receive("ts_talkmode", function ( len, ply )
		ply:SetTalkmode(net.ReadInt(32))
	end)
end

if CLIENT then
	net.Receive("ts_kick", function(len)
		gspeak.io:Kick()
	end)

	function meta:Join()
		gspeak.io:Join()
	end
end