local time = 0
local positions = {{150, 150}}
function DrawCircle()
    love.graphics.print("MY TEST", 400, 200)
    for i, v in pairs(positions) do
        local cx = v[1] + math.sin(time) * 50;
        local cy = v[2]
        if (love.mouse.isDown(1)) then
            love.graphics.setColor(1, 0, 0, 1)
            local x = love.mouse.getX()
            local y = love.mouse.getY()
            local dx = cx - x
            local dy = cy - y
            if ((dx * dx + dy * dy) < (40 * 40)) then
                love.graphics.setColor(1, 0, 0, 1)
            else
                love.graphics.setColor(1, 1, 1, 1)
            end
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        love.graphics.circle("fill", cx, cy, 40, 20)
    end
    
end

function UpdateCircle(dt)
    time = time + math.pi * dt
end
function AddCircle(x, y)
    table.insert(positions, {x, y})
end