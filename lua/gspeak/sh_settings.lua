

function gspeak:UpdateQuery(value, name)
	local q = sql.Query( "SELECT * FROM gspeak_settings WHERE name = '"..name.."'" )
	if q == false then
		gspeak.ConsoleError("Database UPDATE Error: "..sql.LastError());
		return false
	elseif q == nil then
		gspeak.ConsoleSuccess( "New variable ( "..name.." ) found")
		gspeak:InsertQuery(value, name)
	end

	if sql.Query( "UPDATE gspeak_settings SET value = "..gspeak:ValueToDB( value ).." WHERE name = '"..name.."'" ) == false then
		gspeak.ConsoleError( "Database UPDATE Error: "..sql.LastError())
		return false
	end
	return true
end

function gspeak:InsertQuery(value, name)
	if sql.Query( "INSERT INTO gspeak_settings ( name, value ) VALUES ( '" ..name.. "', " ..gspeak:ValueToDB( value ).. ")" ) == false then
		gspeak.ConsoleError("Database INSERT Error: "..sql.LastError());
		return false
	end
	return true
end

function gspeak:ChangeSetting(setting, table, name, value, i, original_table)
	i = i or 1
	if table[setting[i]] == nil then gspeak.ConsoleError("Setting "..name.." not found") return end
	original_table = original_table or table
	if i < #setting then gspeak:ChangeSetting(setting, table[setting[i]], name, value, i+1, original_table) return end
	table[setting[i]] = value

	if !gspeak:UpdateQuery(original_table[setting[1]], setting[1]) then return end
	gspeak.ConsoleSuccess("Changed "..name.." to "..tostring(value))

	if SERVER then
		net.Start("gspeak_server_settings")
			net.WriteTable( { name = setting[1], value = original_table[setting[1]] } )
		net.Broadcast()
	end
end

function gspeak:ValueToDB( value )
	if istable(value) then return "'"..util.TableToJSON( value ).."'" end
	if isstring(value) then return "'"..value.."'" end
	if isbool(value) then return value and "'true'" or "'false'" end
	return value
end

function gspeak:DBToValue( value )
	local number = tonumber( value );
	if number and isnumber( number ) then return number end
	if value == "true" then return true end
	if value == "false" then  return false end
	local result_table = util.JSONToTable( value )
	if ( result_table and table.Count(result_table) > 0 ) then return result_table end
	return value
end

function gspeak:QueryTable( table, func )
	for name, value in pairs(table) do
		func(name, value )
	end
end

function gspeak:SaveResult( result, table )
	for k, v in pairs(result) do
		table[v.name] = gspeak:DBToValue( v.value )
	end
end

--TODO: Unused since load settings handles new entries itself
function gspeak:VersionCheck()
	local versionFile = "gspeak/version.txt"
	if (!file.Exists(versionFile, "DATA")) then
		file.CreateDir("gspeak")
		file.Write(versionFile, gspeak.version)
	else
		local loaded_version = file.Read(versionFile)
		if loaded_version != version then
			if SERVER then
				--TODO: insert new settings
			else
				--TODO: insert new settings
			end
			local update_success = true
			if update_success then file.Write(versionFile, gspeak.version) end
		end
	end
end

function gspeak:ResetSettings()
	if sql.TableExists("gspeak_settings") then
		sql.Query("DROP TABLE gspeak_settings")
	end

	gspeak.settings = table.Copy(gspeak.default_settings)
	gspeak:LoadSettings(gspeak.settings)
	
	net.Start( "gspeak_init" )
		net.WriteTable(gspeak.settings)
	net.Broadcast()
end

function gspeak:LoadSettings( table )
	if !sql.TableExists("gspeak_settings") then
		sql.Query( "CREATE TABLE gspeak_settings ( name VARCHAR(255) PRIMARY KEY, value TEXT )" )
	  	if !sql.TableExists("gspeak_settings") then gspeak.ConsoleError( "Database Error: "..sql.LastError()) return end
		gspeak.ConsoleSuccess( "Table created successfully")
		if !table then return end
		gspeak:QueryTable( table, function(name, value)
			gspeak:InsertQuery( value, name)
		end )
		return
	end

	result = sql.Query( "SELECT * FROM gspeak_settings" )
	if result == false then gspeak.ConsoleError( "Database Error: "..sql.LastError()) return end
	for name, value in pairs( table ) do
		local found = false
		if result then for k, v in pairs(result) do if name == v.name then found = true end end end

		if !found then
			gspeak:InsertQuery( value, name)
		end
	end
	if !result then return end
	gspeak:SaveResult(result, table)
	gspeak.ConsoleSuccess( "Table loaded successfully")
end

concommand.Add("gspeak_reset_settings", function() 
	gspeak:ResetSettings()
end)