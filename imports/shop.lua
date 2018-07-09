shop = {}

local function shopImports()
    local imports = {}
    imports.playerstats = require "imports/playerstats"
    imports.inventary = require "imports/inventary"
    
    local libs = {}
    libs.list   = require "libraries/graphics/list"
    libs.json   = require "libraries/networking/json"
    libs.button = require "libraries/graphics/buttonLove"
    libs.toast  = require "libraries/graphics/toastLove"

    return imports, list
end

local function readShopList()
    -- Gambiarra, provisório
    json = require "libraries/networking/json"
    -- Fim da gambiarra

    local file = love.filesystem.read("shoplist.json")
    return json:decode(file)
end

function shop:setContext()
    self.currentSelectedItem, self.currentSelectedItemID = false, false

    self.windowTitle, self.buyButtonTitle = "Loja de Itens", "Comprar"
    self.screenWidth, self.screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
    self.windowWidth, self.windowHeight = self.screenWidth * 0.9, self.screenHeight * 0.9
    self.windowX, self.windowY = (self.screenWidth - self.windowWidth) / 2, (self.screenHeight - self.windowHeight) / 2
    self.windowMargin = 15

    self.textFont = love.graphics.newFont("sources/fonts/PixelUniCode.ttf", 30)
    self.listX, self.listY = self.windowX + self.windowMargin, self.windowY + self.textFont:getHeight(self.windowTitle) + self.windowMargin
    self.listW, self.listH = 300, self.windowHeight - self.textFont:getHeight(self.windowTitle) - 30

    self.buyButtonX, self.buyButtonY = self.windowX + 400, self.windowY + self.windowHeight - 70
    self.buyButtonWidth, self.buyButtonHeight = 250, 50

    self.selected = {}
    self.selected.titleX, self.selected.titleY = self.windowX + self.listW + 50, self.textFont:getHeight(self.windowTitle) + self.windowMargin

    local imports, list = shopImports()

    self.visibility = false

    local function patternSelected()
        self.selected.title = "Nada Selecionado"
        self.selected.description = "Não há nada selecionado"
        self.selected.price = ""
    end
    patternSelected()

    -- Gambiarra, provisório
    libs.toast  = require "libraries/graphics/toastLove"
    libs.list   = require "libraries/graphics/list"
    libs.button = require "libraries/graphics/buttonLove"
    -- Fim da gambiarra

    withoutMoneyToast = libs.toast:new("Você não tem dinheiro suficiente para isso", 2, {255,255,255,0.9})
    exitShopToast = libs.toast:new("Pressione ENTER para sair da Loja", "infinite", {255, 255, 255, 0.9})
    exitShopToast.show()

    shopList = libs.list:new(self.listX, self.listY, self.listW, self.listH)
    shopListTable = readShopList()
    for i = 1, #shopListTable do
        shopList:add(shopListTable[i].title, shopListTable[i].description, shopListTable[i])
    end
    shopList:done()

    local buyButtonAction = function ()
        if self.selected.id then
            if imports.playerstats:get().money - self.selected.price >= 0 then
                imports.playerstats:setMoney(imports.playerstats:get().money - self.selected.price)
                imports.inventary:refresh(self.selected.id)
            else
                withoutMoneyToast.show()
            end
        end
    end

    buyButton = libs.button:new(self.buyButtonTitle, self.buyButtonWidth, self.buyButtonHeight, self.buyButtonX, self.buyButtonY, {255,255,255}, function() buyButtonAction() end)
end

function shop:update(dt)
    shopList:update(dt)
    withoutMoneyToast.update(dt)
    if (self.currentSelectedItem) then
        for i = 1, #shopListTable do
            if (shopListTable[i].title == self.currentSelectedItem) then
                self.selected.id = self.currentSelectedItemID
                self.selected.title = shopListTable[i].title
                self.selected.description = shopListTable[i].description
                self.selected.price = shopListTable[i].price
            end
        end
    end
end

function shop:toggleVisibility()
    self.visibility = not self.visibility
end

function shop:draw()
    if (self.visibility) then
        love.graphics.setColor(0, 0, 0, 0.9)
        love.graphics.rectangle("fill", 0, 0, self.screenWidth, self.screenHeight)
        
        love.graphics.setColor(255, 255, 255, 0.4)
        love.graphics.rectangle("fill", self.windowX, self.windowY, self.windowWidth, self.windowHeight)

        love.graphics.setColor(255, 255, 255, 1)
        love.graphics.setFont(self.textFont)
        love.graphics.print(self.windowTitle, self.windowX + self.windowMargin, self.windowY + self.windowMargin)

        love.graphics.print(self.selected.title, self.selected.titleX, self.selected.titleY)
        love.graphics.print(self.selected.description .. "\nPreço: " .. self.selected.price, self.selected.titleX, self.selected.titleY + self.textFont:getHeight(self.selected.title))

        shopList:draw()
        buyButton.draw()
        exitShopToast.draw()
        withoutMoneyToast.draw()
    end
end

function shop:mousemoved(x,y)
    if (self.visibility) then
        shopList:mousemoved(x,y)
        buyButton.mousemoved(x,y)
    end
end

function shop:mousepressed(x,y,b,it)
    if (self.visibility) then
        self.currentSelectedItem, self.currentSelectedItemID = shopList:mousepressed(x,y,b,it)
        buyButton.mousepressed(x,y,b,it)
    end
end

return shop