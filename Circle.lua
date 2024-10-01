local time = 0
local positions = {{150, 150}}
function DrawCircle()
    love.graphics.print("MY TEST", 400, 200)
    for i, v in pairs(positions) do
        love.graphics.circle("fill", v[1] + math.sin(time) * 50, v[2], 40, 20)
    end
    
end

function UpdateCircle(dt)
    time = time + math.pi * dt
end
function AddCircle(x, y)
    table.insert(positions, {x, y})
end