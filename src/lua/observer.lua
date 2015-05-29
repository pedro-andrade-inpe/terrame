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
-- Authors: Antonio Jose da Cunha Rodrigues
--          Rodrigo Reis Pereira
--#########################################################################################

-- Observer Types
local TME_OBSERVERS = {
	TEXTSCREEN         = 1,
	LOGFILE            = 2,
	TABLE              = 3,
	CHART              = 45,
	GRAPHIC            = 4,
	DYNAMICGRAPHIC     = 5,
	MAP                = 6,
	UDPSENDER          = 7,
	SCHEDULER          = 8,
	IMAGE              = 9,
	STATEMACHINE       = 10, 
	NEIGHBORHOOD       = 11,
	SHAPEFILE          = 12,
	TCPSENDER          = 13
}

local TME_OBSERVERS_USER = {
	["textscreen"]   = TME_OBSERVERS.TEXTSCREEN,
	["logfile"]      = TME_OBSERVERS.LOGFILE,
	["table"]        = TME_OBSERVERS.TABLE,
	["chart"]        = TME_OBSERVERS.CHART,
	["map"]          = TME_OBSERVERS.MAP,
	["udpsender"]    = TME_OBSERVERS.UDPSENDER,
	["scheduler"]    = TME_OBSERVERS.SCHEDULER,
	["image"]        = TME_OBSERVERS.IMAGE,
	["statemachine"] = TME_OBSERVERS.STATEMACHINE,
	["neighborhood"] = TME_OBSERVERS.NEIGHBORHOOD,
	["shapefile"]    = TME_OBSERVERS.SHAPEFILE,
	["tcpsender"]     = TME_OBSERVERS.TCPSENDER
}

-- Subject Types
local TME_TYPES = {
	CELL            = 1,
	CELLSPACE       = 2,
	NEIGHBORHOOD    = 3,
	TIMER           = 4,
	EVENT           = 5,
	AGENT           = 6,
	AUTOMATON       = 7,
	TRAJECTORY      = 8,
	ENVIRONMENT     = 9,
	SOCIETY         = 10
	-- MESSAGE          -- it isn't a Subject
	-- STATE            -- it isn't a Subject
	-- JUMPCONDITION    -- it isn't a Subject
	-- FLOWCONDITION    -- it isn't a Subject
}

local TME_TYPES_USER = {
	["Cell"]            = TME_TYPES.CELL,
	["CellularSpace"]   = TME_TYPES.CELLSPACE,
	["Neighborhood"]    = TME_TYPES.NEIGHBORHOOD,
	["Timer"]           = TME_TYPES.TIMER,
	["Event"]           = TME_TYPES.EVENT,
	["Agent"]           = TME_TYPES.AGENT,
	["Automaton"]       = TME_TYPES.AUTOMATON,
	["Trajectory"]      = TME_TYPES.TRAJECTORY,
	["Environment"]     = TME_TYPES.ENVIRONMENT,
	["Society"]         = TME_TYPES.SOCIETY
}

_Gtme.createdObservers = {}

-- OBSERVERS CREATION
-- TME_OBSERVERS.TEXTSCREEN
local function observerTextScreen(subjType, target, observerAttrs, datale)
	if datale.observer ~= nil then
		customError("Cannot attach observers of type 'textscreen' to other observers.", 4)
	end
	local observerParams = {}

	if subjType == TME_TYPES.AUTOMATON then
		local locatedInCell = datale.location
		if type(locatedInCell) ~= "Cell" then
			customError("Observing an Automaton requires argument 'location' to be a Cell, got "..type(locatedInCell)..".", 4)
		else
			table.insert(observerParams, locatedInCell)
		end
	end

	if target.cObj_ then
		if type(target) == "CellularSpace" then
			return target.cObj_:createObserver(TME_OBSERVERS.TEXTSCREEN, {}, observerAttrs, observerParams, target.cells)
		else
			return target.cObj_:createObserver(TME_OBSERVERS.TEXTSCREEN, observerAttrs, observerParams)
		end
	else
		return target:createObserver(TME_OBSERVERS.TEXTSCREEN, observerAttrs, observerParams)
	end	
end

-- TME_OBSERVERS.LOGFILE
local function observerLogFile(subjType, target, observerAttrs, datale)
	if datale.observer ~= nil then
		customError("Cannot attach observers of type 'logfile' to other observers.", 4)
	end

	local outfile = datale.outfile or "result_.csv"
	local separator = datale.separator or ";"

	local observerParams = {}
	if subjType == TME_TYPES.AUTOMATON then
		local locatedInCell = datale.location
		if type(locatedInCell) ~= "Cell" then
			incompatibleTypeError("location", "Cell", datale.location, 4)
		else 
			table.insert(observerParams, locatedInCell)
		end
	end 

	table.insert(observerParams, outfile)
	table.insert(observerParams, separator)

	if target.cObj_ then
		if type(target) == "CellularSpace" then
			return target.cObj_:createObserver(TME_OBSERVERS.LOGFILE, {}, observerAttrs, observerParams, target.cells)
		else
			return target.cObj_:createObserver(TME_OBSERVERS.LOGFILE, observerAttrs, observerParams)
		end
	else
		return target:createObserver(TME_OBSERVERS.LOGFILE, observerAttrs, observerParams)
	end	
end

-- TME_OBSERVERS.TABLE
local function observerTable(subjType, target, observerAttrs, datale)
	if datale.observer ~= nil then
		customError("Cannot attach observers of type 'table' to other observers.", 4)
	end

	local column1Label = datale.yLabel or "Attributes"
	local column2Label = datale.xLabel or "Values"
	local observerParams = {}
	if subjType == TME_TYPES.AUTOMATON then
		local locatedInCell = datale.location
		if type(locatedInCell) ~= "Cell" then
			customError("Observing an Automaton requires argument 'location' to be a Cell, got "..type(locatedInCell)..".", 4)
		else
			table.insert(observerParams, locatedInCell)
		end
	elseif (subjType == TME_TYPES.NEIGHBORHOOD) then
		column1Label = "Neighbor"
		column2Label = "Weight"
	end
	table.insert(observerParams, column1Label)
	table.insert(observerParams, column2Label)

	if target.cObj_ then
		if type(target) == "CellularSpace" then
			return target.cObj_:createObserver(TME_OBSERVERS.TABLE, {}, observerAttrs, observerParams, target.cells)
		else
			return target.cObj_:createObserver(TME_OBSERVERS.TABLE, observerAttrs, observerParams)
		end
	else
		return target:createObserver(TME_OBSERVERS.TABLE, observerAttrs, observerParams)
	end	
end

