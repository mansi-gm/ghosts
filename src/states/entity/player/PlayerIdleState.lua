PlayerIdleState = Class{__includes = EntityIdleState}

function PlayerIdleState:enter(params)
    -- render offset for spaced character sprite
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerIdleState:update(dt)
    EntityIdleState.update(self, dt)
end

function PlayerIdleState:update(dt)
    -- checks if any input keys were pressed for the player to walk
    if love.keyboard.isDown('left', 'a') or love.keyboard.isDown('right', 'd') or
       love.keyboard.isDown('up', 'w') or love.keyboard.isDown('down', 's') then
        self.entity:changeState('walk')
    end
end
