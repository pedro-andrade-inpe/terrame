--#########################################################################################
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2014 INPE and TerraLAB/UFOP -- www.terrame.org
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
-- Authors: 
--      Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--      Rodrigo Reis Pereira
--#########################################################################################

Timer_ = {
	type_ = "Timer",
	--- Add a new Event to the timer. If the Event has a start time less than the current
	-- simulation time then add() will prompt a warning (but the Event will be added).
	-- @arg event An Event.
	-- @usage timer:add(Event{...})
	add = function (self, event)
		mandatoryArgument(1, "Event", event)

		if self.events == nil then self.events = {} end

		table.insert(self.events, event)
		self.cObj_:add(event.cObj_)

		if event.cObj_:getTime() < self:getTime() then
			local msg = "Adding an Event with time ("..event.cObj_:getTime()..
				") before the current simulation time ("..self:getTime()..")."
			customWarning(msg)
		end
	end,
	--- Execute the Timer until a final time. It manages the Event queue according to their execution
	-- time and priority. The Event that has lower execution time and lower priority is executed at
	-- each step. It this Event does not return false it is scheduled to execute again according to
	-- its period. The Timer then repeats its execution again and again. It stops only when all its
	-- Events are scheduled to execute after the final time, or when there is no remaining Events.
	-- @arg finalTime A number representing the final time of the simulation.
	-- This argument is mandatory.
	-- @usage timer:execute(2013)
	execute = function(self, finalTime)
		mandatoryArgument(1, "number", finalTime)

		if finalTime < self:getTime() then
			local msg = "Simulating until a time ("..finalTime..
				") before the current simulation time ("..self:getTime()..")."
			customWarning(msg)
		end

		self.cObj_:execute(finalTime)
	end,
	--- Return the current simulation time.
	-- @usage print(timer:getTime())
	getTime = function(self)
		return self.cObj_:getTime()
	end,
	--- Notify every Observer connected to the Timer.
	-- @usage timer:notify()
	notify = function(self)
		local modelTime = self:getTime()
		self.cObj_:notify(modelTime)
	end,
	--- Reset the Timer to time minus infinite, keeping the same Event queue.
	-- @usage timer:reset()
	reset = function(self)
		self.cObj_:reset()
	end
}

metaTableTimer_ = {__index = Timer_, __tostring = _Gtme.tostring}

--- A Timer is an Event-based scheduler that executes and controls the simulation. It contains a
-- set of Events, allowing the simulation to work with processes that start
-- independently and act in different periodicities. Once it has a given simulation time,
-- it ensures that all the Events before that time were already executed.
-- @arg data.... A set of Events.
-- @usage timer = Timer{
--     Event{...},
--     Event{...},
--     -- ...
--     Event{...}
-- }
function Timer(data)
	if type(data) ~= "table" then
		if data == nil then
			data = {}
		else
			customError(tableArgumentMsg())
		end
	end
	
	local cObj = TeTimer()

	forEachOrderedElement(data, function(idx, value, mtype)
		if mtype == "Event" then
			cObj:add(value.cObj_)
		else
			incompatibleTypeError(idx, "Event", value)
		end
	end)
 
	data.cObj_ = cObj
	setmetatable(data, metaTableTimer_)
	cObj:setReference(data)
	return data
end

