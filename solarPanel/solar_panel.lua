-- solar_panel.lua

local SolarPanel = {}
local StaticImage = {}
local LightBulb = {}
local Obstacles = {}
local popupImage = nil
local showMessage = false -- Flag to control popup visibility
local message = "" -- Message to display
local messageTimer = 0 -- Timer to control how long the message is displayed
-- Define the target positions for wires and solar panels
local wirePositions = {
    {4, 2}, {7, 2}, {10, 2}, {2, 3}, {5, 3}
}

local solarPanelPositions = {
    {2, 2, 3, 2}, {5, 2, 6, 2}, {8, 2, 9, 2}, {3, 3, 4, 3}, {6, 3, 7, 3}
}

function SolarPanel.load()
    -- Load background image
    SolarPanel.background = love.graphics.newImage("background.png")
   -- Load the game background music
   SolarPanel.bgMusic = love.audio.newSource("game_music.mp3", "stream") -- Ensure this file exists
   SolarPanel.bgMusic:setLooping(true) -- Make the music loop
   SolarPanel.bgMusic:play() -- Start playing the music
    -- Solar panel (draggable)
    SolarPanel.image = love.graphics.newImage("solarPanel.png")
    SolarPanel.scaleX = 0.3
    SolarPanel.scaleY = 0.3

    -- Initial position (random x along the bottom)
    SolarPanel.originalX = 600
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
            -- To record what is occupying the cell
            grid_cell_info.occupant = nil;
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
        panel.xScale = 1
        panel.yScale = 1
        panel.rotateDebounce = true
        panel.cells = {{},{}}
        panel.isCharged = false
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
        wire.isCharged = false
        wire.tag = "wire"
        table.insert(SolarPanel.wires, wire)
    end

    -- LightBulb
    LightBulb.offImage = love.graphics.newImage("lightoff.png")
    LightBulb.onImage = love.graphics.newImage("lighton.png")
    LightBulb.lightLevel = 0
    LightBulb.isFullyLight = false

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

    -- Deprecated
    -- -- Initialize obstacles
    -- for i = 1, 3 do -- Example with 3 obstacles
    --     local obstacle = {
    --         image = love.graphics.newImage("obstacle.png"), -- Ensure this image exists
    --         scaleX = 0.3,
    --         scaleY = 0.3,
    --         originalX = math.random(100, 200),--love.graphics.getWidth() - 64),
    --         originalY = 500,--math.random(100, love.graphics.getHeight() - 100),
    --         x = 0,
    --         y = 0,
    --         isDragging = false
    --     }
    --     obstacle.x = obstacle.originalX
    --     obstacle.y = obstacle.originalY
    --     table.insert(Obstacles, obstacle)
    -- end

    -- Initialize obstacles
    local obstacle_indices = {
        {3, 3},
        {5, 1},
        {6, 1},
        {6, 4},
        {10, 2},
        {8, 2},
        {5, 2}
    }
    for _, indices in pairs(obstacle_indices) do
        local x = indices[1]
        local y = indices[2]
        SolarPanel.grid[x][y].occupant = {tag = "obstacle", image = love.graphics.newImage("obstacle.png")}
    end

    -- Load the lightoff image
    StaticImage.lightOff = love.graphics.newImage("lightoff.png")
    StaticImage.lightOffScaleX = 1.5
    StaticImage.lightOffScaleY = 1.5

    -- Position of the lightoff image (right of the grid)
    StaticImage.lightOffX = SolarPanel.grid.x_offset + (SolarPanel.grid.x_size * SolarPanel.grid.cell_size) + 10
    StaticImage.lightOffY = SolarPanel.grid.y_offset
    -- Load the lighton image
StaticImage.lightOn = love.graphics.newImage("lighton.png") -- Ensure this image exists
StaticImage.isLightOn = false -- Flag to track if the light is on

