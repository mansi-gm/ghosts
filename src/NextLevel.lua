NextLevel = Class{}

function NextLevel:init(dungeon)
    self.activate = false
    self.dungeon = dungeon
    self.transitionAlpha = 255
end

function NextLevel:update(dt)

    --[[if not self.activate then
        Timer.tween(3, {
            [self] = {transitionAlpha = 0}
        })
        :finish(function()
            self.dungeon.nextLevel = true
            self = nil
        end)
    end]]

    self.transitionAlpha = self.transitionAlpha - (255 / 180)

    if self.transitionAlpha == 0 then
        self.dungeon.nextLevel = true
        self = nil
    end
end

function NextLevel:render()

    love.graphics.setColor(255, 255, 255, self.transitionAlpha)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 4, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 15, 3)
    love.graphics.setColor(56, 56, 56, self.transitionAlpha)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 4 + 1, VIRTUAL_HEIGHT / 3 + 1, VIRTUAL_WIDTH / 2 -2, VIRTUAL_HEIGHT / 2 - 17, 3)
    love.graphics.setColor(255, 255, 255, self.transitionAlpha)
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('Next Level...', 0, 90, VIRTUAL_WIDTH, 'center')

end