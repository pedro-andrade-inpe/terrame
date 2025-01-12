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
	Jump = function(unitTest)
		local j1 = Jump{
			function(_, cell)
				if cell.x > 5 then
					return true
				end
			end,
			target = "go"
		}
		unitTest:assertEquals(string.sub(tostring(j1), 1, 8), "TeJump (", 2)

		Jump{
			function(cell, _, ag1)
				return cell.water > ag1.energy
			end,
			target = nil
		}
		unitTest:assert(true)

		Jump{
			function(cell, _, ag1)
				return cell.water > ag1.energy
			end,
			target = 8
		}
		unitTest:assert(true)

		Jump{
			function(cell, _, ag1)
				return cell.water > ag1.capInf
			end,
			target = "wrongString"
		}
		unitTest:assert(true)
	end
}

