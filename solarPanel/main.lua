-- main.lua

local SolarPanel = require("solar_panel") -- Ensure this is correct
local Menu = require("menu")

local currentState = "menu" -- Track the current state (menu or game)

function love.load()
    Menu.load()
end

function love.update(dt)
    if currentState == "menu" then
        -- Update the menu state
    else
        SolarPanel.update(dt)
    end
end

function love.draw()
    if currentState == "menu" then
        Menu.draw()
    else
        SolarPanel.draw()
    end
end

function love.keypressed(key)
    if currentState == "menu" then
        local action = Menu.keypressed(key) -- Call the menu's keypressed function
        if action == "start_game" then
            currentState = "game" -- Change state to game
            SolarPanel.load() -- Load the game state
        end
    end
end
