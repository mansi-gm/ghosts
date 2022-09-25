Doorway = Class{}

function Doorway:init(direction, open, room)
    self.direction = direction
    self.open = open
    self.room = room

    --intializes positions of each doorway, their width and height
    if direction == 'left' then
        self.x = MAP_RENDER_OFFSET_X
        self.y = MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE
        self.height = 32
        self.width = 16
    elseif direction == 'right' then
        self.x = MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE) - TILE_SIZE
        self.y = MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2 * TILE_SIZE) - TILE_SIZE
        self.height = 32
        self.width = 16
    elseif direction == 'top' then
        self.x = MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2 * TILE_SIZE) - TILE_SIZE
        self.y = MAP_RENDER_OFFSET_Y
        self.height = 16
        self.width = 32
    else
        self.x = MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2 * TILE_SIZE) - TILE_SIZE
        self.y = MAP_RENDER_OFFSET_Y + (MAP_HEIGHT * TILE_SIZE) - TILE_SIZE
        self.height = 16
        self.width = 32
    end
end

function Doorway:render(offsetX, offsetY)
    local texture = gTextures['tiles']
    local quads = gFrames['tiles']

    -- used for shifting the doors when sliding rooms
    self.x = self.x + offsetX
    self.y = self.y + offsetY

    -- two wall tiles are drawn
    -- then the doorway tiles are drawn on top of them
    if self.direction == 'left' then
        love.graphics.draw(texture, quads[6], self.x, self.y + 16) 
        love.graphics.draw(texture, quads[16], self.x, self.y)
        love.graphics.draw(texture, quads[22], self.x, self.y + 16)
        love.graphics.draw(texture, quads[28], self.x, self.y + 32)

        if not self.open then
            love.graphics.draw(texture, quads[68], self.x, self.y + 16)
        end
    elseif self.direction == 'right' then
        love.graphics.draw(texture, quads[6], self.x, self.y + 16)
        love.graphics.draw(texture, quads[17], self.x, self.y)
        love.graphics.draw(texture, quads[23], self.x, self.y + 16)
        love.graphics.draw(texture, quads[29], self.x, self.y + 32)

        if not self.open then
            love.graphics.draw(texture, quads[67], self.x - 0, self.y + 16)
        end
    elseif self.direction == 'top' then
        love.graphics.draw(texture, quads[6], self.x + 16, self.y)
        love.graphics.draw(texture, quads[19], self.x, self.y)
        love.graphics.draw(texture, quads[20], self.x + 16, self.y)
        love.graphics.draw(texture, quads[21], self.x + 32, self.y)

        if not self.open then
            love.graphics.draw(texture, quads[41], self.x + 16, self.y)
        end
    else
        love.graphics.draw(texture, quads[6], self.x + 16, self.y)
        love.graphics.draw(texture, quads[25], self.x, self.y)
        love.graphics.draw(texture, quads[26], self.x + 16, self.y)
        love.graphics.draw(texture, quads[27], self.x + 32, self.y)

        if not self.open then
            love.graphics.draw(texture, quads[47], self.x + 16, self.y)
        end
    end

    -- revert to original positions
    self.x = self.x - offsetX
    self.y = self.y - offsetY
end