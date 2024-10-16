local Menu = {}

function Menu.load()
    -- Load the background image
    Menu.background = love.graphics.newImage("bg.jpg")
    
    -- Set fonts with increased size
    Menu.titleFont = love.graphics.newFont(48)  -- Larger title font
    Menu.buttonFont = love.graphics.newFont(36) -- Larger button font

    -- Menu options
    Menu.options = { "Play", "Exit" }
    Menu.selected = 1 -- Track the currently selected option

    -- Button dimensions
    Menu.buttonWidth = 300
    Menu.buttonHeight = 60
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
        if Menu.selected == 1 then
            -- Trigger a function to switch to the game state
            return "start_game" -- Return a signal to start the game
        elseif Menu.selected == 2 then
            love.event.quit() -- Exit the game
        end
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
