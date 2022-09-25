Dungeon = Class{}

function Dungeon:init(player)
    self.player = player

    self.isComplete = false
    self.nextLevel = false
    self.numRooms = 0

    self.levelMessage = NextLevel(self)

    self.rooms = self:createDungeon()

    for x = 1, 4 do
        for y = 1, 3 do
            if self.rooms[x][y] then
                self.rooms[x][y] = Room(self, y, x)
            end
        end
    end

    self.player = player

    for x = 1, 4 do
        for y = 1, 3 do
            if self.rooms[y][x] then
                self.currentRoom = self.rooms[y][x] -- initializing current room the player is in
                break
            end
        end
    end

    -- next room that a player will enter, has not been set yet
    -- becomes an active room afterwards
    self.nextRoom = nil

    -- values for the camera to translate/shift when changing rooms
    self.cameraX = 0
    self.cameraY = 0
    self.shifting = false

    -- trigger camera translation and adjustment of rooms whenever the player triggers a shift
    -- via a doorway collision, triggered in PlayerWalkState
    Event.on('shift-left', function()
        self:beginShifting(-VIRTUAL_WIDTH, 0)
    end)

    Event.on('shift-right', function()
        self:beginShifting(VIRTUAL_WIDTH, 0)
    end)

    Event.on('shift-up', function()
        self:beginShifting(0, -VIRTUAL_HEIGHT)
    end)

    Event.on('shift-down', function()
        self:beginShifting(0, VIRTUAL_HEIGHT)
    end)
end

function Dungeon:createDungeon()
    
    -- initializes the table so that all values are currently false
    local dungeon = {
        [1] = {
            [1] = false,
            [2] = false,
            [3] = false
        },
        [2] = {
            [1] = false,
            [2] = false,
            [3] = false
        },
        [3] = {
            [1] = false,
            [2] = false,
            [3] = false
        },
        [4] = {
            [1] = false,
            [2] = false,
            [3] = false
        }
    }

    -- initialise row and column positions of rooms in a 2-dimensional array (dungeon)
    local currX = 1
    local currY = 2

    -- initialise a cutoff point
    local roomsMade = 0
    local roomsToBe = 6

    -- insert an invisible object (creeper) that goes through the dungeon's array 
    -- and its path will be marked as the rooms in the maze

    -- max of 6 rooms in dungeon
    while roomsMade < roomsToBe do

        -- 1 in 50 chance for the creeper to move left or right
        if math.random(50) == 1 then
            -- 1 in 30 chance for the creeper to move left
            if math.random(30) == 1 then
                currX = math.max(1, currX - 1)
            -- 1 in 30 chance for the creeper to move right
            elseif math.random(30) == 1 then
                currX = math.min(currX + 1, 4)
            end

        -- 1 in 50 chance for the creeper to move up or down
        elseif math.random(50) == 1 then
            -- 1 in 30 chance for the creeper to move up
            if math.random(30) == 1 then
                currY = math.max(1, currY - 1)
            -- 1 in 30 chance for the creeper to move down
            elseif math.random(30) == 1 then
                currY = math.min(currY + 1, 3)
            end
        end

        -- in case the creeper's path overlaps, dismiss the extra room made
        if not dungeon[currX][currY] then
            roomsMade = roomsMade + 1
        end
        dungeon[currX][currY] = true

        -- if the creeper reaches the end of the array, relocate it to a random place in the dungeon
        if currX == 4 then
            currX = math.random(1, 4)
            currY = math.random(1, 3)
        end
    end

    return dungeon
end

-- checks if all rooms are unlocked so the player can move to the next dungeon
function Dungeon:checkRooms()

    for x = 1, 4 do
        for y = 1, 3 do
            if self.rooms[x][y] then
                if not self.rooms[x][y].unlocked then 
                    return false
                end
            end
        end
    end

    self.levelMessage.activate = true
    return true -- returns true if all rooms are unlocked

end

