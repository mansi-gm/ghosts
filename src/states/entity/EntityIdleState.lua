EntityIdleState = Class{__includes = BaseState}

function EntityIdleState:init(entity, room)
    self.entity = entity

    self.room = room

    self.entity:changeAnimation('idle-' .. self.entity.direction)

    -- used for AI waiting
    self.waitDuration = 0
    self.waitTimer = 0
end

function EntityIdleState:processAI(params, dt)
    if self.waitDuration == 0 then
        self.waitDuration = math.random(5) -- update variable as a random number between 1 to 5 seconds
    else
        self.waitTimer = self.waitTimer + dt

        -- after self.waitDuration seconds, entity starts to walk
        if self.waitTimer > self.waitDuration then
            self.entity:changeState('walk')
        end
    end

    if not self.entity.dead then
        -- one in 250 chance to throw a projectile
        -- (this condition is checked 60 times in a second)
        if math.random(250) == 1 then
            -- ghost's projectile is considered a collidable object
            table.insert(self.room.projectiles, self.entity.object)
            self.entity.object:fire(self.room, self.entity.object.x, self.entity.object.y, self.entity.direction)
            -- projectile is launched in the same direction as the ghost
            self.entity.object = GameObjectThrow(GAME_OBJECT_DEFS['pot'], self.entity.x, self.entity.y)
        end
    end
end

function EntityIdleState:render()
    local anim = self.entity.currentAnimation -- render animation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))
end