-- TME_OBSERVERS.CHART
local function observerChart(subjType, target, observerAttrs, datale)
	if datale.observer ~= nil then
		customError("Cannot attach observers of type 'chart' to other observers.", 4)
	end

	if not observerAttrs or type(observerAttrs) ~= "table" or #observerAttrs == 0 then
		customError("Chart observers must have at least one attribute.", 4)
	end

	if type(datale.curveLabels) ~= "table" then
		if datale.curveLabels == nil then
			datale.curveLabels = {}
			local str = "{"
			for i = 1, #datale.attributes do
				table.insert(datale.curveLabels,datale.attributes[i])
				str = str .. tostring(datale.attributes[i])
				if i ~= #datale.attributes then
					str = str ..","
				end
			end
			str = str .."}"
		else 
			incompatibleTypeError("curveLabels","table", datale.curveLabels, 4)
		end
	end
	
	if type(datale.yLabel) ~="string" then
		if datale.yLabel == nil then
			datale.yLabel = ""
		else
			incompatibleTypeError("yLabel","string", datale.yLabel, 4)
		end
	end
	
	if type(datale.xLabel) ~="string" then
		if datale.xLabel == nil then
			datale.xLabel = "time"
		else
			incompatibleTypeError("xLabel","string", datale.xLabel, 4)
		end
	end
	
	if type(datale.title) ~= "string" then
		if datale.title == nil then
			datale.title = ""
		else
			incompatibleTypeError("title","string", datale.title, 4)
		end
	end
	
	if type(datale.xAxis) ~="string" then
		if datale.xAxis == nil then
			--datale.xAxis = "time"
		else
			incompatibleTypeError("xAxis", "string", datale.xAxis, 4)		
		end	
	end

	local chartTitle = datale.title or ""
	local yLabel = datale.yLabel or ""
	local xLabel = datale.xLabel or ""
	local observerType = ""
	local curveLabels = ""

	local DEF_CURVE_NAME = ""
	local DEF_CURVE_SEP = ";"

	if type(datale.curveLabels) == "table" then
		local curveLabelsCount = #datale.curveLabels
		local attrCount = #observerAttrs

		if curveLabelsCount < attrCount then
			curveLabels = table.concat(datale.curveLabels, DEF_CURVE_SEP)
			for i = curveLabelsCount + 1, attrCount do 
				curveLabels = curveLabels..DEF_CURVE_SEP..DEF_CURVE_NAME..tostring(i)..DEF_CURVE_SEP
			end
		else
			curveLabels = table.concat(datale.curveLabels, DEF_CURVE_SEP)
		end
	end

	if datale.xAxis == nil then
		-- dynamic graphic
		observerType = TME_OBSERVERS.DYNAMICGRAPHIC
	else
		-- graphic
		observerType = TME_OBSERVERS.GRAPHIC
		table.insert(observerAttrs, datale.xAxis)
	end

	local observerParams = {}
	if subjType == TME_TYPES.AUTOMATO then
		local locatedInCell = datale.location
		if type(locatedInCell) ~= "Cell" then
			customError("Observing an Automaton requires argument 'location' to be a Cell, got "..type(locatedInCell)..".", 4)
		else
			table.insert(observerParams, locatedInCell)
		end
	end
	table.insert(observerParams, chartTitle)
	table.insert(observerParams, xLabel)
	table.insert(observerParams, yLabel)
	table.insert(observerParams, curveLabels)

	if datale.legends ~= nil then
		for i=1, #datale.legends do
			table.insert(observerParams, datale.legends[i])
		end
	end

	if target.cObj_ then
		if type(target) == "CellularSpace" then
			return target.cObj_:createObserver(observerType, {}, observerAttrs, observerParams, target.cells)
		else
			return target.cObj_:createObserver(observerType, observerAttrs, observerParams)
		end
	else
		return target:createObserver(observerType, observerAttrs, observerParams)
	end	
end

