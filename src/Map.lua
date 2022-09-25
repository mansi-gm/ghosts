Map = Class{}

function Map:init(room)

    -- initializes its own variables from the room's variables
    self.room = room
    self.entities = self.room.entities

    self.width = 96 
    self.height = 64 

    self.ratioX = MAP_HEIGHT / self.width
    self.ratioY = MAP_HEIGHT / self.height

    self.offsetX = VIRTUAL_WIDTH - self.width
end

function Map:render()

    -- renders everything in circles or rectangles at the exact same place, but the ratio is smaller
    
    love.graphics.setColor(15, 15, 51, 200)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH - self.width, 0, self.width, self.height)

    --PROJECTILES
    love.graphics.setColor(0, 255, 255, 255)
    for k, projectile in pairs(self.room.projectiles) do
        love.graphics.circle('fill', self.offsetX + (projectile.x  / 4), projectile.y / 3, 2, 3)
    end

    --PLAYER
    love.graphics.setColor(255, 255, 0, 255)
    love.graphics.rectangle('fill', self.offsetX + self.room.player.x / 4, self.room.player.y / 3, 2, 2)

    love.graphics.setColor(153, 0, 255, 255)
    love.graphics.rectangle('fill', self.offsetX + self.room.objects[1].x / 4, self.room.objects[1].y / 3, 4, 4)

    love.graphics.setColor(102, 0, 0, 255)
    for k, doorway in pairs(self.room.doorways) do
        love.graphics.rectangle('fill', self.offsetX + doorway.x / 4, doorway.y / 3, 4, 2)
    end

    for k, entity in pairs(self.room.entities) do
        love.graphics.setColor(255, 0, 0, 255)
        love.graphics.rectangle('fill', self.offsetX + entity.x / 4, entity.y / 3, 3, 3)

        love.graphics.setColor(255, 255, 255, 255)
        if entity.direction == 'left' then
            love.graphics.rectangle('fill', (self.offsetX + entity.x / 4), (entity.y / 3) + 1, 1, 1)
        elseif entity.direction == 'right' then
            love.graphics.rectangle('fill', (self.offsetX + entity.x / 4) + 2, (entity.y / 3) + 1, 1, 1)
        elseif entity.direction == 'up' then
            love.graphics.rectangle('fill', (self.offsetX + entity.x / 4) + 1, (entity.y / 3), 1, 1)
        else
            love.graphics.rectangle('fill', (self.offsetX + entity.x / 4) + 1, (entity.y / 3) + 2, 1, 1)
        end
    end

    love.graphics.setColor(255, 0, 0, 255)
    love.graphics.rectangle('line', VIRTUAL_WIDTH - self.width, 0, self.width, self.height, 2)
end