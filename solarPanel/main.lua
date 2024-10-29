-- main.lua

local SolarPanel = require("solar_panel") -- Ensure this is correct
local Menu = require("menu")
local Settings = require("settings") -- New settings screen module

local currentState = "menu" -- Track the current state (menu, game, settings)

function love.load()
    Menu.load() -- Load the menu resources
    SolarPanel.load() -- Load the game resources but do not play music yet

    -- Initialize the background music
    local menuVolume, gameVolume = Settings.getVolumes()
    Menu.bgMusic:setVolume(menuVolume) -- Set volume for menu music
    SolarPanel.bgMusic:setVolume(gameVolume) -- Set volume for game music

    -- Stop the SolarPanel music at the beginning
    SolarPanel.bgMusic:stop() -- Ensure SolarPanel music is stopped initially

    -- Start playing the menu music
    Menu.bgMusic:play() -- Play menu music on load
end

function love.update(dt)
    if currentState == "menu" then
        -- Update the menu state (if needed)
        if not Menu.bgMusic:isPlaying() then
            Menu.bgMusic:play() -- Ensure menu music is playing
        end
    elseif currentState == "settings" then
        -- Update the settings state (if needed)
        -- Add any necessary update logic for settings here
    elseif currentState == "game" then
        SolarPanel.update(dt) -- Update the game only when in the game state
    end

    -- Set the music volumes based on the settings
    local menuVolume, gameVolume = Settings.getVolumes()
    Menu.bgMusic:setVolume(menuVolume)
    SolarPanel.bgMusic:setVolume(gameVolume)
end

function love.draw()
    if currentState == "menu" then
        Menu.draw()
    elseif currentState == "game" then
        SolarPanel.draw()
    elseif currentState == "settings" then
        local menuVolume, gameVolume = Settings.getVolumes()
        Settings.draw(menuVolume, gameVolume) -- Pass the current volumes to the settings draw
    end
end

function love.keypressed(key)
    if currentState == "menu" then
        local action = Menu.keypressed(key) -- Call the menu's keypressed function
        if action == "start_game" then
            currentState = "game" -- Change state to game
            Menu.bgMusic:stop() -- Stop the menu music
            SolarPanel.load() -- Load the game state
            SolarPanel.bgMusic:play() -- Start playing game music
        elseif action == "open_settings" then
            currentState = "settings" -- Change state to settings
            Settings.load() -- Load the settings state
            Menu.bgMusic:stop() -- Stop the menu music
            SolarPanel.bgMusic:stop() -- Ensure game music is stopped
        end
    elseif currentState == "settings" then
        if key == "escape" then
            currentState = "menu" -- Return to menu when "escape" is pressed
            SolarPanel.bgMusic:stop() -- Stop the game music if it’s playing
            Menu.bgMusic:play() -- Start playing menu music again
        end
    end
end

function love.mousepressed(x, y, button)
    if currentState == "menu" then
        local action = Menu.mousepressed(x, y, button)
        if action == "start_game" then
            currentState = "game"
            Menu.bgMusic:stop() -- Stop the menu music
            SolarPanel.load() -- Load the game state
            SolarPanel.bgMusic:play() -- Start playing game music
        elseif action == "open_settings" then
            currentState = "settings"
            Settings.load() -- Load the settings state
            Menu.bgMusic:stop() -- Stop the menu music
            SolarPanel.bgMusic:stop() -- Ensure game music is stopped
        end
    elseif currentState == "settings" then
        Settings.mousepressed(x, y) -- Pass mouse press to the settings module
    end
end

function love.mousemoved(x, y, dx, dy)
    if currentState == "menu" then
        Menu.mousemoved(x, y)
    elseif currentState == "settings" then
        Settings.mousemoved(x, y)
    end
end

function love.mousereleased(x, y, button)
    if currentState == "settings" then
        Settings.mousereleased(x, y, button) -- Call the release function for the settings module
    end
end
