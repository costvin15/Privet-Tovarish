game = {}

-- importando as libraries necessárias

hasImport = false
local function mImports()
    libs = {}
    libs.bump           = libs.bump           or require "libraries/physics/bump"
    libs.toastLove      = libs.toastLove      or require "libraries/graphics/toastLove"

    imports = {}
    imports.player      = imports.player      or require "imports/player"
    imports.playerstats = imports.playerstats or require "imports/playerstats"
    imports.map         = imports.map         or require "imports/map"
    imports.pausedialog = imports.pausedialog or require "imports/pausedialog"
    imports.savegame    = imports.savegame    or require "imports/savegame"
    imports.hud         = imports.hud         or require "imports/hudscreen"
    imports.npc         = imports.npc         or require "imports/npc"
    imports.inventary   = imports.inventary   or require "imports/inventary"
    imports.shop        = imports.shop        or require "imports/shop"

    return libs, imports
end

-- inicializando isLoaded
isLoaded = false
function game:load(canReturn, sX, sY)
    libs, imports = mImports()

    self.pause = false
    -- cria um novo "mundo"
    world = libs.bump.newWorld(32)
    -- definindo o contexto de savegame
    imports.savegame:setContext()
    -- lendo os dados salvos
    local playerData = imports.savegame:read()
    -- se o jogo ainda nao foi carregador
    if not isLoaded then
        imports.playerstats:setContext()
        imports.playerstats:setIfCanReturn(playerData.canBack)
        imports.inventary:setContext()
        isLoaded = true
    end

    -- se o usuario consegue retornar
    if (canReturn) then
        imports.playerstats:setIfCanReturn(canReturn)
        --imports.playerstats:setPosition(100, 100)
        imports.playerstats:setPosition(sX, sY)
    end

    -- inicializando o mapa
    imports.map:open(world, imports.playerstats:get().map)
    -- inicializando os npcs
    npcs = imports.npc:insertByJson(imports.playerstats:get().map, imports.map.currentmap)

    -- criando toast e permitindo sua visibilidade
    buyToast = libs.toastLove:new("Pressione ENTER para abrir a loja")
    buyToast.show()
    canReturnToast = libs.toastLove:new("Pressione BACKSPACE para voltar", 3)
    canReturnToast.show()

    -- se o mapa atual for 1/vector.lua
    if imports.playerstats:get().map == "views/game/maps/1/vector.lua" then
        -- criando o npc buy
        buyNpc = imports.npc:insert(imports.map.currentmap, "sources/images/shopnpc.png", 2020, 500, function() buyToast.draw() end)
    end

    -- inicializa o player no par coordenado (1000, 500)
    imports.player:setContext(world, imports.map.currentmap, imports.playerstats:get().position.x, imports.playerstats:get().position.y)
    -- definindo o contexto
    imports.pausedialog:setContext()
    imports.hud:setContext()
    imports.shop:setContext()
end

function game:update(dt)
    -- se o jogo nao esta pausado
    if not self.pause then
        imports.map:update(dt)
        imports.player:update(world, dt)
        imports.playerstats:update()
        npcs.update(dt)
        
        if imports.playerstats:get().map == "views/game/maps/1/vector.lua" then
            buyNpc.update(dt)
        end
        
        canReturnToast.update(dt)
    end

    imports.inventary:update(dt)
    imports.shop:update(dt)
end

function game:draw()
    love.graphics.setColor(255,255,255)
    -- desenhando player
    playerX, playerY, playerW, playerH = imports.player:draw()
    -- movementa o mapa com base no jogador
    imports.map:draw((- playerX + (love.graphics.getWidth() / 2)) - playerW / 2, - playerY + (love.graphics.getHeight() / 2) - playerH / 2)
    -- inicializa o interação player-mapa
    imports.map:interaction(playerX, playerY)
    -- desenhando os npcs
    npcs.draw()
    -- se o usuario consegue retornar
    if (imports.playerstats:get().canReturn) then
        canReturnToast.draw()
    end
    -- desenhando hud e pausedialog
    imports.hud:draw()
    imports.pausedialog:draw()
    
    -- se o mapa for 1/vector.lua
    if imports.playerstats:get().map == "views/game/maps/1/vector.lua" then
        buyNpc.draw()
    end

    imports.inventary:draw()
    imports.shop:draw()
end

function game:mousemoved(x,y)
    imports.pausedialog:mousemoved(x,y)
    imports.inventary:mousemoved(x,y)
    imports.shop:mousemoved(x,y)
end

function game:mousepressed(x,y,b,it)
    imports.pausedialog:mousepressed(x,y,b,it)
    imports.inventary:mousepressed(x,y,b)
    imports.shop:mousepressed(x,y,b,it)
end

function game:mousereleased(x,y,b,it)
    imports.inventary:mousereleased(x,y,b,it)
end

function game:wheelmoved(x,y)
    imports.inventary:wheelmoved(x,y)
end

function game:keypressed(key)
    if key == "escape" then
        -- desenhando o menu de pausa
        if not imports.inventary.visibility  and not imports.shop.visibility then
           game:togglePause()
        end
    elseif key == "tab" then
        -- desenhando o inventario
        if not imports.pausedialog.configs.visibility and not imports.shop.visibility then
            imports.inventary:toggleVisibility()
            self.pause = imports.inventary.visibility
        end
    elseif key == "return" then
        -- desenhando o menu de loja
        if buyNpc.playerIsClosest() then
            if not imports.pausedialog.configs.visibility and not imports.inventary.visibility then
                imports.shop:toggleVisibility()
                self.pause = imports.shop.visibility
            end
        end
    elseif key == "backspace" then
        -- permitindo o retorno do personagem
        if (imports.playerstats:get().canReturn) then
            imports.playerstats:setMap(imports.playerstats:get().lastestMap)
            
            if (CURRENTSTATE == "game") then
                game:load(true, imports.playerstats:get().lastestPositions.x, imports.playerstats:get().lastestPositions.y)
            elseif (CURRENTSTATE == "multiplayer") then
                gamemultiplayer:load(true, imports.playerstats:get().lastestPositions.x, imports.playerstats:get().lastestPositions.y)
            end
            
            imports.playerstats:setIfCanReturn(false)
        end
    end

    npcs.keypressed(key, playerX, playerY)
    imports.map:keypressed(key, playerX, playerY)
end

-- invertendo a visibilidade do menu de pausa
function game:togglePause()
    self.pause = not self.pause
    imports.pausedialog:toggle()
end

function game:keyreleased(key)
end

return game