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
	State = function(unitTest)
		local error_func = function()
			State(2)
		end
		unitTest:assertError(error_func, tableArgumentMsg())

		State{
			Jump{
				function()
					return true
				end,
				target = "go"
			},
			Flow{ function(_, self)
					self.x = self.x + 1
				end}
		}
		unitTest:assert(true)

		unitTest:assertError(function()
			State{
				id = {},
				Jump{
					function()
						return true
					end,
					target = "go"
				},
				Flow{
					function(_, self)
						self.x = self.x + 1
					end
				}
			}
		end, incompatibleTypeMsg("id", "string", {}))

		unitTest:assertError(function()
			State{
				id = 123,
				Jump{ function()
						return true
					end,
					target = "go"
				},
				Flow{ function(_, self)
						self.x = self.x + 1
					end}
			}
		end, incompatibleTypeMsg("id", "string", 123))

		State{
			id = "IdState",
			Flow{
				function(_, self)
					self.x = self.x + 1
				end},
			Jump{
				function()
					return true
				end,
				target = "go"
			}
		}
		unitTest:assert(true)

		State{
			id = "IdState",
			Flow{
				function(self)
					self.x = self.x + 1
				end
			},
			Jump{
				function()
					return true
				end,
				target = "go"
			}
		}
		unitTest:assert(true)
	end
}

