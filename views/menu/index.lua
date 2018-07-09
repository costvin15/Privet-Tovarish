menu = {}

function menu:load()
    -- Importando todas as bibliotecas necessárias somente quando menu:load for chamado
    buttonLove = require "libraries/graphics/buttonLove"

    mSinglePlayerBtn = buttonLove:new("Um Jogador",
        250, 50, "center", 200,
        {255, 255, 255},
        function ()
            CURRENTSTATE = "game"
            -- Chama novamente love.load()
            love.load()
        end
    )

    mMultiPlayerBtn = buttonLove:new("Multijogador",
        250, 50, "center", 260,
        {255,255,255},
        function ()
            CURRENTSTATE = "multiplayerMenu"
            love.load()
        end
    )
end

function menu:draw()
    mSinglePlayerBtn.draw()
    mMultiPlayerBtn.draw()
end

function menu:mousemoved(x,y)
    mSinglePlayerBtn.mousemoved(x,y)
    mMultiPlayerBtn.mousemoved(x,y)
end

function menu:mousepressed(x,y,b,it)
    mSinglePlayerBtn.mousepressed(x,y,b,it)
    mMultiPlayerBtn.mousepressed(x,y,b,it)
end

return menu