-- Button properties
StaticImage.buttonImage = love.graphics.newImage("button.png") -- Load the button image
StaticImage.buttonX = 600 -- X position of the button
StaticImage.buttonY = 200 -- Y position of the button
StaticImage.buttonWidth = StaticImage.buttonImage:getWidth()
StaticImage.buttonHeight = StaticImage.buttonImage:getHeight()
-- Load a font
local fontSize = 20
StaticImage.font = love.graphics.newFont(fontSize)
-- In the SolarPanel.load function, initialize the timer for light off display

StaticImage.lightOffTimer = 0 -- Timer for light off display

StaticImage.showSchoolLightOff = false -- Flag to control visibility of school light off image
-- Load the school light images
StaticImage.schoolLightOn = love.graphics.newImage("schoollight.png") -- Ensure this image exists
StaticImage.schoolLightOff = love.graphics.newImage("schoollightOff.jpg") -- Ensure this image exists
StaticImage.showSchoolLight = false -- Flag to control visibility of school light images
end

function SolarPanel.update(dt)
    -- If the solar panel is frozen, don't allow movement
    if SolarPanel.isFrozen then
        return
    end
    SolarPanel.updatePanels()
    SolarPanel.evaluateGameState()

    -- Deprecated
    -- -- Draggable solar panel update
    -- if love.mouse.isDown(1) then
    --     local mouseX, mouseY = love.mouse.getPosition()

    --     if not SolarPanel.isDragging and 
    --        mouseX >= SolarPanel.x and mouseX <= SolarPanel.x + SolarPanel.image:getWidth() * SolarPanel.scaleX and 
    --        mouseY >= SolarPanel.y and mouseY <= SolarPanel.y + SolarPanel.image:getHeight() * SolarPanel.scaleY then
    --         SolarPanel.isDragging = true
    --     end

    --     -- If dragging, move the solar panel with the mouse
    --     if SolarPanel.isDragging then
    --         SolarPanel.x = mouseX - (SolarPanel.image:getWidth() * SolarPanel.scaleX / 2)
    --         SolarPanel.y = mouseY - (SolarPanel.image:getHeight() * SolarPanel.scaleY / 2)
    --     end
    -- else
    --     -- When mouse button is released, stop dragging and reset position if no collision
    --     if SolarPanel.isDragging then
    --         SolarPanel.isDragging = false

    --         -- Check if the solar panel collides with the static image
    --         if SolarPanel.checkCollision() then
    --             -- Move solar panel to static image's position
    --             SolarPanel.x = StaticImage.x
    --             SolarPanel.y = StaticImage.y

    --             -- Freeze the solar panel
    --             SolarPanel.isFrozen = true
    --         else
    --             -- Reset to original position if no collision
    --             SolarPanel.x = SolarPanel.originalX
    --             SolarPanel.y = SolarPanel.originalY
    --         end
    --     end
    -- end

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
    -- Check for space key press
    if love.keyboard.isDown("space") then
        SolarPanel.checkPlacement()
    end
 -- Check for button click
 local mouseX, mouseY = love.mouse.getPosition()
 if love.mouse.isDown(1) and 
    mouseX >= StaticImage.buttonX and mouseX <= StaticImage.buttonX + StaticImage.buttonWidth and
    mouseY >= StaticImage.buttonY and mouseY <= (StaticImage.buttonY + StaticImage.buttonHeight)-300 then
     SolarPanel.checkConnections()
 end

 -- Handle light off display timer
 if not StaticImage.isLightOn and StaticImage.lightOffTimer then
     StaticImage.lightOffTimer = StaticImage.lightOffTimer - dt
     if StaticImage.lightOffTimer <= 0 then
         StaticImage.lightOffTimer = nil -- Reset timer
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

