battle = {}
battle.hud = require "imports/hudscreen"
local player = {}
local enemy = {}
local attack = {}
local message = {}
attack.Moan = require("libraries/graphics/Moan")

math.randomseed(os.time())

function player:load()
    local anim8 = require "libraries/graphics/anim8"
    self.animations = {}
    self.animations.spritesheet = love.graphics.newImage("sources/images/player-spritesheet.png")
    self.animations.grid = anim8.newGrid(64, 64, self.animations.spritesheet:getWidth(), self.animations.spritesheet:getHeight())
    self.animations.stop = {}
    self.animations.stop.right = anim8.newAnimation(self.animations.grid('1-1', 20), 0.1)
    self.animations.attack = {}
    self.animations.attack.right = anim8.newAnimation(self.animations.grid('1-13', 20), 0.1)
    self.animations.current = self.animations.stop.right

    self.data = {}
    self.data.size = {}
    self.data.size.width, self.data.size.height = 32, 52
    self.data.position = {}
    self.data.position.x, self.data.position.y = 100, (love.graphics.getHeight() / 2) - self.data.size.height / 2
end

function player:update(dt)
    self.animations.stop.right:update(dt)
    self.animations.attack.right:update(dt)
end

function player:draw()
    self.animations.current:draw(self.animations.spritesheet, self.data.position.x, self.data.position.y)
end

function enemy:load(enemyspritesheet)
    local anim8 = require "libraries/graphics/anim8"
    self.animations = {}
    self.animations.spritesheet = enemyspritesheet
    self.animations.grid = anim8.newGrid(64, 64, self.animations.spritesheet:getWidth(), self.animations.spritesheet:getHeight())
    self.animations.stop = {}
    self.animations.stop.left = anim8.newAnimation(self.animations.grid('1-1', 18), 0.1)
    self.animations.attack = {}
    self.animations.attack.left = anim8.newAnimation(self.animations.grid('1-13', 18), 0.1)
    self.animations.current = self.animations.stop.left

    self.data = {}
    self.data.size = {}
    self.data.size.width, self.data.size.height = 32, 52
    self.data.position = {}
    self.data.position.x, self.data.position.y = love.graphics.getWidth() - 100 - self.data.size.width, (love.graphics.getHeight() / 2) - self.data.size.height / 2
end

function enemy:draw()
    self.animations.current:draw(self.animations.spritesheet, self.data.position.x, self.data.position.y)
end

function attack:load(map, enemiename)
    self.turn = 0;
    self.Moan.font = love.graphics.newFont("sources/fonts/PixelUniCode.ttf", 32)
    self.Moan.font:setFallbacks(self.Moan.font)
    self.Moan.typeSound = love.audio.newSource("sources/sounds/typeSound.wav", "static")
    self.Moan.optionOnSelectSound = love.audio.newSource("sources/sounds/optionSelect.wav", "static")
    self.Moan.optionSwitchSound = love.audio.newSource("sources/sounds/optionSwitch.wav", "static")
    local playerstats = require "imports/playerstats"
    self.enemyLife = math.random(0, 5) * 10
    self.oldEnemyLife = self.enemyLife

    local function controlTurns()
        if playerstats:get().life > 0 and self.enemyLife > 0 then
            if self.turn == 0 then
                self.turn = 1
                damage = 0
                self.Moan.speak({"Seu turno", {100, 100, 100}}, {"Aqui estão suas opções"}, {
                    options = {
                        {"Ataque corporal", function() self.enemyLife, damage = self.enemyLife - playerstats:get().force, playerstats:get().force end},
                        {"Ataque mágico", function() self.enemyLife, damage = self.enemyLife - playerstats:get().magic, playerstats:get().force end},
                        {"Não atacar", function() end}
                    },
                    oncomplete = function()
                        self.Moan.speak({"Seu turno", {100, 100, 100}}, {"Você causou " .. damage .. " de dano"}, {
                            oncomplete = function()
                                controlTurns()
                            end
                        })
                    end
                })
            else
                self.turn = 0
                local enemyAttack = math.random(0, 2) * 5
                self.Moan.speak({"Turno inimigo", {100, 100, 100}}, {"Você sofreu " .. enemyAttack .. " de dano"}, {
                    oncomplete = function()
                        playerstats:setLife(playerstats:get().life - enemyAttack)
                        controlTurns()
                    end
                })
            end
        else
            if playerstats:get().life <= 0 then
                playerstats:setLife(100)
                message:load(1)
            elseif self.enemyLife <= 0 then
                self.enemyLife = math.random(0, 5) * 10
                message:load(0)
            end
        end
    end

    if (imports.playerstats:get().map == "views/game/maps/dungeon1/vector.lua") then
        self.Moan.speak({enemiename, {100, 100, 100}}, {"Olá Viajante", "Como ousas adentrar dentro desta caverna?", "Vamos resolver logo isto de forma rápida..."}, {oncomplete = function() controlTurns() end})
    elseif (imports.playerstats:get().map == "views/game/maps/1/vector.lua") then
        self.Moan.speak({enemiename, {100, 100, 100}}, {"Olá Viajante", "Estás a me desafiar?", "Vamos resolver logo isto de forma rápida..."}, {oncomplete = function() controlTurns() end})
    end
