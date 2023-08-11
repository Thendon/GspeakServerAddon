local colorError = Color(255, 103, 103)
local colorWarning = Color(252, 255, 104)
local colorSuccess = Color(134, 250, 124)

function gspeak:ConsolePrint( text, color )
	if color then MsgC( color, "[Gspeak] ", text, "\n")
	else print( "[Gspeak] " .. text) end
end

function gspeak:ConsoleLog( text, color )
	gspeak:ConsolePrint(text);
end

function gspeak:ConsoleError( text, color )
	gspeak:ConsolePrint(text, colorError);
end

function gspeak:ConsoleWarning( text, color )
	gspeak:ConsolePrint(text, colorWarning);
end

function gspeak:ConsoleSuccess( text, color )
	gspeak:ConsolePrint(text, colorSuccess);
end