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
	belong = function(unitTest)
		local error_func = function()
			belong("2", "2")
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "table", "2"))
	end,
	call = function(unitTest)
		local error_func = function()
			call(Cell{}, 2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 2))

		error_func = function()
			call("value", "sum")
		end

		unitTest:assertError(error_func, "Cannot access elements from an object of type 'string'.")

		error_func = function()
			call(Cell{}, "sum")
		end

		unitTest:assertError(error_func, "Function 'sum' does not exist.")
	end,
	clone = function(unitTest)
		local error_func = function()
			clone(2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", 2))
	end,
	d = function(unitTest)
		local error_func = function()
			d()
		end

		unitTest:assertError(error_func, [[Error: bad arguments in diferential equation constructor "d{arguments}". TerraME has found 0 arguments.
 - the first attribute of a differential equantion must be a function which return a number. It can also be a table of functions like that,
 - the second one must be the initial condition value. It can also be a table of initial conditions,
 - the third one must be the lower integration limit value,
 - the fourth one must be the upper integration limit value, and
 - the fifth, OPTIONAL, must be the integration increment value (default = 0.2).
]])

		local myf = function() end

		error_func = function()
			d{{myf, myf}, {1}, 0, 0, 10}
		end

		unitTest:assertError(error_func, "You should provide the same number of differential equations and initial conditions.")
	end,
	forEachAgent = function(unitTest)
		local a = Agent{value = 2}
		local soc = Society{instance = a, quantity = 10}
		local c = Cell{}

		local error_func = function()
			forEachAgent(nil, function() end)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Society, Group, or Cell"))

		error_func = function()
			forEachAgent(soc)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function"))

		error_func = function()
			forEachAgent(c, function() end)
		end

		unitTest:assertError(error_func, "The Cell does not have a default placement. Please call Environment:createPlacement() first.")
	end,
	forEachAttribute = function(unitTest)
		local a = Agent{value = 2}
		local soc = Society{instance = a, quantity = 10}

		local error_func = function()
			forEachAttribute(soc, function() end)
		end

		unitTest:assertError(error_func, "#1 should be Cell or Agent, got Society.")

		error_func = function()
			forEachAttribute(soc:sample(), 2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function", 2))
	end,
	forEachCell = function(unitTest)
		local error_func = function()
			forEachCell()
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "CellularSpace, Trajectory, or Agent"))

		error_func = function()
			forEachCell(CellularSpace{xdim = 5})
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function"))
	end,
	forEachCellPair = function(unitTest)
		local cs1 = CellularSpace{xdim = 10}
		local cs2 = CellularSpace{xdim = 10}

		local error_func = function()
			forEachCellPair()
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "CellularSpace"))

		error_func = function()
			forEachCellPair(cs1)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "CellularSpace"))

		error_func = function()
			forEachCellPair(cs1, cs2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(3, "function"))
	end,
	forEachConnection = function(unitTest)
		local a = Agent{value = 2}
		local soc = Society{instance = a, quantity = 10}

		soc:createSocialNetwork{probability = 0.8}

		local error_func = function()
			forEachConnection(nil, function() end)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Agent"))

		error_func = function()
			forEachConnection(soc.agents[1])
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function or string"))

		error_func = function()
			forEachConnection(soc.agents[1], "1")
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(3, "function"))

		error_func = function()
			forEachConnection(soc.agents[1], "2", function() end)
		end

		unitTest:assertError(error_func, "Agent does not have a SocialNetwork named '2'.")
	end,
	forEachElement = function(unitTest)
		local error_func = function()
			forEachElement()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		local agent = Agent{w = 3, f = 5}

		error_func = function()
			forEachElement(agent)
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(2))

		error_func = function()
			forEachElement(agent, 12345)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function", 12345))

		error_func = function()
			forEachElement("abc", function() end)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", "abc"))
	end,
	forEachFile = function(unitTest)
		local error_func = function()
			forEachFile()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			forEachFile(2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Directory", 2))

		error_func = function()
			forEachFile(packageInfo("base").path.."data")
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(2))

		error_func = function()
			forEachFile("abcdef12345", function() end)
		end

		unitTest:assertError(error_func, "Directory '' is not valid or does not exist.", 0, true)

		error_func = function()
			forEachFile(packageInfo("base").path.."data", 2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function", 2))
	end,
	forEachModel = function(unitTest)
		local error_func = function()
			forEachModel()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			forEachModel(2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Environment", 2))

		error_func = function()
			forEachModel(Environment{})
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(2))

		error_func = function()
			forEachModel(Environment{}, 2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function", 2))
	end,
	forEachNeighbor = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		cs:createNeighborhood()
		local cell = cs:sample()

		local error_func = function()
			forEachNeighbor(nil, function() end)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Cell"))

		error_func = function()
			forEachNeighbor(cell)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function or string"))

		error_func = function()
			forEachNeighbor(cell, "1")
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(3, "function"))

		error_func = function()
			forEachNeighbor(cell, "2", function() end)
		end

		unitTest:assertError(error_func, "Neighborhood '2' does not exist.")
	end,
	forEachNeighborAgent = function(unitTest)
		Random():reSeed(12345)
		local predator = Agent{
			energy = 40,
			name = "predator",
			execute = function(self)
				self:move(self:getCell():getNeighborhood():sample())
			end
		}

		local predators = Society{
			instance = predator,
			quantity = 20
		}

		local error_func = function()
			forEachNeighborAgent(predators:sample(), function() end)
		end

		unitTest:assertError(error_func, "The Agent does not have a default placement. Please call Environment:createPlacement() first.")

		local cs = CellularSpace{xdim = 5}

		local env = Environment{cs, predators = predators}
		env:createPlacement{}

		error_func = function()
			forEachNeighborAgent(predators:sample(), function() end)
		end

		unitTest:assertError(error_func, "The CellularSpace does not have a default neighborhood. Please call 'CellularSpace:createNeighborhood' first.")

		cs:createNeighborhood()

		error_func = function()
			forEachNeighborAgent(nil, function() end)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Agent"))

		error_func = function()
			forEachNeighborAgent(predators:sample())
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function"))
	end,
	forEachNeighborhood = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local error_func = function()
			forEachNeighborhood(nil, function() end)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Cell"))

		error_func = function()
			forEachNeighborhood(cs:sample())
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function"))
	end,
	forEachOrderedElement = function(unitTest)
		local error_func = function()
			forEachOrderedElement()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			forEachOrderedElement({1, 2, 3})
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function"))

		error_func = function()
			forEachOrderedElement("abc", function() end)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", "abc"))
	end,
	forEachSocialNetwork = function(unitTest)
		local ag = Agent{}

		local error_func = function()
			forEachSocialNetwork(nil, function() end)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Agent"))

		error_func = function()
			forEachSocialNetwork(ag)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function"))
	end,
	getn = function(unitTest)
		local error_func = function()
			getn("2")
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", "2"))
	end,
	getNames = function(unitTest)
		local error_func = function()
			getNames(2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", 2))
	end,
	greaterByAttribute = function(unitTest)
		local error_func = function()
			greaterByAttribute(2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))

		error_func = function()
			greaterByAttribute("cover", "==")
		end

		unitTest:assertError(error_func, incompatibleValueMsg(2, "<, >, <=, or >=", "=="))
	end,
	greaterByCoord = function(unitTest)
		local error_func = function()
			greaterByCoord("==")
		end

		unitTest:assertError(error_func, incompatibleValueMsg(1, "<, >, <=, or >=", "=="))
	end,
	integrate = function(unitTest)
		local error_func = function()
			integrate()
		end

		unitTest:assertError(error_func, tableArgumentMsg())

		error_func = function()
			integrate{step = "a", equation = function() end, initial = 0}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("step", "number", "a"))

		error_func = function()
			integrate{step = -0.5, equation = function() end, initial = 0}
		end

		unitTest:assertError(error_func, positiveArgumentMsg("step", -0.5))

		error_func = function()
			integrate{step = 0.1, method = "eler", equation = function() end, initial = 0}
		end

		unitTest:assertError(error_func, switchInvalidArgumentSuggestionMsg("eler", "method", "euler"))

		error_func = function()
			integrate{equation = 0.1}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("equation", "table", 0.1))

		error_func = function()
			integrate{equation = function() end, initial = "aaa"}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("initial", "table", "aaa"))

		error_func = function()
			integrate{equation = {function() end, 2}}
		end

		unitTest:assertError(error_func, "Table 'equation' should contain only functions, got number.")

		error_func = function()
			integrate{equation = {function() end, function() end}, initial = {1, "b"}}
		end

		unitTest:assertError(error_func, "Table 'initial' should contain only numbers, got string.")

		error_func = function()
			integrate{equation = {function() end, function() end}, initial = {1, 2, 3}}
		end

		unitTest:assertError(error_func, "Tables equation and initial shoud have the same size.")

		local event = Event{start = 0.5, period = 2, priority = 1, action = function() end}

		error_func = function()
			integrate{equation = function() end, initial = 1, event = event, a = 2}
		end

		unitTest:assertError(error_func, "Argument 'a' should not be used together with argument 'event'.")

		error_func = function()
			integrate{equation = function() end, initial = 1, event = event, b = 2}
		end

		unitTest:assertError(error_func, "Argument 'b' should not be used together with argument 'event'.")
	end,
	levenshtein = function(unitTest)
		local error_func = function()
			levenshtein(2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))

		error_func = function()
			levenshtein("abc", 2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 2))
	end,
	round = function(unitTest)
		local error_func = function()
			x = round("a")
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "number", "a"))

		error_func = function()
			x = round(2.5, "a")
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "number", "a"))
	end,
	toLabel = function(unitTest)
		local error_func = function()
			x = toLabel(false)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", false))

		error_func = function()
			x = toLabel("abc", false)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", false))
	end,
	switch = function(unitTest)
		local error_func = function()
			switch("aaaab")
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", "aaaab"))

		error_func = function()
			switch({}, 2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 2))

		error_func = function()
			local data = {att = "abd"}
			switch(data, "att"):caseof{
				abc = function() end
			}
		end

		unitTest:assertError(error_func, switchInvalidArgumentSuggestionMsg("abd", "att", "abc"))

		local options = {
			xxx = true
		}

		error_func = function()
			local data = {att = "abd"}
			switch(data, "att"):caseof{
				xxx = function() end
			}
		end

		unitTest:assertError(error_func, switchInvalidArgumentMsg("abd", "att", options))

		error_func = function()
			local data = {att = "abd"}
			switch(data, "atx"):caseof{
				xxx = function() end
			}
		end

		unitTest:assertError(error_func, "Value of #2 ('atx') does not belong to #1.")

		error_func = function()
			local data = {att = "abd"}
			switch(data, "att"):caseof(2)
		end

		unitTest:assertError(error_func, namedArgumentsMsg())

		error_func = function()
			local data = {att = "abd"}
			switch(data, "att"):caseof{
				abd = 2
			}
		end

		unitTest:assertError(error_func, "Case 'abd' should be a function, got number.")
	end,
	vardump = function(unitTest)
		local mtable = {1, 2, 3}
		local vtable = {[mtable] = 2}

		local error_func = function()
			vardump(vtable)
		end

		unitTest:assertError(error_func, "Function vardump cannot handle an index of type table.")
	end,
	forEachRecursiveDirectory = function(unitTest)
		local file = File(packageInfo("base").path.."lua/Utils.lua")

		local wrongType = function()
			forEachRecursiveDirectory(file, function(_) end)
		end

		unitTest:assertError(wrongType, "Argument '#1' must be a 'Directory' or 'string' path.")
	end
}