end

function attack:update(dt)
    self.Moan.update(dt)
end

function attack:draw()
    self.Moan.draw()

    love.graphics.setColor(255, 255, 255, 1)
    love.graphics.rectangle("fill", love.graphics.getWidth() / 2 - 150, love.graphics.getHeight() / 2 - 100, 300, 20)
    love.graphics.setColor(0, 255, 0, 1)
    
    if (300 * self.enemyLife / self.oldEnemyLife < 0) then
        love.graphics.rectangle("fill", (love.graphics.getWidth() / 2 - 150), love.graphics.getHeight() / 2 - 100, 0, 20)
    else
        love.graphics.rectangle("fill", (love.graphics.getWidth() / 2 - 150), love.graphics.getHeight() / 2 - 100, 300 * self.enemyLife / self.oldEnemyLife, 20)
    end
end

function attack:keyreleased(key)
    self.Moan.keyreleased(key)
end

function message:load(param)
    self.font = love.graphics.newFont("sources/fonts/PixelUniCode.ttf", 32)
    if param == 0 then
        local money = math.random(0, 6) * 5 
        self.currentMessage = "O inimigo foi derrotado e você recebeu " .. money .. " de dinheiro"
        playerstats:setMoney(playerstats:get().money + money)
        self.isComplete = true
    elseif param == 1 then
        self.currentMessage = "Você foi derrotado"
        self.isComplete = true
    end
end

function message:update(dt)
    if love.keyboard.isDown("space") and self.isComplete == true then
        self.currentMessage, self.isComplete = false, false
        CURRENTSTATE = "game"
    end
end

function message:draw()
    if self.currentMessage then
        love.graphics.push()
        local sW, sH = love.graphics.getWidth(), love.graphics.getHeight()
        local mW, mH = sW / 2, sH / 2
        local rW, rH = sW * 0.7, sH * 0.5
        local mX, mY = mW - rW / 2, mH - rH / 2
        
        love.graphics.setColor(0,0,0, 1)
        love.graphics.rectangle("fill", mX, mY, rW, rH)
        love.graphics.setColor(255, 255, 255, 1)
        love.graphics.setFont(self.font)
        love.graphics.print(self.currentMessage, (mX + rW / 2) - self.font:getWidth(self.currentMessage) / 2, (mY + rH / 2) - self.font:getHeight(self.currentMessage) / 2)
        love.graphics.pop()
    end
end

-- PRINCIPALS CALLBACKS
function battle:load(enemyspritesheet, enemiename)
    playerstats = require "imports/playerstats"
    
    player:load()
    enemy:load(enemyspritesheet)
    attack:load(imports.playerstats:get().map, enemiename)
    self.hud:setContext()

    if (imports.playerstats:get().map == "views/game/maps/dungeon1/vector.lua") then mapBackground = love.graphics.newImage("sources/images/cave.png")
    elseif (imports.playerstats:get().map == "views/game/maps/1/vector.lua") then mapBackground = love.graphics.newImage("sources/images/camp.png") end
end

function battle:update(dt)
    player:update(dt)
    attack:update(dt)
    message:update(dt)
end

function battle:draw()
    love.graphics.draw(mapBackground, 0, 0, 0)
    player:draw()
    enemy:draw()
    attack:draw()
    self.hud:draw()
    message:draw()
end

function battle:keyreleased(key)
    attack:keyreleased(key)
end

return battle