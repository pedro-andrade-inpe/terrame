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
-- Authors: Pedro R. Andrade (pedro.andrade@inpe.br)
--#########################################################################################

--- A log file to save attributes of an object. The saved file uses the csv
-- standard: The first line contains the attribute names and the following lines
-- contains values according to the calls to notify().
-- @arg data.subject An Agent, Cell, CellularSpace, Society.
-- @arg data.file A string with the file name to be saved. The default value is "result.csv".
-- @arg data.separator A string with the separator. The default value is ",".
-- @arg data.select A vector of strings with the name of the attributes to be observed.
-- If it is only a single value then it can also be described as a string.
-- As default, it selects all the user-defined attributes of an object.
-- @usage LogFile{
--     subject = cs,
--     file = "cs.csv",
--     separator = ";"
-- }
LogFile = function(data)
	mandatoryTableArgument(data, "subject")
	defaultTableValue(data, "separator", ",")
	defaultTableValue(data, "file", "result.csv")

	if type(data.select) == "string" then data.select = {data.select} end

	if data.select == nil then
		data.select = {}
		if type(data.subject) == "Cell" then
			forEachElement(data.subject, function(idx, value, mtype)
				if not belong(mtype, {"number", "string", "boolean"}) then return end
				local size = string.len(idx)
				if not belong(idx, {"x", "y", "past"}) and string.sub(idx, size, size) ~= "_" then
					table.insert(data.select, idx)
				end
			end)
		elseif type(data.subject) == "Agent" then
			forEachElement(data.subject, function(idx, value, mtype)
				if not belong(mtype, {"number", "string", "boolean"}) then return end
				local size = string.len(idx)
				if string.sub(idx, size, size) ~= "_" then
					table.insert(data.select, idx)
				end
			end)
		elseif type(data.subject) == "CellularSpace" then
			forEachElement(data.subject, function(idx, value, mtype)
				if not belong(mtype, {"number", "string", "boolean"}) then return end
				local size = string.len(idx)
				if not belong(idx, {"minCol", "maxCol", "minRow", "maxRow", "ydim", "xdim"}) and string.sub(idx, size, size) ~= "_" then
					table.insert(data.select, idx)
				end
			end)
		elseif type(data.subject) == "Society" then
			forEachElement(data.subject, function(idx, value, mtype)
				if not belong(mtype, {"number", "string", "boolean"}) then return end
				table.insert(data.select, idx)
			end)
		else
			customError("Invalid type. LogFile only works with Cell, CellularSpace, Agent, and Society.")
		end

		verify(#data.select > 0, "The subject does not have at least one valid attribute to be used.")
	end

	mandatoryTableArgument(data, "select", "table")
	verify(#data.select > 0, "LogFile must select at least one attribute.")
	forEachElement(data.select, function(_, value)
		if data.subject[value] == nil then
			if  value == "#" then
				if data.subject.obsattrs == nil then
					data.subject.obsattrs = {}
				end

				data.subject.obsattrs["quantity_"] = true
				data.subject.quantity_ = #data.subject
			else
				customError("Selected element '"..value.."' does not belong to the subject.")
			end
		elseif type(data.subject[value]) == "function" then
			if data.subject.obsattrs == nil then
				data.subject.obsattrs = {}
			end

			data.subject.obsattrs[value] = true
		end
	end)

	if data.subject.obsattrs then
		forEachElement(data.subject.obsattrs, function(idx)
			for i = 1, #data.select do
				if data.select[i] == idx then
					data.select[i] = idx.."_"
					local mvalue = data.subject[idx](data.subject)
					data.subject[idx.."_"] = mvalue
				end
			end
		end)
	end

	verifyUnnecessaryArguments(data, {"subject", "select", "file", "separator"})

	for i = 1, #data.select do
		if data.select[i] == "#" then
			data.select[i] = "quantity_"
			data.subject.quantity_ = #data.subject
		end
	end

	local observerType = 2
	local observerParams = {}
	local subject = data.subject
	local id

	table.insert(observerParams, data.file)
	table.insert(observerParams, data.separator)

	if type(subject) == "CellularSpace" then
		id = subject.cObj_:createObserver(observerType, {}, data.select, observerParams, subject.cells)
	else
		id = subject.cObj_:createObserver(observerType, data.select, observerParams)
	end

	table.insert(createdObservers, {subject = data.subject, id = id})
	return id
end

