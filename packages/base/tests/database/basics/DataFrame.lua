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
	DataFrame = function(unitTest)
		local filename = "dump.lua"
		local expected = DataFrame{
			{age = 1, wealth = 10, vision = 2},
			{age = 3, wealth =  8, vision = 1},
			{age = 3, wealth = 15, vision = 2}
		}

		expected:save(filename)
		local actual = DataFrame{file = filename}

		unitTest:assertEquals(#actual, #expected)

		for i = 1, 3 do
			unitTest:assertEquals(expected[i].age, actual[i].age)
			unitTest:assertEquals(expected[i].wealth, actual.wealth[i])
			unitTest:assertEquals(expected.vision[i], actual[i].vision)
		end

		File(filename):deleteIfExists()
	end,
	save = function(unitTest)
		local filename1 = "dump.lua"
		local filename2 = "dump.csv"

		local expected = DataFrame{
			{age = 1, wealth = 10, vision = 2},
			{age = 3, wealth =  8, vision = 1},
			{age = 3, wealth = 15, vision = 2}
		}

		expected:save(filename1)
		unitTest:assertFile(filename1)

		expected:save(filename2)
		unitTest:assertFile(filename2)
	end
}

