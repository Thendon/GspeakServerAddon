

local handler = {}

local updateCooldown = 0
local initialAutoMoveDone = false

function handler:LoadTslib()
    if pcall( require, "tslib" ) then
        if pcall( function() tslib.getVersion() end) then
            gspeak.cl.tslib.version = tslib.getVersion()
            MsgC( gspeak.cl.color.red, "TSlib included - ", gspeak.cl.color.white, "Version ", tostring(gspeak.cl.tslib.version), "\n")
            if gspeak.cl.tslib.version >= gspeak.cl.tslib.req and gspeak.cl.tslib.version < gspeak.cl.tslib.max then
                gspeak.cl.running = true
                gspeak:set_tsid(0) --loading mode
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
	tslib.sendSettings(	gspeak.settings.radio.down,
						gspeak.settings.radio.dist,
						gspeak.settings.radio.volume,
						gspeak.settings.radio.noise )
end

--Tries to move the User into the channel until succeeds
local function forceMoveLoop()
	local success = tslib.forceMove( function( success )
		if success then
			gspeak.ConsoleSuccess("moved client into channel")
			return
		end
		forceMoveLoop()
	end, gspeak.settings.password, gspeak.settings.channelName)

	if (!success) then
		gspeak.ConsoleError("force move failed")
	end
end

--unused (could be triggered by admin or map change?)
local function forceKickLoop()
	tslib.forceKick( function(success)
		if success then
			gspeak.ConsoleSuccess("kicked client from channel")
			return
		end
		forceKickLoop()		
	end)
end

local updateNameInProgress
function handler:UpdateName( name )
	if updateNameInProgress then return end
	updateNameInProgress = true
	tslib.sendName( name, function( success )
		if success then
			gspeak:ChatLog("changed Teamspeak nickname to " .. name)
		else
			gspeak:ChatError("failed to update nickname (" .. name .. ")")
		end
		updateNameInProgress = false
	end )
end

function handler:CheckConnection()
	if gspeak.cl.TS.connected then
		updateCooldown = updateCooldown + 1
		--update every 100th tick
		if updateCooldown > 100 then
			updateCooldown = 0
			tslib.update()
		end

		if gspeak.settings.def_initialForceMove and !initialAutoMoveDone then
			gspeak.ConsoleLog("try move client into channel")
			initialAutoMoveDone = true
			forceMoveLoop()
		end

		if gspeak.settings.updateName then
			local name = LocalPlayer():GetTeamspeakName()
			--compareName( string ) compares the users teamspeak name with the string
			--with Teamspeaks name buffer-limits in mind
			if !tslib.compareName( name ) then
				self:UpdateName( name )
			end
		end

		gspeak.cl.TS.version = tslib.getGspeakVersion()

		 --lost connection to Teamspeak3
		if gspeak.cl.TS.version == 0 then
			gspeak.cl.TS.connected = false
			initialAutoMoveDone = false
			gspeak:set_tsid( 0 )
		end
	elseif tslib.connectTS() == true then
		if !IsValid(LocalPlayer()) then return end
		gspeak.cl.TS.version = tslib.getGspeakVersion()
		if gspeak.cl.TS.version == 0 then return end
		if gspeak.cl.TS.version < gspeak.cl.TS.req or gspeak.cl.TS.version > gspeak.cl.TS.max then gspeak.cl.TS.failed = true return end

		net.Start( "ts_talkmode" )
			net.WriteInt( gspeak.cl.settings.talkmode, 32 )
		net.SendToServer()

		tslib.delAll()
		tslib.sendClientPos( 0, 0, 0, 0, 0, 0)
		gspeak.io:SendSettings()

		gspeak.cl.TS.failed = false
		gspeak.cl.TS.connected = true
	end
end

function handler:Disconnect()
	if gspeak.cl.TS.connected then
		return
	end

	tslib.discoTS()
end

function handler:SendName(name)
    tslib.sendName( name, function( success )
        gspeak.ConsolePrint( "name change " .. (success and "successfull" or "failed" ))
    end )
end

-- function handler:RemovePlayer(playerIndex, isEntity, entityIndex)
-- 	tslib.delPos(playerIndex, isEntity, entityIndex)
-- end

-- function handler:SetPlayer(tsId, volume, playerEntIndex, pos, isEntity, entityIndex)
-- 	tslib.sendPos(tsId, volume, playerEntIndex, pos.x, pos.y, pos.z, isEntity, entityIndex)
-- end

--DREAM VERSION

-- function handler:SetPlayer(tsId, volume, playerEntIndex, pos, isRadio, entityIndex)
-- 	tslib.sendPos(tsId, volume, playerEntIndex, pos.x, pos.y, pos.z, isRadio, entityIndex)
-- end

-- function handler:RemovePlayer(playerIndex, isEntity, entityIndex)
--     tslib.delPos(playerIndex, isEntity, entityIndex)
-- end

function handler:SetHearable(tsId, volume, pos, effect)
	tslib.sendPlayer(tsId, volume, pos.x, pos.y, pos.z, effect)
end

function handler:RemoveHearable(tsId)
	tslib.removePlayer(tsId)
end

function handler:GetHearableData(tsId)
	return tslib.getPlayerData(tsId)
end

--DREAM VERSION

function handler:SetLocalPlayer(foward, up)
    tslib.sendClientPos(foward.x, foward.y, foward.z, up.x, up.y, up.z)
end

function handler:IsTalking()
    return tslib.talkCheck()
end

function handler:IsInChannel()
	return tslib.getInChannel()
end

function handler:GetTsId()
	return tslib.getTsID()
end

-- function handler:GetHearables()
-- 	return tslib.getAllID()
-- end

-- function handler:Tick()
-- 	tslib.tick()
-- end

//************************************************************//
//							DEBUGGING
//************************************************************//

local last_load_a = 0

local function arrayListUpdate( DList )
	if last_load_a > CurTime() - 1 then return end
	last_load_a = CurTime()
	DList:Clear()
	--local players_hearable = tslib.getAllID()
	for k, v in pairs(tslib.getArray()) do
		DList:AddLine( tonumber(k), v )
	end
	DList:SortByColumn( 1 )
end

local arrayList = nil

concommand.Add("gspeakarray", function()
	if !arrayList then
		local sizeX = 100
		local sizeY = 500

		arrayList = vgui.Create( "DListView" )
		arrayList:SetSize( sizeX, sizeY )
		arrayList:SetPos( ScrW() - sizeX, 0 )
		arrayList:AddColumn( "It" ):SetFixedWidth( 25 )
		arrayList:AddColumn( "clientID" ):SetFixedWidth( 75 )
		arrayList:SetSortable( false )
		arrayList.Think = arrayListUpdate
	else
		arrayList:Remove()
		arrayList = nil
	end
end)

return handler