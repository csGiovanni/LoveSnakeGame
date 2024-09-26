require("Circle")

function love.load()
    
end

function love.update(dt)
    UpdateCircle(dt)
end

function love.draw()
    love.graphics.print("Hello World", 400, 300)
    DrawCircle()
end