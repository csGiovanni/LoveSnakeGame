-- main.lua

local SolarPanel = require("solar_panel")

function love.load()
    SolarPanel.load()
end

function love.update(dt)
    SolarPanel.update(dt)
end

function love.draw()
    SolarPanel.draw()
end
