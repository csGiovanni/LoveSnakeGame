-- solar_panel.lua

local SolarPanel = {}
local StaticImage = {}
local Obstacles = {}
local message = "" -- Message to display when an obstacle is placed incorrectly

function SolarPanel.load()
    -- Load background image
    SolarPanel.background = love.graphics.newImage("background.png")

    -- Solar panel (draggable)
    SolarPanel.image = love.graphics.newImage("solarPanel.png")
    SolarPanel.scaleX = 0.3
    SolarPanel.scaleY = 0.3

    -- Initial position (random x along the bottom)
    SolarPanel.originalX = math.random(0, love.graphics.getWidth() - SolarPanel.image:getWidth() * SolarPanel.scaleX)
    SolarPanel.originalY = love.graphics.getHeight() - SolarPanel.image:getHeight() * SolarPanel.scaleY

    -- Current position (used for dragging)
    SolarPanel.x = SolarPanel.originalX
    SolarPanel.y = SolarPanel.originalY

    -- State for dragging and freezing
    SolarPanel.isDragging = false
    SolarPanel.isFrozen = false

    -- Static image (random x along the top)
    StaticImage.image = love.graphics.newImage("panelPosition.png")
    StaticImage.scaleX = 0.3
    StaticImage.scaleY = 0.3

    -- Randomly position static image at the top
    StaticImage.x = math.random(0, love.graphics.getWidth() - StaticImage.image:getWidth() * StaticImage.scaleX)
    StaticImage.y = 0

    -- Initialize obstacles
    Obstacles = {} -- Reset obstacles table
    for i = 1, 3 do
        local obstacle = {
            image = love.graphics.newImage("obstacle.png"),
            scaleX = 0.3,
            scaleY = 0.3,
            originalX = math.random(0, love.graphics.getWidth() - 64),
            originalY = math.random(100, love.graphics.getHeight() - 100),
            x = 0,
            y = 0,
            isDragging = false
        }
        obstacle.x = obstacle.originalX
        obstacle.y = obstacle.originalY
        table.insert(Obstacles, obstacle)
    end

    message = "" -- Reset message
end

-- Add a reset function to reinitialize the game
function SolarPanel.reset()
    SolarPanel.load()
end

function SolarPanel.update(dt)
    -- If the solar panel is frozen, don't allow movement
    if SolarPanel.isFrozen then
        return
    end

    -- Draggable solar panel update
    if love.mouse.isDown(1) then
        local mouseX, mouseY = love.mouse.getPosition()

        if not SolarPanel.isDragging and 
           mouseX >= SolarPanel.x and mouseX <= SolarPanel.x + SolarPanel.image:getWidth() * SolarPanel.scaleX and 
           mouseY >= SolarPanel.y and mouseY <= SolarPanel.y + SolarPanel.image:getHeight() * SolarPanel.scaleY then
            SolarPanel.isDragging = true
        end

        -- If dragging, move the solar panel with the mouse
        if SolarPanel.isDragging then
            SolarPanel.x = mouseX - (SolarPanel.image:getWidth() * SolarPanel.scaleX / 2)
            SolarPanel.y = mouseY - (SolarPanel.image:getHeight() * SolarPanel.scaleY / 2)
        end
    else
        -- When mouse button is released, stop dragging and reset position if no collision
        if SolarPanel.isDragging then
            SolarPanel.isDragging = false

            -- Check if the solar panel collides with the static image
            if SolarPanel.checkCollision() then
                -- Move solar panel to static image's position
                SolarPanel.x = StaticImage.x
                SolarPanel.y = StaticImage.y

                -- Freeze the solar panel
                SolarPanel.isFrozen = true
            else
                -- Reset to original position if no collision
                SolarPanel.x = SolarPanel.originalX
                SolarPanel.y = SolarPanel.originalY
            end
        end
    end

    -- Update obstacles
    for i, obstacle in ipairs(Obstacles) do
        if love.mouse.isDown(1) then
            local mouseX, mouseY = love.mouse.getPosition()

            if not obstacle.isDragging and
               mouseX >= obstacle.x and mouseX <= obstacle.x + obstacle.image:getWidth() * obstacle.scaleX and
               mouseY >= obstacle.y and mouseY <= obstacle.y + obstacle.image:getHeight() * obstacle.scaleY then
                obstacle.isDragging = true
            end

            -- If dragging, move the obstacle with the mouse
            if obstacle.isDragging then
                obstacle.x = mouseX - (obstacle.image:getWidth() * obstacle.scaleX / 2)
                obstacle.y = mouseY - (obstacle.image:getHeight() * obstacle.scaleY / 2)
            end
        else
            if obstacle.isDragging then
                obstacle.isDragging = false

                -- Check if obstacle collides with the static image
                if SolarPanel.checkObstacleCollision(obstacle) then
                    -- Display a message saying you can't place it here
                    message = "You can't place this here!"
                    -- Return the obstacle to its original position
                    obstacle.x = obstacle.originalX
                    obstacle.y = obstacle.originalY
                else
                    -- Reset the message
                    message = ""
                end
            end
        end
    end

    -- Check for obstacle collisions with each other only if no one is being dragged
    if not SolarPanel.isDragging then
        for i, obstacle in ipairs(Obstacles) do
            if not obstacle.isDragging then
                for j, otherObstacle in ipairs(Obstacles) do
                    if i ~= j and not otherObstacle.isDragging then -- Ensure not to check against itself and only if the other isn't being dragged
                        if SolarPanel.checkObstacleCollisionPair(obstacle, otherObstacle) then
                            -- Handle the collision (e.g., reset position of the colliding obstacle)
                            obstacle.x = obstacle.originalX
                            obstacle.y = obstacle.originalY
                        end
                    end
                end
            end
        end
    end