function SolarPanel.drawObstacles()
    -- Draw obstacles
    for i = 1, SolarPanel.grid.x_size do
        for j = 1, SolarPanel.grid.y_size do
            local obstacle = SolarPanel.grid[i][j].occupant
            if (obstacle ~= nil and obstacle.tag == "obstacle") then
                local x = (i - 1) * SolarPanel.grid.spacing + SolarPanel.grid.x_offset
                local y = (j - 1) * SolarPanel.grid.spacing + SolarPanel.grid.y_offset
                love.graphics.draw(obstacle.image, x, y, 0, 0.1, 0.1,
                obstacle.image:getWidth() / 2, obstacle.image:getHeight() / 2)
            end
        end
    end
    -- for _, obstacle in ipairs(Obstacles) do
    --     love.graphics.draw(obstacle.image, obstacle.x, obstacle.y, 0, obstacle.scaleX, obstacle.scaleY)
    -- end
end

function SolarPanel.draw()
    love.graphics.draw(SolarPanel.background, 0, 0)
    SolarPanel.drawGrid()
    SolarPanel.drawOutlines()
    SolarPanel.drawObstacles()
    SolarPanel.drawPanels()
    SolarPanel.drawLightBulb()
    SolarPanel.drawWires()

    -- Deprecated
    -- -- Draw static image (panel position)
    -- love.graphics.draw(StaticImage.image, StaticImage.x, StaticImage.y, 0, StaticImage.scaleX, StaticImage.scaleY)
 
    -- Deprecated
    -- Draw the light image based on the state
    -- if StaticImage.isLightOn then
    --     love.graphics.draw(StaticImage.lightOn, StaticImage.lightOffX, StaticImage.lightOffY, 0, StaticImage.lightOffScaleX, StaticImage.lightOffScaleY)
    -- else
    --     love.graphics.draw(StaticImage.lightOff, StaticImage.lightOffX, StaticImage.lightOffY, 0, StaticImage.lightOffScaleX, StaticImage.lightOffScaleY)
    -- end

    -- Deprecated
    -- Draw the solar panel if it's not frozen
    -- if not SolarPanel.isFrozen then
    --     love.graphics.draw(SolarPanel.image, SolarPanel.x, SolarPanel.y, 0, SolarPanel.scaleX, SolarPanel.scaleY)
    -- else
    --     -- Draw the solar panel at the static image's position when frozen
    --     love.graphics.draw(SolarPanel.image, StaticImage.x, StaticImage.y, 0, SolarPanel.scaleX, SolarPanel.scaleY)
    -- end

    -- Deprecated
    -- Draw obstacles
    -- for _, obstacle in ipairs(Obstacles) do
    --     love.graphics.draw(obstacle.image, obstacle.x, obstacle.y, 0, obstacle.scaleX, obstacle.scaleY)
    -- end

    -- Show the popup message if applicable
    if showMessage then
        love.graphics.draw(popupImage, love.graphics.getWidth() / 2 - popupImage:getWidth() / 2, love.graphics.getHeight() / 2 - popupImage:getHeight() / 2)

        -- Set the font size and color for the message
        local fontSize = 15 -- Set your desired font size here
        local font = love.graphics.newFont(fontSize)
        love.graphics .setFont(font)
        love.graphics.setColor(1, 1, 1) -- Set color to white
        -- love.graphics.print(message, love.graphics.getWidth() / 2 - font:getWidth(message) / 2, love.graphics.getHeight() / 2 - font:getHeight(message) / 2)
    end

     -- Draw the button
     local buttonWidth = 150
     local buttonHeight = 50
     local buttonX = StaticImage.buttonX
     local buttonY = StaticImage.buttonY
 
     -- Draw a rectangle for the button
     love.graphics.setColor(0.5, 0.5, 0.5) -- Set button color (gray)
     love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight)
 
     -- Draw the text in the center of the button
     love.graphics.setFont(StaticImage.font)
     love.graphics.setColor(1, 1, 1) -- Set text color (white)
     local text = "Check Light"
     local textWidth = StaticImage.font:getWidth(text)
     local textHeight = StaticImage.font:getHeight(text)
     love.graphics.print(text, buttonX + (buttonWidth - textWidth) / 2, buttonY + (buttonHeight - textHeight) / 2)
 
     -- Reset color to white for other drawings
     love.graphics.setColor(1, 1, 1)
         -- Draw the light image based on the state
