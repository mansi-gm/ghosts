Room = Class{}

function Room:init(dungeon, y, x)
    self.width = MAP_WIDTH
    self.height = MAP_HEIGHT

    self.unlocked = false
    self.playing = true

    self.map = Map(self)

    self.tiles = {}
    self:generateWallsAndFloors()

    -- all entities in the room
    self.entities = {}
    self:generateEntities()

    -- all game objects in the room
    self.objects = {}
    self:generateObjects()

    -- all projectiles in the room
    self.projectiles = {}

    self.dungeon = dungeon

    -- reference to player for collisions, etc.
    self.player = self.dungeon.player

    -- reference of the room's position in the dungeon
    self.x = x
    self.y = y
    self.rooms = self.dungeon.rooms

    self.dungeonRooms = DungeonRooms(self.rooms, self.y, self.x)

    -- doorways that lead to other rooms in the dungeon
    self.doorways = {}
    self:generateDoorways(self.y, self.x)

    -- used for centering the dungeon rendering
    self.renderOffsetX = MAP_RENDER_OFFSET_X
    self.renderOffsetY = MAP_RENDER_OFFSET_Y

    -- used for drawing when this room is the next room, adjacent to the active
    self.adjacentOffsetX = 0
    self.adjacentOffsetY = 0
end

-- checks for adjacent rooms and connects them with a doorway
function Room:generateDoorways(hIndex, vIndex)

    self.hIndex = hIndex
    self.vIndex = vIndex
    if self.hIndex < 4 then
        if self.rooms[self.hIndex + 1][self.vIndex] then 
            table.insert(self.doorways, Doorway('right', false, self))
        end
    end
    if self.hIndex > 1 then
        if self.rooms[self.hIndex - 1][self.vIndex] then
            table.insert(self.doorways, Doorway('left', false, self))
        end
    end
    if self.vIndex < 4 then
        if self.rooms[self.hIndex][self.vIndex + 1] then
            table.insert(self.doorways, Doorway('bottom', false, self))
        end
    end
    if self.vIndex > 1 then
        if self.rooms[self.hIndex][self.vIndex - 1] then
            table.insert(self.doorways, Doorway('top', false, self))
        end
    end
end

-- randomly creates 7 entities in the room
function Room:generateEntities()
    local types = {'skeleton', 'slime', 'bat', 'ghost', 'spider'}

    for i = 1, 7 do
        local type = types[math.random(#types)]

        table.insert(self.entities, Entity {
            animations = ENTITY_DEFS[type].animations,
            walkSpeed = ENTITY_DEFS[type].walkSpeed or 20,

            -- ensure X and Y are within bounds of the map / room
            x = math.random(MAP_RENDER_OFFSET_X + TILE_SIZE,
                VIRTUAL_WIDTH - TILE_SIZE * 2 - 16),
            y = math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
                VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16),

            width = 16,
            height = 16,

            health = 1
        })

        self.entities[i].stateMachine = StateMachine {
            ['walk'] = function() return EntityWalkState(self.entities[i], self) end,
            ['idle'] = function() return EntityIdleState(self.entities[i], self) end
        }

        self.entities[i]:changeState('walk')
    end
end

-- Creates game objects (the switch) in the room
function Room:generateObjects()
    table.insert(self.objects, GameObject(
        GAME_OBJECT_DEFS['switch'],
        math.random(MAP_RENDER_OFFSET_X + TILE_SIZE,
                    VIRTUAL_WIDTH - TILE_SIZE * 2 - 16),
        math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
                    VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16)
    ))

    -- get reference to the switch
    local switch = self.objects[1]

    -- anonymous function callback for the switch that opens the doors when pressed
    switch.onCollide = function()
        if switch.state == 'unpressed' then
            
            -- if this is the first time the switch was pressed, the player earns 5 coins
            self.player.coins = self.player.coins + 5
            if not self.unlocked then
                self.player.roomNum = self.player.roomNum + 1
                self.unlocked = true
            end
        end
        
        -- opens every door if the switch is pressed
        for k, doorway in pairs(self.doorways) do
            doorway.open = true
        end
        switch.state = 'pressed'
    end
