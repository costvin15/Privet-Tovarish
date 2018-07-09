npc = {}
npc.isEnable = true

local function pointIsInsideRectangle(px, py, x, y, w, h)
    if px and py and x and y and w and h then
        return px >= x and px <= (x + w) and py >= y and py <= (y + h)
    end
end

function npc:insert(map, spritesheet, x, y, action)
    local anim8 = require "libraries/graphics/anim8"
    local mNPCSpriteSheet = love.graphics.newImage(spritesheet)
    local mNPCGrid = anim8.newGrid(64, 64, mNPCSpriteSheet:getWidth(), mNPCSpriteSheet:getHeight())
    local mNPCWalkingUp = anim8.newAnimation(mNPCGrid('2-9', 9), 0.1)
    local mNPCWalkingDown = anim8.newAnimation(mNPCGrid('2-9', 11), 0.1)
    local mNPCWalkingLeft = anim8.newAnimation(mNPCGrid('1-9', 10), 0.1)
    local mNPCWalkingRight = anim8.newAnimation(mNPCGrid('1-9', 12), 0.1)
    local mNPCStopped = anim8.newAnimation(mNPCGrid('1-1', 11), 0.1)

    local current = {}
    current.animations = {}
    current.spritesheet = mNPCSpriteSheet
    current.animations.up = mNPCWalkingUp
    current.animations.down = mNPCWalkingDown
    current.animations.left = mNPCWalkingLeft
    current.animations.right = mNPCWalkingRight
    current.animations.stop = mNPCStopped
    current.animations.current = current.animations.stop
    current.position = {}
    current.position.x = x
    current.position.y = y
    current.size = {}
    current.size.width = 32
    current.size.height = 52
    current.movements = {}
    current.action = action or function () end

    local mapLayer = map:addCustomLayer("npcLayer", 6)
    mapLayer.sprites = {
        npc = {
            image = current.spritesheet,
            x = current.position.x,
            y = current.position.y
        }
    }

    current.movement = function (x,y)
        local pos = {}
        pos.x = x
        pos.y = y
        table.insert(current.movements, pos)
    end

    local countMov = 1
    current.update = function (dt)
        current.animations.up:update(dt)
        current.animations.down:update(dt)
        current.animations.left:update(dt)
        current.animations.right:update(dt)

        if self.isEnable and countMov <= #current.movements then
            if math.abs(current.position.x - current.movements[countMov].x) > 0 then
                current.position.x = (current.position.x - current.movements[countMov].x < 0 and current.position.x + 1) or (current.position.x - current.movements[countMov].x > 0 and current.position.x - 1) or current.position.x
                if current.position.x - current.movements[countMov].x < 0 then
                   current.animations.current = current.animations.right
                else
                    current.animations.current = current.animations.left
                end
            elseif math.abs(current.position.y - current.movements[countMov].y) > 0 then
                current.position.y = (current.position.y - current.movements[countMov].y < 0 and current.position.y + 1) or (current.position.y - current.movements[countMov].y > 0 and current.position.y - 1) or current.position.y
                if current.position.y - current.movements[countMov].y < 0 then
                   current.animations.current = current.animations.down
                else
                    current.animations.current = current.animations.up
                end
            else
                current.animations.current = current.animations.stop
                countMov = countMov < #current.movements and countMov + 1 or countMov
            end
        end
    end

    current.playerIsClosest = function()
        local rectActionX = current.position.x
        local rectActionY = (current.position.y + current.size.height)
        local rectActionW, rectActionH = current.size.width, current.size.width
        if playerX and playerY then
            return pointIsInsideRectangle(playerX + playerW / 2, playerY + playerH, rectActionX, rectActionY, rectActionW, rectActionH)
        end
    end
    
    current.draw = function ()
        function mapLayer:draw()
            for _, sprite in pairs (self.sprites) do
                if current.position.x and current.position.y then
                    current.animations.current:draw(sprite.image, (current.position.x - (current.size.width / 2)), (current.position.y - (current.size.height / 4)))
                end
            end
        end

        local rectActionX = current.position.x
        local rectActionY = (current.position.y + current.size.height)
        local rectActionW, rectActionH = current.size.width, current.size.width
        if (pointIsInsideRectangle(playerX + playerW / 2, playerY + playerH, rectActionX, rectActionY, rectActionW, rectActionH)) then
            current.action()
        end

        return current.position.x, current.position.y, current.size.width, current.size.height
    end

    return current
end

local function loadNpcFile(currentmap)
    local JSONParser = require "libraries/networking/json"
    local file = love.filesystem.read("npcs.json")
    local data = JSONParser:decode(file)
    
    for i = 1, #data do
        if data[i].map == currentmap then
            return data[i].npcs
        end
    end
end

