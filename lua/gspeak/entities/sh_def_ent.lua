ENT.GspeakEntity = true
ENT.Radio = true

function ENT:VoiceEffect()
	return gspeak.voiceEffects.Radio
end

function ENT:GetAudioSourceRange()
	return self.range
end

function ENT:GetAudioSourcePosition()
	return self:GetPos()
end

function ENT:DefaultInitialize()
	self.connected_radios = {}
	self.settings = { 
		trigger_at_talk = false, 
		start_com = gspeak.settings.radio_start, 
		end_com = gspeak.settings.radio_stop 
	}

	if CLIENT then
		gspeak:RegisterGspeakEntity(self)
	end
end

function ENT:GetSpeakers()
	local speakers = {}

	for k, radio_id in pairs(self.connected_radios) do
		local ent = Entity(radio_id)
		if !IsValid(ent) then 
			self:RemoveId(radio_id, k)
			continue 
		end

		local ply = ent:GetSpeaker()
		if !IsValid(ply) then 
			self:RemoveId(radio_id, k)
			continue 
		end

		table.insert(speakers, ply)
	end

	return speakers
end

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "Freq" )
	self:NetworkVar( "Int", 1, "Range" )
	self:NetworkVar( "Bool", 0, "Sending" )
	self:NetworkVar( "Bool", 1, "Online" )
	self:NetworkVar( "Bool", 2, "Hearable" )
	self:NetworkVar( "Bool", 3, "Radio" )
	self:NetworkVar( "Entity", 0, "Speaker" )
end

function ENT:OnRemove()
	local connectedRadios = self.connected_radios
	local entIndex = self:EntIndex()

	timer.Simple( 0, function()
		if IsValid( self ) then return end
		
		for k, radio_id in pairs(connectedRadios) do
			local ent = Entity(radio_id)
			if !IsValid(ent) then continue end
			ent:RemoveRadio( entIndex )
		end
	end)
end

function ENT:CheckTalking()
	if !self.settings.trigger_at_talk then return end
	for k, v in next, self.connected_radios do
		if gspeak:radio_valid(Entity(v)) then
			local speaker = Entity(v):GetSpeaker()
			if gspeak:player_valid(speaker) then
				self:TriggerCom( speaker:IsTalking() )
			end
		end
	end
end

function ENT:TriggerCom( trigger )
	if trigger and !self.trigger_com then
		self.trigger_com = true
		self:EmitSound(self.settings.start_com)
	elseif !trigger and self.trigger_com then
		self.trigger_com = false
		self:EmitSound(self.settings.end_com)
	end
end

function ENT:RemoveRadio( radio_id )
	for k, v in pairs(self.connected_radios) do
		if v == radio_id then
			self:RemoveID( radio_id, k )
			return
		end
	 end
end

function ENT:RemoveID( radio_id, id )
	-- if gspeak.cl.TS.connected then
	-- 	gspeak.io:RemovePlayer( radio_id, true, self:EntIndex() )
	-- end

	self:TriggerCom( false )

	table.remove(self.connected_radios, id)
	--self:UpdateUI()
end

function ENT:AddRadio( radio_id )
	if radio_id == self:EntIndex() then	return end
	for k, v in pairs(self.connected_radios) do
		if v == radio_id then	return end
	end

	if !self.settings.trigger_at_talk and self.trigger then self:TriggerCom( true ) end

	table.insert(self.connected_radios, radio_id)
	--self:UpdateUI()
end

function ENT:Rescan(own_freq, own_online, own_sending)
	self.freq = own_freq
	self.online = own_online
	self.sending = own_sending
	local radio_id = self:EntIndex()

	for k, v in pairs( gspeak.cl.radios ) do
		if !gspeak:radio_valid(v) then
			table.remove(gspeak.cl.radios, k)
			continue
		end

		local v_id = v:EntIndex()
		local v_freq = v:GetFreq()

		if radio_id == v_id then continue end
	
		if self.online and v:GetOnline() and self.freq == v_freq then
			if v:GetSending() then
				self:AddRadio(v_id)
			else
				self:RemoveRadio(v_id)
			end
			if self.sending then
				v:AddRadio(radio_id)
			else
				v:RemoveRadio(radio_id)
			end
		else
			self:RemoveRadio(v_id)
			v:RemoveRadio(radio_id)
		end
	end
end

if SERVER then
	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end
end

function ENT:checkTime(diff)
	local now = CurTime()
	self.last_try = self.last_try or 0
	if self.last_try < now - diff then
		self.last_try = now
		return true
	end
	return false
end

--obsolete
-- function ENT:AddHearables( pos, volume )
-- 	for k, v in next, self.connected_radios do
-- 		local remove_v = false
-- 		if gspeak:radio_valid(Entity(v)) then
-- 			local speaker = Entity(v):GetSpeaker()
-- 			if gspeak:player_valid(speaker) and gspeak:IsPlayerAlive(speaker) then
-- 				if gspeak.cl.TS.connected and speaker != LocalPlayer() and speaker:GetTsId() != 0 then
-- 					gspeak.io:SetPlayer(speaker:GetTsId(), volume, v, pos, true, self:EntIndex())
-- 				end
-- 				continue
-- 			end
-- 		end

-- 		self:RemoveID( v, k )
-- 	end
-- end
