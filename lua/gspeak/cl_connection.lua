

local informedAboutFail = false

local connectionCooldown = 0
local updatePlayerCooldown = 0

hook.Add("Think", "gspeak_connect", function()
	if gspeak.cl.failed then 
        if informedAboutFail then return end
		informedAboutFail = true
		net.Start("gspeak_failed")
		net.SendToServer()
        return 
    end

	local now = CurTime()
	
	if !gspeak.cl.running then
		if connectionCooldown > now then return end
		gspeak:request_init()
		connectionCooldown = now + 10
		return
	end

	gspeak.io:CheckConnection()
	if !gspeak.cl.TS.connected then return end

	local tsId = gspeak.io:GetTsId()
	if tsId != LocalPlayer():GetTsId() and connectionCooldown < now then
		gspeak:set_tsid( tsId )
		connectionCooldown = now + 10
	end

	gspeak.cl.TS.inChannel = gspeak.io:IsInChannel()

	if !gspeak.cl.TS.inChannel then return end

	for i, ply in ipairs(player.GetAll()) do
		local tsId = ply:GetTsId()
		if (tsId == 0) then continue end
		local success, volume, talking = gspeak.io:GetHearableData(tsId)
		if (!success) then continue end
		ply.volume = volume
		ply:SetTalking(talking)
	end

	-- gspeak.io:Tick()
end)

gameevent.Listen( "client_disconnect" )
hook.Add( "client_disconnect", "gpseak_disconnect", function( data )
	local message = data.message	// The reason of the 

	// Called when the client is disconnecting from the server.
	gspeak.ConsoleLog("disconnect hook " .. message)

	gspeak.io:Disconnect()
end )

function gspeak:set_tsid( ts_id )
	-- if ts_id == 0 then
	-- 	gspeak.cl.TS.connected = false
	-- end
	net.Start("ts_id")
		net.WriteInt(ts_id, 32)
	net.SendToServer()
end

function gspeak:request_init()
	net.Start("gspeak_request_init")
	net.SendToServer()
end

-- function gspeak:get_tsid(ply)
-- 	ply.req_it = ply.req_it or 1
-- 	if ply.ts_id == 0 then ply.req_it = ply.req_it + 1 end
-- 	if ply.req_it > 1000 then
-- 		gspeak:request_ts_id( ply )
-- 		ply.req_it = 1
-- 	end
-- 	return ply.ts_id
-- end

-- function gspeak:request_ts_id( ply )
-- 	net.Start("request_ts_id")
-- 		net.WriteEntity( ply )
-- 	net.SendToServer()
-- end

-- net.Receive("ts_ply_id", function( len )
-- 	local ply = net.ReadEntity()
-- 	--TODO should be reimplemented
-- 	--if (ply.ts_id) then gspeak.io:RemovePlayer(ply:EntIndex(), false, -1) end
-- 	ply.ts_id = net.ReadInt( 32 )
-- end)

-- net.Receive("gspeak_ply_disc", function ( len )
-- 	index = net.ReadInt(32)
-- 	if gspeak.cl.TS.connected then gspeak.io:RemovePlayer(index, false, -1) end
-- end)

-- hook.Add("EntityRemoved", "gspeak_entity_removed", function( ent )
-- 	if !gspeak.cl.TS.connected then return end

-- 	--if !gspeak:IsGspeakEntity() then return end
-- 	if !ent:IsPlayer() then return end

-- 	gspeak.io:RemovePlayer(ent:EntIndex(), false, -1)
-- end)

-- hook.Add("OnEntityCreated", "gspeak_entity_created", function( ent ))
-- 	--if !gspeak:IsGspeakEntity() then return end
-- 	if !ent:IsPlayer() then return end

-- 	request_ts_id( ent )
-- end)

net.Receive("gspeak_failed_broadcast", function(len)
	local ply = net.ReadEntity()
	ply.failed = true
end)