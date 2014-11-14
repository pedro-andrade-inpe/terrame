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
-- indirect, special, incidental, or caonsequential damages arising out of the use
-- of this library and its documentation.
--
-- Authors: Pedro R. Andrade
--          Rodrigo Reis Pereira
-------------------------------------------------------------------------------------------

return{
	notify = function(unitTest)
		local sc1 = Society{
			instance = Agent{},
			quantity = 20
		}

		local error_func = function()
			sc1:notify("not_int")
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "Event or positive number", "not_int"))

		error_func = function()
			sc1:notify(-1)
		end
		unitTest:assert_error(error_func, incompatibleValueMsg(1, "Event or positive number", -1))
	end,
	remove = function(unitTest)
		local agent1 = Agent{}

		local soc1 = Society{
			instance = agent1,
			quantity = 1
		}

		local ag = soc1:sample()
		soc1:remove(ag)

		local error_func = function()
			soc1:remove()
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "Agent or function"))
	
		local error_func = function()
			soc1:remove(ag)
		end
		unitTest:assert_error(error_func, "Could not remove the Agent (id = '1').")
	end,
	sample = function(unitTest)
		local agent1 = Agent{}

		local soc1 = Society{
			instance = agent1,
			quantity = 1
		}

		soc1:remove(soc1:sample())

		local error_func = function()
			soc1:sample()
		end
		unitTest:assert_error(error_func, "Trying to sample an empty Society.")
	end,
	Society = function(unitTest)
		local ag1 = Agent{}

		local sc1 = Society{
			instance = ag1,
			quantity = 20
		}

		local error_func = function()
			sc2 = Society{
				quantity = 20
			}
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg("instance"))

		error_func = function()
			sc2 = Society{
				instance = "wrongType",
				quantity = 20
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("instance", "Agent", "wrongType"))

		error_func = function()
			sc2 = Society{
				instance = ag1
			}
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg("quantity"))

		error_func = function()
			sc2 = Society{
				instance = ag1,
				quantity = "wrongType"
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("quantity", "positive integer number (except zero)", "wrongType"))

		error_func = function()
			sc2 = Society{
				instance = ag1,
				quantity = -15
			}
		end
		unitTest:assert_error(error_func, incompatibleValueMsg("quantity", "positive integer number (except zero)", -15))
	end,
	add = function(unitTest)
		local ag1 = Agent{}

		local sc1 = Society{
			instance = ag1,
			quantity = 20
		}

		local error_func = function()
			sc1:add("wrongType")
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "Agent or table", "wrongType"))
	end,
	createSocialNetwork = function(unitTest)
		local ag1 = Agent{}
		local sc1 = Society{instance = ag1, quantity = 20}

		local error_func = function()
			sc1:createSocialNetwork()
		end
		unitTest:assert_error(error_func, tableParameterMsg())

		error_func = function()
			sc1:createSocialNetwork(15)
		end
		unitTest:assert_error(error_func, namedParametersMsg())

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "voi"
			}
		end
		unitTest:assert_error(error_func, switchInvalidParameterSuggestionMsg("voi", "strategy", "void"))

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "terralab"
			}
		end

		local options = {
			cell = true,
			["function"] = true,
			neighbor = true,
			probability = true,
			quantity = true,
			void = true
		}
			
		unitTest:assert_error(error_func, switchInvalidParameterMsg("terralab", "strategy", options))

		sc1:createSocialNetwork{
			strategy = "void",
			name = "void"
		}

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "void",
				name = "void"
			}
		end
		unitTest:assert_error(error_func, "SocialNetwork 'void' already exists in the Society.")

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "void",
				name = "void2",
				probability = 0.5
			}
		end
		unitTest:assert_error(error_func, unnecessaryParameterMsg("probability"))

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "quantity",
				quantity = "terralab"
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("quantity", "number", "terralab"))

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "quantity",
				quantity = 0
			}
		end
		unitTest:assert_error(error_func, incompatibleValueMsg("quantity", "positive number (except zero)", 0))

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "quantity",
				quantity = 5,
				probability = 0.2
			}
		end
		unitTest:assert_error(error_func, unnecessaryParameterMsg("probability"))

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "probability",
				probability = "wrongValue"
			}
		end

		unitTest:assert_error(error_func, incompatibleTypeMsg("probability", "number", "wrongValue"))

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "probability",
				probability = 0
			}
		end
		unitTest:assert_error(error_func, incompatibleValueMsg("probability", "a number between 0 and 1", 0))

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "probability",
				probability = 0.5,
				quantity = 5	
			}
		end
		unitTest:assert_error(error_func, unnecessaryParameterMsg("quantity"))

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "probability",
				probability = 1.5,
			}
		end
		unitTest:assert_error(error_func, incompatibleValueMsg("probability", "a number between 0 and 1", 1.5))

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "probability",
				probability = 0.5,
				name = 2
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("name", "string", 2))

		error_func = function()
			sc1:createSocialNetwork{strategy = "cell", name = "c"}
		end

		unitTest:assert_error(error_func, "Society has no placement. Use Environment:createPlacement() first.")

		local cs = CellularSpace{xdim = 5}
		local ag1 = Agent{}
		local sc1 = Society{instance = ag1, quantity = 20}
		local env = Environment{cs, sc1}
		env:createPlacement{strategy = "random"}

		error_func = function()
			sc1:createSocialNetwork{strategy = "neighbor", name = "c"}
		end
		unitTest:assert_error(error_func, "CellularSpace has no Neighborhood named '1'. Use CellularSpace:createNeighborhood() first.")

		local ag1 = Agent{}
		local sc1 = Society{instance = ag1, quantity = 20}
		local cs = CellularSpace{xdim = 5}
		cs:createNeighborhood()
		local env = Environment{cs, sc1}

		error_func = function()
			sc1:createSocialNetwork{strategy = "neighbor", name = "c"}
		end
		unitTest:assert_error(error_func, "Society has no placement. Use Environment:createPlacement() first.")

		env:createPlacement{strategy = "random"}
		error_func = function()
			sc1:createSocialNetwork{strategy = "cell", name = "c", quantity = 5}
		end
		unitTest:assert_error(error_func, unnecessaryParameterMsg("quantity"))

		error_func = function()
			sc1:createSocialNetwork{strategy = "neighbor", name = 22}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("name", "string", 22))

		error_func = function()
			sc1:createSocialNetwork{strategy = "neighbor", quantity = 1}
		end
		unitTest:assert_error(error_func, unnecessaryParameterMsg("quantity"))

		error_func = function()
			sc1:createSocialNetwork{strategy = "function", name = "c", filter = 3}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("filter", "function", 3))

		error_func = function()
			sc1:createSocialNetwork{strategy = "function", name = "c", filter = function(ag) return true end, quantity = 1}
		end
		unitTest:assert_error(error_func, unnecessaryParameterMsg("quantity"))

		local ag1 = Agent{
			name = "nonfoo",
			init = function(self)
				self.age = Random():integer(10)
			end,
			execute = function(self)
				self.age = self.age + 1
				self:walk()
				forEachAgent(self:getCell(), function(agent)
					if agent.name == "foo" then
						findCounter = findCounter + 1
					end
				end)
			end
		}
	end,
	get = function(unitTest)
		local ag1 = Agent{
			name = "nonfoo",
			execute = function(self) end
		}

		local sc1 = Society{
			instance = ag1,
			quantity = 10
		}

		local error_func = function()
			ag1 = sc1:get(nil)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("index", "positive integer number"))

		error_func = function()
			ag1 = sc1:get("asdfg")
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("index", "positive integer number", "asdfg"))
	end,
	getAgent = function(unitTest)
		local ag1 = Agent{
			name = "nonfoo",
			execute = function(self) end
		}

		local sc1 = Society{
			instance = ag1,
			quantity = 10
		}

		local error_func = function()
			sc1:getAgent("1")
		end
		unitTest:assert_error(error_func, deprecatedFunctionMsg("getAgent", "get"))
	end,
	getAgents = function(unitTest)
		local ag1 = Agent{
			name = "nonfoo",
			execute = function(self) end
		}

		local sc1 = Society{
			instance = ag1,
			quantity = 10
		}

		local error_func = function()
			sc1:getAgents()
		end
		unitTest:assert_error(error_func, deprecatedFunctionMsg("getAgents", ".agents"))
	end,
	size = function(unitTest)
		local ag1 = Agent{
			name = "nonfoo",
			execute = function(self) end
		}

		local sc1 = Society{
			instance = ag1,
			quantity = 10
		}

		local error_func = function()
			sc1:size()
		end
		unitTest:assert_error(error_func, deprecatedFunctionMsg("size", "operator #"))
	end,
	split = function(unitTest)
		local ag1 = Agent{
			name = "nonfoo",
			execute = function(self) end
		}

		local sc1 = Society{
			instance = ag1,
			quantity = 10
		}

		local error_func = function()
			group = sc1:split(nil)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "string or function"))

		error_func = function()
			group = sc1:split(15)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "string or function", 15))
	end,
	synchronize = function(unitTest)
		local ag1 = Agent{
			name = "nonfoo",
			execute = function(self) end
		}

		local sc1 = Society{
			instance = ag1,
			quantity = 10
		}

		sc1:synchronize()

		local error_func = function()
			sc1:synchronize("test")
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "positive number", "test"))

		error_func = function()
			sc1:synchronize(-13)
		end
		unitTest:assert_error(error_func, incompatibleValueMsg(1, "positive number", -13))
	end
}

