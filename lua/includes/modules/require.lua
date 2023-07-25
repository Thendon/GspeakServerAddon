//**********************************************************
//  Require
//
//  How to use:
//  -   use: Require( <pathToFile> )
//      example: Require( "classes/core/printer")
//      note:   do NOT add any prefixes like cl_, sv_, sh_
//              or the .lua file ending.
//              Scince all files are included only one time
//              it is recommended to save the return into a
//              local variable
//
//  What it does:
//  -   all found files get combined and included ONCE
//  -   if the file was required before, the same pointer gets returned
//  -   scans in lua and gamemode folder by default
//  -   no prefix is handled like sh_
//
//  How it works:
//  -   meta-table magic
//**********************************************************

local prefixes = {}
local subfolders = { "", GM.Name .. "/gamemode/" }

if ( SERVER ) then prefixes = { "", "sh_", "sv_" } end
if ( CLIENT ) then prefixes = { "", "sh_", "cl_" } end

local required = {}

--has to be used for lua refresh
hook.Add("OnReloaded", "ResetRequire", function()
    required = {}
end)

local function pathStringToTable( pathString )
    return string.Explode("/", pathString)
end

local function tableToPathString( table )
    local pathString = ""
    local first = true
    for k, v in next, table do
        if ( !first ) then pathString = pathString .. "/" end
        pathString = pathString .. v
        first = false
    end
    return pathString
end

local function seperateFileAndFolder( path )
    local tPath = pathStringToTable( path )
    local filename = tPath[#tPath]
    table.remove( tPath )
    local folder = tableToPathString( tPath ) .. "/"
    return filename, folder
end

local function generateMeta( include )
    local meta = {}
    meta.__index = include
    return meta
end

local function handlePath( domain, path )
    --finally include a disired file
    local incl = include( path )
    --reserve pointer for domain ( or use existing one )
    required[domain] = required[domain] or incl or {}
    if ( !incl ) then return end
    --return if found table is the included one
    if ( required[domain] == incl ) then return end
    --generate metatable and link it with found table
    setmetatable( required[domain], generateMeta( incl ) )
end

local function Require( domain )
    --return pointer of already required files
    if ( required[domain] ) then return required[domain] end
    --prepare string to be included
    local filename, folder = seperateFileAndFolder( domain .. ".lua" )
    --combine all subfolder & prefix combinations
    for i, subfolder in next, subfolders do
        for k, prefix in next, prefixes do
            --check for file existence
            local finalPath = subfolder .. folder .. prefix .. filename
            local exists = file.Exists(finalPath, "LUA")
            if ( !exists ) then continue end
            handlePath( domain, finalPath )
        end
    end
    --throw error if nothing could be included
    if ( !required[domain] ) then error("require failed") end
    --return final include
    return required[domain]
end

_G.Require = Require
