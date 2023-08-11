

hook.Add("InitPostEntity", "gspeak_override_animations", function()
    function GAMEMODE:MouthMoveAnimation( ply )
        gspeak:MouthMoveAnimation( ply )
    end

    function GAMEMODE:GrabEarAnimation( ply )
        gspeak:GrabEarAnimation( ply )
    end
end)

function gspeak:MouthMoveAnimation( ply )
	if !gspeak.cl.running then return end
	local FlexNum = ply:GetFlexNum() - 1
	if ( FlexNum <= 0 ) then return end

	ply.volume = ply.volume or 0
	ply.mouthweight = ply.mouthweight or 0

	local new_weight = 0
	if ply.volume != 0 and ply.hearable and ply.talking then
		new_weight = math.Approach(ply.mouthweight,math.Clamp( 1 + math.log(ply.volume, 10), 0, 1 ),FrameTime() * 7)
	end

	for i = 0, FlexNum - 1 do
		local Name = ply:GetFlexName( i )
		if ( Name == "jaw_drop" or Name == "right_part" or Name == "left_part" or Name == "right_mouth_drop" or Name == "left_mouth_drop" ) then
			ply:SetFlexWeight( i, new_weight )
		end
	end
	ply.mouthweight = new_weight
end

function gspeak:GrabEarAnimation( ply )
	ply.ChatGestureWeight = ply.ChatGestureWeight or 0
	local update = false
	if ply.ChatGesture then
		if ply.ChatStation then
			ply.ChatGestureWeight = math.Approach( ply.ChatGestureWeight, 0.5, FrameTime() * 10.0 );
		else
			ply.ChatGestureWeight = math.Approach( ply.ChatGestureWeight, 1, FrameTime() * 10.0 );
		end
		update = true
	elseif ply.ChatGestureWeight > 0 then
		ply.ChatGestureWeight = math.Approach( ply.ChatGestureWeight, 0, FrameTime()  * 10.0 );
		update = true
	end

	if update then
		ply:AnimRestartGesture( GESTURE_SLOT_CUSTOM, ACT_GMOD_IN_CHAT )
		ply:AnimSetGestureWeight( GESTURE_SLOT_CUSTOM, ply.ChatGestureWeight )
		ply.ChatGesture = false
	end
end