-- DEFAULT MAP AND IMAGE OBSERVERS LEGENDS colobar functions
local function getDefaultCellspaceNumberColorBars(i)
	local defaultCellspaceNumberColorBars = {
		{ {color = TME_LEGEND_COLOR.WHITE, value = 0}, {color = TME_LEGEND_COLOR.BLACK, value = 1} },
		{ {color = TME_LEGEND_COLOR.YELLOW, value = 0}, {color = TME_LEGEND_COLOR.BLUE, value = 1} },
		{ {color = TME_LEGEND_COLOR.GREEN, value = 0}, {color = TME_LEGEND_COLOR.RED, value = 1} }
	}
	--if i > 2 then return defaultCellspaceNumberColorBars[3]
	--else return defaultCellspaceNumberColorBars[i]
	return defaultCellspaceNumberColorBars[i % #defaultCellspaceNumberColorBars+1]
end

local function getDefaultCellspaceTextColorBars(i)
	local defaultCellspaceTextColorBars = {
		{ {color = TME_LEGEND_COLOR.WHITE, value = "WHITE"}, {color = TME_LEGEND_COLOR.BLACK, value = "BLACK"} },
		{ {color = TME_LEGEND_COLOR.YELLOW, value = "YELLOW"}, {color = TME_LEGEND_COLOR.BLUE, value = "BLUE"} },
		{ {color = TME_LEGEND_COLOR.GREEN, value = "GREEN"}, {color = TME_LEGEND_COLOR.RED, value = "GREEN"} }
	}
	return defaultCellspaceTextColorBars[i % #defaultCellspaceTextColorBars+1]
end

local function getDefaultCellspaceBooleanColorBars(i)
	local defaultCellspaceBooleanColorBars = {
		{ {color = TME_LEGEND_COLOR.WHITE, value = true}, {color = TME_LEGEND_COLOR.BLACK, value = false} },
		{ {color = TME_LEGEND_COLOR.YELLOW, value = true}, {color = TME_LEGEND_COLOR.BLUE, value = false} },
		{ {color = TME_LEGEND_COLOR.GREEN, value = true}, {color = TME_LEGEND_COLOR.RED, value = false} }
	}
	return defaultCellspaceBooleanColorBars[i % #defaultCellspaceBooleanColorBars+1]
end

local function getDefaultAgentColorBar(i)
	local defaultAgentColorBars = {  
		{ {color = TME_LEGEND_COLOR.GREEN, value = "state1"}, {color = TME_LEGEND_COLOR.RED, value = "state2"} }
	}
	return defaultAgentColorBars[i % #defaultAgentColorBars+1]
end

local function getDefaultAutomatonColorBar(i)
	local defaultAutomatonColorBars = {
		{ {color = TME_LEGEND_COLOR.GREEN, value = "state1"}, {color = TME_LEGEND_COLOR.RED, value = "state2"} }
	}
	return defaultAutomatonColorBars[i % #defaultAutomatonColorBars+1]
end

local function getDefaultTrajectoryColorBar(trajectorySize, i)
	local defaultTrajectoryColorBars = {
		{ {color = TME_LEGEND_COLOR.GREEN, value = 0}, {color = TME_LEGEND_COLOR.RED, value = trajectorySize } }
	}
	return defaultTrajectoryColorBars[i % #defaultTrajectoryColorBars+1]
end

local function getDefaultNeighborhoodColorBar(i)
	local defaultNeighborhoodColorBars = {  
		{ {color = TME_LEGEND_COLOR.GREEN, value = "GREEN"}, {color = TME_LEGEND_COLOR.RED, value = "RED"} }
	}
	return defaultNeighborhoodColorBars[i % #defaultNeighborhoodColorBars+1]
end

local function getDefaultSocietyColorBar(i)
	local defaultSocietyColorBar = {  
		{ {color = TME_LEGEND_COLOR.GREEN, value = "GREEN"}, {color = TME_LEGEND_COLOR.RED, value = "RED"} }
	}
	return defaultSocietyColorBar[i % #defaultSocietyColorBar+1]
end

-- OBSERVER MAP
-- In this function the second argument can assume two types of entities: a lua class ou a c++ one depending
-- on the target type. This is necessary for Society type.
-- Last argument is used only for trajectories
local function observerMap(subjType, target, tbDimensions, observerAttrs, datale, csCells, trajectorySize)
	if subjType == TME_TYPES.TRAJECTORY then
		observerAttrs = {"trajectory"}		
	elseif subjType == TME_TYPES.NEIGHBORHOOD then
		observerAttrs = {"weight"}
	elseif observerAttrs == nil or #observerAttrs > 2 or #observerAttrs == 0 then
		customError("Map observers must have exactly one or two attributes.", 4)
	end

	local observerParams = {}
	
	if type(datale.legends) ~= "table"  then
		if datale.legends == nil then
			datale.legends = {}
		else
			incompatibleTypeError("legends","table", datale.legends, 4)	
		end
	end
	
	if #datale.legends > 0 then
		local flagOk = true
		for i=1,#datale.legends do
			if type(datale.legends[i]) ~= "Legend" then
				flagOk = false
				break
			end
		end
		if not flagOk then
			customError("Argument 'legends' expects a set of Legend objects.", 4)
		end	
	end
	
	if #datale.legends == 0 then
		local caseof = {
			[TME_TYPES.CELLSPACE] = function()
				local cellspaceColorBar = ""
				local legs = {}
				for i=1,#observerAttrs do
					local t = type(csCells[1][observerAttrs[i]])
					local leg = {}
					if t == "number" then 
						leg = Legend{type = TME_LEGEND_TYPE.NUMBER, colorBar = getDefaultCellspaceNumberColorBars(i)}			
					elseif t == "boolean" then
						leg = Legend { grouping = TME_LEGEND_GROUPING.UNIQUEVALUE,
							maximum = 1, minimum = 0, 
							type = TME_LEGEND_TYPE.BOOL,
							colorBar = getDefaultCellspaceBooleanColorBars(i) 
						}
					else
						leg = Legend { grouping = TME_LEGEND_GROUPING.UNIQUEVALUE,
							maximum = 1, minimum = 0,
							type = TME_LEGEND_TYPE.TEXT,
							colorBar = getDefaultCellspaceTextColorBars(i)
						}
					end
					table.insert(legs, leg)
				end
				datale.legends = legs
			end,
			[TME_TYPES.AGENT] = function()
				local agentColorBar = getDefaultAgentColorBar(1)
				datale.legends = { Legend { colorBar = agentColorBar, type = "string" } }
			end,
			[TME_TYPES.AUTOMATON] = function()
				local automatonColorBar = getDefaultAutomatonColorBar(1)
				datale.legends = { Legend { colorBar = automatonColorBar } }
			end,
			[TME_TYPES.TRAJECTORY] = function()
				observerAttrs = {"trajectory"}
				local trajectoryColorBar = getDefaultTrajectoryColorBar(trajectorySize,1)
				datale.legends = { Legend { colorBar = trajectoryColorBar, slices = trajectorySize } }
			end,
			[TME_TYPES.NEIGHBORHOOD] = function()
				local neighborhoodColorBar = getDefaultNeighborhoodColorBar(1)
				datale.legends = { Legend { colorBar = neighborhoodColorBar } }
			end,
			[TME_TYPES.SOCIETY] = function()
				local societyColorBar = getDefaultSocietyColorBar(1)
				datale.legends = { Legend { colorBar = defaultSocietyColorBar } }
			end
		}
		caseof[subjType]()
	end

	if subjType == TME_TYPES.AUTOMATON or subjType == TME_TYPES.AGENT 
	   or subjType == TME_TYPES.TRAJECTORY or subjType == TME_TYPES.SOCIETY
	   or subjType == TME_TYPES.NEIGHBORHOOD then

		local csObserver = datale.observer
		if not csObserver then customError("Argument 'observer' not found.", 3) end
		local cs = csObserver.target
		table.insert(observerParams, cs)
		table.insert(observerParams, csObserver.id)
	end

	for i=1, #datale.legends do
		table.insert(observerParams, datale.legends[i])
	end

	if #tbDimensions ~= 0 then
		if type(observerAttrs) ~= "table" then
			incompatibleTypeError("attributes","table", observerAttrs, 3)
		elseif #observerAttrs == 0 or #observerAttrs > 2 then
			customError("Map observers must have exactly one or two attributes.", 3)
		end
		-- cellularspace
		-- #201
		-- return target.cObj_:createObserver(TME_OBSERVERS.MAP, tbDimensions, observerAttrs, observerParams, csCells)
		local idObs = target.cObj_:createObserver(TME_OBSERVERS.MAP, tbDimensions, observerAttrs, observerParams, csCells)
		target.cObj_:notify(0)
		target.cObj_:notify(0)
		return idObs
	else
		if type(target) == "Society" then
			local obsId = -1
			forEachAgent(target, function(ag)
				if ag.cObj_ == nil then
					customError("It is simple agent and it can not be observable.", 3)
				end
				obsId = ag.cObj_:createObserver(TME_OBSERVERS.MAP, observerAttrs, observerParams)
			end)
			target.observerId = obsId
			return obsId 
		else
			if target.cObj_ then
				return target.cObj_:createObserver(TME_OBSERVERS.MAP, observerAttrs, observerParams)
			else
				return target:createObserver(TME_OBSERVERS.MAP, observerAttrs, observerParams)
			end
		end
	end
end

-- OBSERVER NEIGHBORHOOD
local function observerNeighborhood(target, neighborhoods, datale)
	if #neighborhoods > 2 or #neighborhoods == 0 then
		customError("Neighborhood Observers must have exactly one or two neighborhoods.", 3)
	end

	local observerParams = {}
	local legends = datale.legends or {}

	csObserver = datale.observer
	if not csObserver then customError("Argument 'observer' was not found.", 3) end

	local mtype = csObserver.type
	if mtype ~= "map" and mtype ~= TME_OBSERVERS.MAP and mtype ~= "image" and mtype ~= TME_OBSERVERS.IMAGE then
		customError("Cannot attach observers of type '".. csObserver.type .."'.", 3)
	end

	local cs = csObserver.target
	if not cs or type(cs) ~= "CellularSpace" then
		customError("Basis observer is not related to a CellularSpace.", 3)
	end

	table.insert(observerParams, cs)
	table.insert(observerParams, csObserver.id)

	for i = 1, #legends do
		table.insert(observerParams, legends[i])
	end

	obs = target.cObj_:createObserver(TME_OBSERVERS.NEIGHBORHOOD, neighborhoods, observerParams)
	target.observerId = obs
	return obs
end

-- OBSERVER IMAGE
-- Last argument is used only for trajectories
local function observerImage(subjType, target, tbDimensions, observerAttrs, datale, csCells, trajectorySize)
	if subjType == TME_TYPES.TRAJECTORY then
		observerAttrs = {"trajectory"}
	elseif subjType == TME_TYPES.NEIGHBORHOOD then
		observerAttrs = {"weight"}		
	elseif type(observerAttrs) ~= "table" then
		if observerAttrs == nil then
			customError("Image observers must have exactly one or two attributes.", 4)
		else
			incompatibleTypeError("attributes","table", observerAttrs, 4)
		end
	elseif #observerAttrs > 2 or #observerAttrs == 0 then
		customError("Image observers must have exactly one or two attributes.", 4)   
	end

	local observerParams = {}
	local legends = datale.legends or {} 

	if subjType == TME_TYPES.CELLSPACE or subjType == TME_TYPES.AUTOMATON then
		local path = datale.path or "."
		local prefix = datale.prefix or "result_"
		observerParams = { path, prefix }
	end

	if not datale.legends then datale.legends = {} end

	if #datale.legends == 0 then
		if subjType == TME_TYPES.CELLSPACE then
			local cellspaceColorBar = ""
			local legs = {}
			if observerAttrs == nil then observerAttrs = {} end
			for i = 1, #observerAttrs do
				local t = type(csCells[1][observerAttrs[i]])
				local leg = {}
				if t == "number" then
					leg = Legend { type = TME_LEGEND_TYPE.NUMBER, colorBar = getDefaultCellspaceNumberColorBars(i) }
				elseif t == "boolean" then
					leg = Legend {  type = TME_LEGEND_TYPE.BOOL, colorBar = getDefaultCellspaceBooleanColorBars(i) }
				else
					leg = Legend { type = TME_LEGEND_TYPE.TEXT, colorBar = getDefaultCellspaceTextColorBars(i) }
				end
				table.insert(legs, leg)
			end
			datale.legends = legs
		elseif subjType == TME_TYPES.AGENT then
			local agentColorBar = getDefaultAgentColorBar(1)
			datale.legends = { Legend { colorBar = agentColorBar, type = "string" } }
		elseif subjType == TME_TYPES.AUTOMATON then
			local automatonColorBar = getDefaultAutomatonColorBar(1)
			datale.legends = { Legend { colorBar = automatonColorBar } }
		elseif subjType == TME_TYPES.TRAJECTORY then
			observerAttrs = {"trajectory"}
			local trajectoryColorBar = getDefaultTrajectoryColorBar(trajectorySize,1)
			datale.legends = { Legend { colorBar = trajectoryColorBar, slices = trajectorySize } }
		elseif subjType == TME_TYPES.NEIGHBORHOOD then
			local neighborhoodColorBar = getDefaultNeighborhoodColorBar(1)
			datale.legends = { Legend { colorBar = neighborhoodColorBar } }
		elseif subjType == TME_TYPES.SOCIETY then
			local societyColorBar = getDefaultSocietyColorBar(1)
			datale.legends = { Legend { colorBar = defaultSocietyColorBar } }
		elseif subjType == TME_TYPES.NEIGHBORHOOD then
			local neighborhoodColorBar = getDefaultNeighborhoodColorBar(1)
			datale.legends = { Legend { colorBar = neighborhoodColorBar } }
		end
	end

	if subjType == TME_TYPES.AUTOMATON or subjType == TME_TYPES.AGENT 
		or subjType==TME_TYPES.TRAJECTORY or subjType == TME_TYPES.SOCIETY
		or subjType == TME_TYPES.NEIGHBORHOOD then

		local csObserver = datale["observer"]
		if (not csObserver) then customError("Argument 'observer' not found.") end

		local cs = csObserver.target
		if not cs then customError("Argument 'cellspace' not found.") end

		table.insert(observerParams, cs)
		table.insert(observerParams, csObserver.id)
	end

	for i = 1, #datale.legends do
		table.insert(observerParams, datale.legends[i])
	end

	if #tbDimensions ~= 0 then
		if type(observerAttrs) ~= "table" then
			incompatibleTypeError("attributes","table", observerAttrs, 3)
		elseif #observerAttrs == 0 or #observerAttrs > 2 then
			customError("Image observers must have exactly one or two attributes.", 3)
		end

		-- #201
		-- return target.cObj_:createObserver(TME_OBSERVERS.IMAGE, tbDimensions, observerAttrs, observerParams, csCells)
		local idObs = target.cObj_:createObserver(TME_OBSERVERS.IMAGE, tbDimensions, observerAttrs, observerParams, csCells)
		target.cObj_:notify(0)
		target.cObj_:notify(0)
		return idObs
	else
		if type(target) == "Society" then
			local obsId = -1
			forEachAgent(target, function(ag)
				if ag.cObj_ == nil then
					customError("It is simple agent and it can not be observable.", 3)
				end
				obsId = ag.cObj_:createObserver(TME_OBSERVERS.IMAGE, observerAttrs, observerParams)
			end)
			target.observerId = obsId
			return obsId 
		else
			if target.cObj_ then
				return target.cObj_:createObserver(TME_OBSERVERS.IMAGE, observerAttrs, observerParams)
			else
				return target:createObserver(TME_OBSERVERS.IMAGE, observerAttrs, observerParams)
			end
		end
	end
end

-- OBSERVER UDPSENDER
local function observerUDPSender(subjType, target, tbDimensions, observerAttrs, datale,csCells)
	local observerParams = {}
  
	if datale.port and type(datale.port) ~="number" then
		incompatibleTypeError("port", "number", datale.port, 4)
	elseif type(datale.port) =="number" then
		local pt = datale.port
		-- #200
		if pt == 80 or pt == 8080 then
			customError("Observers UDP should not use system ports.", 4)
		end
	end
	local port = datale.port or 456456
	port = "".. port
	if datale.hosts and type(datale.hosts) ~= "table" then
		incompatibleTypeError("hosts","table", datale.hosts, 4)   
	elseif datale.hosts then
		if datale.hosts and #datale.hosts == 0 then
			datale.hosts = nil
		else
			local flag = true
			for i = 1, getn(datale.hosts) do
				if type(datale.hosts[i]) ~= "string" then
					flag = false
					break
				end		
			end
			if not flag then
				customError("Attribute 'hosts' must be a string table.", 4)
			end	  
		end
	end

	if observerAttrs then
		local flag = true
		local attr = ""
		for i=1, getn(observerAttrs) do
			if observerAttrs[i] ~= "currentState" and not target[observerAttrs[i]] then
				flag = false
				attr = observerAttrs[i]
				break
			end
		end
		if not flag then
			customError("Attribute '".. attr .."' not found.", 4)
		end
	end

	local hosts = datale.host or {""}

	-- if visible argument not exist so it is defined as true (default)
	if datale.visible ~= nil and datale.visible == false then
		observerParams.visible = datale.visible
	end

	-- if compress argument not exist so it is defined as false (default)
	if datale.compress ~= nil and datale.compress == true then
		observerParams.compress = datale.compress
	end
	table.insert(observerParams, port)

	for i = 1, #hosts do
		table.insert(observerParams, hosts[i])
	end

	if #tbDimensions ~= 0 then
		-- cellularspace
		local aux = observerParams
		observerParams = {aux}
		return target.cObj_:createObserver(TME_OBSERVERS.UDPSENDER, tbDimensions, observerAttrs, observerParams, csCells)
	end

	if target.cObj_ then
		return target.cObj_:createObserver(TME_OBSERVERS.UDPSENDER, observerAttrs, observerParams)
	else
		return target:createObserver(TME_OBSERVERS.UDPSENDER, observerAttrs, observerParams)
	end
end

-- OBSERVER TCPSENDER
local function observerTCPSender(subjType, target, tbDimensions, observerAttrs, datale,csCells)
	local observerParams = {}
	local port = datale.port or 456456
	local hosts = datale.hosts or {""}

	-- if visible argument not exist so it is defined as true (default)
	if datale.visible ~= nil and datale.visible == false then
		observerParams.visible = datale.visible
	end

	-- if compress argument not exist so it is defined as false (default)
	if datale.compress ~= nil and datale.compress == true then
		observerParams.compress = datale.compress
	end
	table.insert(observerParams, port)

	for i=1,#hosts,1 do
		table.insert(observerParams, hosts[i])
	end

	if #tbDimensions ~= 0 then
		-- cellularspace
		local aux = observerParams
		observerParams = {aux}
		return target.cObj_:createObserver(TME_OBSERVERS.TCPSENDER, tbDimensions, observerAttrs, observerParams, csCells)
	end
	if subjType == TME_TYPES.CELL then
		return target.cObj_:createObserver(TME_OBSERVERS.TCPSENDER, observerAttrs, observerParams)
	else
		customError("Observer TCP not implemented for this target!!!", 3);
	end
	
	-- if target.cObj_ then
		-- return target.cObj_:createObserver(TME_OBSERVERS.TCPSENDER, observerAttrs, observerParams)
	-- else
		-- return target:createObserver(TME_OBSERVERS.TCPSENDER, observerAttrs, observerParams)
	-- end
end

-- OBSERVER SCHEDULER
local function observerScheduler(subjType, target, observerAttrs, datale)
	local observerAttrs = {}
	local observerParams = {"", ""}

	if target.cObj_ then
		return target.cObj_:createObserver(TME_OBSERVERS.SCHEDULER, observerAttrs, observerParams)
	else
		return target:createObserver(TME_OBSERVERS.SCHEDULER, observerAttrs, observerParams)
	end
	--return target:createObserver(TME_OBSERVERS.SCHEDULER, observerAttrs, observerParams)
end

-- OBSERVER STATEMACHINE
local function observerStateMachine(subjType, target, observerAttrs, datale)
	local observerAttrs = {"currentState"}	   
		
	if type(datale.legends) ~= "table"  then
		if datale.legends == nil then
			datale.legends = {}
		else
			incompatibleTypeError("legends","table", datale.legends, 4)	
		end
	end
	
	local legends = datale.legends

	if #legends > 1 then
		customError("State machine observers can have only one legend.", 3)
	end

	local observerParams = {}
	if subjType == TME_TYPES.AUTOMATON then
		local locatedInCell = datale.location
		if type(locatedInCell) ~= "Cell" then
			customError("Observing an Automaton requires argument 'location' to be a Cell, got "..type(locatedInCell)..".", 3)
		else 
			table.insert(observerParams,locatedInCell)
		end
	end
	table.insert(observerParams, legends[1])

	if target.cObj_ then
		return target.cObj_:createObserver(TME_OBSERVERS.STATEMACHINE, observerAttrs, observerParams)
	else
		return target:createObserver(TME_OBSERVERS.STATEMACHINE, observerAttrs, observerParams)
	end
	--return target.cObj_:createObserver(TME_OBSERVERS.STATEMACHINE, observerAttrs, observerParams)
end

-- OBSERVER SHAPEFILE
-- In this function the second argument can assume two types of entities: a lua class ou a c++ one
-- depending on the target type. This is necessary for Society type.
-- Last argument is used only for trajectories
local function observerShapefile(subjType, target, tbDimensions, observerAttrs, datale, csCells, trajectorySize)
	if #observerAttrs > 2 or #observerAttrs == 0 then
		customError("Map observers must have exactly one or two attributes.", 3)
	end
	if subjType ~= TME_TYPES.CELLSPACE then
		customError("The target for Observer Shapefile should be a CellularSpace.", 3)
	end

	local observerParams = {}
	if not datale.legends then datale.legends = {} end

	if #datale.legends == 0 then
		local cellspaceColorBar = ""
		local legs = {}
		for i=1,#observerAttrs do
			local t = type(csCells[1][observerAttrs[i]])
			local leg = {}
			if t == "number" then
				leg = Legend { type = TME_LEGEND_TYPE.NUMBER, colorBar = getDefaultCellspaceNumberColorBars(i) }			
			elseif t == "boolean" then
				leg = Legend { grouping = TME_LEGEND_GROUPING.UNIQUEVALUE,
					maximum = 1, minimum = 0, 
					type = TME_LEGEND_TYPE.BOOL,
					colorBar = getDefaultCellspaceBooleanColorBars(i) 
				}
			else
				leg = Legend { grouping = TME_LEGEND_GROUPING.UNIQUEVALUE,
					maximum = 1, minimum = 0,
					type = TME_LEGEND_TYPE.TEXT,
					colorBar = getDefaultCellspaceTextColorBars(i)
				}
			end
			table.insert(legs, leg)
		end
		datale.legends = legs
	end

	for i=1, #datale.legends do
		table.insert(observerParams, datale.legends[i])
	end

	if #tbDimensions ~= 0 then
		return target.cObj_:createObserver(TME_OBSERVERS.SHAPEFILE, tbDimensions, observerAttrs, observerParams, csCells)
	else
		if target.cObj_ then
			return target.cObj_:createObserver(TME_OBSERVERS.SHAPEFILE, observerAttrs, observerParams)
		else
			return target:createObserver(TME_OBSERVERS.SHAPEFILE, observerAttrs, observerParams)
		end
	end
end

-- Constructor for Observers
Observer_ = {
	type_ = "Observer",
	--- Kill the observer itself.
	-- @arg func A function that can be used when observing a Society. It takes an Agent as 
	-- argument and returns true if the Agent should not be observed anymore.
	-- @usage observer:kill()
	kill = function(self, func)
		if self.target.cObj_ then 
			if self.type == TME_OBSERVERS.NEIGHBORHOOD or self.type == "neighborhood" then
				return self.target.cObj_:kill(self.id, self.observer.target.cObj_)
			else
				return self.target.cObj_:kill(self.id)
			end
		else
			if type(self.target) == "Society" then
				return self.target:remove(func)
			else
				return false
			end
		end
	end,
	--- Kill all the observers connected to a Society.
	-- @usage observer:killAll()
	killAll = function(self)
		if type(self.target) == "Society" then
			return self.target:remove(function() return true end)
		else
			customError("This function is not applicable to this type.")
		end
	end
}

local observerPossibleParams = {"type", "target", "attributes", "xAxis", "xLabel", "yLabel", "title", "curveLabels", "legends", "path", "location", "outfile", "separator", "prefix", "observer",--[["cellspace",]] "neighIndex", "neighType", "port", "hosts"}
--- Observer is the way to collect data from the objects of a model in order to save, toi
-- graphically plot them, or to send them to another computer. Observers can be created from any
-- TerraME object that has a built-in function called notify(). This function needs to be called
-- to update its observers because they are passive objects. Observers do not need to be put into
-- an object to exist, as in the second example on the left side.
-- Default values of observer types depend on the arguments. See table below for a description on how it works.
-- @arg data.type A string to define the way to observe a given object. See the table below.
-- @arg data.attributes A vector of strings with the name of the attributes to be observed. If it is only a
-- single value then it can also be described as a string. 
-- @arg data.file Name of the file to be saved. In the case of images, it represent the fixed
-- part of the file name that will be concatenated with a timestamp and ".png". In the case of
-- logfiles, it must be a file ending with ".csv". Default value is "result_" for image files and
-- result_.csv for logfiles.
-- @arg data.host A string or a vector of strings with host names for udpsenders.
-- @arg data.legends A Legend or a vector of Legends to paint objects according to their properties.
-- @arg data.location A Cell representing a location to observe an Automaton.
-- @arg data.neighIndex A string or a vector of strings representing the neighborhood indexes to
-- be drawn by a neighborhood observer. Default is "1".
-- @arg data.neighType One of three strings, "basic" (default), "color", or "width", for
-- neighborhood observers. Basic type draws neighborhoods as lines with the same color and width.
-- Color draws them using colors according to their weights. Width draws them with widths
-- according to their weights. All them use the attribute width of Legends. The first two use it as
-- width for all lines, while the last one interpolates the weights of the relations to draw widths
-- between one pixel and the Legend width.
-- @arg data.observer An Observer that will be used as background for drawing properties of observed objects that canxnot be drawn alone.
-- @arg data.port A string or a vector of strings with ports for the respective host names to be used by udpsenders.
-- @arg data.separator The attribute separator character (i.e., ";"). Used only for logfiles.
-- @arg data.target The TerraME object that will be observed.
-- @arg data.title An overall title to the observer.
-- @arg data.xaxis A string representing the attribute to be used as x axis in a chart observer. When nil, time will be used as axis.
-- @arg data.xLabel Name of the x-axis. It does not show any label as default.
-- @arg data.yLabel Name of the y-axis. It does not show any label as default.
-- @arg data.curveLabels Vector of the same size of attributes that indicates the labels for each
-- line of a chart. Default is the name of the attributes.
-- @tabular type
-- Type & Description & Compulsory arguments & Optional arguments \
-- "chart" & Create a line chart showing the variation of one or more attributes (y axis) of an
-- object. X axis values come from the single argument of notify(). & target, attributes & xaxis, xLabel, yLabel, title, curveLabels \
-- "image" & Create a map with the spatial distribution of a given Agent, CellularSpace, Society or
-- Trajectory, saving it in a png file for each notify(). It works in the same way of the observer map. & target, attributes & file, legends \
-- "logfile" & Save attributes of an object into a csv text file, with one row for each notify(). & target, file, attributes, separator & \ 
-- "map" & Create a map with the spatial distribution of a given CellularSpace, Trajectory, Agent,
-- or Society. It draws each element into the screen, according to one or two attributes (two is
-- allowed only for CellularSpace) colored from one or two Legends, respectively. The second
-- attribute and Legend are used as background. & target, attributes, observer (unless when the
-- target is a CellularSpace), legends & \
-- "neighborhood" & Draw the Neighborhood of a Cell, or the Neighborhoods of each Cell within a
-- Trajectory, CellularSpace, or Environment. They are drawn as lines, according to a neighType.
-- & target, observer & neighIndex, neighType \
-- "scheduler" & Create a display with the current time and Event queue of a given Timer. & target & \
-- "statemachine" & Draw the state machine of an Automaton in a Cell or an Agent. As default,
-- states are drawn as gray circles with a green circle to represent the current state. Unique
-- value Legends can be used to map state names to colors, putting the current state in evidence
-- with bold font. & target, location (only when the target is an Automaton), legends & \
-- "table" & Display a table with the current attributes of an object. Each notify() overwrites the previous values. & target, attributes & \
-- "textscreen" & Create a display in a tabular format with the current attributes of an object. It will have one row for each notify(). &
-- target, attributes & \
-- "udpsender" & Send observed attributes of an object through a UDP port of a given IP. &  target, attributes, host, port & 
--
-- @usage observer1 = Observer {
--	 target = cs,
--	 attributes = "water",
--	 legends = {soilWaterLeg}
-- }
-- 
-- Observer {
--	 target = trajectory,
--	 observer = observer
-- }
-- 
-- observer3 = Observer {
--	 target = cell,
--	 type = "chart",
--	 attributes = {"water"}
-- }
-- @tabular default_arguments
-- Arguments, from higher to lower priority &
-- Default type \
-- file == "*.csv"  &
-- logfile \
-- file ~= nil &
-- image \
-- host ~= nil or port ~= nil &
-- udpsender \
-- neighIndex ~= nil or neighType ~= nil &
-- neighborhood \
-- type(target) == "Timer" &
-- scheduler \
-- type(target) == "Event" &
-- table \
-- type(target) == "CellularSpace" &
-- map \
-- type(target) == "Trajectory" &
-- map \
-- type(observer) == "Observer" and type(target) == "Cell" &
-- neighborhood \
-- type(target) == "Cell" &
-- table \
-- type(target) == "Automaton" &
-- map \
-- type(target) == "Agent" &
-- statemachine \
-- type(target) == "Society" &
-- map \
-- type(target) == "Group" &
-- map \
function _Gtme.Observer(data)
	if type(data.target) == "CellularSpace" then
		if type(data.attributes) == "table" then
			local att = data.attributes[1]
			if type(data.target:sample()[att]) == "function" then
				forEachCell(data.target, function(cell)
					cell[att.."_"] = cell[att](cell)
				end)
				data.target.attrfunc_ = {att}
				if data.curveLabels == nil then
					data.curveLabels = {data.attributes[1]}
				end
				data.attributes[1] = data.attributes[1].."_"
			end
		end
	end

	if type(data.target) == "Society" then
		if type(data.attributes) == "table" then
			local att = data.attributes[1]
			if type(data.target[att]) == "function" then
				data.target[att.."_"] = data.target[att](data.target)
				if data.target.attrfunc_ == nil then
					data.target.attrfunc_ = {}
				end
				
				table.insert(data.target.attrfunc_, att)
				if data.curveLabels == nil then
					data.curveLabels = {data.attributes[1]}
				end
				data.attributes[1] = data.attributes[1].."_"
			end
		elseif data.attributes == nil then
			if data.target.attrfunc_ == nil then
				data.target.attrfunc_ = {}
			end
			if data.curveLabels == nil then
				data.curveLabels = {"quantity"}
			end
			data.target["quantity_"] = #data.target
			data.attributes = {"quantity_"}
			table.insert(data.target.attrfunc_, "quantity_")
		end
	end

	if type(data) ~= "table" then
		if data == nil then
			tableArgumentError("Observer", 3)
		else
 			namedArgumentsError("Observer", 3)
		end
	elseif getn(data) == 0 then
		customError("Observer needs more information to be created.", 3)
	end

	local t = type(data.target)
	if t ~= "Agent" and t ~= "Automaton" and t ~= "Cell" and t ~= "CellularSpace" and t ~= "Environment"
	and t ~= "Event" and t ~= "table" and t ~= "Neighborhood" and t ~= "Society" and t ~= "Timer" and t ~= "Trajectory" then
		incompatibleTypeError("target","one of the following types [Agent, Automaton, Cell, CellularSpace, Environment, Event, Neighborhood, Society, Timer, Trajectory]", data.target, 3)
	else
		if t == "Agent" or t == "Automaton" then
			if data.type == "map" or data.type == "image" then
				if type(data.observer) ~= "Observer" then
					incompatibleTypeError("observer","Observer", data.observer, 3)
				else
					if data.observer.type ~= data.type then
						customError("Cannot attach observers of different types. Only 'image' and 'map' observers can be attached.", 3)
					elseif data.type ~= "image" and data.type ~= "map" then
						customError("Cannot attach observers of type '".. type(data.observer.type) .."' to other observers. Only 'image' and 'map' observers can be attached.", 3)
					end
				end
			end
		end
		if type(data.type) ~= "string" then
			local caseof = {
				[TME_TYPES.CELL] = TME_OBSERVERS.TABLE,
				[TME_TYPES.CELLSPACE] = TME_OBSERVERS.MAP,
				[TME_TYPES.TIMER] = TME_OBSERVERS.SCHEDULER,
				[TME_TYPES.EVENT] = TME_OBSERVERS.TABLE,
				[TME_TYPES.AGENT] = TME_OBSERVERS.MAP,
				[TME_TYPES.AUTOMATON] = TME_OBSERVERS.MAP,
				[TME_TYPES.TRAJECTORY] = TME_OBSERVERS.MAP,
				[TME_TYPES.SOCIETY] = TME_OBSERVERS.MAP,
				[TME_TYPES.NEIGHBORHOOD] = TME_OBSERVERS.MAP
			}
			local obsT = caseof[TME_TYPES_USER[t]]

			for k,v in pairs(TME_OBSERVERS) do
				if v == obsT then obsT = k break end
			end
			for k,v in pairs(TME_OBSERVERS) do
				if v == TME_OBSERVERS[obsT] then obsT = k break end
			end
			data.type = caseof[TME_TYPES_USER[t]]
			for k,v in pairs(TME_OBSERVERS_USER) do
				if v == data.type then data.type = k break end
			end 
		end

		local dt = data.type

		if t == "Cell" or t == "Environment" then
			if data.type ~= "chart" and data.type ~= "logfile" and data.type ~= "table" and  data.type ~= "textscreen" and  data.type ~= "udpsender" and data.type ~= "neighborhood" then
				incompatibleValueError("type","one of the strings from the set ['chart','logfile','neighborhood','table','textscreen','udpsender']","'".. dt .."'", 3)
			end
		elseif t == "CellularSpace" then
			if data.type ~= "chart" and data.type ~= "image" and data.type ~= "logfile" and  data.type ~= "map" and  data.type ~= "table" and data.type ~= "textscreen" and data.type~= "udpsender" and data.type ~= "shapefile" then
				incompatibleValueError("type","one of the strings from the set ['chart','image','logfile','map','table','textscreen','udpsender','shapefile']","'".. dt .."'", 3)
			end
		elseif t == "Society" or t == "Trajectory" then
			if data.type ~= "chart" and data.type ~= "image" and data.type ~= "logfile" and  data.type ~= "map" and  data.type ~= "table" and data.type ~= "textscreen" and data.type~= "udpsender" then
				incompatibleValueError("type","one of the strings from the set ['chart','image','logfile','map','table','textscreen','udpsender']","'".. dt .."'", 3)
			end
		elseif t == "Event" or t == "userdata" or t == "Pair" then
			if data.type ~= "logfile" and data.type ~= "table" and data.type ~= "textscreen" and  data.type~= "udpsender" then
				incompatibleValueError("type","one of the strings from the set ['logfile','table','textscreen','udpsender']","'".. dt .."'", 3)
			end
		elseif t == "Neighborhood" then
			if data.type ~= "neighborhood" and data.type ~= "table" and data.type~= "udpsender" then
				incompatibleValueError("type","one of the strings from the set ['neighborhood','table','udpsender']","'".. dt .."'", 3)
			end
		elseif t == "Timer" then
			if data.type ~= "logfile" and data.type ~= "scheduler" and data.type ~= "table" and  data.type ~= "textscreen" and  data.type~= "udpsender" then
				incompatibleValueError("type","one of the strings from the set ['logfile','scheduler','table','textscreen','udpsender']","'".. dt .."'", 3)
			end
		elseif t == "Agent" or t == "Automaton" then
			if data.type ~= "chart" and data.type ~= "image" and data.type ~= "logfile" and  data.type ~= "map" and  data.type ~= "statemachine" and  data.type ~= "table" and  data.type ~= "textscreen" and  data.type ~= "udpsender" then
				incompatibleValueError("type","one of the strings from the set ['chart','image','logfile','map','statemachine','table','textscreen','udpsender']","'".. dt .."'", 3)
			end
		end
	end

	verifyUnnecessaryArguments(data, observerPossibleParams)

	local metaTable = {__index = Observer_,__tostring = tostringTerraME}
	setmetatable(data, metaTable)

	local target = ""
	local cppSubject = nil
	local targetType = ""

	target = data.target
	if target == nil then
		customError("Argument 'target' is compulsory.", 3)
	else
		-- Checks the Lua target type
		if type(target) == "table" and target.cObj_ ~= nil then
			--local t = type(target)
			--if (t == "Agent" or t == "Automaton" or t == "Cell" or t == "CellularSpace" or t == "Environment" or t == "Neighborhood" or t == "Society" or t == "Timer" or t == "Trajectory") and (target.cObj_ ~= nil) then
			if type(target.cObj_) == "table" then
				cppSubject = target.cObj_[1]
			else
				cppSubject = target.cObj_
			end
		else
			-- Este teste causa bug no ObsSociety
			-- if type(target) == "userdata" then
			cppSubject = target
			--end
		end

		if type(targetType) == "string" then targetType = TME_TYPES_USER[type(target)] end
	end

	local neighborhoods = data.neighIndex or {}

	-- retrieve observer basic items
	local observerId = -1
	local observerType = data.type or nil
	if type(observerType) == "string" then observerType = TME_OBSERVERS_USER[observerType] end

	local flagAttrsValid = true

	if data.attributes and type(data.attributes)=="table" then
		local t = data.type
		if #data.attributes == 0 then
			if t == "chart" or t == "image" or t=="map" then
				flagAttrsValid = false		  
			end
		elseif #data.attributes > 0 then
			for i = 1, #data.attributes do
				if type(data.attributes[i]) ~= "string" then
					flagAttrsValid = false
					break	
				end
			end
		elseif #data.attributes > 2 then
			if t == "image" or t == "map" then
				flagAttrsValid = false
			end
		elseif type(data.target) == "CellularSpace" and data.target.cells[1] ~= nil then
			for i = 1, #data.attributes do
				if data.target.cells[1][data.attributes[i]] == nil then
					flagAttrsValid = false
					break  
				end
			end

		end

		if #data.attributes ~= 0 and not flagAttrsValid then
			customError("Incompatible values. Argument 'attributes' expected a set of valid object fields.", 3)
		elseif #data.attributes == 0 then
			if data.type == "image" then
				customError("Image observers must have exactly one or two attributes.", 3)
			elseif data.type == "map" then
				customError("Map observers must have exactly one or two attributes.", 3)
			elseif data.type == "chart" then
				customError("Chart observers must have at least one attribute.", 3)
			end

			data.attributes = {}
		end
	elseif type(data.attributes) ~= "nil" then
		incompatibleTypeError("attributes","table", data.attributes, 3)
	end
	observerId = nil

	table.insert(_Gtme.createdObservers, data)

	if observerType == TME_OBSERVERS.TEXTSCREEN then
		if data.attributes == nil then
			data.attributes = {}
		end
		observerId = observerTextScreen(targetType, cppSubject, data.attributes, data)
	elseif observerType == TME_OBSERVERS.LOGFILE then
		if data.attributes == nil then
			data.attributes = {}
		end
		observerId = observerLogFile(targetType, cppSubject, data.attributes, data)
	elseif observerType == TME_OBSERVERS.TABLE then
		if data.attributes == nil then
			dataattributes = {}
		end
		observerId = observerTable(targetType, cppSubject, data.attributes, data)
	elseif observerType == TME_OBSERVERS.CHART then
		observerId = observerChart(targetType, cppSubject, data.attributes, data)
	elseif observerType == TME_OBSERVERS.MAP then
		local tbDimensions = {}
		local cells = {}
		if targetType == TME_TYPES.CELLSPACE then
			tbDimensions = { tonumber(target.maxCol - target.minCol + 1),
				tonumber(target.maxRow - target.minRow + 1) }
			cells = target.cells
		end

		if targetType == TME_TYPES.TRAJECTORY then
			observerId = observerMap(targetType, cppSubject, tbDimensions, data.attributes, data, cells, #target)
		else
			observerId = observerMap(targetType, cppSubject, tbDimensions, data.attributes, data, cells)
		end
	elseif observerType == TME_OBSERVERS.IMAGE then
		if data.legends == nil then
			customWarning("A default legend will be used.", 3)
		elseif type(data.legends) ~= "table" then
			incompatibleTypeError("legends","table", data.legends, 3)
		elseif type(data.legends[1]) ~= "Legend" then
			isTableLeg = true
			for _,legend in pairs(data.legends) do
				if type(legend) ~= "Legend" then
					isTableLeg = false
					incompatibleTypeError("legends","a set of legends", legend, 3)
				end
			end
		end

		if data.path == nil then
			data.path = "."
		elseif type(data.path) ~= "string" then
			incompatibleTypeError("path","string", data.path, 3)	  
		end

		if data.prefix == nil then 	
			data.prefix = "result_"
		elseif type(data.prefix) ~= "string" then
			incompatibleTypeError("prefix","string", data.prefix, 3)
		end

		local tbDimensions = {}
		local cells = {}
		if targetType == TME_TYPES.CELLSPACE then
			tbDimensions = { tonumber(target.maxCol - target.minCol + 1),
				tonumber(target.maxRow - target.minRow + 1) }
			cells = target.cells
		end

		if targetType == TME_TYPES.TRAJECTORY then
			observerId = observerImage(targetType, cppSubject, tbDimensions, data.attributes, data, cells, #target)
		else
			observerId = observerImage(targetType, cppSubject, tbDimensions, data.attributes, data, cells)
		end
	elseif observerType == TME_OBSERVERS.UDPSENDER then
		local tbDimensions = {}
		local cells = {}
		if targetType == TME_TYPES.CELLSPACE then
			tbDimensions = { tonumber(target.maxCol - target.minCol + 1),
				tonumber(target.maxRow - target.minRow + 1) }
			cells = target.cells
		end
		if data.attributes == nil then
			data.attributes = {}
		end
		observerId = observerUDPSender(targetType, cppSubject, tbDimensions, data.attributes, data, cells)
	elseif observerType == TME_OBSERVERS.SCHEDULER then
		observerId = observerScheduler(targetType, cppSubject, data.attributes, data)
	elseif observerType == TME_OBSERVERS.STATEMACHINE then
		observerId = observerStateMachine(targetType, cppSubject, data.attributes, data)
	elseif observerType == TME_OBSERVERS.NEIGHBORHOOD then
		deprecatedFunction("Neighborhood Observer", "Map or Image Observer with Neighborhood object as target", 3)
	elseif observerType == TME_OBSERVERS.SHAPEFILE then
		local tbDimensions = {}
		local cells = {}
		if targetType == TME_TYPES.CELLSPACE then
			tbDimensions = { tonumber(target.maxCol - target.minCol + 1),
				tonumber(target.maxRow - target.minRow + 1) }
			cells = target.cells
		end

		observerId = observerShapefile(targetType, cppSubject, tbDimensions, data.attributes, data, cells)
	elseif observerType == TME_OBSERVERS.TCPSENDER then
		local tbDimensions = {}
		local cells = {}
		if (targetType == TME_TYPES.CELLSPACE) then
			tbDimensions = { tonumber(target.maxCol - target.minCol + 1),
			tonumber(target.maxRow - target.minRow + 1) }
			cells = target.cells
		end
		return observerTCPSender(targetType, cppSubject, tbDimensions, observerAttrs, attrTab, cells)
	end

	data.id = observerId 
	return data
end

local deadObserverMetaTable_ = {__index = function()
    customError("Trying to use a function of an observer that was destroyed.")
end}

function _Gtme.killAllObservers()
	forEachElement(_Gtme.createdObservers, function(idx, obs)
		if obs.target.cObj_ then
			if obs.type == TME_OBSERVERS.NEIGHBORHOOD or obs.type == "neighborhood" then
				obs.target.cObj_:kill(obs.id, obs.observer.target.cObj_)
			else
				obs.target.cObj_:kill(obs.id)
			end
		elseif type(obs.target) == "Society" then
			obs.target:remove(func)
		else
			return
		end
		setmetatable(obs, deadObserverMetaTable_)
	end)
	_Gtme.createdObservers = {}
end
