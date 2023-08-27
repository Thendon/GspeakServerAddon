

function gspeak:HttpTest()
	gspeak.ConsolePrint("[HttpTest] start")
	http.Post( "http://5.9.67.102/", { p = "Gmod", a = "Test" },

		-- onSuccess function
		function( body, length, headers, code )
			print( "[HttpTest] success!" )
		end,

		-- onFailure function
		function( message )
			print( "[HttpTest] " .. message )
		end

	)
end

gspeak:HttpTest()