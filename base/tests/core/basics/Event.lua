-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2014 INPE and TerraLAB/UFOP.
--
-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.
--
-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this library and its documentation.
--
-- Authors: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--          Pedro R. Andrade (pedro.andrade@inpe.br)
-------------------------------------------------------------------------------------------

return{
	Event = function(unitTest)
		local event = Event{action = function() end}

		unitTest:assertEquals(event:getTime(), 1)
		unitTest:assertEquals(event:getPeriod(), 1)
		unitTest:assertEquals(event:getPriority(), 0)
		unitTest:assertEquals(type(event), "Event")

		event = Event{start = 0.5, period = 2, priority = 1, action = function(event) end}

		unitTest:assertEquals(event:getTime(), 0.5)
		unitTest:assertEquals(event:getPeriod(), 2)
		unitTest:assertEquals(event:getPriority(), 1)
	
		event = Event{start = -1, period = 2, priority = -5.2, action = function(event) end}

		unitTest:assertEquals(event:getTime(), -1)
		unitTest:assertEquals(event:getPeriod(), 2)
		unitTest:assertEquals(event:getPriority(), -5.2)

		event = Event{start = 0.5, period = 2, priority = "verylow", action = function(event) end}
		unitTest:assertEquals(event:getPriority(), 10)

		event = Event{start = 0.5, period = 2, priority = "low", action = function(event) end}
		unitTest:assertEquals(event:getPriority(), 5)

		event = Event{start = 0.5, period = 2, priority = "medium", action = function(event) end}
		unitTest:assertEquals(event:getPriority(), 0)

		event = Event{start = 0.5, period = 2, priority = "high", action = function(event) end}
		unitTest:assertEquals(event:getPriority(), -5)

		event = Event{start = 0.5, period = 2, priority = "veryhigh", action = function(event) end}
		unitTest:assertEquals(event:getPriority(), -10)

		local ag = Agent{execute = function() end}
		local soc = Society{
			instance = ag,
			quantity = 5
		}
		local c = Cell{}
		local cs = CellularSpace{xdim = 5}

		forEachCell(cs, function(cell)
			cell.value = Random():integer(10)
		end)

		local traj = Trajectory{target = cs, greater = function(c1, c2) return c1.value > c2.value end}

		local t = Timer{
			Event{action = soc},
			Event{action = c},
			Event{action = cs},
			Event{action = ag},
			Event{action = traj}
		}

		t:execute(2)
	end,
--[[ #241
	config = function(unitTest)
		local event = Event{action = function(event) end}

		event:config(0.5, 2, 1)

		unitTest:assertEquals(event[1]:getTime(), 0.5) -- SKIP
		unitTest:assertEquals(event[1]:getPeriod(), 2) -- SKIP
		unitTest:assertEquals(event[1]:getPriority(), 1) -- SKIP
	
		event:config(1)

		unitTest:assertEquals(event[1]:getTime(), 1) -- SKIP
		unitTest:assertEquals(event[1]:getPeriod(), 2) -- SKIP
		unitTest:assertEquals(event[1]:getPriority(), 1) -- SKIP
	end,
--]]
	getParent = function(unitTest)
		unitTest:assert(true)
	end,
	getPeriod = function(unitTest)
		local event = Event{period = 2, action = function(event) end}
		unitTest:assertEquals(event:getPeriod(), 2)
	end,
	getPriority = function(unitTest)
		local event = Event{priority = -10, action = function(event) end}
		unitTest:assertEquals(event:getPriority(), -10)
	end,
	getTime = function(unitTest)
		local event = Event{start = -10, action = function(event) end}
		unitTest:assertEquals(event:getTime(), -10)
	end,
	__tostring = function(unitTest)
		local event = Event{start = -10, action = function(event) end}

		unitTest:assertEquals(tostring(event), [[action    function
cObj_     Event
period    number [1]
priority  number [0]
start     number [-10]
]])
	end
}

