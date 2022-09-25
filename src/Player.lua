Player = Class{__includes = Entity}

function Player:init(def)
    Entity.init(self, def)
    self.object  = nil
    self.coins = 0 -- stores the no of coins the player has
    self.roomNum = 0
end

function Player:update(dt)
    Entity.update(self, dt)
end

-- checks if the right side of object A is to the right of the left side of object B
-- or if the left side of object A is to the left of the right side of object B
-- or if the top side of object A is above the bottom side of object B
-- or if the bottom side of object A is below the top side of object B
function Player:collides(target)
    local selfY, selfHeight = self.y + self.height / 2, self.height / 2
    
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
                selfY + selfHeight < target.y or selfY > target.y + target.height)
end

function Player:render()

    Entity.render(self)
end
 