gamemultiplayer = {}

playerData = {
    direction = "down",
    stopped = true,
    firstConnection = true
}

hasImport = false
local function mImports()
    libs = {}
    libs.bump            = libs.bump            or require "libraries/physics/bump"
    libs.toastLove       = libs.toastLove       or require "libraries/graphics/toastLove"

    imports = {}
    imports.player       = imports.player       or require "imports/player"
    imports.playerstats  = imports.playerstats  or require "imports/playerstats"
    imports.map          = imports.map          or require "imports/map"
    imports.pausedialog  = imports.pausedialog  or require "imports/pausedialog"
    imports.savegame     = imports.savegame     or require "imports/savegame"
    imports.hud          = imports.hud          or require "imports/hudscreen"
    imports.npc          = imports.npc          or require "imports/npc"
    imports.inventary    = imports.inventary    or require "imports/inventary"
    imports.shop         = imports.shop         or require "imports/shop"
    imports.otherplayers = imports.otherplayers or require "imports/otherplayers"

    return libs, imports
end

local connectionResult = false
local libs, imports = mImports()
function gamemultiplayer:load(canReturn, sX, sY)
    self.pause = false

    world = libs.bump.newWorld(32)
    imports.savegame:setContext()
    imports.playerstats:setContext()

    local pData = imports.savegame:read()
    if not isLoaded then
        imports.playerstats:setIfCanReturn(pData.canBack)
        isLoaded = true
    end

    if (canReturn) then
        imports.playerstats:setIfCanReturn(canReturn)
        imports.playerstats:setPosition(100, 100)
        imports.playerstats:setPosition(sX, sY)
    end

    imports.map:open(world, imports.playerstats:get().map)
    --npcs = imports.npc:insertByJson(imports.playerstats:get().map, imports.map.currentmap)

    buyToast = libs.toastLove:new("Pressione ENTER para abrir a loja")
    buyToast.show()

    canReturnToast = libs.toastLove:new("Pressione BACKSPACE para voltar")
    canReturnToast.show()

    buyNpc = imports.npc:insert(imports.map.currentmap, "sources/images/player-spritesheet.png", 2020, 500,
    function() buyToast.draw() end)

    imports.player:setContext(world, imports.map.currentmap, imports.playerstats:get().position.x, imports.playerstats:get().position.y)
    imports.pausedialog:setContext()

    imports.hud:setContext()
    imports.inventary:setContext()
    imports.shop:setContext()

    imports.playerstats:setNickName(CURRENTNICKNAME)
    imports.otherplayers:setContext(imports.map.currentmap)    
    
    if playerData.firstConnection then
        love.thread.newThread("views/multiplayer/client.lua"):start()
        love.thread.getChannel("configs_ip"):push(CURRENTIP)
        love.thread.getChannel("configs_port"):push(CURRENTPORT)
        playerData.firstConnection = not playerData.firstConnection
    end

    connectionResultToast = toast:new("nothing", 3)
end

function gamemultiplayer:update(dt)
    love.thread.getChannel("toServer"):push(json:encode({x = imports.playerstats:get().position.x, y = imports.playerstats:get().position.y, direction = playerData.direction, stopped = playerData.stopped, nickname = imports.playerstats:get().nickname, map = imports.playerstats:get().map}))

    if not connectionResult then
        connectionResult = love.thread.getChannel("resultConnection"):pop()
    end

    if connectionResult then
        connectionResultToast = toast:new(connectionResult or "", 3)
        connectionResultToast.show()
        connectionResult = false
    end

    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        playerData.direction = "up"
        playerData.stopped = false
    elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        playerData.direction = "down"
        playerData.stopped = false
    elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        playerData.direction = "left"
        playerData.stopped = false
    elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        playerData.direction = "right"
        playerData.stopped = false
    else
        playerData.stopped = true
    end

    
    if not self.pause then
        imports.map:update(dt)
        imports.player:update(world, dt)
        imports.otherplayers:update(dt)
        imports.playerstats:update()
        --npcs.update(dt)
        buyNpc.update(dt)
        canReturnToast.update(dt)
    end

    imports.inventary:update(dt)
    imports.shop:update(dt)
    connectionResultToast.update(dt)
end

function gamemultiplayer:draw()
    love.graphics.setColor(255,255,255)
    playerX, playerY, playerW, playerH = imports.player:draw()
    -- movementa o mapa com base no jogador
    imports.map:draw((- playerX + (love.graphics.getWidth() / 2)) - playerW / 2, - playerY + (love.graphics.getHeight() / 2) - playerH / 2)
    -- inicializa o interação player-mapa
    imports.map:interaction(playerX, playerY)
    --npcs.draw()
    local response = love.thread.getChannel("fromServer"):pop()
    if response then
        imports.otherplayers:draw({x = imports.playerstats:get().position.x, y = imports.playerstats:get().position.y, direction = playerData.direction, stopped = playerData.stopped, nickname = imports.playerstats:get().nickname, map = imports.playerstats:get().map}, response)
    end
    
    if (imports.playerstats:get().canReturn) then
        canReturnToast.draw()
    end

    imports.hud:draw()
    imports.pausedialog:draw()
    buyNpc.draw()

    imports.inventary:draw()
    imports.shop:draw()
    
    love.graphics.setColor(0,0,0,1)
    connectionResultToast.draw()
end

function gamemultiplayer:mousemoved(x,y)
    imports.pausedialog:mousemoved(x,y)
    imports.inventary:mousemoved(x,y)
    imports.shop:mousemoved(x,y)
end

function gamemultiplayer:mousepressed(x,y,b,it)
    imports.pausedialog:mousepressed(x,y,b,it)
    imports.inventary:mousepressed(x,y,b)
    imports.shop:mousepressed(x,y,b,it)
end

function gamemultiplayer:mousereleased(x,y,b,it)
    imports.inventary:mousereleased(x,y,b,it)
end

function gamemultiplayer:wheelmoved(x,y)
    imports.inventary:wheelmoved(x,y)
end

function gamemultiplayer:keypressed(key)
    if key == "escape" then
        if not imports.inventary.visibility  and not imports.shop.visibility then
           gamemultiplayer:togglePause()
        end
    elseif key == "tab" then
        if not imports.pausedialog.configs.visibility and not imports.shop.visibility then
            imports.inventary:toggleVisibility()
        end
    elseif key == "return" then
        if buyNpc.playerIsClosest() then
            if not imports.pausedialog.configs.visibility and not imports.inventary.visibility then
                imports.shop:toggleVisibility()
            end
        end
    elseif key == "backspace" then
        if (imports.playerstats:get().canReturn) then
            imports.playerstats:setMap(imports.playerstats:get().lastestMap)
            gamemultiplayer:load(true, imports.playerstats:get().lastestPositions.x, imports.playerstats:get().lastestPositions.y)
            imports.playerstats:setIfCanReturn(false)
        end
    end

    imports.map:keypressed(key, playerX, playerY)
end

function gamemultiplayer:togglePause()
    imports.pausedialog:toggle()
end

function gamemultiplayer:keyreleased(key)
end

return gamemultiplayer