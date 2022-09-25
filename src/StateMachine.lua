StateMachine = Class{}

function StateMachine:init(states)
	-- initializes base functions
	self.empty = {
		render = function() end,
		update = function() end,
		processAI = function() end,
		enter = function() end,
		exit = function() end
	}

	-- takes an input variable or an empty array
	-- self.states = {startState, PlayState, GameOverState}
	self.states = states or {} 
	self.current = self.empty
end

function StateMachine:change(stateName, enterParams)
	assert(self.states[stateName]) -- state must exist
	self.current:exit()
	self.current = self.states[stateName]() -- takes one state from the array and executes it
	self.current:enter(enterParams)
end

function StateMachine:update(dt)
	self.current:update(dt)
end

function StateMachine:render()
	self.current:render()
end

function StateMachine:processAI(params, dt)
	self.current:processAI(params, dt)
end
