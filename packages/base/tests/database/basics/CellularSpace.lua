-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

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

return{
	CellularSpace = function(unitTest)
		local usingShape = function()
			local cs = CellularSpace{
				file = filePath("test/cabecadeboi900.shp"),
				xy = {"Col", "Lin"},
				as = {
					height = "height_"
				},
				geometry = false
			}

			unitTest:assertEquals("cabecadeboi900.shp", cs.layer)
			unitTest:assertEquals(121, #cs.cells)

			for _ = 1, 5 do
				local cell = cs:sample()
				unitTest:assertType(cell.object_id0, "string")
				unitTest:assertType(cell.x, "number")
				unitTest:assertType(cell.y, "number")
				unitTest:assertNotNil(cell.height)
				unitTest:assertNil(cell.height_)
				unitTest:assertNotNil(cell.soilWater)
				unitTest:assertNil(cell.geom)
			end

			local cell = cs:get(0, 0)
			unitTest:assertEquals(0, cell.x)
			unitTest:assertEquals(0, cell.y)

			cell = cs.cells[1]
			unitTest:assertEquals(0, cell.x)
			unitTest:assertEquals(0, cell.y)

			cell = cs:get(0, 1)
			unitTest:assertEquals(0, cell.x)
			unitTest:assertEquals(1, cell.y)

			cell = cs.cells[2]
			unitTest:assertEquals(0, cell.x)
			unitTest:assertEquals(1, cell.y)

			cell = cs:get(0, 9)
			unitTest:assertEquals(0, cell.x)
			unitTest:assertEquals(9, cell.y)

			cell = cs.cells[100]
			unitTest:assertEquals(9, cell.x)
			unitTest:assertEquals(0, cell.y)

			cell = cs:get(0, 10)
			unitTest:assertEquals(0, cell.x)
			unitTest:assertEquals(10, cell.y)

			cell = cs.cells[101]
			unitTest:assertEquals(9, cell.x)
			unitTest:assertEquals(1, cell.y)

			cs = CellularSpace{
				file = filePath("test/cabecadeboi900.shp"),
				xy = function(mcell)
					return mcell.Col, mcell.Lin
				end
			}

			unitTest:assertEquals("cabecadeboi900.shp", cs.layer)
			unitTest:assertEquals(121, #cs.cells)

			for _ = 1, 5 do
				local mcell = cs:sample()
				unitTest:assertEquals(mcell.x, mcell.Col)
				unitTest:assertEquals(mcell.y, mcell.Lin)
			end

			cs = CellularSpace{file = filePath("brazilstates.shp", "base")}

			unitTest:assertNotNil(cs.cells[1])
			unitTest:assertEquals(#cs.cells, 27)
			unitTest:assertType(cs.cells[1], "Cell")

			unitTest:assertEquals(cs.yMin, 0)
			unitTest:assertEquals(cs.yMax, 0)

			unitTest:assertEquals(cs.xMin, 0)
			unitTest:assertEquals(cs.yMax, 0)

			local valuesDefault = {
				2300000,  12600000, 2700000,  6700000,  5200000,
				16500000,  1900000,  5400000, 7400000,  3300000,
				8700000,  13300000, 2600000, 1300000, 300000,
				9600000, 4800000, 1600000, 33700000,  1000000,
				2700000, 2800000, 300000, 500000,  1700000,
				4300000,  2300000
			}

			for i = 1, 27 do
				unitTest:assertEquals(valuesDefault[i], cs.cells[i].POPUL)
			end
		end

		local missingWithShape = function()
			local missing = -1
			local cs = CellularSpace{
				file = filePath("test/CellsAmaz.shp"),
				missing = missing
			}

			local missCount = 0
			forEachCell(cs, function(c)
				if c.pointcount == -1 then
					missCount = missCount + 1
				end
			end)

			unitTest:assertEquals(missCount, 156)
		end

		local gis = getPackage("gis")

		local usingProject = function()
			local projName = File("cellspace_basic.tview")
			local author = "Avancini"
			local title = "Cellular Space"

			if projName:exists() then projName:delete() end

			local proj = gis.Project{
				file = projName:name(true),
				clean = true,
				author = author,
				title = title
			}

			local layerName1 = "Sampa"

			gis.Layer{
				project = proj,
				name = layerName1,
				file = filePath("test/sampa.shp", "gis")
			}

			local clName1 = "Sampa_Cells_DB"
			local tName1 = "sampa_cells"
			local password = getConfig().password
			local database = "postgis_22_sample"

			local layer1 = gis.Layer{
				project = proj,
				source = "postgis",
				clean = true,
				input = layerName1,
				name = clName1,
				resolution = 0.3,
				password = password,
				database = database,
				table = tName1
			}

			local cs = CellularSpace{
				project = projName:name(true),
				layer = clName1
			}

			forEachCell(cs, function(c)
				unitTest:assertNotNil(c.geom)
				unitTest:assertNil(c.OGR_GEOMETRY)
			end)

			cs = CellularSpace{
				project = "cellspace_basic",
				layer = clName1,
				geometry = false
			}

			forEachCell(cs, function(c)
				unitTest:assertNil(c.geom)
				unitTest:assertNil(c.OGR_GEOMETRY)
			end)

			unitTest:assertEquals(303, #cs.cells)
			-- unitTest:assertFile(projName:name(true)) -- SKIP #TODO(#1242)

			projName:delete()
			layer1:delete()
		end

		local missingWithLayer = function()
			local projFile = File("cellspace_basic.tview"):deleteIfExists()
			local author = "Avancini"
			local title = "Cellular Space"

			local proj = gis.Project{
				file = projFile,
				clean = true,
				author = author,
				title = title
			}

			local missLayerName = "CellsAmaz"
			gis.Layer{
				project = proj,
				name = missLayerName,
				file = filePath("test/CellsAmaz.shp")
			}

			local missing = -1
			local cs = CellularSpace{
				project = proj,
				layer = missLayerName,
				missing = missing
			}

			local missCount = 0
			forEachCell(cs, function(c)
				if c.pointcount == -1 then
					missCount = missCount + 1
				end
			end)

			unitTest:assertEquals(missCount, 156)

			projFile:delete()
		end

		local usingPgm = function()
			local cs = CellularSpace{
				file = filePath("simple.pgm", "base")
			}
			unitTest:assertEquals(#cs, 100)

			local pgmFile = filePath("test/error/pgm-invalid-max.pgm", "base")
			local pgmWarn = function()
				cs = CellularSpace{
					file = pgmFile
				}
			end
			unitTest:assertWarning(pgmWarn, "File '"..pgmFile.."' does not have a maximum value declared.")
			unitTest:assertEquals(#cs, 100)

			pgmFile = filePath("test/error/pgm-invalid-size.pgm", "base")
			local pgmWarn2 = function()
				cs = CellularSpace{
					file = pgmFile
				}
			end
			unitTest:assertWarning(pgmWarn2, "Data from file '"..pgmFile.."' does not match declared size: expected '(2, 2)', got '(10, 10)'.")
			unitTest:assertEquals(#cs, 100)
		end

		local usingCsv = function()
			local cs = CellularSpace{file = filePath("test/simple-cs.csv", "base"), sep = ";"}

			unitTest:assertType(cs, "CellularSpace")
			unitTest:assertEquals(400, #cs)

			unitTest:assertType(cs:sample().maxSugar, "number")
			unitTest:assertType(cs:sample().maxSugar, "number")
			unitTest:assertType(cs:sample().maxSugar, "number")
		end

		local loadTifDirectory = function()
			local dir = Directory("csdir")

			if dir:exists() then
				dir:delete()
			end

			dir:create()

			local proj = gis.Project{
				file = "cellspace_basic.tview",
				clean = true,
				author = "Avancini"
			}

			local layer = gis.Layer{
				project = proj,
				name = "Tif",
				epsg = 5880,
				file = filePath("cabecadeboi-elevation.tif", "gis")
			}

			local toData1 = {file = File(tostring(dir).."/elevation1.tif"), overwrite = true}
			local toData2 = {file = File(tostring(dir).."/elevation2.tif"), overwrite = true}
			layer:export(toData1)
			layer:export(toData2)

			local cs

			local sourceUnnecessary = function()
				cs = CellularSpace{
					directory = dir,
					source = "directory"
				}
			end

			unitTest:assertWarning(sourceUnnecessary, "Argument 'source' is unnecessary.")

			forEachCell(cs, function(cell)
				unitTest:assertEquals(cell.elevation1, cell.elevation2)
			end)

			dir:delete()
			proj.file:delete()
		end

		unitTest:assert(usingShape)
		unitTest:assert(missingWithShape)
		unitTest:assert(usingProject)
		unitTest:assert(missingWithLayer)
		unitTest:assert(usingPgm)
		unitTest:assert(usingCsv)
		unitTest:assert(loadTifDirectory)
	end,
	loadNeighborhood = function(unitTest)
		local cs1 = CellularSpace{
			file = filePath("test/cabecadeboi900.shp", "base"),
			xy = {"Col", "Lin"}
		}

		local cs2 = CellularSpace{
			file = filePath("test/river.shp", "base")
		}

		local cs3 = CellularSpace{
			file = filePath("test/emas.shp", "base"),
			xy = {"Col", "Lin"},
		}

		unitTest:assertType(cs1, "CellularSpace")
		unitTest:assertEquals(121, #cs1)

		local countTest = 1

		cs1:loadNeighborhood{file = filePath("cabecadeboi-neigh.gpm", "base")}

		local sizes = {}
		local minSize = math.huge
		local maxSize = -math.huge
		local minWeight = math.huge
		local maxWeight = -math.huge
		local sumWeight = 0

		forEachCell(cs1, function(cell)
			local neighborhood = cell:getNeighborhood()
			unitTest:assertNotNil(neighborhood)

			local neighborhoodSize = #neighborhood

			unitTest:assert(neighborhoodSize >= 5)
			unitTest:assert(neighborhoodSize <= 12)

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, function(neigh, weight, c)
				unitTest:assertNotNil(c)
				unitTest:assertNotNil(neigh)

				unitTest:assert(weight >= 900)
				unitTest:assert(weight <= 1800)

				minWeight = math.min(weight, minWeight)
				maxWeight = math.max(weight, maxWeight)

				unitTest:assertEquals(weight, neighborhood:getWeight(neigh))
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(5, minSize)
		unitTest:assertEquals(12, maxSize)
		unitTest:assertEquals(900, minWeight)
		unitTest:assertEquals(1800, maxWeight)
		unitTest:assertEquals(1617916.8, sumWeight, 0.00001)

		unitTest:assertEquals(28, sizes[11])
		unitTest:assertEquals(8,  sizes[7])
		unitTest:assertEquals(28, sizes[8])
		unitTest:assertEquals(4,  sizes[10])
		unitTest:assertEquals(49, sizes[12])
		unitTest:assertEquals(4,  sizes[5])

		countTest = countTest + 1

		cs1:loadNeighborhood{
			file = filePath("cabecadeboi-neigh.gpm", "base"),
			name = "my_neighborhood"..countTest
		}

		sizes = {}

		minSize   = math.huge
		maxSize   = -math.huge
		minWeight = math.huge
		maxWeight = -math.huge
		sumWeight = 0

		forEachCell(cs1, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assertNotNil(neighborhood)

			local neighborhoodSize = #neighborhood

			unitTest:assert(neighborhoodSize >= 5)
			unitTest:assert(neighborhoodSize <= 12)

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(neigh, weight, c)
				unitTest:assertNotNil(c)
				unitTest:assertNotNil(neigh)

				unitTest:assert(weight >= 900)
				unitTest:assert(weight <= 1800)

				minWeight = math.min(weight, minWeight)
				maxWeight = math.max(weight, maxWeight)

				unitTest:assertEquals(weight, neighborhood:getWeight(neigh))
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(5, minSize)
		unitTest:assertEquals(12, maxSize)
		unitTest:assertEquals(900, minWeight)
		unitTest:assertEquals(1800, maxWeight)
		unitTest:assertEquals(1617916.8, sumWeight, 0.00001)

		unitTest:assertEquals(28, sizes[11])
		unitTest:assertEquals(8, sizes[7])
		unitTest:assertEquals(28, sizes[8])
		unitTest:assertEquals(4, sizes[10])
		unitTest:assertEquals(49, sizes[12])
		unitTest:assertEquals(4, sizes[5])

		countTest = countTest + 1

		cs3:loadNeighborhood{
			file = filePath("test/gpmdistanceDbEmasCells.gpm", "base"),
			name = "my_neighborhood"..countTest
		}

		sizes = {}

		minSize = math.huge
		maxSize = -math.huge
		sumWeight = 0

		forEachCell(cs3, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assertNotNil(neighborhood)

			local neighborhoodSize = #neighborhood

			unitTest:assert(neighborhoodSize >= 3)
			unitTest:assert(neighborhoodSize <= 8)

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(neigh, weight, c)
				unitTest:assertNotNil(c)
				unitTest:assertNotNil(neigh)

				unitTest:assertEquals(weight, 1)

				unitTest:assertEquals(weight, neighborhood:getWeight(neigh))
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(3, minSize)
		unitTest:assertEquals(8, maxSize)
		unitTest:assertEquals(10992, sumWeight)

		unitTest:assertEquals(4, sizes[3])
		unitTest:assertEquals(34, sizes[4])
		unitTest:assertEquals(72, sizes[5])
		unitTest:assertEquals(34, sizes[6])
		unitTest:assertEquals(48, sizes[7])
		unitTest:assertEquals(1243, sizes[8])

		countTest = countTest + 1

		cs2:loadNeighborhood{
			file = filePath("test/emas-distance.gpm", "base"),
			name = "my_neighborhood"..countTest
		}

		minSize   = math.huge
		maxSize   = -math.huge
		minWeight = math.huge
		maxWeight = -math.huge

		sumWeight = 0

		forEachCell(cs2, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assertNotNil(neighborhood)

			local neighborhoodSize = #neighborhood

			unitTest:assert(neighborhoodSize >= 5)
			unitTest:assert(neighborhoodSize <= 120)

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(neigh, weight, c)
				unitTest:assertNotNil(c)
				unitTest:assertNotNil(neigh)

				unitTest:assert(weight >= 70.8015)
				unitTest:assert(weight <= 9999.513)

				minWeight = math.min(weight, minWeight)
				maxWeight = math.max(weight, maxWeight)
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(5, minSize)
		unitTest:assertEquals(120, maxSize)
		unitTest:assertEquals(70.8015, minWeight, 0.00001)
		unitTest:assertEquals(9999.513, maxWeight, 0.00001)
		unitTest:assertEquals(84604261.93974, sumWeight, 0.00001)

		-- .GAL Regular CS
		countTest = countTest + 1

		local unnecessaryArgument = function()
			cs1:loadNeighborhood{
				file = filePath("test/cabecadeboi-neigh.gal", "base"),
				name = "my_neighborhood"..countTest,
				che = false
			}
		end
		unitTest:assertWarning(unnecessaryArgument, unnecessaryArgumentMsg("che"))

		sizes = {}

		minSize   = math.huge
		maxSize   = -math.huge
		sumWeight = 0

		forEachCell(cs1, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assertNotNil(neighborhood)

			local neighborhoodSize = #neighborhood

			unitTest:assert(neighborhoodSize >= 5)
			unitTest:assert(neighborhoodSize <= 12)

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(neigh, weight, c)
				unitTest:assertNotNil(c)
				unitTest:assertNotNil(neigh)

				unitTest:assertEquals(1, weight)
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(1236, sumWeight)
		unitTest:assertEquals(5,    minSize)
		unitTest:assertEquals(12,   maxSize)

		unitTest:assertEquals(28, sizes[11])
		unitTest:assertEquals(8,  sizes[7])
		unitTest:assertEquals(28, sizes[8])
		unitTest:assertEquals(4,  sizes[10])
		unitTest:assertEquals(49, sizes[12])
		unitTest:assertEquals(4,  sizes[5])

		-- .GAL Irregular CS
		countTest = countTest + 1

		cs2:loadNeighborhood{
			file = filePath("test/emas-distance.gal", "base"),
			name = "my_neighborhood"..countTest
		}

		minSize   = math.huge
		maxSize   = -math.huge
		sumWeight = 0

		forEachCell(cs2, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assertNotNil(neighborhood)

			local neighborhoodSize = #neighborhood

			unitTest:assert(neighborhoodSize >= 5)
			unitTest:assert(neighborhoodSize <= 120)

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(neigh, weight, c)
				unitTest:assertNotNil(c)
				unitTest:assertNotNil(neigh)
				unitTest:assertEquals(1, weight)
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(14688, sumWeight)
		unitTest:assertEquals(5,     minSize)
		unitTest:assertEquals(120,   maxSize)

		-- .GWT Regular CS
		countTest = countTest + 1

		cs1:loadNeighborhood{
			file = filePath("test/cabecadeboi-neigh.gwt", "base"),
			name = "my_neighborhood"..countTest
		}

		sizes = {}

		minSize   = math.huge
		maxSize   = -math.huge
		minWeight = math.huge
		maxWeight = -math.huge
		sumWeight = 0

		forEachCell(cs1, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assertNotNil(neighborhood)

			local neighborhoodSize = #neighborhood
			unitTest:assertType(neighborhoodSize, "number")

			unitTest:assert(neighborhoodSize >= 5)
			unitTest:assert(neighborhoodSize <= 12)

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(neigh, weight, c)
				unitTest:assertNotNil(c)
				unitTest:assertNotNil(neigh)

				unitTest:assert(weight >= 900)
				unitTest:assert(weight <= 1800)

				minWeight = math.min(weight, minWeight)
				maxWeight = math.max(weight, maxWeight)
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(1800, maxWeight)
		unitTest:assertEquals(900, minWeight)
		unitTest:assertEquals(1617916.8, sumWeight, 0.00001)

		unitTest:assertEquals(28, sizes[11])
		unitTest:assertEquals(8,  sizes[7])
		unitTest:assertEquals(28, sizes[8])
		unitTest:assertEquals(4,  sizes[10])
		unitTest:assertEquals(49, sizes[12])
		unitTest:assertEquals(4,  sizes[5])

		-- .GWT Irregular CS
		countTest = countTest + 1

		cs2:loadNeighborhood{
			file = filePath("test/emas-distance.gwt", "base"),
			name = "my_neighborhood"..countTest
		}

		minSize   = math.huge
		maxSize   = -math.huge
		minWeight = math.huge
		maxWeight = -math.huge
		sumWeight = 0

		forEachCell(cs2, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assertNotNil(neighborhood)

			local neighborhoodSize = #neighborhood
			unitTest:assertType(neighborhoodSize, "number")

			unitTest:assert(neighborhoodSize >= 5)
			unitTest:assert(neighborhoodSize <= 120)

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(neigh, weight, c)
				unitTest:assertNotNil(c)
				unitTest:assertNotNil(neigh)
				unitTest:assertType(weight, "number")

				unitTest:assert(weight >= 70.8015)
				unitTest:assert(weight <= 9999.513)

				minWeight = math.min(weight, minWeight)
				maxWeight = math.max(weight, maxWeight)
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(9999.513, maxWeight)
		unitTest:assertEquals(70.8015, minWeight)
		unitTest:assertEquals(5, minSize)
		unitTest:assertEquals(120, maxSize)
		unitTest:assertEquals(84604261.93974, sumWeight, 0.00001)

		-- GAL from shapefile
		local cs = CellularSpace{
			file = filePath("brazilstates.shp", "base")
		}

		cs:loadNeighborhood{
			file = filePath("test/brazil.gal", "base"),
			check = false
		}

		local count = 0
		forEachCell(cs, function(cell)
			count = count + #cell:getNeighborhood()
		end)

		unitTest:assertEquals(count, 7)
	end,
	save = function(unitTest)
		local gis = getPackage("gis")

		local createProject = function()
			local proj = gis.Project{
				file = "cellspace_save_basic.tview",
				clean = true,
				author = "Avancini",
				title = "CellularSpace"
			}

			return proj
		end

		local createPostgisLayer = function(project, clName)
			local layer = gis.Layer{
				project = project,
				name = "Sampa",
				file = filePath("test/sampa.shp", "gis")
			}

			return gis.Layer{
				project = project,
				source = "postgis",
				clean = true,
				input = layer.name,
				name = clName,
				resolution = 0.3,
				password = getConfig().password,
				database = "postgis_22_sample"
			}
		end

		local saveNewDataAndLayerPostgis = function()
			local proj = createProject()
			local clName1 = "Sampa_Cells_DB"

			local layer1 = createPostgisLayer(proj, clName1)

			local cs = CellularSpace{
				layer = layer1,
				geometry = false
			}

			unitTest:assertEquals(#cs, 303)

			cs = CellularSpace{
				project = proj,
				layer = clName1
			}

			unitTest:assertEquals(#cs, 303)

			forEachCell(cs, function(cell)
				cell.t0 = 1000
			end)

			local cellSpaceLayerNameT0 = clName1.."_CellSpace_T0"

			cs:save(cellSpaceLayerNameT0, "t0")

			local layer2 = gis.Layer{
				project = proj,
				name = cellSpaceLayerNameT0
			}

			unitTest:assertEquals(layer2.table, string.lower(cellSpaceLayerNameT0))

			local cs2 = CellularSpace{
				project = proj,
				layer = layer2.name
			}

			unitTest:assertEquals(cs2:sample().t0, 1000)

			forEachCell(cs2, function(cell)
				unitTest:assertEquals(cell.t0, 1000)
				cell.t0 = cell.t0 + 1000
			end)

			cs2:save(cellSpaceLayerNameT0, "t0")

			local cs3 = CellularSpace{
				project = proj,
				layer = cellSpaceLayerNameT0,
				geometry = false
			}

			unitTest:assertEquals(cs3:sample().t0, 2000)

			local cellSpaceLayerNameCopy = cellSpaceLayerNameT0.."_Copy"

			cs3:save(cellSpaceLayerNameCopy)

			local layer3 = gis.Layer{
				project = proj,
				name = cellSpaceLayerNameCopy
			}

			unitTest:assertEquals(layer3.table, string.lower(cellSpaceLayerNameCopy))

			local cs4 = CellularSpace{
				project = proj,
				layer = cellSpaceLayerNameCopy,
				geometry = false
			}

			unitTest:assertEquals(cs4:sample().t0, 2000)

			proj.file:delete()
			layer1:delete()
			layer2:delete()
			layer3:delete()
		end

		local saveDoublePrecision = function()
			local proj = createProject()
			local layer = createPostgisLayer(proj, "SampaPg")

			local cs = CellularSpace{
				layer = layer
			}

			local num = 0.123456789012345

			forEachCell(cs, function(cell)
				cell.number = num
			end)

			cs:save(layer.name, "number")

			local cs2 = CellularSpace{
				layer = layer
			}

			unitTest:assertEquals(cs2:sample().number, num)

			proj.file:delete()
			layer:delete()
		end

		local saveWithGeom = function()
			local proj = createProject()
			local clName = "SampaPg"
			local layer = createPostgisLayer(proj, "SampaPg")

			local cs = CellularSpace{
				project = proj,
				layer = layer.name,
				geometry = false
			}

			local cellSpaceLayerNameGeom = clName.."_CellSpace_Geom"

			cs:save(cellSpaceLayerNameGeom)

			local cs1 = CellularSpace{
				project = proj,
				layer = cellSpaceLayerNameGeom
			}

			forEachCell(cs1, function(cell)
				unitTest:assertNotNil(cell.geom)
			end)

			proj.file:delete()
			layer:delete()
			cs1.layer:delete()
		end

		local saveWithMissing = function()
			local proj = createProject()

			local layer = gis.Layer{
				project = proj,
				name = "CellsAmaz",
				file = filePath("test/CellsAmaz.shp")
			}

			local currDir = {
				file = "CellsAmaz.shp",
				overwrite = true
			}

			layer:export(currDir)

			local layerCd = gis.Layer{
				project = proj,
				name = "layerCd",
				file = currDir.file
			}

			local cs = CellularSpace{
				project = proj,
				layer = layerCd.name,
				missing = 0
			}

			cs:save(layerCd.name, "pointcount")

			local newCs = CellularSpace{
				file = currDir.file
			}

			unitTest:assertEquals(newCs:sample().pointcount, 0)

			proj.file:delete()
			layerCd:delete()
		end

		local saveTifDirectory = function()
			local dir = Directory("csdir")

			if dir:exists() then
				dir:delete()
			end

			dir:create()

			local proj = createProject()

			local layer = gis.Layer{
				project = proj,
				name = "Tif",
				epsg = 5880,
				file = filePath("cabecadeboi-elevation.tif", "gis")
			}

			local toData1 = {file = File(tostring(dir).."/elevation1.tif"), overwrite = true}
			local toData2 = {file = File(tostring(dir).."/elevation2.tif"), overwrite = true}
			layer:export(toData1)
			layer:export(toData2)

			local cs = CellularSpace{
				directory = dir
			}

			forEachCell(cs, function(cell)
				cell.elevation3 = cell.elevation1 + cell.elevation2
				cell.elevation4 = cell.elevation1 + 4
			end)

			local outFile1 = File(tostring(dir).."/elevation3.tif"):deleteIfExists()
			local outFile2 = File(tostring(dir).."/elevation4.tif"):deleteIfExists()

			cs:save(outFile1, "elevation3")
			cs:save(outFile2, "elevation4")

			local newCs1 = CellularSpace{file = outFile1}
			local newCs2 = CellularSpace{file = outFile2}

			unitTest:assertEquals(#newCs1, #cs)
			unitTest:assertEquals(#newCs1, #newCs2)
			unitTest:assertEquals(#newCs1, 10000)

			for i = 0, #newCs1 - 1 do
				local s = tostring(i)
				unitTest:assertEquals(cs:get(s).elevation1, cs:get(s).elevation2)
				unitTest:assertEquals(cs:get(s).elevation3, cs:get(s).elevation1 + cs:get(s).elevation2)
				unitTest:assertEquals(newCs1:get(s).b0, (cs:get(s).elevation1 + cs:get(s).elevation2) % 256) --< 256 means 8 bits tif
				unitTest:assertEquals(newCs2:get(s).b0, (cs:get(s).elevation1 + 4) % 256)
			end

			dir:delete()
			proj.file:delete()
		end

		unitTest:assert(saveNewDataAndLayerPostgis)
		unitTest:assert(saveDoublePrecision)
		unitTest:assert(saveWithGeom)
		unitTest:assert(saveWithMissing)
		unitTest:assert(saveTifDirectory)
	end,
	synchronize = function(unitTest)
		local gis = getPackage("gis")
		local projName = "cellspace_basic.tview"
		local author = "Avancini"
		local title = "Cellular Space"

		local proj = gis.Project {
			file = projName,
			clean = true,
			author = author,
			title = title
		}

		local layerName1 = "Sampa"
		gis.Layer{
			project = proj,
			name = layerName1,
			file = filePath("test/sampa.shp", "gis")
		}

		local cs = CellularSpace{
			project = proj,
			layer = layerName1
		}

		cs:synchronize()

		unitTest:assertNil(cs:sample().past.geom)

		File(projName):deleteIfExists()
	end
}

