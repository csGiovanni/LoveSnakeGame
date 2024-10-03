require("Circle")

-- Initialize Slots
function love.load()
    AddSlot(500, 500)
    AddSlot(600, 200)
end

local click_debounce = false
function love.update(dt)
    UpdateCircle(dt)
    if (love.mouse.isDown(2)) then
        if (click_debounce == false) then
            click_debounce = true
            AddCircle(love.mouse.getX(), love.mouse.getY())
        end
    else
        click_debounce = false
    end
end

function love.draw()
    love.graphics.print("Hello World", 400, 300)
    DrawSlots()
    DrawCircles()
end