-- Ensure that the module does not reload itself
local Menu = {}

function Menu.load()
    Menu.title = "Solar Panel Game"
    Menu.startButton = {
        x = love.graphics.getWidth() / 2 - 100,
        y = love.graphics.getHeight() / 2 - 25,
        width = 200,
        height = 50,
        text = "Start Game"
    }
end

function Menu.update(dt)
    -- Handle any updates here, for now, we just wait for mouse input
end

function Menu.draw()
    -- Draw the title
    love.graphics.printf(Menu.title, 0, love.graphics.getHeight() / 4, love.graphics.getWidth(), "center")

    -- Draw the start button
    love.graphics.rectangle("line", Menu.startButton.x, Menu.startButton.y, Menu.startButton.width, Menu.startButton.height)
    love.graphics.printf(Menu.startButton.text, Menu.startButton.x, Menu.startButton.y + 15, Menu.startButton.width, "center")
end

function Menu.mousepressed(x, y, button, istouch, presses)
    -- Check if the start button is clicked
    if button == 1 and
       x >= Menu.startButton.x and x <= Menu.startButton.x + Menu.startButton.width and
       y >= Menu.startButton.y and y <= Menu.startButton.y + Menu.startButton.height then
        -- Switch to the game state
        gameState = "game"
    end
end

return Menu
s