-- Draw the school light image based on the state
if StaticImage.isLightOn then
    love.graphics.draw(StaticImage.schoolLightOn, 0, 0, 0, love.graphics.getWidth() / StaticImage.schoolLightOn:getWidth(), love.graphics.getHeight() / StaticImage.schoolLightOn:getHeight())
elseif not StaticImage.isLightOn and StaticImage.lightOffTimer then
    love.graphics.draw(StaticImage.schoolLightOff, 0, 0, 0, love.graphics.getWidth() / StaticImage.schoolLightOff:getWidth(), love.graphics.getHeight() / StaticImage.schoolLightOff:getHeight())
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
            if (i == x_size - 1 and j == 0) then
                love.graphics.setColor(0.2, 0.2, 0.2, 1)

                love.graphics.rectangle("fill",
                x_offset + i * spacing - cell_size / 2,
                y_offset + j * spacing - cell_size / 2,
                cell_size, cell_size)

                love.graphics.setColor(0.7, 0.7, 0.7, 1)
            else
                love.graphics.rectangle("fill",
                x_offset + i * spacing - cell_size / 2,
                y_offset + j * spacing - cell_size / 2,
                cell_size, cell_size)
            end
            
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
function SolarPanel.drawLightBulb()
    local scale = 1
    local x = (SolarPanel.grid.x_size) * SolarPanel.grid.spacing + SolarPanel.grid.x_offset
    local y = SolarPanel.grid.y_offset
    if (LightBulb.isFullyLight) then
        love.graphics.draw(LightBulb.onImage, x, y, 0, scale, scale, LightBulb.onImage:getWidth() / 2, LightBulb.onImage:getHeight() / 2)
    else
        love.graphics.setColor(1, 1, 1, 1 - 1/6 * LightBulb.lightLevel) -- Make "unlit" less visible for higher light levels
        love.graphics.draw(LightBulb.offImage, x, y, 0, scale, scale, LightBulb.offImage:getWidth() / 2, LightBulb.offImage:getHeight() / 2)
        love.graphics.setColor(1, 1, 1, 1/6 * LightBulb.lightLevel) -- Make "lit" more visible for higher light levels
        love.graphics.draw(LightBulb.onImage, x, y, 0, scale, scale, LightBulb.onImage:getWidth() / 2, LightBulb.onImage:getHeight() / 2)
        love.graphics.setColor(1, 1, 1, 1) -- Reset Color
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

    -- Below is purely for debugging
    -- local x = love.mouse.getX()
    -- local y = love.mouse.getY()
    -- local ix, iy = CoordsToGridIndices(x, y, true)

    -- love.graphics.setColor(0, 0, 0) -- RGB values for black
    -- love.graphics.print("X: "..ix..", Y:"..iy, 0, 0)
    -- if (SolarPanel.evaluateGameState()) then
    --     love.graphics.print("LIGHT", 100, 0)
    -- else
    --     love.graphics.print("DARK", 100, 0)
    -- end
    
    -- love.graphics.setColor(1, 1, 1) -- Reset color to white for other drawings
