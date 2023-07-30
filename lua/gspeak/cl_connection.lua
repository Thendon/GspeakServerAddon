AddCSLuaFile()

local informedAboutFail = false

hook.Add("Think", "gspeak_connect", function()
	if gspeak.cl.failed then 
        if !informedAboutFail then
            informedAboutFail = true
            net.Start("gspeak_failed")
            net.SendToServer()
        end
        return 
    end

	local now = CurTime()
	gspeak.chill = gspeak.chill or now + 10
	if !gspeak.cl.running then
		if gspeak.chill > now then return end
		gspeak:request_init()
		gspeak.chill = now + 10
		return
	end

	gspeak.io:CheckConnection()
	if !gspeak.cl.TS.connected then return end

	local ts_id = gspeak.io:GetTsId()
	if ts_id != LocalPlayer().ts_id and gspeak.chill < now then
		gspeak:set_tsid( ts_id )
		gspeak.chill = now + 10
	end

	gspeak.cl.TS.inChannel = gspeak.io:IsInChannel()

	if !gspeak.cl.TS.inChannel then return end

	gspeak.io:Tick()
end

--pretty stupid solution, maybe not necessary
hook.Add("Think", "gspeak_update_playerlist", function()
	if !gspeak.cl.TS.inChannel then return end

    if gspeak.chill < now then
        gspeak:UpdatePlayers()
        gspeak.chill = now + 10
    end
end

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
-- 		--net.WriteInt( ts_id, 32 )
-- 	net.SendToServer()
-- end

net.Receive("ts_ply_id", function( len )
	local ply = net.ReadEntity()
	if (ply.ts_id) then gspeak.io:RemovePlayer(ply:EntIndex(), false, -1) end
	ply.ts_id = net.ReadInt( 32 )
end)

net.Receive("gspeak_ply_disc", function ( len )
	index = net.ReadInt(32)
	if gspeak.cl.TS.connected then gspeak.io:RemovePlayer(index, false, -1) end
end)

net.Receive("gspeak_failed_broadcast", function(len)
	local ply = net.ReadEntity()
	ply.failed = true
end)