

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
		--gspeak.ConsoleWarning("debug code, uncomment me!")
		gspeak:set_tsid( tsId )
		connectionCooldown = now + 10
	end

	gspeak.cl.TS.inChannel = gspeak.io:IsInChannel()

	--if !gspeak.cl.TS.inChannel then return end

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
	LocalPlayer():SetTsId(ts_id)
end

function gspeak:request_init()
	net.Start("gspeak_request_init")
	net.SendToServer()
end

net.Receive("gspeak_failed_broadcast", function(len)
	local ply = net.ReadEntity()
	ply.failed = true
end)