local time = 0
function DrawCircle()
    love.graphics.print("MY TEST", 400, 200)
    love.graphics.circle("fill", 150 + math.sin(time) * 50, 150, 40, 20)
end

function UpdateCircle(dt)
    time = time + math.pi * dt
end