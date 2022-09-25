PlayState = Class{__includes = BaseState}

function PlayState:init()
    -- intialize the player
    self.player = Player {
        animations = ENTITY_DEFS['player'].animations,
        walkSpeed = ENTITY_DEFS['player'].walkSpeed,

        x = VIRTUAL_WIDTH / 2 - 8,
        y = VIRTUAL_HEIGHT / 2 - 11,

        width = 16,
        height = 22,

        health = 6, 
        -- ONE HEART = 2 HEALTH

        -- rendering and collision offset for spaced sprites
        offsetY = 5
    }

    self.dungeon = Dungeon(self.player)
    --self.currentRoom = self.dungeon.currentRoom

    self.levelNum = 1

    -- player has their own state machine (further functions can be added)
    self.player.stateMachine = StateMachine {
        ['walk'] = function() return PlayerWalkState(self.player, self.dungeon) end,
        ['idle'] = function() return PlayerIdleState(self.player) end,
        ['swing-sword'] = function() return PlayerSwingSwordState(self.player, self.dungeon) end,
        ['carry-walk'] = function() return PlayerCarryWalkState(self.player, self.dungeon) end,
        ['carry-idle'] = function() return PlayerCarryIdleState(self.player, self.dungeon) end,
        ['lift'] = function() return PlayerLiftState(self.player, self.dungeon) end,
        ['throw'] = function() return PlayerThrowState(self.player, self.dungeon) end
    }
    self.player:changeState('idle') -- default player state is idle
end

function PlayState:enter(params)

end

function PlayState:update(dt)
    if love.keyboard.wasPressed('escape') then -- if the player wants to quit the game
        love.event.quit()
    end

    self.dungeon:update(dt)

    -- checks if all rooms in the current dungeon are unlocked
    -- if yes, then levelNumber increments, and the player is moved to a new dungeon
    if self.dungeon:checkRooms() then
        self.dungeon = Dungeon(self.player)
        self.player:changeState('idle')

        self.levelNum = self.levelNum + 1
    end
end

function PlayState:render()
    -- render dungeon and all entities separate from hearts GUI
    love.graphics.push()
    self.dungeon:render()
    love.graphics.pop()

    --DRAWING HEARTS
    local healthLeft = self.player.health
    local heartFrame = 1

    for i = 1, 3 do
        if healthLeft > 1 then
            heartFrame = 5
        elseif healthLeft == 1 then
            heartFrame = 3
        else
            heartFrame = 1
        end

        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][heartFrame],
            (i - 1) * (TILE_SIZE + 1), 2)

        healthLeft = healthLeft - 2
    end

    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print('Coins: ' .. tostring(self.player.coins), 60, 2)

    love.graphics.print('Level: ' .. tostring(self.levelNum), VIRTUAL_WIDTH - 100, 2)
end
