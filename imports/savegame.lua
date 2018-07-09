savegame = {}

local function mImports()
    local libs = {}
    libs.json = require "libraries/networking/json"
    return libs
end

local function createFile()
    self.file = love.filesystem.newFile("savegame.json")
    self.file:write("[]")
    self.file:close()
    return true
end

function savegame:setContext()
    self.file = love.filesystem.read("savegame.json")
    if not self.file then
        savegame:write(1000, 500, 100, 10, 10, 20, "views/game/maps/1/vector.lua", {}, false, false, {x = false, y = false})
    end
end

function savegame:write(posx, posy, life, magic, force, money, map, inventary, canBack, lastestMap, lastestPositions)
    local t = {}
    t.position = {}

    t.position.x, t.position.y = posx, posy
    t.life, t.magic, t.force, t.money = life, magic, force, money
    t.map = map
    t.inventary = inventary
    t.canBack = canBack
    t.lastestMap = lastestMap
    t.lastestPositions = lastestPositions

    local mLibs = mImports()
    local currentFile = io.open("savegame.json", "w")
    currentFile:write(mLibs.json:encode(t))

    return currentFile:close()
end

function savegame:read()
    local mLibs = mImports()
    local currentFile = io.open("savegame.json", "r")
    return mLibs.json:decode(currentFile:read())
end

return savegame