end
function SolarPanel.drawOutlines()
    -- Get Grid Information
    local x_offset = SolarPanel.grid.x_offset
    local y_offset = SolarPanel.grid.y_offset
    local x_size = SolarPanel.grid.x_size
    local y_size = SolarPanel.grid.y_size
    local cell_size = SolarPanel.grid.cell_size
    local spacing = SolarPanel.grid.spacing
    
    local setOutlineColor = function (isCharged)
        if (isCharged) then
            if (LightBulb.isFullyLight) then
                love.graphics.setColor(0.8, 0.8, 0) -- RGB values for yellow
            else
                love.graphics.setColor(0, 0.5, 0) -- RGB values for green
            end
            
        else
            love.graphics.setColor(0.2, 0.2, 0.2) -- RGB values for gray
        end
        
    end
    local setWhite = function ()
        love.graphics.setColor(1, 1, 1) -- RGB values for white
    end
    for i = 0, x_size - 1 do
        for j = 0, y_size - 1 do
            local occupant = SolarPanel.grid[i+1][j+1].occupant
            if (occupant ~= nil) then
                -- Draw each wire outline
                if (occupant.tag == "wire") then
                    local wire = occupant
                    local x_size = SolarPanel.wire_xSize
                    local y_size = SolarPanel.wire_ySize
                    setOutlineColor(occupant.isCharged)
                    drawRotatedRectangle("fill", wire.x, wire.y, x_size + 4, y_size + 4, math.pi / 2 * wire.rotation)
                    setWhite()
                -- Draw each panel outline
                elseif (occupant.tag == "panel") then
                    local newCellSize = cell_size + 4
                    setOutlineColor(occupant.isCharged)
                    love.graphics.rectangle("fill",
                    x_offset + i * spacing - newCellSize / 2,
                    y_offset + j * spacing - newCellSize / 2,
                    newCellSize, newCellSize)
                    setWhite()
                end
            end
        end
    end
end

function CoordsToGridIndices(x, y, account_for_offset)
    local x_size = SolarPanel.grid.x_size
    local y_size = SolarPanel.grid.y_size
    local x_offset = SolarPanel.grid.x_offset
    local y_offset = SolarPanel.grid.y_offset
    local spacing = SolarPanel.grid.spacing
    local cell_size = SolarPanel.grid.cell_size
    if account_for_offset then
        x = x - x_offset
        y = y - y_offset
    end
    -- To account for detection depending on cell size. e.g the cell may be "out of bounds"
    x = x + cell_size / 2
    y = y + cell_size / 2

    local index_x = math.floor(x / spacing) + 1
    local index_y = math.floor(y / spacing) + 1

    if (index_x < 1 or index_x > x_size or
        index_y < 1 or index_y > y_size) then
        index_x = -1
        index_y = -1
    end
    return index_x, index_y
end
local function SnapToGrid(panel)
    local grid_x_offset = SolarPanel.grid.x_offset
    local grid_y_offset = SolarPanel.grid.y_offset
    local spacing = SolarPanel.grid.spacing

    -- Translate coordinates to origin coordinates to make calculations easier
    -- a.k.a pretend the grid at the top left of the screen
    local nx = panel.x - grid_x_offset
    local ny = panel.y - grid_y_offset
    local grid_x, grid_y = CoordsToGridIndices(nx, ny)
    -- If outside the grid, do not snap
    if (grid_x == -1 or grid_y == -1) then
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
            offsety = xy.y * panel.yScale
        end
    else
        -- Place wire in the middle of the cell
        offsety = 0
        offsetx = 0
    end
    -- Snap to grid
    panel.x = (grid_x - 1) * spacing + grid_x_offset - offsetx
    panel.y = (grid_y - 1) * spacing + grid_y_offset - offsety
end
local function PlacePanel(panel)
    local x = love.mouse.getX()
    local y = love.mouse.getY()
    local grid_x, grid_y = CoordsToGridIndices(x, y, true)
    if (grid_x == -1 or grid_y == -1) then
        return
    end

    local occupant = SolarPanel.grid[grid_x][grid_y].occupant
    if occupant == nil then
        -- Panel requires special case
        if (panel.tag == "panel") then
            -- Set neighbor grid cell occupant to panel as well
            if (panel.rotation == 0) then
                -- Handle case of panel being off grid and colliding panel
                if (grid_x == 1 or SolarPanel.grid[grid_x - 1][grid_y].occupant ~= nil) then
                    return
                end
                SolarPanel.grid[grid_x - 1][grid_y].occupant = panel
                panel.cells[1].x = grid_x - 1
                panel.cells[1].y = grid_y
            else
                 -- Handle case of panel being off grid and colliding panel
                if (grid_y == 1 or SolarPanel.grid[grid_x][grid_y - 1].occupant ~= nil) then
                    return
                end
                SolarPanel.grid[grid_x][grid_y - 1].occupant = panel
                panel.cells[1].x = grid_x
                panel.cells[1].y = grid_y - 1
            end
            panel.cells[2].x = grid_x
            panel.cells[2].y = grid_y
        end


        SolarPanel.grid[grid_x][grid_y].occupant = panel
        SnapToGrid(panel)
    end
