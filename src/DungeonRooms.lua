--
-- USED FOR DEBUGGING
-- to show a map of all the rooms in a dungeon and which room the player is in
--

DungeonRooms = Class{}

function DungeonRooms:init(dungeon, hIndex, vIndex)
    self.dungeon = dungeon
    self.hIndex = hIndex
    self.vIndex = vIndex
end

function DungeonRooms:update(dt) end

function DungeonRooms:render()

    love.graphics.setColor(58, 58, 58, 200)
    love.graphics.rectangle('fill', 0, VIRTUAL_HEIGHT - 64, 96, 64)

    for x = 1, 4 do
        for y = 1, 3 do
            if self.dungeon[x][y] then
                if (y == self.hIndex) and (x == self.vIndex) then
                    love.graphics.setColor(250, 130, 130, 200)
                    love.graphics.rectangle('fill', (x - 1) * 24, (VIRTUAL_HEIGHT - 64) + ((y - 1) * 21), 24, 21)
                    love.graphics.setColor(58, 58, 58, 200)
                else
                    love.graphics.setColor(199, 199, 199, 200)
                    love.graphics.rectangle('fill', (x - 1) * 24, (VIRTUAL_HEIGHT - 64) + ((y - 1) * 21), 24, 21)
                    love.graphics.setColor(58, 58, 58, 200)
                end
            end
        end
    end

end
