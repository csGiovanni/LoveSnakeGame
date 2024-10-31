-- solar_panel.lua

local SolarPanel = {}
local StaticImage = {}
local Obstacles = {}
local popupImage = nil
local showMessage = false -- Flag to control popup visibility
local message = "" -- Message to display
local messageTimer = 0 -- Timer to control how long the message is displayed

function SolarPanel.load()
    -- Load background image
    SolarPanel.background = love.graphics.newImage("background.png")
    -- Load game music
    SolarPanel.gameMusic = love.audio.newSource("game_music.mp3", "stream")
    SolarPanel.gameMusic:setLooping(true) -- Set the music to loop
    SolarPanel.gameMusic:play() -- Play the music
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
    SolarPanel.isFrozen = false -- New flag to freeze movement after collision

    -- Initialize Grid
    SolarPanel.grid = {}
    local x_size = 10
    local y_size = 4
    -- Record the size of the grid
    SolarPanel.grid.x_size = x_size
    SolarPanel.grid.y_size = y_size
    -- Record where the grid has been placed
    SolarPanel.grid.x_offset = 100
    SolarPanel.grid.y_offset = 100
    -- Record spacing between each cell
    SolarPanel.grid.spacing = 52
    -- Record how big to draw each cell
    SolarPanel.grid.cell_size = 50
    for i = 1, x_size do
        SolarPanel.grid[i] = {}
        for j = 1, y_size do
            -- Create information for each grid cell
            SolarPanel.grid[i][j] = {}
            local grid_cell_info = SolarPanel.grid[i][j]
            -- To record if a solar panel is occupying a cell
            grid_cell_info.occupied = false;
        end
    end

    -- Initialize Solar Panels and the selected panel
    SolarPanel.panelImage = love.graphics.newImage("solarPanel2.png")
    SolarPanel.panels = {}
    SolarPanel.selected = nil
    for i = 1, 5 do
        local panel = {}
        panel.x = 50 + i * 100
        panel.y = 400
        panel.rotation = 0
        panel.xScale = 0.22
        panel.yScale = 0.21
        panel.rotateDebounce = true
        panel.tag = "panel"
        table.insert(SolarPanel.panels, panel)
    end
    SolarPanel.wires = {}
    SolarPanel.wire_xSize = SolarPanel.grid.cell_size - 2
    SolarPanel.wire_ySize = SolarPanel.grid.cell_size / 4
    for i = 1, 5 do
        local wire = {}
        wire.x = 50 + i * 100
        wire.y = 500
        wire.rotation = 0
        wire.xScale = 0.22
        wire.yScale = 0.21
        wire.rotateDebounce = true
        wire.tag = "wire"
        table.insert(SolarPanel.wires, wire)
    end
    -- Static image (random x along the top)
    StaticImage.image = love.graphics.newImage("panelPosition.png")
    StaticImage.scaleX = 0.3
    StaticImage.scaleY = 0.3

    -- Randomly position static image at the bottom
    -- Random seems to generate the same output each time
    -- StaticImage.x = math.random(0, love.graphics.getWidth() - StaticImage.image:getWidth() * StaticImage.scaleX)
    StaticImage.x = 50
    StaticImage.y = 420 -- Positioned at the bottom of the screen

    -- Load popup image
    popupImage = love.graphics.newImage("popup.png") -- Ensure this image exists

    -- Initialize obstacles
    for i = 1, 3 do -- Example with 3 obstacles
        local obstacle = {
            image = love.graphics.newImage("obstacle.png"), -- Ensure this image exists
            scaleX = 0.3,
            scaleY = 0.3,
            originalX = math.random(100, 200),--love.graphics.getWidth() - 64),
            originalY = 500,--math.random(100, love.graphics.getHeight() - 100),
            x = 0,
            y = 0,
            isDragging = false
        }
        obstacle.x = obstacle.originalX
        obstacle.y = obstacle.originalY
        table.insert(Obstacles, obstacle)
    end
end

