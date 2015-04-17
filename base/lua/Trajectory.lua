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

Trajectory_ = {
	type_ = "Trajectory",
	--- Add a new Cell to the Trajectory.
	-- @arg cell A Cell that will be added.
	-- @usage traj:add(cell)
	add = function(self, cell)
		mandatoryArgument(1, "Cell", cell)

		verify(not self:get(cell.x, cell.y), "Cell ("..cell.x..", "..cell.y..") already belongs to the Trajectory.")
		table.insert(self.cells, cell)
		self.cObj_:add(#self, cell.cObj_)
	end,
	--- Add a new Cell to the Trajectory.
	-- @arg cell A Cell that will be added.
	-- @usage traj:addCell(cell)
	-- @deprecated Trajectory:add
	addCell = function(self, cell)
		deprecatedFunction("addCell", "add")
	end,
	--- Retrieve a copy of the Trajectory, with the same parent, select, greater, and Cells.
	-- @usage copy = traj:clone()
	clone = function(self)
		local cloneT = Trajectory{
			target = self.parent,
			select = self.select,
			greater = self.greater,
			build = false
		}

		forEachCell(self, function(cell)
			cloneT:add(cell)
		end)
		return cloneT
	end,
	--- Apply a filter over the original CellularSpace. It returns true if the function was applied 
	-- sucessfully.
	-- @arg f A function (Cell)->boolean to filter the CellularSpace, adding to the Trajectory 
	-- only those Cells whose returning value is true. The default value is the previous filter 
	-- applied to the Trajectory.  
	-- @usage traj:filter(function(cell)
	--     return cell.cover = "forest"
	-- end)
	filter = function(self, f)
		optionalArgument(1, "function", f)

		if f then self.select = f end

		self.cells = {}
		self.cObj_:clear()

		if type(self.select) == "function" then
			for i, cell in ipairs(self.parent.cells) do
				if self.select(cell) then 
					table.insert(self.cells, cell)
					self.cObj_:add(i, cell.cObj_)
				end
			end
		else
			for i, cell in ipairs(self.parent.cells) do
				table.insert(self.cells, cell)
				self.cObj_:add(i, cell.cObj_)
			end
		end
	end,
	--- Return a Cell from the Trajectory given its x and y locations.
	-- If the Cell does not belong to the Trajectory then it will return nil.
	-- @arg xIndex The x location.
	-- @arg yIndex The y location.
	-- @usage traj:get(1, 1)
	get = function(self, xIndex, yIndex)
		mandatoryArgument(1, "number", xIndex)
		mandatoryArgument(2, "number", yIndex)

		local result
		forEachCell(self, function(cell)
			if cell.x == xIndex and cell.y == yIndex then
				result = cell
				return false
			end
		end)
		return result
	end,
	--- Return a cell given its x and y locations.
	-- @arg index a Coord.
	-- @usage traj:getCell(index)
	-- @deprecated Trajectory:get
	getCell = function(self, index)
		deprecatedFunction("getCell", "get")
	end,
	--- Randomize the Cells, changing their traversing order.
	-- @usage traj:randomize()
	randomize = function(self)
		local randomObj = Random()

		local numcells = #self
		for i = 1, numcells do
			local pos1 = randomObj:integer(1, numcells)
			local pos2 = randomObj:integer(1, numcells)
			local cell1 = self.cells[pos1]
			self.cells[pos1] = self.cells[pos2]
			self.cells[pos2] = cell1
		end
	end,
	--- Rebuild the Trajectory from the original data using the last filter and sort functions.
	-- @usage traj:rebuild()
	rebuild = function(self)
		self:filter()
		self:sort()
	end,
	--- Sort the current CellularSpace subset of the Trajectory. It returns a boolean value indicating
	--  whether the Trajectory was sucessfully sorted.
	-- @arg f A function (Cell, Cell)->boolean to sort the generated subset of Cells. It 
	-- returns true if the first one has priority over the second one. Default: No sorting function 
	-- will be applied.
	-- @see Utils:greaterByAttribute
	-- @see Utils:greaterByCoord
	-- @usage traj:sort(function(c, d)
	--     return c.dist < d.dist
	-- end)
	sort = function(self, f)
		optionalArgument(1, "function", f)

		if f then self.greater = f end

		if type(self.greater) == "function" then
			table.sort(self.cells, self.greater)
			self.cObj_:clear()
			for i, cell in ipairs(self.cells) do
				self.cObj_:add(i, cell.cObj_)
			end
		else
			customWarning("Cannot sort the Trajectory because there is no previous function.")
		end
	end
}

setmetatable(Trajectory_, metaTableCellularSpace_)
metaTableTrajectory_ = {
	__index = Trajectory_,
	--- Retrieve the number of Cells of the CellularSpace.
	-- @usage print(#traj)
	__len = function(self)
		return #self.cells
	end,
	__tostring = tostringTerraME
}

--- Type that defines a spatial trajectory over the Cells of a CellularSpace. It inherits 
-- CellularSpace; therefore it is possible to use all functions of such type within a Trajectory. For 
-- instance, calling Utils:forEachCell() also traverses Trajectories, and it is possible to create a 
-- Trajectory from another Trajectory.
-- @inherits CellularSpace
-- @arg data.target The CellularSpace over which the Trajectory will take place.
-- @arg data.select A function (Cell)->boolean to filter the CellularSpace, adding to the Trajectory
-- only those Cells whose returning value is true. If this argument is missing, all Cells will be 
-- included in the Trajectory. Note that, according to Lua language, if this function returns
-- anything but false or nil, the Cell will be added to the Trajectory.
-- @arg data.greater A function (Cell, Cell)->boolean to sort the generated subset of Cells. It 
-- returns true if the first one has priority over the second one. If this argument is missing, no 
-- sorting function will be applied. See Utils:greaterByAttribute() and Utils:greaterByCoord() as 
-- predefined options to sort objects.
-- @arg data.build A boolean value indicating whether the Trajectory will be computed or not when 
-- created. Default is true.
-- @output cells A vector of Cells pointed by the Trajectory.
-- @output parent The CellularSpace where the Trajectory takes place.
-- @output select The last function used to filter the Trajectory.
-- @output greater The last function used to sort the Trajectory.
--
-- @usage traj = Trajectory {
--     target = cs,
--     select = function(c)
--         return c.cover == "forest"
--     end,
--     greater = function(c, d)
--         return c.dist < d.dist
--     end
-- }
-- 
-- traj = Trajectory {
--     target = cs,
--     greater = function(c, d)
--         return c.dist < d.dist
--     end
-- }
-- 
-- traj = Trajectory {
--     target = cs,
--     build = false
-- }
function Trajectory(data)
	verifyNamedTable(data)

	checkUnnecessaryArguments(data, {"target", "build", "select", "greater"})

	if data.target == nil then
		mandatoryArgumentError("target")
	elseif type(data.target) ~= "CellularSpace" and type(data.target) ~= "Trajectory" then
		incompatibleTypeError("target", "CellularSpace or Trajectory", data.target)
	end

	defaultTableValue(data, "build", true)

	data.parent = data.target

	-- Copy the functions from the parent to the Trajectory (only those that do not exist)
	forEachElement(data.parent, function(idx, value, mtype)
		if mtype == "function" and data[idx] == nil then
			data[idx] = value
		end
	end)

	data.target = nil

	optionalTableArgument(data, "select", "function")
	optionalTableArgument(data, "greater", "function")

	local cObj = TeTrajectory()
	data.cObj_ = cObj
	data.cells = {}

	setmetatable(data, metaTableTrajectory_)

	if data.build then
		data:filter()
		if data.greater then data:sort() end
		data.build = nil
	end

	cObj:setReference(data)

	return data
end

