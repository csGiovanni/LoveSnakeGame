local Menu = {}

function Menu.load()
    -- Load the background image and set the music
    Menu.background = love.graphics.newImage("bg.jpg")
    
    -- Set fonts with increased size
    Menu.titleFont = love.graphics.newFont(48)  -- Larger title font
    Menu.buttonFont = love.graphics.newFont(36) -- Larger button font

    -- Menu options
    Menu.options = { "Play", "Settings", "Exit" }
    Menu.selected = 1 -- Track the currently selected option

    -- Button dimensions
    Menu.buttonWidth = 300
    Menu.buttonHeight = 60

    -- Load background music
    Menu.bgMusic = love.audio.newSource("bg_music.mp3", "stream")
    Menu.bgMusic:setLooping(true) -- Make the music loop
    Menu.bgMusic:play() -- Start playing the music
    
end

function Menu.keypressed(key)
    if key == "down" then
        Menu.selected = Menu.selected + 1
        if Menu.selected > #Menu.options then
            Menu.selected = 1
        end
    elseif key == "up" then
        Menu.selected = Menu.selected - 1
        if Menu.selected < 1 then
            Menu.selected = #Menu.options
        end
    elseif key == "return" then
        return Menu.activateOption(Menu.selected)
    end
end

function Menu.mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        for i, option in ipairs(Menu.options) do
            local buttonX = love.graphics.getWidth() / 2 - Menu.buttonWidth / 2
            local buttonY = 200 + (i - 1) * 70

            -- Check if the mouse click is within the button's boundaries
            if x >= buttonX and x <= buttonX + Menu.buttonWidth and
               y >= buttonY and y <= buttonY + Menu.buttonHeight then
                Menu.selected = i -- Set the selected option
                return Menu.activateOption(i) -- Simulate pressing "return" to trigger the option
            end
        end
    end
end

function Menu.mousemoved(x, y)
    for i, option in ipairs(Menu.options) do
        local buttonX = love.graphics.getWidth() / 2 - Menu.buttonWidth / 2
        local buttonY = 200 + (i - 1) * 70

        -- Check if the mouse is within the button's boundaries
        if x >= buttonX and x <= buttonX + Menu.buttonWidth and
           y >= buttonY and y <= buttonY + Menu.buttonHeight then
            Menu.selected = i -- Highlight the button under the mouse
        end
    end
end

function Menu.activateOption(selected)
    if selected == 1 then
        -- Stop the background music before starting the game
        Menu.bgMusic:stop()
        return "start_game" -- Return signal to start the game
    elseif selected == 2 then
        return "open_settings" -- Return signal to open the settings screen
    elseif selected == 3 then
        love.event.quit() -- Exit the game
    end
end

function Menu.draw()
    -- Draw background
    love.graphics.draw(Menu.background, 0, 0)

    -- Draw title
    love.graphics.setFont(Menu.titleFont)
    love.graphics.setColor(0, 0, 0) -- Set color to black for the title
    love.graphics.printf("Solar Panel", 0, 50, love.graphics.getWidth(), "center")

    -- Draw menu options with shadows
    love.graphics.setFont(Menu.buttonFont)
    for i, option in ipairs(Menu.options) do
        -- Set shadow color and position
        local shadowOffset = 3
        if i == Menu.selected then
            love.graphics.setColor(0.5, 0.5, 0.5) -- Gray for shadow
            love.graphics.rectangle("fill", love.graphics.getWidth() / 2 - Menu.buttonWidth / 2 + shadowOffset,
                                    200 + (i - 1) * 70 + shadowOffset, Menu.buttonWidth, Menu.buttonHeight)
        end

        -- Set button color and draw
        if i == Menu.selected then
            love.graphics.setColor(1, 0, 0) -- Highlight selected option in red
        else
            love.graphics.setColor(0, 0, 0) -- Black for unselected options
        end
        
        love.graphics.rectangle("fill", love.graphics.getWidth() / 2 - Menu.buttonWidth / 2,
                                200 + (i - 1) * 70, Menu.buttonWidth, Menu.buttonHeight)

        -- Reset color for text
        love.graphics.setColor(1, 1, 1) -- Set color to white for text
        love.graphics.printf(option, 0, 200 + (i - 1) * 70 + 10, love.graphics.getWidth(), "center")
    end

    love.graphics.setColor(1, 1, 1) -- Reset color
end

return Menu