end

-- Function to check collision between solar panel and static image
function SolarPanel.checkCollision()
    local solarPanelRight = SolarPanel.x + SolarPanel.image:getWidth() * SolarPanel.scaleX
    local solarPanelBottom = SolarPanel.y + SolarPanel.image:getHeight() * SolarPanel.scaleY
    local staticImageRight = StaticImage.x + StaticImage.image:getWidth() * StaticImage.scaleX
    local staticImageBottom = StaticImage.y + StaticImage.image:getHeight() * StaticImage.scaleY

    return SolarPanel.x < staticImageRight and
           solarPanelRight > StaticImage.x and
           SolarPanel.y < staticImageBottom and
           solarPanelBottom > StaticImage.y
end

-- Function to check collision between an obstacle and the static image
function SolarPanel.checkObstacleCollision(obstacle)
    local obstacleRight = obstacle.x + obstacle.image:getWidth() * obstacle.scaleX
    local obstacleBottom = obstacle.y + obstacle.image:getHeight() * obstacle.scaleY
    local staticImageRight = StaticImage.x + StaticImage.image:getWidth() * StaticImage.scaleX
    local staticImageBottom = StaticImage.y + StaticImage.image:getHeight() * StaticImage.scaleY

    return obstacle.x < staticImageRight and
           obstacleRight > StaticImage.x and
           obstacle.y < staticImageBottom and
           obstacleBottom > StaticImage.y
end

-- Function to check collision between two obstacles
function SolarPanel.checkObstacleCollisionPair(obstacle1, obstacle2)
    local obstacle1Right = obstacle1.x + obstacle1.image:getWidth() * obstacle1.scaleX
    local obstacle1Bottom = obstacle1.y + obstacle1.image:getHeight() * obstacle1.scaleY
    local obstacle2Right = obstacle2.x + obstacle2.image:getWidth() * obstacle2.scaleX
    local obstacle2Bottom = obstacle2.y + obstacle2.image:getHeight() * obstacle2.scaleY

    return obstacle1.x < obstacle2Right and
           obstacle1Right > obstacle2.x and
           obstacle1.y < obstacle2Bottom and
           obstacle1Bottom > obstacle2.y
end

function SolarPanel.draw()
    -- Draw background image
    love.graphics.draw(SolarPanel.background, 0, 0)

    -- Draw static image at the top first (so it is behind)
    love.graphics.draw(StaticImage.image, StaticImage.x, StaticImage.y, 0, StaticImage.scaleX, StaticImage.scaleY)

    -- Draw draggable solar panel on top
    love.graphics.draw(SolarPanel.image, SolarPanel.x, SolarPanel.y, 0, SolarPanel.scaleX, SolarPanel.scaleY)

    -- Draw obstacles
    for i, obstacle in ipairs(Obstacles) do
        love.graphics.draw(obstacle.image, obstacle.x, obstacle.y, 0, obstacle.scaleX, obstacle.scaleY)
    end

    -- Display message
    love.graphics.setColor(1, 1, 1) -- Ensure text is white
    love.graphics.print(message, 10, love.graphics.getHeight() - 20)
end

return SolarPanel
