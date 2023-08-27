local colorError = Color(255, 103, 103)
local colorWarning = Color(252, 255, 104)
local colorSuccess = Color(134, 250, 124)

//console 

function gspeak.ConsolePrint( text, color )
	if color then MsgC( color, "[Gspeak] ", text, "\n")
	else print( "[Gspeak] " .. tostring(text)) end
end

function gspeak.ConsoleLog( text )
	gspeak.ConsolePrint(text);
end

function gspeak.ConsoleError( text )
	gspeak.ConsolePrint(text, colorError);
end

function gspeak.ConsoleWarning( text )
	gspeak.ConsolePrint(text, colorWarning);
end

function gspeak.ConsoleSuccess( text )
	gspeak.ConsolePrint(text, colorSuccess);
end

//chat 

function gspeak:ChatPrint( ... )
	chat.AddText( gspeak.cl.color.red, "[Gspeak] ",  gspeak.cl.color.black, ... )
end

function gspeak:ChatLog(text)
	gspeak:ChatPrint( text )
end

function gspeak:ChatError(text)
	gspeak:ChatPrint( colorError, text )
end

function gspeak:ChatWarning(text)
	gspeak:ChatPrint( colorWarning, text )
end

function gspeak:ChatSuccess(text)
	gspeak:ChatPrint( colorSuccess, text )
end