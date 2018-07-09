hud = {}

local function mImports()
    local imports = {}
    imports.playerstats = require "imports/playerstats"
    return imports
end

function hud:setContext()
    self.configs = {}
    self.configs.windowWidth = love.graphics.getWidth()
    self.configs.windowHeight = love.graphics.getHeight()
    self.configs.width = 230
    self.configs.height = 70
    self.configs.margin = 15
    self.configs.barwidth = self.configs.width - self.configs.margin * 2
    self.font = love.graphics.newFont(10)

    self.configs.widthMoney = 120
    self.configs.heightMoney = 50
    self.configs.coinImage = love.graphics.newImage("sources/images/coin.png")
    self.configs.font = love.graphics.newFont("sources/fonts/PixelUniCode.ttf", 40)
end

function hud:draw()
    local imports = mImports()
    love.graphics.setFont(self.font)
    love.graphics.setColor(0,0,0,0.8)
    love.graphics.rectangle("fill", self.configs.margin, self.configs.margin, self.configs.width, self.configs.height)
    love.graphics.setColor(0,255,0)
    love.graphics.rectangle("fill", self.configs.margin * 2, self.configs.margin * 2, self.configs.barwidth * imports.playerstats:get().life / 100, 10)
    love.graphics.setColor(0,0,0)
    love.graphics.print("Vida: " .. imports.playerstats:get().life, self.configs.margin * 2, self.configs.margin * 2)

    love.graphics.setColor(255,0,0)
    love.graphics.rectangle("fill", self.configs.margin * 2, self.configs.margin * 2 + 15, self.configs.barwidth * imports.playerstats:get().force / 40, 10)
    love.graphics.setColor(0,0,0)
    love.graphics.print("Força: " .. imports.playerstats:get().force, self.configs.margin * 2, self.configs.margin * 2 + 15)
    
    love.graphics.setColor(0,0,255)
    love.graphics.rectangle("fill", self.configs.margin * 2, self.configs.margin * 2 + 30, self.configs.barwidth * imports.playerstats:get().magic / 40, 10)
    love.graphics.setColor(0,0,0)
    love.graphics.print("Magia: " .. imports.playerstats:get().magic, self.configs.margin * 2, self.configs.margin * 2 + 30)

    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", self.configs.windowWidth - self.configs.widthMoney - self.configs.margin, self.configs.margin, self.configs.widthMoney, self.configs.heightMoney)

    love.graphics.setColor(255, 255, 255, 1)
    love.graphics.draw(self.configs.coinImage, self.configs.windowWidth - self.configs.widthMoney - self.configs.margin + 3, self.configs.margin * 1.5 - 2, 0, 0.15, 0.15, 0, 0, 0, 0)

    love.graphics.setFont(self.configs.font)
    love.graphics.print(imports.playerstats:get().money, self.configs.windowWidth - self.configs.widthMoney - self.configs.margin + 50, self.configs.margin + 1)
end

return hud