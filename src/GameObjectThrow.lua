GameObjectThrow = Class{__includes = GameObject}

function GameObjectThrow:init(def, x, y)
   self.dx = 0
   self.dy = 0
   self.distance = 0 
   self.projectile = false

   self.type = def.type

    self.texture = def.texture
    self.frame = def.frame or 1

    -- whether it acts as an obstacle or not
    self.solid = def.solid

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states

    -- dimensions
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height

   self.room = nil
end

function GameObjectThrow:fire(room, x, y, direction)
    -- based on direction, the x- and y- coordinates change (positive/negative)
    if direction == 'left' then
        self.dx = -OBJECT_THROW_SPEED
    elseif direction == 'right' then
        self.dx = OBJECT_THROW_SPEED
    elseif direction == 'up' then
        self.dy = -OBJECT_THROW_SPEED
    else
        self.dy = OBJECT_THROW_SPEED
    end

    self.room = room
    self.projectile = true -- sets flag for projectile to keep moving 
end

function GameObjectThrow:update(dt)
    if self.projectile then
        self.x = self.x + self.dx * dt
        self.y = self.y + self.dy * dt
        self.distance = self.distance + OBJECT_THROW_SPEED * dt
    end
end

-- if the projectile collides with a wall or player, it must be destroyed
function GameObjectThrow:destroy(room)
    for k, projectile in pairs(room.projectiles) do
        if projectile == self then
            table.remove(room.projectiles, k)
        end
    end
    self.projectile = false
end

function GameObjectThrow:checkCollisions(room)

    local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) 
            + MAP_RENDER_OFFSET_Y - TILE_SIZE

    return false
end

function GameObjectThrow:render(adjacentOffsetX, adjacentOffsetY)
    love.graphics.draw(gTextures['tiles'], gFrames['tiles'][72], math.floor(self.x + adjacentOffsetX), math.floor(self.y + adjacentOffsetY))
end