function SolarPanel.update(dt)
    -- If the solar panel is frozen, don't allow movement
    if SolarPanel.isFrozen then
        return
    end
    SolarPanel.updatePanels()

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
                    -- Display the popup message
                    message = "You can't place this here!"
                    showMessage = true

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

    -- Update the message timer
    if showMessage then
        messageTimer = messageTimer + dt
        if messageTimer >= 2 then -- Display for 2 seconds
            showMessage = false
            messageTimer = 0
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
    love.graphics.draw(SolarPanel.background, 0, 0)
    SolarPanel.drawGrid()
    SolarPanel.drawPanels()
    SolarPanel.drawWires()
    -- Draw static image
    love.graphics.draw(StaticImage.image, StaticImage.x, StaticImage.y, 0, StaticImage.scaleX, StaticImage.scaleY)

    -- Draw the solar panel if it's not frozen
    if not SolarPanel.isFrozen then
        love.graphics.draw(SolarPanel.image, SolarPanel.x, SolarPanel.y, 0, SolarPanel.scaleX, SolarPanel.scaleY)
    else
        -- Draw the solar panel at the static image's position when frozen
        love.graphics.draw(SolarPanel.image, StaticImage.x, StaticImage.y, 0, SolarPanel.scaleX, SolarPanel.scaleY)
    end

    -- Draw obstacles
    for _, obstacle in ipairs(Obstacles) do
        love.graphics.draw(obstacle.image, obstacle.x, obstacle.y, 0, obstacle.scaleX, obstacle.scaleY)
    end

    -- Show the popup message if applicable
    if showMessage then
        love.graphics.draw(popupImage, love.graphics.getWidth() / 2 - popupImage:getWidth() / 2, love.graphics.getHeight() / 2 - popupImage:getHeight() / 2)
        
        -- Set the font size and color for the message
        local fontSize = 15 -- Set your desired font size here
        local font = love.graphics.newFont(fontSize)
        love.graphics.setFont(font)

        -- Set the color to black
        love.graphics.setColor(0, 0, 0) -- RGB values for black
        love.graphics.print(message, love.graphics.getWidth() / 2 - 90, love.graphics.getHeight() / 2 - 10) -- Shifted text to the left
        love.graphics.setColor(1, 1, 1) -- Reset color to white for other drawings
    end
end

function SolarPanel.drawGrid()
    -- Get Grid Information
    local x_offset = SolarPanel.grid.x_offset
    local y_offset = SolarPanel.grid.y_offset
    local x_size = SolarPanel.grid.x_size
    local y_size = SolarPanel.grid.y_size
    local cell_size = SolarPanel.grid.cell_size
    local spacing = SolarPanel.grid.spacing
    
    -- Draw Each Cell
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    for i = 0, x_size - 1 do
        for j = 0, y_size - 1 do
            love.graphics.rectangle("fill",
            x_offset + i * spacing - cell_size / 2,
            y_offset + j * spacing - cell_size / 2,
            cell_size, cell_size)
        end
    end
    love.graphics.setColor(1, 1, 1, 1) -- Reset color to white for other drawings
end
-- For positioning the image correctly
local function getPanelXYOffset(panel) 
    return {
        x = SolarPanel.panelImage:getWidth() / 2,
        y = SolarPanel.panelImage:getHeight() / 2
    }
end
function SolarPanel.drawPanels()
    -- Draw each panel
    for i, panel in pairs(SolarPanel.panels) do
        local xy = getPanelXYOffset(panel) 
        love.graphics.draw(SolarPanel.panelImage, -- Image to draw
        panel.x, panel.y, -- Where to draw
        math.pi / 2 * panel.rotation, panel.xScale, panel.yScale, -- Rotation and Scale
        xy.x, xy.y) -- Image ofset
    end
    
end
local function drawRotatedRectangle(mode, x, y, width, height, angle)
	-- We cannot rotate the rectangle directly, but we
	-- can move and rotate the coordinate system.
	love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.rotate(angle)
	-- love.graphics.rectangle(mode, 0, 0, width, height) -- origin in the top left corner
	love.graphics.rectangle(mode, -width/2, -height/2, width, height) -- origin in the middle
	love.graphics.pop()
end
function SolarPanel.drawWires()
    -- Draw each wire
    for i, wire in pairs(SolarPanel.wires) do
        local x_size = SolarPanel.wire_xSize
        local y_size = SolarPanel.wire_ySize
        love.graphics.setColor(0.3, 0.3, 0.3) -- RGB values for black
        drawRotatedRectangle("fill", wire.x, wire.y, x_size, y_size, math.pi / 2 * wire.rotation)
        love.graphics.setColor(1, 1, 1) -- RGB values for white
    end
