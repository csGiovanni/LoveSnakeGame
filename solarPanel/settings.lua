local Settings = {}

local sliderWidth = 200
local sliderHeight = 10
local sliderX = 300
local menuSliderY = 200
local gameSliderY = 300

local isDraggingMenuSlider = false
local isDraggingGameSlider = false

local menuVolume = 1.0
local gameVolume = 1.0

function Settings.load()
    -- Load any resources if necessary
end

function Settings.draw(menuVol, gameVol)
    love.graphics.clear(0.1, 0.1, 0.1) -- Dark background
    love.graphics.setFont(love.graphics.newFont(48))
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Settings", 0, 50, love.graphics.getWidth(), "center")

    -- Draw the menu volume slider
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf("Menu Volume", sliderX - 50, menuSliderY - 30, 200, "left")
    love.graphics.rectangle("fill", sliderX, menuSliderY, sliderWidth, sliderHeight)
    love.graphics.rectangle("fill", sliderX + (menuVolume * sliderWidth) - 5, menuSliderY - 5, 10, sliderHeight + 10)

    -- Draw the game volume slider
    love.graphics.printf("Game Volume", sliderX - 50, gameSliderY - 30, 200, "left")
    love.graphics.rectangle("fill", sliderX, gameSliderY, sliderWidth, sliderHeight)
    love.graphics.rectangle("fill", sliderX + (gameVolume * sliderWidth) - 5, gameSliderY - 5, 10, sliderHeight + 10)

    love.graphics.printf("Press ESC to return", 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")
end

function Settings.mousepressed(x, y)
    if x >= sliderX and x <= sliderX + sliderWidth then
        if y >= menuSliderY - 5 and y <= menuSliderY + sliderHeight + 5 then
            isDraggingMenuSlider = true
        elseif y >= gameSliderY - 5 and y <= gameSliderY + sliderHeight + 5 then
            isDraggingGameSlider = true
        end
    end
end

function Settings.mousemoved(x, y, dx, dy)
    -- Check if the user is dragging the menu slider
    if isDraggingMenuSlider then
        local newVolume = (x - sliderX) / sliderWidth
        menuVolume = math.max(0, math.min(1, newVolume)) -- Clamp between 0 and 1
    end

    -- Check if the user is dragging the game slider
    if isDraggingGameSlider then
        local newVolume = (x - sliderX) / sliderWidth
        gameVolume = math.max(0, math.min(1, newVolume)) -- Clamp between 0 and 1
    end
end

function Settings.mousereleased(x, y, button)
    -- Reset dragging states when the mouse button is released
    isDraggingMenuSlider = false
    isDraggingGameSlider = false
end

function Settings.getVolumes()
    return menuVolume, gameVolume
end

return Settings
