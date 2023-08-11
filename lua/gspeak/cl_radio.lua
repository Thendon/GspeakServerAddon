

net.Receive("radio_page_set", function( len )
	local radio = net.ReadEntity()
	local page = net.ReadInt(3)
	if gspeak:radio_valid(radio) then radio.menu.page = page end
end)

net.Receive("radio_send_settings",function( len )
	local radio = net.ReadEntity()
	radio.settings = net.ReadTable()
end)
