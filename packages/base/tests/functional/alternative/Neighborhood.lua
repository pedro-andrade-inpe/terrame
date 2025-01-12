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
	add = function(unitTest)
		local neigh = Neighborhood()
		local cell1 = Cell{}
		local cell2 = Cell{x = 0, y = 1}

		local error_func = function()
			neigh:add()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			neigh:add(112)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Cell", 112))

		error_func = function()
			neigh:add(cell1, "not_number")
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "number", "not_number"))

		error_func = function()
			neigh:add(cell2)
			neigh:add(cell2)
		end

		unitTest:assertError(error_func, "Cell 'C00L01' already belongs to the Neighborhood.")
	end,
	getWeight = function(unitTest)
		local cell1 = Cell{x = 0, y = 0}
		local neigh = Neighborhood()

		local error_func = function()
			neigh:getWeight()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			neigh:getWeight(12345)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Cell", 12345))

		error_func = function()
			neigh:getWeight(cell1)
		end

		unitTest:assertError(error_func, "Cell 'C00L00' does not belong to the Neighborhood.")
	end,
	isNeighbor = function(unitTest)
		local neigh = Neighborhood()

		local error_func = function()
			neigh:isNeighbor()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			neigh:isNeighbor(123)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Cell", 123))
	end,
	remove = function(unitTest)
		local neigh = Neighborhood()

		local error_func = function()
			neigh:remove()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			neigh:remove(123)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Cell", 123))

		error_func = function()
			neigh:remove(123)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Cell", 123))
	end,
	sample = function(unitTest)
		local neigh = Neighborhood()
		local c = Cell{}

		local error_func = function()
			neigh:sample()
		end

		unitTest:assertError(error_func, "It is not possible to sample the Neighborhood because it is empty.")

		neigh:add(c)
	end,
	setWeight = function(unitTest)
		local cell1 = Cell{}
		local neigh = Neighborhood()

		local error_func = function()
			neigh:setWeight()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			neigh:setWeight(12345)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Cell", 12345))

		error_func = function()
			neigh:setWeight(cell1)
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(2))

		error_func = function()
			neigh:setWeight(cell1, "notnumber")
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "number", "notnumber"))

		error_func = function()
			neigh:setWeight(cell1, 0.5)
		end

		unitTest:assertError(error_func, "Cell 'C00L00' does not belong to the Neighborhood.")
	end
}

