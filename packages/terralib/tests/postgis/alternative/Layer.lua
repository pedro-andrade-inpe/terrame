-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.

-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.

-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this software and its documentation.
--
-------------------------------------------------------------------------------------------

return {
	Layer = function(unitTest)
		local projName = "sampa_alternative.tview"

		local proj1 = Project{
			file = projName,
			clean = true,
			author = "Avancini",
			title = "SAMPA"
		}

		local layerName1 = "Sampa"
		Layer{
			project = proj1,
			name = layerName1,
			file = filePath("sampa.shp", "terralib")
		}

		local host = nil -- "localhost"
		local port = nil
		local user = "postgres"
		local password = "postgres"
		local database = "postgis_22_sample"
		local encoding = "CP1252"
		local tableName = "sampa"

		local data = {
			type = "POSTGIS",
			host = host,
			port = port,
			user = user,
			password = password,
			database = database,
			table = tableName, -- USED ONLY TO DROP
			encoding = encoding
		}

		local tl = TerraLib{}
		tl:copyLayer(proj1, layerName1, data)
		
		local layerName2 = "SampaDB"

		Layer{
			project = proj1,
			source = "postgis",
			name = layerName2,
			user = user,
			password = password,
			database = database,
			table = tableName
		}

		local layerAlreadyExists = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = port,
				user = user,
				password = password,
				database = database,
				table = tableName
			}
		end
		unitTest:assertError(layerAlreadyExists, "Layer '"..layerName2.."' already exists in the Project.")

		tl:dropPgTable(data)
		proj1.layers[layerName2] = nil

		local sourceMandatory = function()
			Layer{
				project = proj1,
				-- source = "postgis",
				name = layerName2,
				port = port,
				user = user,
				password = password,
				database = database,
				table = tableName
			}
		end
		unitTest:assertError(sourceMandatory, mandatoryArgumentMsg("source"))

		local nameMandatory = function()
			Layer{
				project = proj1,
				source = "postgis",
				--name = layerName2,
				port = port,
				user = user,
				password = password,
				database = database,
				table = tableName
			}
		end
		unitTest:assertError(nameMandatory, mandatoryArgumentMsg("name"))

		local userMandatory = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = port,
				--user = user,
				password = password,
				database = database,
				table = tableName
			}
		end
		unitTest:assertError(userMandatory, mandatoryArgumentMsg("user"))

		local passMandatory = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = port,
				user = user,
				--password = password,
				database = database,
				table = tableName
			}
		end
		unitTest:assertError(passMandatory, mandatoryArgumentMsg("password"))

		local dbMandatory = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = port,
				user = user,
				password = password,
				--database = database,
				table = tableName
			}
		end
		unitTest:assertError(dbMandatory, mandatoryArgumentMsg("database"))

		local tableMandatory = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = port,
				user = user,
				password = password,
				database = database,
				--table = tableName
			}
		end
		unitTest:assertError(tableMandatory, mandatoryArgumentMsg("table"))

		local fileUnnecessary = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = port,
				user = user,
				password = password,
				database = database,
				table = tableName,
				file = filePath("sampa.shp", "terralib")
			}
		end
		unitTest:assertError(fileUnnecessary, unnecessaryArgumentMsg("file"))

		local sourceNotString = function()
			Layer{
				project = proj1,
				source = 123,
				name = layerName2,
				port = port,
				user = user,
				password = password,
				database = database,
				table = tableName
			}
		end
		unitTest:assertError(sourceNotString, incompatibleTypeMsg("source", "string", 123))

		local layerNotString = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = 123,
				port = port,
				user = user,
				password = password,
				database = database,
				table = tableName
			}
		end
		unitTest:assertError(layerNotString, incompatibleTypeMsg("name", "string", 123))

		local hostNotString = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				host = 123,
				port = port,
				user = user,
				password = password,
				database = database,
				table = tableName
			}
		end
		unitTest:assertError(hostNotString, incompatibleTypeMsg("host", "string", 123))

		local portNotString = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = "123",
				user = user,
				password = password,
				database = database,
				table = tableName
			}
		end
		unitTest:assertError(portNotString, incompatibleTypeMsg("port", "number", "123"))

		local userNotString = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = port,
				user = 123,
				password = password,
				database = database,
				table = tableName
			}
		end
		unitTest:assertError(userNotString, incompatibleTypeMsg("user", "string", 123))

		local passNotString = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = port,
				user = user,
				password = 123,
				database = database,
				table = tableName
			}
		end
		unitTest:assertError(passNotString, incompatibleTypeMsg("password", "string", 123))

		local dbNotString = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = port,
				user = user,
				password = password,
				database = 123,
				table = tableName
			}
		end
		unitTest:assertError(dbNotString, incompatibleTypeMsg("database", "string", 123))

		local tableNotString = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = port,
				user = user,
				password = password,
				database = database,
				table = 123
			}
		end
		unitTest:assertError(tableNotString, incompatibleTypeMsg("table", "string", 123))

		local wrongHost = "inotexist"
		local hostNonExists = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				host = wrongHost,
				port = port,
				user = user,
				password = password,
				database = database,
				table = tableName
			}
		end
		unitTest:assertError(hostNonExists, "It was not possible to create a connection to the given data source due to the following error: "
								.."could not translate host name \""..wrongHost.."\" to address: Unknown server error\n.") -- TODO: "\n." (REVIEW)			
		
		local wrongPort = 2345
		local portWrong = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				host = host,
				port = wrongPort,
				user = user,
				password = password,
				database = database,
				table = tableName
			}
		end
		unitTest:assertError(portWrong, "Please check the port '"..wrongPort.."'.")			
		
		local nonuser = "usernotexists"
		local userNotExists = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				host = host,
				port = port,
				user = nonuser,
				password = password,
				database = database,
				table = tableName
			}
		end
		unitTest:assertError(userNotExists, "It was not possible to create a connection to the given data source due to the following error: "
							.."FATAL:  password authentication failed for user \""..nonuser.."\"\n.") -- TODO: MESSAGE IS WRONG

		local wrongPass = "passiswrong"
		local passWrong = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				host = host,
				port = port,
				user = user,
				password = wrongPass,
				database = database,
				table = tableName
			}
		end
		unitTest:assertError(passWrong, "It was not possible to create a connection to the given data source due to the following error: "
							.."FATAL:  password authentication failed for user \""..user.."\"\n.")

		local tableWrong = "thetablenotexists"
		local tableNotExists = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				host = host,
				port = port,
				user = user,
				password = password,
				database = database,
				table = tableWrong
			}
		end
		unitTest:assertError(tableNotExists, "Is not possible add the Layer. The table '"..tableWrong.."' does not exist.")

		if isFile(projName) then
			rmFile(projName)
		end
		
		local projName = "amazonia.tview"

		if isFile(projName) then
			rmFile(projName)
		end

		local proj = Project{
			file = projName,
			clean = true,
			author = "Avancini",
			title = "The Amazonia"
		}

		local layerName1 = "Sampa"
		Layer{
			project = proj,
			name = layerName1,
			file = filePath("sampa.shp", "terralib")
		}

		local clName1 = "Sampa_Cells"
		local tName1 = "add_cellslayer_alternative"
		
		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = "postgres"
		local database = "postgis_22_sample"
		local encoding = "CP1252"

		local sourceMandatory = function() 
			Layer{
				project = proj,
				-- source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				user = user,
				password = password,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(sourceMandatory, mandatoryArgumentMsg("source"))

		local inputMandatory = function()
			Layer{
				project = proj,
				source = "postgis",
				--input = layerName1,
				name = clName1,
				resolution = 0.7,
				user = user,
				password = password,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(inputMandatory, mandatoryArgumentMsg("input"))

		local layerMandatory = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				--name = clName1,
				resolution = 0.7,
				user = user,
				password = password,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(layerMandatory, mandatoryArgumentMsg("name"))

		local userMandatory = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				--user = user,
				password = password,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(userMandatory, mandatoryArgumentMsg("user"))

		local passMandatory = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				user = user,
				--password = password,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(passMandatory, mandatoryArgumentMsg("password"))

		local dbMandatory = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				user = user,
				password = password,
				--database = database,
				table = tName1
			}
		end
		unitTest:assertError(dbMandatory, mandatoryArgumentMsg("database"))

		local sourceNotString = function()
			Layer{
				project = proj,
				source = 123,
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				user = user,
				password = password,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(sourceNotString, incompatibleTypeMsg("source", "string", 123))

		local inputNotString = function()
			Layer{
				project = proj,
				source = "postgis",
				input = 123,
				name = clName1,
				resolution = 0.7,
				user = user,
				password = password,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(inputNotString, incompatibleTypeMsg("input", "string", 123))

		local layerNotString = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = 123,
				resolution = 0.7,
				user = user,
				password = password,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(layerNotString, incompatibleTypeMsg("name", "string", 123))

		local resNotNumber = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = "10000",
				user = user,
				password = password,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(resNotNumber, incompatibleTypeMsg("resolution", "number", "10000"))

		local resMustBePositive = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = -1,
				user = user,
				password = password,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(resMustBePositive, positiveArgumentMsg("resolution", -1))

		local hostNotString = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				host = 123,
				user = user,
				password = password,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(hostNotString, incompatibleTypeMsg("host", "string", 123))

		local portNotString = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				port = "123",
				user = user,
				password = password,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(portNotString, incompatibleTypeMsg("port", "number", "123"))

		local passNotString = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				user = user,
				password = 123,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(passNotString, incompatibleTypeMsg("password", "string", 123))

		local dbNotString = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				user = user,
				password = password,
				database = 123,
				table = tName1
			}
		end
		unitTest:assertError(dbNotString, incompatibleTypeMsg("database", "string", 123))

		local tableNotString = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				user = user,
				password = password,
				database = database,
				table = 123
			}
		end
		unitTest:assertError(tableNotString, incompatibleTypeMsg("table", "string", 123))

		local unnecessaryArgument = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				user = user,
				password = password,
				database = database,
				table = tName1,
				file = filePath("sampa.shp", "terralib")
			}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("file"))

		local boxNonBoolean = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				box = 123,
				user = user,
				password = password,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(boxNonBoolean, incompatibleTypeMsg("box", "boolean", 123))

		local wrongHost = "inotexist"
		local hostNonExists = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				host = wrongHost,
				user = user,
				password = password,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(hostNonExists, "It was not possible to create a connection to the given data source due to the following error: "
								.."could not translate host name \""..wrongHost.."\" to address: Unknown server error\n.") -- TODO: "\n." (REVIEW)			
		
		local wrongPort = 2345
		local portWrong = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				port = wrongPort,
				user = user,
				password = password,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(portWrong, "Please check the port '"..wrongPort.."'.")			
		
		local nonuser = "usernotexists"
		local userNotExists = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				user = nonuser,
				password = password,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(userNotExists, "It was not possible to create a connection to the given data source due to the following error: "
							.."FATAL:  password authentication failed for user \""..nonuser.."\"\n.") -- TODO: MESSAGE IS WRONG

		local wrongPass = "passiswrong"
		local passWrong = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				user = user,
				password = wrongPass,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(passWrong, "It was not possible to create a connection to the given data source due to the following error: "
							.."FATAL:  password authentication failed for user \""..user.."\"\n.")

		local pgData = {
			type = "POSTGIS",
			port = port,
			user = user,
			password = password,
			database = database,
			table = tName1,
			encoding = encoding
		}

		local tl = TerraLib{}
		tl:dropPgTable(pgData)

		Layer{
			project = proj,
			source = "postgis",
			input = layerName1,
			name = clName1,
			resolution = 0.7,
			user = user,
			password = password,
			database = database,
			table = tName1
		}

		local clName2 = "Another_Setores_Cells"
		local tableAlreadyExists = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName2,
				resolution = 0.7,
				user = user,
				password = password,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(tableAlreadyExists, "The table '"..tName1.."' already exists.")

		tl:dropPgTable(pgData)

		if isFile(projName) then
			rmFile(projName)
		end
	end
}
