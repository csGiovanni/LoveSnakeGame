-- main.lua

local SolarPanel = require("solar_panel")

-- Define game states
local state = "menu"

-- Define button properties
local button = {
    x = 0,
    y = 0,
    width = 200,
    height = 50,
    text = "Start Game",
    -- You can set these in love.load based on the window size
}

function love.load()
    -- Initialize button position (centered)
    button.x = (love.graphics.getWidth() - button.width) / 2
    button.y = (love.graphics.getHeight() - button.height) / 2

    -- Load resources if any
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
        if isInside(x, y, button.x, button.y, button.width, button.height) then
            -- Transition to game state
            state = "game"
            SolarPanel.reset() -- Optional: Reset game state if needed
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
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height, 10, 10)

    -- Draw button text
    love.graphics.setColor(1, 1, 1) -- White color for text
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(button.text)
    local textHeight = font:getHeight(button.text)
    love.graphics.print(
        button.text,
        button.x + (button.width - textWidth) / 2,
        button.y + (button.height - textHeight) / 2
    )
end
