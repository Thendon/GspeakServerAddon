--database performance demo by nockich 

local tPlayers = {
    Player1 = {
        pos = Vector(34234, 234234, 234),
        name = "Twat"
    },
    Player2 = {
        pos = Vector(2345342, 34253245, 32455),
        name = "Posh Prick"
    }
}

local iStart = SysTime()
local iLoops = 5000

local function setup()
    sql.Query("CREATE TABLE gspeak_players(id, name, pos)")

    sql.Query("INSERT INTO gspeak_players(id, name, pos) VALUES (Player1, 0, 0")
    sql.Query("INSERT INTO gspeak_players(id, name, pos) VALUES (Player2, 0, 0")
end
--setup()


local function parsePlayerVector(pPlayer)
    local vPos = pPlayer:GetPos()
    return string.format("%s,%s,%s", vPos.x, vPos.y, vPos.z)
end

iStart = SysTime()
for i = 1, iLoops do
    for playerID, pPlayer in next, tPlayers do
        string.format("%s,%s,%s", pPlayer.pos.x, pPlayer.pos.y, pPlayer.pos.z)

        sql.Query(string.format("UPDATE gspeak_players WHERE id='%s' SET pos='%s'", playerID, sParsedPos))
    end
end
iFinish = SysTime() - iStart
print("SQL Upatate Single Method: " .. iFinish)

iStart = SysTime()
for i = 1, iLoops do
    local tPosData = {}

    for playerID, pPlayer in next, tPlayers do
        tPosData[#tPosData + 1] = {
            id = playerID,
            pos = pPlayer.pos
        }
    end

    -- Just using an already existing entry
    sql.Query("UPDATE gspeak_players WHERE id='Player1' SET pos ='" .. util.TableToJSON(tPosData) .. "'")
end
iFinish = SysTime() - iStart
print("SQL Update All: " .. iFinish)