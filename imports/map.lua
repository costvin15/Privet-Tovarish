map = {}

--[[verifica se um par coordenado informado
está dentro de um retângulo informado.
@retorna: booleano
@param:
px: ponto x do par coordenado
px: ponto y do par coordenado
x: ponto x do retângulo informado
y: ponto y do retângulo informado
w: tamanho horizontal do retângulo informado
h: tamanho vertical do retângulo informado
]]
local function pointIsInsideRectangle(px, py, x, y, w, h) return px >= x and px <= (x + w) and py >= y and py <= (y + h) end
local function imports()
    local libs = {}
    libs.sti = require "libraries/graphics/sti"
    libs.toastLove = require "libraries/graphics/toastLove"

    local imports = {}
    imports.playerstats = require "imports/playerstats"
    return libs, imports
end

function map:open(world, vector)
    local libs = imports()
    mCurrentMap = libs.sti(vector)

    self.currentmapname = vector
    self.currentmap = mCurrentMap
    self.world = world
    self.toast = libs.toastLove:new("Pressione ENTER para entrar")

    for i = 1, #self.currentmap.layers do
        if self.currentmap.layers[i].name == "objects" then
            for j = 1, #self.currentmap.layers[i].objects do
                world:add(self.currentmap.layers[i].objects[j], self.currentmap.layers[i].objects[j].x, self.currentmap.layers[i].objects[j].y, self.currentmap.layers[i].objects[j].width, self.currentmap.layers[i].objects[j].height)
            end
        end
    end

    for i = 1, #mCurrentMap.layers do
        if (self.currentmap.layers[i].name == "player") then
            self.spawnX, self.spawnY = self.currentmap.layers[i].properties["spawnX"], self.currentmap.layers[i].properties["spawnY"]
            PRINCIPALMAP = (self.currentmap.layers[i].properties["principalmap"] and CURRENTMAP) or PRINCIPALMAP
        end
    end
end

function map:interaction(x,y)
    for i = 1, #self.currentmap.layers do
        if self.currentmap.layers[i] and self.currentmap.layers[i].name == "interacao" and #self.currentmap.layers[i].objects > 0 then
            for j = 1, #self.currentmap.layers[i].objects do
                if self.currentmap.layers[i].objects[j] then
                    if pointIsInsideRectangle(x, y, self.currentmap.layers[i].objects[j].x, self.currentmap.layers[i].objects[j].y, self.currentmap.layers[i].objects[j].width, self.currentmap.layers[i].objects[j].height) then
                        self.toast.show()
                        self.toast.draw()
                    end
                end
            end
        end
    end
end

function map:update(dt)
    self.currentmap:update(dt)
end

function map:draw(x,y)
    self.currentmap:draw(x,y)
end

local function changeMap(to)
    imports.playerstats:setMap(to)
    game:load()
end

function map:keypressed(key, x, y)
    local libs, imports = imports()

    if (key == "return") then
        for i = 1, #self.currentmap.layers do
            if self.currentmap.layers[i] and self.currentmap.layers[i].name == "interacao" and #self.currentmap.layers[i].objects > 0 then
                for j = 1, #self.currentmap.layers[i].objects do
                    if self.currentmap.layers[i].objects[j] then
                        if pointIsInsideRectangle(x, y, self.currentmap.layers[i].objects[j].x, self.currentmap.layers[i].objects[j].y, self.currentmap.layers[i].objects[j].width, self.currentmap.layers[i].objects[j].height) then
                            local lastestMap = self.currentmapname
                            local lastestX, lastestY = imports.playerstats:get().position.x, imports.playerstats:get().position.y
                            imports.playerstats:setMap("views/game/maps/" .. self.currentmap.layers[i].objects[j].name .. "/vector.lua")
                            
                            if (CURRENTSTATE == "game") then
                                game:load(true, self.currentmap.layers[i].objects[j].properties["spawnX"], self.currentmap.layers[i].objects[j].properties["spawnY"])
                            elseif (CURRENTSTATE == "multiplayer") then
                                gamemultiplayer:load(true, self.currentmap.layers[i].objects[j].properties["spawnX"], self.currentmap.layers[i].objects[j].properties["spawnY"])
                            end
                            
                            imports.playerstats:setLastestMap(lastestMap)
                            imports.playerstats:setLastestPosition(lastestX, lastestY)
                        end
                    end
                end
            end
        end
    end
end

return map