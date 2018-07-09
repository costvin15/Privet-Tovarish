player = {}

-- importando as libraries necessárias
local function mImports()
    local libs = {}
    libs.anim8 = require "libraries/graphics/anim8"
    return libs
end

--[[
Inicializa player
@params:
world: mundo definido pela library Bump (física)
map: mapa definido pela library STI
]]
function player:setContext(world, map, spawnX, spawnY)
    local libs = mImports()
    
    self.animations = {}
    self.animations.spritesheet = love.graphics.newImage("sources/images/player-spritesheet.png")
    self.animations.grid = libs.anim8.newGrid(64, 64, self.animations.spritesheet:getWidth(), self.animations.spritesheet:getHeight())
    self.animations.walking = {}
    self.animations.walking.up = libs.anim8.newAnimation(self.animations.grid('2-9', 9), 0.1)
    self.animations.walking.down = libs.anim8.newAnimation(self.animations.grid('2-9', 11), 0.1)
    self.animations.walking.left = libs.anim8.newAnimation(self.animations.grid('1-9', 10), 0.1)
    self.animations.walking.right = libs.anim8.newAnimation(self.animations.grid('1-9', 12), 0.1)
    self.animations.stop = {}
    self.animations.stop.up = libs.anim8.newAnimation(self.animations.grid('1-1', 9), 0.1)
    self.animations.stop.down = libs.anim8.newAnimation(self.animations.grid('1-1', 11), 0.1)
    self.animations.stop.left = libs.anim8.newAnimation(self.animations.grid('1-1', 10), 0.1)
    self.animations.stop.right = libs.anim8.newAnimation(self.animations.grid('1-1', 12), 0.1)
    self.animations.current = self.animations.stop.down
    
    self.data = {}
    self.data.canMove = true
    self.data.position = {}
    self.data.position.x, self.data.position.y = spawnX, spawnY
    self.data.size = {}
    self.data.size.width, self.data.size.height = 32, 52
    self.data.speed = 100

    world:add(self.data, self.data.position.x, self.data.position.y, self.data.size.width, self.data.size.height)

    self.map = {}
    self.map.layer = map:addCustomLayer("playerLayer", 7)
    self.map.layer.sprites = {
        player = {
            image = self.animations.spritesheet,
            x = self.data.position.x, y = self.data.position.y
        }
    }
end

function player:get()
    return self.data.position.x, self.data.position.y
end

local lastKey
function player:update(world, dt)
    self.animations.walking.up:update(dt)
    self.animations.walking.down:update(dt)
    self.animations.walking.left:update(dt)
    self.animations.walking.right:update(dt)

    local dx, dy = 0, 0
    if (self.data.canMove) then
        if (love.keyboard.isDown("up") or love.keyboard.isDown("w")) then
            lastKey, dy = "up", - self.data.speed * dt
            self.animations.current = self.animations.walking.up
        elseif (love.keyboard.isDown("down") or love.keyboard.isDown("s")) then
            lastKey, dy = "down", self.data.speed * dt
            self.animations.current = self.animations.walking.down
        elseif (love.keyboard.isDown("left") or love.keyboard.isDown("a")) then
            lastKey, dx = "left", - self.data.speed * dt
            self.animations.current = self.animations.walking.left
        elseif (love.keyboard.isDown("right") or love.keyboard.isDown("d")) then
            lastKey, dx = "right", self.data.speed * dt
            self.animations.current = self.animations.walking.right
        else
            if (lastKey == "up") then
                self.animations.current = self.animations.stop.up
            elseif (lastKey == "down") then
                self.animations.current = self.animations.stop.down
            elseif (lastKey == "left") then
                self.animations.current = self.animations.stop.left
            elseif (lastKey == "right") then
                self.animations.current = self.animations.stop.right
            end
        end
    else
        self.animations.current = self.animations.stop.down
    end

    self.data.position.x, self.data.position.y = world:move(self.data, self.data.position.x + dx, self.data.position.y + dy)
end

function player:draw()
    local animations = self.animations
    local data = self.data
    function self.map.layer:draw()
        for _, sprite in pairs(self.sprites) do
            animations.current:draw(animations.spritesheet, data.position.x - data.size.width / 2, data.position.y - data.size.height / 4)
        end
    end

    return data.position.x, data.position.y, data.size.width, data.size.height
end

return player