local last_load_w = 0

local function gspeak_players_create_list( DList )
	--if !gspeak.hearablePlayers then return end
	if last_load_w > CurTime() - 1 then return end
	last_load_w = CurTime()
	DList:Clear()
	
	for i, ent in ipairs(gspeak.gspeakEntities) do
		local id = ent:EntIndex()
		
		local isHearable, volume, pos, effect = gspeak:GetEntityDebugInfo(ent)

		if (!isHearable) then continue end

		local speakers = ent:GetSpeakers()

		if (#speakers == 0) then
			DList:AddLine(id, "no speaker", nil, nil, volume, nil, effect)
			continue
		end

		for i, speaker in ipairs(speakers) do
			local talking = tostring(speaker:IsTalking())
			local tsId = speaker:GetTsId()
			local tsVolume = speaker.volume
			local ply = tostring(speaker)
			DList:AddLine(id, ply, tsId, talking, volume, tsVolume, effect)
		end
	end
	DList:SortByColumn( 1 )
end

concommand.Add("gspeakwho", function()
	if gspeak.who == nil or gspeak.who == false then
		Gspeak_who_list = vgui.Create( "DListView" )
		Gspeak_who_list:SetSize( 450, 450 )
		Gspeak_who_list:SetPos( 25, 200 )
		Gspeak_who_list:AddColumn( "ID" ):SetFixedWidth( 25 )
		Gspeak_who_list:AddColumn( "Ply" )
		Gspeak_who_list:AddColumn( "TsId" ):SetFixedWidth( 50 )
		Gspeak_who_list:AddColumn( "talking" ):SetFixedWidth( 50 )
		Gspeak_who_list:AddColumn( "gm vol" ):SetFixedWidth( 50 )
		Gspeak_who_list:AddColumn( "ts vol" ):SetFixedWidth( 50 )
		Gspeak_who_list:AddColumn( "effect" ):SetFixedWidth( 50 )
		Gspeak_who_list:SetSortable( false )
		Gspeak_who_list.Think = gspeak_players_create_list
		gspeak.who = true
	else
		Gspeak_who_list:Remove()
		gspeak.who = false
	end
end)
