
local handler = {}

function handler:LoadTslib()
    if pcall( require, "tslib" ) then
        if pcall( function() tslib.getVersion() end) then
            gspeak.cl.tslib.version = tslib.getVersion()
            MsgC( gspeak.cl.color.red, "TSlib included - ", gspeak.cl.color.white, "Version ", tostring(gspeak.cl.tslib.version), "\n")
            if gspeak.cl.tslib.version >= gspeak.cl.tslib.req and gspeak.cl.tslib.version < gspeak.cl.tslib.max then
                gspeak.cl.running = true
                gspeak:set_tsid(-1) --loading mode
                return
            else
                gspeak.cl.tslib.wrongVersion = true
                MsgC( gspeak.cl.color.red, "TSlib Wrong Version! - ", gspeak.cl.color.white, "Version ", tostring(gspeak.cl.tslib.version), "\n")
            end
        else
            gspeak.cl.tslib.wrongVersion = true
            MsgC( gspeak.cl.color.red, "TSlib - ", gspeak.cl.color.white, "No Version function!\n")
        end
    else
        MsgC( gspeak.cl.color.red, "TSlib - ", gspeak.cl.color.white, "No TSlib DLL found / require failed!\n")
    end
	gspeak.cl.failed = true
end

function handler:SendSettings()
	if !tslib.sendSettings(	gspeak.settings.password,
							gspeak.settings.radio.down,
							gspeak.settings.radio.dist,
							gspeak.settings.radio.volume,
							gspeak.settings.radio.noise ) then gspeak:chat_text("channel Password too long!", true) end
end

--Tries to move the User into the channel until succeeds
local function forceMoveLoop()
	tslib.forceMove( function( success )
		gspeak:ConsolePrint("force move callback " .. tostring(success))
		if !success then
			forceMoveLoop()
		end
	end)
end

local updateNameInProgress
function handler:UpdateName( name )
	if updateNameInProgress then return end
	updateNameInProgress = true
	tslib.sendName( name, function( success )
		if success then
			gspeak:chat_text("changed Teamspeak nickname to " .. name)
		else
			gspeak:chat_text("failed to update nickname (" .. name .. ")", true)
		end
		updateNameInProgress = false
	end )
end

function handler:CheckConnection()
	if gspeak.cl.TS.connected then
		gspeak.cl.updateTick = gspeak.cl.updateTick + 1
		--update every 100th tick
		if gspeak.cl.updateTick > 100 then
			gspeak.cl.updateTick = 0
			tslib.update() --causing lua underflow error in beta version
		end

		if gspeak.settings.def_initialForceMove and !gspeak.cl.movedInitially then
			gspeak.cl.movedInitially = true
			forceMoveLoop()
		end

		if gspeak.settings.updateName then
			local name = gspeak:GetName( LocalPlayer() )
			--compareName( string ) compares the users teamspeak name with the string
			--with Teamspeaks name buffer-limits in mind
			if !tslib.compareName( name ) then
				gspeak:updateName( name )
			end
		end

		gspeak.cl.TS.version = tslib.getGspeakVersion()

		 --closed Teamspeak3
		if gspeak.cl.TS.version == -1 then
			gspeak.cl.TS.connected = false
			gspeak.cl.movedInitially = false
		end
		return
	elseif tslib.connectTS() == true then
		if !IsValid(LocalPlayer()) then return end
		gspeak.cl.TS.version = tslib.getGspeakVersion()
		if gspeak.cl.TS.version == -1 or gspeak.cl.TS.version == 0 then return end
		if gspeak.cl.TS.version < gspeak.cl.TS.req or gspeak.cl.TS.version > gspeak.cl.TS.max then gspeak.cl.TS.failed = true return end

		net.Start( "ts_talkmode" )
			net.WriteInt( gspeak.cl.settings.talkmode, 32 )
		net.SendToServer()

		tslib.delAll()
		tslib.sendClientPos( 0, 0, 0, 0, 0, 0)
		--gspeak:send_settings()
		gspeak.io:SendSettings()

		gspeak.cl.TS.failed = false
		gspeak.cl.TS.connected = true
	end
end

function handler:SendName(name)
    tslib.sendName( name, function( success )
        gspeak:ConsolePrint( "name change " .. (success and "successfull" or "failed" ))
    end )
end

function handler:RemovePlayer(playerIndex, isEntity, entityIndex)
    tslib.delPos(playerIndex, isEntity, entityIndex)
end

function handler:SetPlayer(tsId, volume, playerIndex, pos, isEntity, entityIndex)
    tslib.sendPos(tsId, volume, playerIndex, pos.x, pos.y, pos.z, isEntity, entityIndex)
end

function handler:SetLocalPlayer(foward, up)
    tslib.sendClientPos(foward.x, foward.y, foward.z, up.x, up.y, up.z)
end

function handler:IsTalking()
    return tslib.talkCheck()
end

//************************************************************//
//							DEBUGGING
//************************************************************//

local last_load_a = 0

local function gspeak_array_create_list( DList )
	if last_load_a > CurTime() - 1 then return end
	last_load_a = CurTime()
	DList:Clear()
	--local players_hearable = tslib.getAllID()
	for k, v in pairs(tslib.getArray()) do
		DList:AddLine( tonumber(k), v )
	end
	DList:SortByColumn( 1 )
end

concommand.Add("gspeakarray", function()
	if gspeak.array == nil or gspeak.array == false then
		Gspeak_array_list = vgui.Create( "DListView" )
		Gspeak_array_list:SetSize( 100, 1050 )
		Gspeak_array_list:SetPos( 1820, 0 )
		Gspeak_array_list:AddColumn( "It" ):SetFixedWidth( 25 )
		Gspeak_array_list:AddColumn( "clientID" ):SetFixedWidth( 75 )
		Gspeak_array_list:SetSortable( false )
		Gspeak_array_list.Think = gspeak_array_create_list
		gspeak.array = true
	else
		Gspeak_array_list:Remove()
		gspeak.array = false
	end
end)

return handler