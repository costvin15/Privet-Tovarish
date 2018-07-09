stats = {
    currentUser = {}
}

function stats:setContext()
    local savegame = require "imports/savegame"

    self.currentUser.position = {}
    self.currentUser.position.x, self.currentUser.position.y = savegame:read().position.x, savegame:read().position.y
    self.currentUser.life, self.currentUser.magic, self.currentUser.force, self.currentUser.money = savegame:read().life, savegame:read().magic, savegame:read().force, savegame:read().money
    self.currentUser.map = self.currentUser.map or savegame:read().map
    self.currentUser.inventary = savegame:read().inventary

    self.currentUser.lastestMap = savegame:read().lastestMap
    self.currentUser.canReturn = false
    self.currentUser.lastestPositions = savegame:read().lastestPositions and savegame:read().lastestPositions or self.currentUser.position
    self.currentUser.nickname = ""
end

local getMT = { __index = stats }
function stats:get()
    return setmetatable({
        position = self.currentUser.position,
        life = self.currentUser.life,
        magic = self.currentUser.magic,
        force = self.currentUser.force,
        magic = self.currentUser.magic,
        money = self.currentUser.money,
        inventary = self.currentUser.inventary,
        map = self.currentUser.map,
        lastestMap = self.currentUser.lastestMap,
        canReturn = self.currentUser.canReturn,
        lastestPositions = self.currentUser.lastestPositions,
        nickname = self.currentUser.nickname
    }, getMT)
end

function stats:update()
    local player = require "imports/player"
    self.currentUser.position.x, self.currentUser.position.y = player:get()
end

function stats:setLife(life) self.currentUser.life = life end
function stats:setMagic(magic) self.currentUser.magic = magic end
function stats:setForce(force) self.currentUser.force = force end
function stats:setMoney(money) self.currentUser.money = money end
function stats:setMap(map) self.currentUser.map = map end

function stats:addToInventary(item)
    table.insert(self.currentUser.inventary, item)
end

function stats:removeFromInventary(item)
    for i = 1, #self.currentUser.inventary do
        if self.currentUser.inventary == item then
            for j = i, #self.currentUser.inventary do
                self.currentUser.inventary[j] = self.currentUser.inventary[j + 1]
            end
        end
    end
end

function stats:setPosition(x,y) self.currentUser.position.x, self.currentUser.position.y = x,y end
function stats:setIfCanReturn(bool) self.currentUser.canReturn = bool end
function stats:setLastestMap(lastest) self.currentUser.lastestMap = lastest end
function stats:setLastestPosition(x,y) self.currentUser.lastestPositions.x, self.currentUser.lastestPositions.y = x,y end
function stats:setNickName(name) self.currentUser.nickname = name end

return stats