end
local function TrySelect(selectable)
    -- Check if the mouse is inside a circle
    local x = love.mouse.getX()
    local y = love.mouse.getY()
    local cx = selectable.x
    local cy = selectable.y
    local dx = cx - x
    local dy = cy - y
    -- Distance Squared instead of Distance to save on performance
    -- If there is already a selected circle, do not select another
    if ((dx * dx + dy * dy) < (40 * 40) and SolarPanel.selected == nil) then
        SolarPanel.selected = selectable

        local x_size = SolarPanel.grid.x_size
        local y_size = SolarPanel.grid.y_size
        for i = 1, x_size do
            for j = 1, y_size do
                if SolarPanel.grid[i][j].occupant == selectable then
                    SolarPanel.grid[i][j].occupant = nil
                end
            end
        end
        return true
    end
    return false
end
function SolarPanel.checkPlacement()
    local wireCorrect = true
    local solarCorrect = true

    -- Check wires
    for _, pos in ipairs(wirePositions) do
        local x, y = pos[1], pos[2]
        if SolarPanel.grid[x][y].occupant == nil or SolarPanel.grid[x][y].occupant.tag ~= "wire" then
            wireCorrect = false
            break
        end
    end

    -- Check solar panels
    for _, pos in ipairs(solarPanelPositions) do
        local x1, y1, x2, y2 = pos[1], pos[2], pos[3], pos[4]
        if (SolarPanel.grid[x1][y1].occupant == nil or SolarPanel.grid[x2][y2].occupant == nil) or 
           (SolarPanel.grid[x1][y1].occupant.tag ~= "panel" and SolarPanel.grid[x2][y2].occupant.tag ~= "panel") then
            solarCorrect = false
            break
        end
    end
SolarPanel.checkConnections()
     -- Show message based on placement

     if wireCorrect and solarCorrect then

        message = "Wires and Solar Panels are placed correctly!"

        StaticImage.isLightOn = true -- Set the light to on

        -- Automatically check connections after placement

        SolarPanel.checkConnections()

    else

        message = "Please check the placement of wires and solar panels."

        StaticImage.isLightOn = false -- Set the light to off

    end

    showMessage = true

end
function SolarPanel.checkConnections()
    local wireCorrect = true
    local solarCorrect = true

    -- -- Check wires
    -- for _, pos in ipairs(wirePositions) do
    --     local x, y = pos[1], pos[2]
    --     if SolarPanel.grid[x][y].occupant == nil or SolarPanel.grid[x][y].occupant.tag ~= "wire" then
    --         wireCorrect = false
    --         break
    --     end
    -- end

    -- -- Check solar panels
    -- for _, pos in ipairs(solarPanelPositions) do
    --     local x1, y1, x2, y2 = pos[1], pos[2], pos[3], pos[4]
    --     if (SolarPanel.grid[x1][y1].occupant == nil or SolarPanel.grid[x2][y2].occupant == nil) or 
    --        (SolarPanel.grid[x1][y1].occupant.tag ~= "panel" and SolarPanel.grid[x2][y2].occupant.tag ~= "panel") then
    --         solarCorrect = false
    --         break
    --     end
    -- end

    local allCorrect = SolarPanel.evaluateGameState()
    wireCorrect = allCorrect
    solarCorrect = allCorrect

    -- Set the light status based on connection correctness
    if wireCorrect and solarCorrect then
        StaticImage.isLightOn = true -- Light on
        StaticImage.showSchoolLight = true -- Show the school light image
    else
        StaticImage.isLightOn = false -- Light off
        StaticImage.lightOffTimer = 3 -- Set timer for light off display
        StaticImage.showSchoolLight = false -- Hide the school light image
        -- Display the school light off image for 3 seconds
        
    end
