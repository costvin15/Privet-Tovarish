CURRENTSTATE = "menu"
CURRENTIP, CURRENTPORT, CURRENTNICKNAME = "", "", ""

menuView            = require "views/menu/index"
gameView            = require "views/game/index"
multiplayerView     = require "views/multiplayer/index"
multiplayerMenuView = require "views/multiplayer-menu/index"
battleView          = require "views/battle/index"

function love.load()
    if (CURRENTSTATE == "menu") then
        menuView:load()
    elseif (CURRENTSTATE == "game") then
        gameView:load()
    elseif (CURRENTSTATE == "multiplayer") then
        multiplayerView:load()
    elseif (CURRENTSTATE == "multiplayerMenu") then
        multiplayerMenuView:load()
    elseif (CURRENTSTATE == "battle") then
        battleView:load()
    end
end

function love.update(dt)
    if (CURRENTSTATE == "game") then
        gameView:update(dt)
    elseif (CURRENTSTATE == "multiplayer") then
        multiplayerView:update(dt)
    elseif (CURRENTSTATE == "multiplayerMenu") then
        multiplayerMenuView:update(dt)
    elseif (CURRENTSTATE == "battle") then
        battleView:update(dt)
    end
end

function love.draw()
    if (CURRENTSTATE == "menu") then
        menuView:draw()
    elseif (CURRENTSTATE == "game") then
        gameView:draw()
    elseif (CURRENTSTATE == "multiplayer") then
        multiplayerView:draw()
    elseif (CURRENTSTATE == "multiplayerMenu") then
        multiplayerMenuView:draw()
    elseif (CURRENTSTATE == "battle") then
        battleView:draw()
    end
end

function love.mousemoved(x,y)
    if (CURRENTSTATE == "menu") then
        menuView:mousemoved(x,y)
    elseif (CURRENTSTATE == "game") then
        gameView:mousemoved(x,y)   
    elseif (CURRENTSTATE == "multiplayer") then
        multiplayerView:mousemoved(x,y) 
    elseif (CURRENTSTATE == "multiplayerMenu") then
        multiplayerMenuView:mousemoved(x,y)
    end
end

function love.mousepressed(x,y,b,it)
    if (CURRENTSTATE == "menu") then
        menuView:mousepressed(x,y,b,it)
    elseif (CURRENTSTATE == "game") then
        gameView:mousepressed(x,y,b,it)
    elseif (CURRENTSTATE == "multiplayer") then
        multiplayerView:mousepressed(x,y,b,it)
    elseif (CURRENTSTATE == "multiplayerMenu") then
        multiplayerMenuView:mousepressed(x,y,b,it)
    end
end

function love.mousereleased(x,y,b,it)
    if (CURRENTSTATE == "game") then
        gameView:mousereleased(x,y,b,it)
    elseif (CURRENTSTATE == "multiplayer") then
        multiplayerView:mousereleased(x,y,b,it)
    end
end

function love.wheelmoved(x,y)
    if (CURRENTSTATE == "game") then
        gameView:wheelmoved(x,y)
    elseif (CURRENTSTATE == "multiplayer") then
        multiplayerView:wheelmoved(x,y)
    end
end

function love.keypressed(key)
    if (CURRENTSTATE == "game") then
        gameView:keypressed(key)
    elseif (CURRENTSTATE == "multiplayer") then
        multiplayerView:keypressed(key)
    elseif (CURRENTSTATE == "multiplayerMenu") then
        multiplayerMenuView:keypressed(key)
    end
end

function love.textinput(text)
    if (CURRENTSTATE == "multiplayerMenu") then
        multiplayerMenuView:textinput(text)
    end
end

function love.keyreleased(key)
    if (CURRENTSTATE == "game") then
        gameView:keyreleased(key)
    elseif (CURRENTSTATE == "multiplayer") then
        multiplayerView:keyreleased(key) 
    elseif (CURRENTSTATE == "battle") then
        battleView:keyreleased(key)
    end
end