-- Prepares for the camera shifting process / tween of the camera position.
function Dungeon:beginShifting(shiftX, shiftY)
    self.shifting = true

    -- start all doors in next room as open until we get in
    for k, doorway in pairs(self.nextRoom.doorways) do
        doorway.open = true
    end

    self.nextRoom.adjacentOffsetX = shiftX
    self.nextRoom.adjacentOffsetY = shiftY

    -- tween the player position so they move through the doorway
    -- tween means to move the player x amount of distance within y amount of time (non-dynamic)
    local playerX, playerY = self.player.x, self.player.y

    if shiftX > 0 then
        playerX = VIRTUAL_WIDTH + (MAP_RENDER_OFFSET_X + TILE_SIZE)
    elseif shiftX < 0 then
        playerX = -VIRTUAL_WIDTH + (MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE) - TILE_SIZE - self.player.width)
    elseif shiftY > 0 then
        playerY = VIRTUAL_HEIGHT + (MAP_RENDER_OFFSET_Y + self.player.height / 2)
    else
        playerY = -VIRTUAL_HEIGHT + MAP_RENDER_OFFSET_Y + (MAP_HEIGHT * TILE_SIZE) - TILE_SIZE - self.player.height
    end

    -- tween the camera in whichever direction the new room is in, as well as the player to be
    -- at the opposite door in the next room, walking through the wall (which is stenciled)
    Timer.tween(1, {
        [self] = {cameraX = shiftX, cameraY = shiftY},
        [self.player] = {x = playerX, y = playerY}
    }):finish(function()
        self:finishShifting()

        -- reset player to the correct location in the room
        if shiftX < 0 then
            self.player.x = MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE) - TILE_SIZE - self.player.width
            self.player.direction = 'left'
        elseif shiftX > 0 then
            self.player.x = MAP_RENDER_OFFSET_X + TILE_SIZE
            self.player.direction = 'right'
        elseif shiftY < 0 then
            self.player.y = MAP_RENDER_OFFSET_Y + (MAP_HEIGHT * TILE_SIZE) - TILE_SIZE - self.player.height
            self.player.direction = 'up'
        else
            self.player.y = MAP_RENDER_OFFSET_Y + self.player.height / 2
            self.player.direction = 'down'
        end

        -- close all doors in the current room
        for k, doorway in pairs(self.currentRoom.doorways) do
            doorway.open = false
            
        end
    end)
end

-- Resets a few variables needed to perform a camera shift and swaps the next and
-- current room.
function Dungeon:finishShifting()
    self.cameraX = 0
    self.cameraY = 0
    self.shifting = false
    self.currentRoom = self.nextRoom
    self.currentRoom:generateDoorways(self.nextRoom.y, self.nextRoom.x)
    self.currentRoom.x = self.nextRoom.x
    self.currentRoom.y = self.nextRoom.y
    self.currentRoom.adjacentOffsetX = 0
    self.currentRoom.adjacentOffsetY = 0 
end

function Dungeon:update(dt)
    -- pause updating if we're in the middle of shifting rooms or moving dungeons
    if not self.nextLevel then
        if not self.shifting then    
            self.currentRoom:update(dt)
        else
            -- still update the player animation if we're shifting rooms
            self.player.currentAnimation:update(dt)
        end
    end
end

-- shifting rooms triggered by player walking into an open doorway
function Dungeon:shiftRoom(direction)
    self.direction = direction

    -- uses player's direction to determine which doorway the player walked through
    -- intializes the next room's position and changes the currentRoom's x- and y- positions
    -- calls back Event for camera shifting

    --RIGHT
    if self.direction == 'right' then

        if self.currentRoom.y < 4 then
            if self.rooms[self.currentRoom.y + 1][self.currentRoom.x] then
                self.nextRoom = self.rooms[self.currentRoom.y + 1][self.currentRoom.x]
                self.nextRoom.x = self.currentRoom.x
                self.nextRoom.y = self.currentRoom.y + 1
                Event.dispatch('shift-right')
            end
        end
    --LEFT
    elseif self.direction == 'left' then

        if self.currentRoom.y > 1 then
            if self.rooms[self.currentRoom.y - 1][self.currentRoom.x] then
                self.nextRoom = self.rooms[self.currentRoom.y - 1][self.currentRoom.x]
                self.nextRoom.x = self.currentRoom.x
                self.nextRoom.y = self.currentRoom.y - 1
                Event.dispatch('shift-left')
            end
        end
    -- TOP
    elseif self.direction == 'up' then

        if self.currentRoom.x > 1 then
            if self.rooms[self.currentRoom.y][self.currentRoom.x - 1] then
                self.nextRoom = self.rooms[self.currentRoom.y][self.currentRoom.x - 1]
                self.nextRoom.x = self.currentRoom.x - 1
                self.nextRoom.y = self.currentRoom.y
                Event.dispatch('shift-up')
            end
        end
    -- BOTTOM
    elseif self.direction == 'down' then

        if self.currentRoom.x < 3 then
            if self.rooms[self.currentRoom.y][self.currentRoom.x + 1] then
                self.nextRoom = self.rooms[self.currentRoom.y][self.currentRoom.x + 1]
                self.nextRoom.x = self.currentRoom.x + 1
                self.nextRoom.y = self.currentRoom.y
                Event.dispatch('shift-down')
            end
        end
    end
end

function Dungeon:render()
    -- translate the camera if we're actively shifting
    if self.shifting then
        love.graphics.translate(-math.floor(self.cameraX), -math.floor(self.cameraY))
    end

    self.currentRoom:render()
    
    if self.nextRoom then
        self.nextRoom:render()
    end

    if self:checkRooms() then
        self.levelMessage:render()
    end

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.printf(tostring(self.currentRoom.y) .. ", " .. tostring(self.currentRoom.x), 0, 10, VIRTUAL_WIDTH, 'center')
end