end
function SolarPanel.updatePanels()
    local mouseDown = love.mouse.isDown(1)

    if (not mouseDown) then
        if (SolarPanel.selected ~= nil) then
            -- Could be wire or panel
            PlacePanel(SolarPanel.selected);
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

    -- Iterate through each wireto determine if they should be selected and move
    for i, wire in pairs(SolarPanel.wires) do
        if (TrySelect(wire)) then
            break
        end
    end
    


    -- If we haven't selected a wire, iterate and select a panel
    if (SolarPanel.selected ~= nil) then
        return
    end

    for i, panel in pairs(SolarPanel.panels) do
        if (TrySelect(panel)) then
            break
        end
    end
end

-- Helper functions for stack functionality
function PushStack(stack, item)
    table.insert(stack, item)
end
function PopStack(stack)
    return table.remove(stack)
end
local function neighborsFromWire(wire, results)
    local neighbors = {}
    -- TODO: support more wire types

    local verify = function (x, y)
        -- Only return neighbors that have an occupant (wire or panel)
        if (SolarPanel.grid[x][y].occupant == nil) then
            return false
        end
        -- If a panel is the occupant, no further checks needed
        if (SolarPanel.grid[x][y].occupant.tag == "panel") then
            return true
        end
        -- If occupant is a wire, make sure it aligns with the current wire
        if (SolarPanel.grid[x][y].occupant.tag == "wire" and
            SolarPanel.grid[x][y].occupant.rotation ~= wire.rotation) then
            return false
        end

        return true
    end
    if (wire.rotation == 0) then
        -- Check left and right
        local ix, iy = CoordsToGridIndices(wire.x, wire.y, true)
        local lx = ix - 1
        local rx = ix + 1
        if (lx > 0 and results.seen[lx][iy] == false and verify(lx, iy)) then
            table.insert(neighbors, {
                x = lx,
                y = iy
            })
        end
        if (rx <= SolarPanel.grid.x_size and results.seen[rx][iy] == false and verify(rx, iy)) then
            table.insert(neighbors, {
                x = rx,
                y = iy
            })
        end
    else
        -- Check up and down
        local ix, iy = CoordsToGridIndices(wire.x, wire.y, true)
        local dy = iy - 1
        local uy = iy + 1
        if (dy > 0 and results.seen[ix][dy] == false and verify(ix, dy)) then
            table.insert(neighbors, {
                x = ix,
                y = dy
            })
        end
        if (uy <= SolarPanel.grid.x_size and results.seen[ix][uy] == false and verify(ix, uy)) then
            table.insert(neighbors, {
                x = ix,
                y = uy
            })
        end
    end
    return neighbors