end
local function SnapToGrid(panel)
    local x_size = SolarPanel.grid.x_size
    local y_size = SolarPanel.grid.y_size
    local x_offset = SolarPanel.grid.x_offset
    local y_offset = SolarPanel.grid.y_offset
    local spacing = SolarPanel.grid.spacing
    local cell_size = SolarPanel.grid.cell_size

    -- Translate coordinates to origin coordinates to make calculations easier
    -- a.k.a pretend the grid at the top left of the screen
    local nx = panel.x - x_offset
    local ny = panel.y - y_offset
    -- If outside the grid, do not snap
    if (nx < -cell_size / 2  or nx > spacing * x_size + (cell_size - 1) / 2  or
        ny < -cell_size / 2  or ny > spacing * y_size + (cell_size - 1) / 2) then
        return
    end

    -- Snap panels and wires differently
    local offsetx, offsety
    if panel.tag == "panel" then
        -- Account for size and rotation of panel
        local xy = getPanelXYOffset(panel)
        if (panel.rotation == 0) then
            offsetx = xy.x * panel.xScale / 2
            offsety = 0
        else
            offsetx = 0
            offsety = xy.y * panel.yScale / 2
        end
    else
        -- Place wire in the middle of the cell
        offsety = 0
        offsetx = 0
    end

    -- let midpoint = nx + cell_size/2          | To account for size of cell
    -- let snapped = nx - midpoint % spacing    | to snap to the grid
    -- let on_grid = snapped + x_offset         | To reposition back to where grid is
    -- let in_center = on_grid + cell_size/2    | To put in center of cell
    -- let positioned = in_center - offsetx     | To reposition depending on if solar panel or wire, and rotation

    panel.x = (nx - (nx + cell_size/2) % spacing) + x_offset + cell_size/2 - offsetx
    panel.y = (ny - (ny + cell_size/2) % spacing) + y_offset + cell_size/2 - offsety
end
function SolarPanel.updatePanels()
    local mouseDown = love.mouse.isDown(1)

    if (not mouseDown) then
        if (SolarPanel.selected ~= nil) then
            -- Could be wire or panel
            SnapToGrid(SolarPanel.selected);
            SolarPanel.selected = nil
        end
        
        return
    end

    -- If a panel or wire is selected, move with mouse and snap to slots
    if (SolarPanel.selected ~= nil) then
        local x = love.mouse.getX()
        local y = love.mouse.getY()
        SolarPanel.selected.x = x;
        SolarPanel.selected.y = y;
        if (love.keyboard.isDown('r') and SolarPanel.selected.rotateDebounce) then
            SolarPanel.selected.rotateDebounce = false
            SolarPanel.selected.rotation = 1 - SolarPanel.selected.rotation
        elseif (not love.keyboard.isDown('r') and not SolarPanel.selected.rotateDebounce) then
            SolarPanel.selected.rotateDebounce = true
        end
        return;
    end

    -- Iterate through each spawned circle to determine if they should be selected and move
    for i, panel in pairs(SolarPanel.panels) do
        -- Check if the mouse is inside a circle
        local x = love.mouse.getX()
        local y = love.mouse.getY()
        local cx = panel.x
        local cy = panel.y
        local dx = cx - x
        local dy = cy - y
        -- Distance Squared instead of Distance to save on performance
        -- If there is already a selected circle, do not select another
        if ((dx * dx + dy * dy) < (40 * 40) and SolarPanel.selected == nil) then
            SolarPanel.selected = panel
            break;
        end
    end

    -- If we haven't selected a panel, iterate and select a wire
    if (SolarPanel.selected ~= nil) then
        return
    end

    for i, wire in pairs(SolarPanel.wires) do
        -- Check if the mouse is inside a circle
        local x = love.mouse.getX()
        local y = love.mouse.getY()
        local cx = wire.x
        local cy = wire.y
        local dx = cx - x
        local dy = cy - y
        -- Distance Squared instead of Distance to save on performance
        -- If there is already a selected circle, do not select another
        if ((dx * dx + dy * dy) < (40 * 40) and SolarPanel.selected == nil) then
            SolarPanel.selected = wire
            break;
        end
    end

end


return SolarPanel
