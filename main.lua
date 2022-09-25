-- connects all the classes, libraries, and variables together
require 'src/Dependencies'

function love.load()
    math.randomseed(os.time())
    love.window.setTitle('Ghosts')
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- used for handling resolution with different width-height ratios
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    love.graphics.setFont(gFonts['small'])

    -- to maneuver between the title scree, gameplay, and the game-over screen
    -- Also easy to add extra states by adding it here
    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['play'] = function() return PlayState() end,
        ['game-over'] = function() return GameOverState() end
    }
    gStateMachine:change('start')

    -- initializes an array to store which input keys are pressed
    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

-- global function to check which key was pressed
function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    Timer.update(dt)
    gStateMachine:update(dt)

    -- clears all contents of the array at the moment after all functions are used
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()
    gStateMachine:render()
    push:finish()
end