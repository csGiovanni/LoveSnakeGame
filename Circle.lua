local circles = {}
local slots = {}
local selected_circle = nil;
-- Snap a circle to coordinate {x, y} within a snap_radius
local function SnapCircle(circle, x, y, snap_radius)
    local cx = circle.x;
    local cy = circle.y;
    local dx = cx - x;
    local dy = cy - y;
    if (dx * dx + dy * dy < snap_radius * snap_radius) then
        circle.x = x;
        circle.y = y;
    end
end
function DrawCircles()
    love.graphics.print("Left Click = Drag | Right Click = Place Circle", 100, 100)
    for i, circle in pairs(circles) do
        local cx = circle.x
        local cy = circle.y
        if (circle == selected_circle) then
            love.graphics.setColor(1, 0, 0, 1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        love.graphics.circle("fill", cx, cy, 40, 20)
        love.graphics.setColor(1, 1, 1, 1)
    end
    
end
function DrawSlots()
    for i, circle in pairs(slots) do
        local cx = circle.x
        local cy = circle.y

        love.graphics.setColor(0, 0, 1, 1)
        love.graphics.circle("fill", cx, cy, 50, 20)
        love.graphics.setColor(1, 1, 1, 1)
    end
    
end

function UpdateCircle(dt)
    -- Iterate through each spawned circle to determine if they should be selected and move
    for i, circle in pairs(circles) do
        -- Check if the player has left mouse down
        if (love.mouse.isDown(1)) then
            -- Check if the mouse is inside a circle
            local x = love.mouse.getX()
            local y = love.mouse.getY()
            local cx = circle.x
            local cy = circle.y
            local dx = cx - x
            local dy = cy - y
            -- Distance Squared instead of Distance to save on performance
            -- If there is already a selected circle, do not select another
            if ((dx * dx + dy * dy) < (40 * 40) and selected_circle == nil) then
                selected_circle = circle;
            end
        else
            selected_circle = nil;
        end
    end
    -- If a select is selected, move with mouse and snap to slots
    if (selected_circle ~= nil) then
        local x = love.mouse.getX()
        local y = love.mouse.getY()
        selected_circle.x = x;
        selected_circle.y = y;

        -- If inside a slot, Snap (checking handled inside the SnapCircle function)
        for i, slot in pairs(slots) do
            SnapCircle(selected_circle, slot.x, slot.y, 50);
        end
    end
end
-- Spawn a Circle
function AddCircle(x, y)
    table.insert(circles, {
        x = x,
        y = y,
    })
end
-- Spawn a Slot
function AddSlot(x,y)
    table.insert(slots, {
        x = x, 
        y = y})
end