end
local function neighborsFromPanel(panel, results)
    local neighbors = {}
    for i = 1, 2 do
        local cell = panel.cells[i]
        local ix = cell.x
        local iy = cell.y
        -- Check each 4 directions as neighbors
        -- Verification function for the occupant of a grid cell
        -- Only return wires; solar panels must be connected by wires
        local verify = function (x, y, rotation)
            -- Ensure x and y are within bounds
            if not (x > 0 and x <= SolarPanel.grid.x_size and
            y > 0 and y <= SolarPanel.grid.y_size) then
                return false
            end
            -- Ensure we have a wire
            if not (results.seen[x][y] == false and SolarPanel.grid[x][y].occupant ~= nil and
            SolarPanel.grid[x][y].occupant.tag == "wire") then
                return false
            end
            -- Ensure the wire is the desired rotation
            -- E.g., if we are checking "left," then the wire should be horizontal (rotation == 0)
            -- if we are checking "up," then the wire should be vertical (rotation == 1)
            return SolarPanel.grid[x][y].occupant.rotation == rotation
        end
        -- Left
        do
            local x = ix - 1
            local y = iy
            if (verify(x,y,0)) then
                -- This check was put to prevent the double "hit" of solar panels since a solar panel takes up two slots
                -- Since we now only take wires as neighbors, this is no longer an issue
                -- local occupant = SolarPanel.grid[x][y].occupant
                -- if (occupant ~= nil and occupant.tag == "panel") then
                --     -- print("DOUBLE CHECK")
                --     local cell1 = occupant.cells[1]
                --     local cell2 = occupant.cells[2]
                --     results.seen[cell1.x][cell1.y] = true
                --     results.seen[cell2.x][cell2.y] = true
                -- else
                --     -- print("NOT DOUBLE CHECK")
                -- end
                table.insert(neighbors, {
                    x = x,
                    y = y
                })
                results.seen[x][y] = true
            end
        end
        -- Right
        do
            local x = ix + 1
            local y = iy
            if (verify(x,y,0)) then
                table.insert(neighbors, {
                    x = x,
                    y = y
                })
                results.seen[x][y] = true
            end
        end
        -- Up
        do
            local x = ix
            local y = iy + 1
            if (verify(x,y,1)) then
                table.insert(neighbors, {
                    x = x,
                    y = y
                })
                results.seen[x][y] = true
            end
        end
        -- Down
        do
            local x = ix
            local y = iy - 1
            if (verify(x,y,1)) then
                table.insert(neighbors, {
                    x = x,
                    y = y
                })
                results.seen[x][y] = true
            end
        end
    end
    return neighbors
end
-- See how many solar panels and wires are connected to the light bulb
local function searchFromBulb(results)
    local stack = {}
    local grid_cell = {
        x = SolarPanel.grid.x_size,
        y = 1
    }
    PushStack(stack, grid_cell)

    for i = 1, SolarPanel.grid.x_size do
        for j = 1, SolarPanel.grid.y_size do
            local item = SolarPanel.grid[i][j].occupant
            if (item ~= nil) then
                item.isCharged = false
            end
        end
    end

    -- Perform a "search" from the light bulb to get our path
    while (#stack > 0) do
        local cell = PopStack(stack)
        -- Remember the cell we have seen
        results.seen[cell.x][cell.y] = true

        local item = SolarPanel.grid[cell.x][cell.y].occupant
        if (item ~= nil) then
            item.isCharged = true
            if (item.tag == "panel") then
                local cell1 = item.cells[1]
                local cell2 = item.cells[2]
                results.seen[cell1.x][cell1.y] = true
                results.seen[cell2.x][cell2.y] = true
                results.panelsVisited = results.panelsVisited + 1
                -- print("visited panel")
                local neighbors = neighborsFromPanel(item, results)
                for _, neighbor_cell in pairs(neighbors) do
                    PushStack(stack, neighbor_cell)
                end
            elseif (item.tag == "wire") then
                results.wiresVisited = results.wiresVisited + 1
                -- print("visited wire")
                local neighbors = neighborsFromWire(item, results)
                for _, neighbor_cell in pairs(neighbors) do
                    PushStack(stack, neighbor_cell)
                end
            end
        end
    end
end

function SolarPanel.evaluateGameState()
    local results = {
        seen = {},
        wiresVisited = 0,
        panelsVisited = 0
    }
    for i = 1, SolarPanel.grid.x_size do
        results.seen[i] ={} 
        for j = 1, SolarPanel.grid.y_size do
            results.seen[i][j] = false
        end
    end

    searchFromBulb(results)
    LightBulb.lightLevel = results.panelsVisited
    LightBulb.isFullyLight = false
    if (results.panelsVisited > 4) then
        LightBulb.isFullyLight = true
        return true
    end
    return false
end


return SolarPanel
