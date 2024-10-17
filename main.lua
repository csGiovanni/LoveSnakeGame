-- main.lua

local SolarPanel = require("solar_panel")

-- Define game states
local state = "menu"

-- Define Start Game button properties
local startButton = {
    x = 0,
    y = 0,
    width = 200,
    height = 50,
    text = "Start Game",
}

-- Define Quit button properties
local quitButton = {
    x = 0,
    y = 0,
    width = 200,
    height = 50,
    text = "Quit",
}

function love.load()
    -- Initialize buttons positions (centered)
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    startButton.x = (windowWidth - startButton.width) / 2
    startButton.y = (windowHeight - startButton.height) / 2 - 30

    quitButton.x = (windowWidth - quitButton.width) / 2
    quitButton.y = startButton.y + startButton.height + 20 -- 20 pixels below the start button

    -- Load game resources
    SolarPanel.load()
end

function love.update(dt)
    if state == "game" then
        SolarPanel.update(dt)
    end
    -- No need to update anything for the menu in this simple example
end

function love.draw()
    if state == "menu" then
        drawMenu()
    elseif state == "game" then
        SolarPanel.draw()
    end
end

function love.mousepressed(x, y, buttonType, istouch, presses)
    if state == "menu" and buttonType == 1 then -- 1 is the left mouse button
        -- Start Game Button
        if isInside(x, y, startButton.x, startButton.y, startButton.width, startButton.height) then
            -- Transition to game state
            state = "game"
            SolarPanel.reset() -- Optional: Reset game state if needed
        end

        -- Quit Button
        if isInside(x, y, quitButton.x, quitButton.y, quitButton.width, quitButton.height) then
            love.event.quit()
        end
    elseif state == "game" then
        -- Pass mouse pressed event to SolarPanel if needed
        -- For example:
        -- SolarPanel.mousepressed(x, y, buttonType, istouch, presses)
    end
end

-- Helper function to check if a point is inside a rectangle
function isInside(x, y, rectX, rectY, rectWidth, rectHeight)
    return x >= rectX and x <= (rectX + rectWidth) and
           y >= rectY and y <= (rectY + rectHeight)
end

-- Function to draw the menu
function drawMenu()
    -- Set a background color or image
    love.graphics.clear(0.1, 0.1, 0.1) -- Dark gray background

    -- Draw the "Start Game" button
    love.graphics.setColor(0.2, 0.6, 1) -- Button color (light blue)
    love.graphics.rectangle("fill", startButton.x, startButton.y, startButton.width, startButton.height, 10, 10)

    -- Draw Start button text
    love.graphics.setColor(1, 1, 1) -- White color for text
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(startButton.text)
    local textHeight = font:getHeight(startButton.text)
    love.graphics.print(
        startButton.text,
        startButton.x + (startButton.width - textWidth) / 2,
        startButton.y + (startButton.height - textHeight) / 2
    )

    -- Draw the "Quit" button
    love.graphics.setColor(0.6, 0.2, 0.2) -- Button color (light red)
    love.graphics.rectangle("fill", quitButton.x, quitButton.y, quitButton.width, quitButton.height, 10, 10)

    -- Draw Quit button text
    love.graphics.setColor(1, 1, 1) -- White color for text
    local quitTextWidth = font:getWidth(quitButton.text)
    local quitTextHeight = font:getHeight(quitButton.text)
    love.graphics.print(
        quitButton.text,
        quitButton.x + (quitButton.width - quitTextWidth) / 2,
        quitButton.y + (quitButton.height - quitTextHeight) / 2
    )
end
