

local nextWrite = 0
local writeDelay = 0.1
local writeSize = 5000
local writeMaxCount = 500
local writeCount = 0

function gspeak:WriteBytes(outStream)
	gspeak:ConsolePrint("[FileTest] write " .. (writeSize) .. " bytes")
	for	i = 0, writeSize / 4 do
		outStream:WriteByte(1);
		outStream:WriteByte(0);
		outStream:WriteByte(0);
		outStream:WriteByte(1);
	end
end

function gspeak:OpenOutStream()
	if !file.Exists("gspeak", "DATA") then
		file.CreateDir("gspeak")
	end
	if !file.Exists("gspeak/io.out.dat", "DATA") then
		file.Write("gspeak/io.out.dat")
	end

	gspeak:ConsolePrint("[FileTest] start ")
	return file.Open("gspeak/io.out.dat", "a", "DATA")
end

function gspeak:CloseOutStream(outStream)
	outStream:Close() 
	gspeak:ConsolePrint("[FileTest] done ")
end

hook.Add("Think", "FileTest", function()
	if writeCount >= writeMaxCount then
		return
	end

	if nextWrite < CurTime() then
		local outStream = gspeak:OpenOutStream()
		outStream = gspeak:OpenOutStream()
		gspeak:WriteBytes(outStream)
		nextWrite = CurTime() + writeDelay
		writeCount = writeCount + 1
		gspeak:CloseOutStream(outStream)
	end
end)

--gspeak:FileTest(false)
--gspeak:FileTest(false)
--gspeak:FileTest(false)