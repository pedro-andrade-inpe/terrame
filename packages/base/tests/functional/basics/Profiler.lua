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
	Profiler = function(unitTest)
		unitTest:assertType(Profiler(), "Profiler")
		local prof = Profiler()
		unitTest:assertEquals(prof, Profiler())
	end,
	start = function(unitTest)
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
		Profiler():start("test")
		unitTest:assertEquals(Profiler():current().name, "test")
		Profiler():start("test2")
		unitTest:assertEquals(Profiler():current().name, "test2")
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end,
	count = function(unitTest)
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
		Profiler():start("test1")
		unitTest:assertEquals(Profiler():count("test1"), 1)
		Profiler():stop("test1")
		Profiler():start("test2")
		unitTest:assertEquals(Profiler():count("test1"), 1)
		unitTest:assertEquals(Profiler():count("test2"), 1)
		Profiler():stop("test2")
		Profiler():start("test2")
		unitTest:assertEquals(Profiler():count("test2"), 2)
		Profiler():stop("test2")
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end,
	current = function(unitTest)
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
		local current = Profiler():current()
		Profiler():start("test")
		unitTest:assertEquals(Profiler():current().name, "test")
		Profiler():stop()
		unitTest:assertEquals(Profiler():current().name, current.name)
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end,
	uptime = function(unitTest)
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
		local timeString, timeNumber = Profiler():uptime("main")
		unitTest:assertType(timeString, "string")
		unitTest:assertType(timeNumber, "number")
		Profiler():start("test")
		local _, startTime = Profiler():uptime()
		delay(0.1)
		Profiler():stop("test")
		Profiler():start("test")
		delay(0.1)
		local _, currentTime = Profiler():uptime()
		unitTest:assert(startTime < currentTime)
		unitTest:assert(Profiler():stop("test").time < currentTime)
		_, currentTime = Profiler():uptime("test")
		delay(0.1)
		local _, uptime = Profiler():uptime("test")
		unitTest:assertEquals(currentTime, uptime)
		Profiler().blocks["test"].totalTime = 3600
		timeString = Profiler():uptime("test")
		unitTest:assertEquals(timeString, "1 hour")
		Profiler().blocks["test"].totalTime = 7250
		timeString = Profiler():uptime("test")
		unitTest:assertEquals(timeString, "2 hours")
		Profiler().blocks["test"].totalTime = 86401
		timeString = Profiler():uptime("test")
		unitTest:assertEquals(timeString, "1 day")
		Profiler().blocks["test"].totalTime = 86465321
		timeString = Profiler():uptime("test")
		unitTest:assertEquals(timeString, "1000 days and 18 hours")
		Profiler().blocks["test"].totalTime = 60
		timeString = Profiler():uptime("test")
		unitTest:assertEquals(timeString, "1 minute")
		Profiler().blocks["test"].totalTime = 125
		timeString = Profiler():uptime("test")
		unitTest:assertEquals(timeString, "2 minutes and 5 seconds")
		Profiler().blocks["test"].totalTime = 0
		timeString = Profiler():uptime("test")
		unitTest:assertEquals(timeString, "less than one second")
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end,
	clock = function(unitTest)
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
		local timeString, timeNumber = Profiler():clock("main")
		unitTest:assertType(timeString, "string")
		unitTest:assertType(timeNumber, "number")
		Profiler():start("test")
		local _, startTime = Profiler():clock()
		delay(0.1)
		Profiler():stop("test")
		Profiler():start("test")
		delay(0.1)
		local _, currentTime = Profiler():clock()
		unitTest:assert(startTime < currentTime)
		unitTest:assert(Profiler():stop("test").clock < currentTime)
		_, currentTime = Profiler():clock("test")
		delay(0.1)
		local _, clock = Profiler():clock("test")
		unitTest:assertEquals(currentTime, clock)
		Profiler().blocks["test"].totalClock = 3600
		timeString = Profiler():clock("test")
		unitTest:assertEquals(timeString, "1 hour")
		Profiler().blocks["test"].totalClock = 7250
		timeString = Profiler():clock("test")
		unitTest:assertEquals(timeString, "2 hours")
		Profiler().blocks["test"].totalClock = 86401
		timeString = Profiler():clock("test")
		unitTest:assertEquals(timeString, "1 day")
		Profiler().blocks["test"].totalClock = 86465321
		timeString = Profiler():clock("test")
		unitTest:assertEquals(timeString, "1000 days and 18 hours")
		Profiler().blocks["test"].totalClock = 60
		timeString = Profiler():clock("test")
		unitTest:assertEquals(timeString, "1 minute")
		Profiler().blocks["test"].totalClock = 125
		timeString = Profiler():clock("test")
		unitTest:assertEquals(timeString, "2 minutes and 5 seconds")
		Profiler().blocks["test"].totalClock = 0.15
		timeString = Profiler():clock("test")
		unitTest:assertEquals(timeString, "150 milliseconds")
		Profiler().blocks["test"].totalClock = 0.9999
		timeString = Profiler():clock("test")
		unitTest:assertEquals(timeString, "1 second")
		Profiler().blocks["test"].totalClock = 0.999
		timeString = Profiler():clock("test")
		unitTest:assertEquals(timeString, "999 milliseconds")
		Profiler().blocks["test"].totalClock = 1
		timeString = Profiler():clock("test")
		unitTest:assertEquals(timeString, "1 second")
		Profiler().blocks["test"].totalClock = 0.001
		timeString = Profiler():clock("test")
		unitTest:assertEquals(timeString, "1 millisecond")
		Profiler().blocks["test"].totalClock = 0
		timeString = Profiler():clock("test")
		unitTest:assertEquals(timeString, "0 milliseconds")
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end,
	stop = function(unitTest)
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
		Profiler():start("test1")
		delay(0.1)
		Profiler():start("test2")
		local tTable = Profiler():stop("test1")
		unitTest:assertType(tTable.strTime, "string")
		unitTest:assertType(tTable.strClock, "string")
		unitTest:assertType(tTable.time, "number")
		unitTest:assertType(tTable.clock, "number")
		unitTest:assert(tTable.time > Profiler():stop("test2").time)
		unitTest:assertEquals(Profiler():current().name, "main")
		Profiler():start("test1")
		unitTest:assertEquals(Profiler():current().name, "test1")
		Profiler():start("test2")
		unitTest:assertEquals(Profiler():current().name, "test2")
		Profiler():stop()
		unitTest:assertEquals(Profiler():current().name, "test1")
		Profiler():stop()
		unitTest:assertEquals(Profiler():current().name, "main")
		Profiler():start("test1")
		unitTest:assertEquals(Profiler():current().name, "test1")
		Profiler():start("test2")
		unitTest:assertEquals(Profiler():current().name, "test2")
		Profiler():stop("test1")
		unitTest:assertEquals(Profiler():current().name, "test2")
		Profiler():stop()
		unitTest:assertEquals(Profiler():current().name, "main")
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end,
	clean = function(unitTest)
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
		Profiler():clean()
		unitTest:assertEquals(Profiler():current().name, "main")
		Profiler():clean()
		Profiler():clean()
		unitTest:assertEquals(Profiler():current().name, "main")
		Profiler():start("test")
		unitTest:assertEquals(Profiler():current().name, "test")
		Profiler():clean()
		unitTest:assertEquals(Profiler():current().name, "main")
		unitTest:assertNil(Profiler().blocks["test"])
		unitTest:assert(not belong("test", Profiler().stack))
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end,
	report = function(unitTest)
		unitTest:assert(true)
	end,
	steps = function(unitTest)
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
		Profiler():start("test1")
		Profiler():steps("test1", 5)
		unitTest:assertEquals(Profiler():current().steps, 5)
		Profiler():steps("test2", 5)
		unitTest:assertEquals(Profiler():current().steps, 5)
		Profiler():start("test2")
		unitTest:assertEquals(Profiler():current().steps, 5)
		Profiler():stop("test2")
		unitTest:assertEquals(Profiler().blocks["test2"].steps, 5)
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end,
	eta = function(unitTest)
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
		Profiler():steps("test", 10)
		Profiler():start("test")
		delay(0.9)
		Profiler():stop("test")
		local timeString, timeNumber = Profiler():eta("test")
		unitTest:assertType(timeString, "string")
		unitTest:assertType(timeNumber, "number")
		unitTest:assertEquals(timeNumber, 10, 1)
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end
}