end

-- generates the walls and floors of the rooms
function Room:generateWallsAndFloors()
    for y = 1, self.height do
        table.insert(self.tiles, {})

        for x = 1, self.width do
            local id = TILE_EMPTY


            -- CORNERS

            if x == 1 and y == 1 then
                id = TILE_TOP_LEFT_CORNER
            elseif x == 1 and y == self.height then
                id = TILE_BOTTOM_LEFT_CORNER
            elseif x == self.width and y == 1 then
                id = TILE_TOP_RIGHT_CORNER
            elseif x == self.width and y == self.height then
                id = TILE_BOTTOM_RIGHT_CORNER


            -- WALLS

            elseif x == 1 then
                id = TILE_LEFT_WALLS[math.random(#TILE_LEFT_WALLS)]
            elseif x == self.width then
                id = TILE_RIGHT_WALLS[math.random(#TILE_RIGHT_WALLS)]
            elseif y == 1 then
                id = TILE_TOP_WALLS[math.random(#TILE_TOP_WALLS)]
            elseif y == self.height then
                id = TILE_BOTTOM_WALLS[math.random(#TILE_BOTTOM_WALLS)]
            
            
            -- FLOOR

            else
                id = TILE_FLOORS[math.random(#TILE_FLOORS)]
            end

            table.insert(self.tiles[y], {
                id = id
            })
        end
    end
end

function Room:update(dt)
    -- don't update anything if we are sliding to another room (we have offsets)
    if self.adjacentOffsetX ~= 0 or self.adjacentOffsetY ~= 0 then return end

    if self.playing then -- flag to see if the player is playing 
        self.player:update(dt)

        -- 1 in 800 chance for a heart to spawn in the room
        if math.random(800) == 1 then
            local offsetX, offsetY = MAP_RENDER_OFFSET_X + TILE_SIZE, MAP_RENDER_OFFSET_Y + TILE_SIZE
            local heart = GameObject(GAME_OBJECT_DEFS['heart'], math.random(offsetX, VIRTUAL_WIDTH - offsetX), math.random(offsetY, VIRTUAL_HEIGHT - offsetY))
            table.insert(self.objects, heart)

            -- callback function to increase player health if the heart is consumed
            heart.onConsume = function()
                self.player.health = math.min(math.floor(self.player.health) + 2, 6)
            end
        end

        for i = #self.entities, 1, -1 do
            local entity = self.entities[i]

            -- remove entity from the table if health is <= 0
            if entity.health <= 0 then
                entity.dead = true
            elseif not entity.dead then
                entity:processAI({room = self}, dt)
                entity:update(dt)
            end        
        end

        for k, object in pairs(self.objects) do
            object:update(dt)

            -- trigger collision callback on object
            if self.player:collides(object) then
                if object.consumable then
                    object:onConsume()
                    table.remove(self.objects, k)
                elseif object.type == 'pot' then

                else
                    object:onCollide()
                end
            end
        end
        
        -- checks for collisions between the player and projectiles
        for k, projectile in pairs(self.projectiles) do
            projectile:update(dt)

            if projectile:collides(self.player) and not self.player.invulnerable then
                self.player:damage(1)
                self.player:goInvulnerable(1.5)
                projectile:destroy(self) -- projectile destroyed after colliding with player

                -- if player is out of health, self.playing flag is set to false
                if self.player.health == 0 then
                    self.playing = false
                end
            end

            -- destroy projectile if it hits with the walls or doors
            local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) 
                + MAP_RENDER_OFFSET_Y - TILE_SIZE

            if projectile.x < MAP_RENDER_OFFSET_X + TILE_SIZE or projectile.x > VIRTUAL_WIDTH - TILE_SIZE * 2 - projectile.width or projectile.y < MAP_RENDER_OFFSET_Y + TILE_SIZE - projectile.height / 2 or  projectile.y > bottomEdge - projectile.height then
                projectile:destroy(self)
            end
        end
    -- if player loses all three hearts, they can choose to spend 15 coins to keep playing
    elseif not self.playing then
        --checks input response ('y' for yes and 'n'  for no)
        if love.keyboard.wasPressed('y') then
            if self.player.coins >= COINS_NEEDED then
                self.playing = true
                self.player.coins = self.player.coins - COINS_NEEDED
                self.player.health = 6
            else
                gStateMachine:change('game-over') -- if not, move to game over screen
            end
        elseif love.keyboard.wasPressed('n') then
            gStateMachine:change('game-over') -- player chooses not to spend coins and goes to game over screen
        end
    end
end

function Room:render()
    love.graphics.setColor(255, 255, 255, 255)
    
    -- render doorways; stencils are placed where the arches are after so the player can
    -- move through them convincingly
    love.graphics.stencil(function()
        -- left
        love.graphics.rectangle('fill', -TILE_SIZE - 6, MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE,
            TILE_SIZE * 2 + 6, TILE_SIZE * 2)

        -- right
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE) - 6,
            MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE, TILE_SIZE * 2 + 6, TILE_SIZE * 2)

        -- top
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
            -TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)

        --bottom
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
            VIRTUAL_HEIGHT - TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
    end, 'replace', 1)

    love.graphics.setStencilTest('less', 1)

    -- INSIDE STENCIL START
    -- player can only see a circle of radius 24 pixels around them
    -- line of vision

    love.graphics.stencil(function()
        love.graphics.circle('fill', self.player.x + self.player.width / 2, self.player.y + self.player.height / 2 , 24)
    end, 'replace', 1)

    love.graphics.setStencilTest('greater', 0)

    -- render everything (tiles, objects, entities, projectiles) inside this stencil

    for y = 1, self.height do
        for x = 1, self.width do
            local tile = self.tiles[y][x]
            love.graphics.draw(gTextures['tiles-new'], gFrames['tiles-new'][tile.id],
                (x - 1) * TILE_SIZE + self.renderOffsetX + self.adjacentOffsetX,
                (y - 1) * TILE_SIZE + self.renderOffsetY + self.adjacentOffsetY)
        end
    end

    for k, doorway in pairs(self.doorways) do
        doorway:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end

    for k, object in pairs(self.objects) do
        object:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end

    for k, entity in pairs(self.entities) do
        if not entity.dead then entity:render(self.adjacentOffsetX, self.adjacentOffsetY) end
    end

    for k, projectile in pairs(self.projectiles) do
        projectile:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end

    if self.player then
        self.player:render()
    end

    love.graphics.setStencilTest()

    --INSIDE STENCIL FINISH

    love.graphics.setStencilTest()

    -- render overlays like the map / monitor after the stencil
    self.map:render()
    --self.dungeonRooms:render()

    if not self.playing then -- UI to ask player if they want to continue
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.rectangle('fill', VIRTUAL_WIDTH / 4, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 15, 3)
        love.graphics.setColor(56, 56, 56, 255)
        love.graphics.rectangle('fill', VIRTUAL_WIDTH / 4 + 1, VIRTUAL_HEIGHT / 3 + 1, VIRTUAL_WIDTH / 2 -2, VIRTUAL_HEIGHT / 2 - 17, 3)
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf('CONTINUE?', 0, 90, VIRTUAL_WIDTH, 'center')

        love.graphics.setFont(gFonts['medium'])
        love.graphics.print('Y: Yes', 110, 140)
        love.graphics.setFont(gFonts['medium'])
        love.graphics.print('N: No', 230, 140)
    end
end