function npc:insertByJson(currentmap, map)
    local anim8 = require "libraries/graphics/anim8"
    local toastLove = require "libraries/graphics/toastLove"
    local battleView = require "views/battle/index"

    npcs = loadNpcFile(currentmap)

    npcsParsed = {}
    local mapLayer = map:addCustomLayer("npcLayer", 6)
    mapLayer.sprites = {}

    if npcs then
        for i = 1, #npcs do
            local mNPCSpriteSheet = love.graphics.newImage(npcs[i].spritesheet)
            local mNPCGrid = anim8.newGrid(64, 64, mNPCSpriteSheet:getWidth(), mNPCSpriteSheet:getHeight())
            local mNPCWalkingUp = anim8.newAnimation(mNPCGrid('2-9', 9), 0.1)
            local mNPCWalkingDown = anim8.newAnimation(mNPCGrid('2-9', 11), 0.1)
            local mNPCWalkingLeft = anim8.newAnimation(mNPCGrid('1-9', 10), 0.1)
            local mNPCWalkingRight = anim8.newAnimation(mNPCGrid('1-9', 12), 0.1)
            local mNPCStopped = anim8.newAnimation(mNPCGrid('1-1', 11), 0.1)
            
            local current = {}
            current.animations = {}
            current.spritesheet = mNPCSpriteSheet
            current.animations.up = mNPCWalkingUp
            current.animations.down = mNPCWalkingDown
            current.animations.left = mNPCWalkingLeft
            current.animations.right = mNPCWalkingRight
            current.animations.stop = mNPCStopped
            current.animations.current = current.animations.stop
            current.id = npcs[i].id
            current.position = {}
            current.position.x = npcs[i].x
            current.position.y = npcs[i].y
            current.size = {}
            current.size.width = 32
            current.size.height = 52
            current.battle = npcs[i].battle
            current.name = npcs[i].name
            current.inviteBattleMessage = toastLove:new("Pressione ENTER para batalhar")
            current.inviteBattleMessage.show()
    
            current.script = npcs[i].script

            npc = {
                image = current.spritesheet,
                x = current.position.x,
                y = current.position.y
            }

            table.insert(mapLayer.sprites, npc)
            table.insert(npcsParsed, current)
        end
    end

    local countMov = 1
    npcsParsed.update = function (dt)
        for i = 1, #npcsParsed do
            npcsParsed[i].animations.up:update(dt)
            npcsParsed[i].animations.down:update(dt)
            npcsParsed[i].animations.left:update(dt)
            npcsParsed[i].animations.right:update(dt)

            if self.isEnable and countMov <= #npcsParsed[i].script then
                if math.abs(npcsParsed[i].position.x - npcsParsed[i].script[countMov].x) > 0 then
                    npcsParsed[i].position.x = (npcsParsed[i].position.x - npcsParsed[i].script[countMov].x < 0 and npcsParsed[i].position.x + 1) or (npcsParsed[i].position.x - npcsParsed[i].script[countMov].x > 0 and npcsParsed[i].position.x - 1) or npcsParsed[i].position.x 
                    if npcsParsed[i].position.x - npcsParsed[i].script[countMov].x < 0 then
                        npcsParsed[i].animations.current = npcsParsed[i].animations.right
                    else
                        npcsParsed[i].animations.current = npcsParsed[i].animations.left
                    end
                elseif math.abs(npcsParsed[i].position.y - npcsParsed[i].script[countMov].y) > 0 then
                    npcsParsed[i].position.y = (npcsParsed[i].position.y - npcsParsed[i].script[countMov].y < 0 and npcsParsed[i].position.y + 1) or (npcsParsed[i].position.y - npcsParsed[i].script[countMov].y > 0 and npcsParsed[i].position.y - 1) or npcsParsed[i].position.y 
                    if npcsParsed[i].position.y - npcsParsed[i].script[countMov].y < 0 then
                        npcsParsed[i].animations.current = npcsParsed[i].animations.down
                    else
                        npcsParsed[i].animations.current = npcsParsed[i].animations.up
                    end
                else
                    npcsParsed[i].animations.current = npcsParsed[i].animations.stop
                    countMov = countMov < #npcsParsed[i].script and countMov + 1 or countMov
                end   
            end
        end
    end

    npcsParsed.draw = function ()
        function mapLayer:draw()
            for _, sprite in pairs (self.sprites) do
                for i = 1, #npcsParsed do
                    npcsParsed[i].animations.current:draw(npcsParsed[i].spritesheet, npcsParsed[i].position.x, npcsParsed[i].position.y)        
                end
            end
        end
        for i = 1, #npcsParsed do
            if npcsParsed[i].battle then
                local rectActionX = npcsParsed[i].position.x + npcsParsed[i].size.width / 2
                local rectActionY = (npcsParsed[i].position.y + npcsParsed[i].size.height)
                local rectActionW, rectActionH = npcsParsed[i].size.width, npcsParsed[i].size.width
                if playerX and playerY then
                    if pointIsInsideRectangle(playerX + playerW / 2, playerY + playerH, rectActionX, rectActionY, rectActionW, rectActionH) then
                        npcsParsed[i].inviteBattleMessage.draw()
                    end
                end
            end
        end
    end

    npcsParsed.keypressed = function (key, playerX, playerY)
        for i = 1, #npcsParsed do
            if npcsParsed[i].battle then
                local rectActionX = npcsParsed[i].position.x + npcsParsed[i].size.width / 2
                local rectActionY = (npcsParsed[i].position.y + npcsParsed[i].size.height)
                local rectActionW, rectActionH = npcsParsed[i].size.width, npcsParsed[i].size.width
                if playerX and playerY then
                    if pointIsInsideRectangle(playerX + playerW / 2, playerY + playerH, rectActionX, rectActionY, rectActionW, rectActionH) then
                        if key == "return" then
                            battleView:load(npcsParsed[i].spritesheet, npcsParsed[i].name)
                            CURRENTSTATE = "battle"
                        end
                    end
                end
            end
        end
    end
    
    return npcsParsed
end

return npc