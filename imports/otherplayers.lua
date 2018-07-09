local players = {}

function players:setContext(map)
    local anim8 = require "libraries/graphics/anim8"
    self.json = require "libraries/networking/json"

    self.animations = {}
    self.animations.spritesheet = love.graphics.newImage("sources/images/player-spritesheet.png")
    self.animations.grid = anim8.newGrid(64, 64, self.animations.spritesheet:getWidth(), self.animations.spritesheet:getHeight())
    self.animations.walking = {}
    self.animations.walking.up = anim8.newAnimation(self.animations.grid('2-9', 9), 0.1)
    self.animations.walking.down = anim8.newAnimation(self.animations.grid('2-9', 11), 0.1)
    self.animations.walking.left = anim8.newAnimation(self.animations.grid('1-9', 10), 0.1)
    self.animations.walking.right = anim8.newAnimation(self.animations.grid('1-9', 12), 0.1)
    self.animations.stop = {}
    self.animations.stop.up = anim8.newAnimation(self.animations.grid('1-1', 9), 0.1)
    self.animations.stop.down = anim8.newAnimation(self.animations.grid('1-1', 11), 0.1)
    self.animations.stop.left = anim8.newAnimation(self.animations.grid('1-1', 10), 0.1)
    self.animations.stop.right = anim8.newAnimation(self.animations.grid('1-1', 12), 0.1)
    self.animations.size = {}
    self.animations.size.width, self.animations.size.height = 32, 52
    
    self.map = {}
    self.map.layer = map:addCustomLayer("othersPlayersLayer", 8)
end

function players:update(dt)
    self.animations.walking.up:update(dt)
    self.animations.walking.down:update(dt)
    self.animations.walking.left:update(dt)
    self.animations.walking.right:update(dt)
    self.animations.stop.up:update(dt)
    self.animations.stop.down:update(dt)
    self.animations.stop.left:update(dt)
    self.animations.stop.right:update(dt)
end

function players:draw(userdata, response)
    local response = self.json:decode(response)
    local animations = self.animations
    
    function self.map.layer:draw()
        for i = 1, #response do
            local row = response[i]
            if userdata.nickname ~= row.nickname and userdata.map == row.map then
                love.graphics.setFont(love.graphics.newFont(14))
                love.graphics.print(row.nickname, (row.x + animations.size.width / 2) - love.graphics.getFont():getWidth(row.nickname) / 2, row.y - 20)
                if row.direction == "up" then
                    if row.stopped then
                        animations.stop.up:draw(animations.spritesheet, row.x - animations.size.width / 2, row.y - animations.size.height / 4)
                    else
                        animations.walking.up:draw(animations.spritesheet, row.x - animations.size.width / 2, row.y - animations.size.height / 4)
                    end
                elseif row.direction == "down" then
                    if row.stopped then
                        animations.stop.down:draw(animations.spritesheet, row.x - animations.size.width / 2, row.y - animations.size.height / 4)
                    else
                        animations.walking.down:draw(animations.spritesheet, row.x - animations.size.width / 2, row.y - animations.size.height / 4)
                    end
                elseif row.direction == "left" then
                    if row.stopped then
                        animations.stop.left:draw(animations.spritesheet, row.x - animations.size.width / 2, row.y - animations.size.height / 4)
                    else
                        animations.walking.left:draw(animations.spritesheet, row.x - animations.size.width / 2, row.y - animations.size.height / 4)
                    end
                elseif row.direction == "right" then
                    if row.stopped then
                        animations.stop.right:draw(animations.spritesheet, row.x - animations.size.width / 2, row.y - animations.size.height / 4)
                    else
                        animations.walking.right:draw(animations.spritesheet, row.x - animations.size.width / 2, row.y - animations.size.height / 4)
                    end
                end
            end
        end
    end
end

return players