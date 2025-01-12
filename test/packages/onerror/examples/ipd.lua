-- @example Iterated Prisoner's dilemma model.
-- It implements a championship with a set of Agents
-- where they play with each other a non-cooperative game
-- repeatedly.
-- Some of the available strategies are Pavlov and Tit-for-tat.
-- In the end, the model shows the results for each strategy. \
-- For more information, see Axelrod, R. (1984) The Evolution of
-- Cooperation. Basic Books. See also Nowak, M., and Sigmund, K.
-- (1993) A strategy of win-stay, lose-shift that outperforms
-- tit-for-tat in the Prisoner's Dilemma game. Nature 364.6432: 56-58.
-- @arg TURNS The number of times an Agent plays
-- with each opponent.
-- @arg CHAMPIONSHIP A vector with the strategies used
-- in the championship.

Random{seed = 12345}

-- STRATEGIES AND META-STRATEGIES
COOPERATE     = 1
NOT_COOPERATE = 2

TFT = Agent{ -- TIT-FOR-TAT
	name = "TFT",
	prepare_for_championship = function(ag)
		ag.last = COOPERATE
	end,
	play = function(ag)
		return ag.last
	end,
	update = function(ag, oponent_strategy)
		ag.last = oponent_strategy
	end
}

TF2T = Agent{ -- TIT-FOR-TWO-TATS
	name = "TF2T",
	prepare_for_championship = function(ag)
		ag.last = COOPERATE
	end,
	action = COOPERATE,
	last = COOPERATE,
	previous = COOPERATE,
	play = function(ag)
		return ag.action
	end,
	update = function(ag, oponent_strategy)
		ag.previous = ag.last
		ag.last = oponent_strategy
		if ag.previous == ag.last and ag.last == NOT_COOPERATE then
			ag.action = NOT_COOPERATE
		else
			ag.action = COOPERATE
		end
	end
}

COOP1 = Agent{ -- COOPERATE UNTIL THE OPPONENT DEFECTS ONCE
	name = "COOP1",
	action = COOPERATE,
	prepare_for_championship = function(ag)
		ag.last = COOPERATE
	end,
	play = function(ag)
		return ag.action
	end,
	update = function(ag, oponent_strategy)
		if oponent_strategy == NOT_COOPERATE then
			ag.action = NOT_COOPERATE
		end
	end
}

NTFT = Agent{ -- NOT TIT-FOR-TAT
	name = "NTFT",
	action = NOT_COOPERATE,
	prepare_for_championship = function(ag)
		ag.last = COOPERATE
	end,
	play = function(ag)
		return ag.action
	end,
	update = function(ag, oponent_strategy)
		if oponent_strategy == COOPERATE then ag.action = NOT_COOPERATE
		else								  ag.action = COOPERATE end
	end
}

AD = Agent{ -- ALWAYS DEFECT
	name = "AD",
	play = function()
		return NOT_COOPERATE
	end,
	update = function() end,
	prepare_for_championship = function() end
}

AC = Agent{ -- ALWAYS COOPERATE
	name = "AC",
	play = function()
		return COOPERATE
	end,
	update = function() end,
	prepare_for_championship = function() end
}

local fifty = Random{p = 0.5}

RANDOM = Agent{
	name = "RANDOM",
	play = function()
		if fifty:sample() then
			return COOPERATE
		else
			return NOT_COOPERATE
		end
	end,
	update = function() end,
	prepare_for_championship = function() end
}

PAVLOV = Agent{ -- WIN-STAY-LOSE-SHIFT
	name = "PAVLOV",
	prepare_for_championship = function(ag) ag.action = COOPERATE end,
	play = function(ag)
		return ag.action
	end,
	update = function(ag, oponent_strategy)
		if oponent_strategy == NOT_COOPERATE then
			if ag.action == COOPERATE then
				ag.action = NOT_COOPERATE
			else
				ag.action = COOPERATE
			end
		end
	end
}

-- PARAMETERS
TURNS = 40
CHAMPIONSHIP = {TFT, AD, COOP1, PAVLOV, RANDOM, TF2T, NTFT}

function Game(p1, p2)
	if p1 == COOPERATE     and p2 == COOPERATE     then return {3, 3} end
	if p1 == COOPERATE     and p2 == NOT_COOPERATE then return {0, 5} end
	if p1 == NOT_COOPERATE and p2 == COOPERATE     then return {5, 0} end
	if p1 == NOT_COOPERATE and p2 == NOT_COOPERATE then return {1, 1} end
end

-- MODEL
nplayers = getn(CHAMPIONSHIP)

-- create a matrix with the results
results = {}
for i = 1, nplayers do
	results[i] = {}

	for j = 1, nplayers do
		results[i][j] = 0
	end
end

-- the championchip, pair by pair
for i = 1, nplayers do
	for j = i, nplayers do
		player1 = CHAMPIONSHIP[i]
		player2 = CHAMPIONSHIP[j]

		player1:prepare_for_championship()
		player2:prepare_for_championship()

		payoff1 = 0
		payoff2 = 0

		for _ = 1, TURNS do
			a1 = player1:play()
			a2 = player2:play()

			player1:update(a2)
			player2:update(a1)

			payoffs = Game(a1, a2)

			payoff1 = payoff1 + payoffs[1]
			payoff2 = payoff2 + payoffs[2]
		end

		results[i][j] = payoff1
		results[j][i] = payoff2
	end
end

-- plot the results
p = "\t"

for j = 1, nplayers do
	p = p..CHAMPIONSHIP[j].name.."\t"
end

print(p.."_SUM_")

for i = 1, nplayers do
	p = CHAMPIONSHIP[i].name.."\t"
	sum = 0
	for j = 1, nplayers do
		p = p..results[i][j].."\t"
		sum = sum + results[i][j]
	end
	print(p..sum)
end

a = bcs + dfg

