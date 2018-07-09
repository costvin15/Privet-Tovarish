inventary = {}

local function mImports()
    local imports = {}
    imports.stats = require "imports/playerstats"

    local libs = {}
    libs.list = require "libraries/graphics/list"
    libs.json = require "libraries/networking/json"
    libs.button = require "libraries/graphics/buttonLove"

    return imports, libs
end

local function consultShopList()
    local imports, libs = mImports()
    local file = love.filesystem.read("shoplist.json")
    return libs.json:decode(file)
end

function inventary:setContext()
    self.currentSelectedItem, self.currentSelectedItemID = false, false

    self.windowTitle, self.useButtonTitle = "Inventário", "Usar";
    self.screenWidth, self.screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
    self.windowWidth, self.windowHeight = self.screenWidth * 0.9, self.screenHeight * 0.9
    self.windowX, self.windowY = (self.screenWidth - self.windowWidth) / 2, (self.screenHeight - self.windowHeight) / 2
    self.windowMargin = 15

    self.textFont = love.graphics.newFont("sources/fonts/PixelUniCode.ttf", 30)
    self.listX, self.listY = self.windowX + self.windowMargin, self.windowY + self.textFont:getHeight(self.windowTitle) + self.windowMargin
    self.listW, self.listH = 300, self.windowHeight - self.textFont:getHeight(self.windowTitle) - 30

    self.useButtonX, self.useButtonY = self.windowX + 400, self.windowY + self.windowHeight - 70
    self.useButtonWidth, self.useButtonHeight = 250, 50

    self.selected = {}
    self.selected.titleX, self.selected.titleY = self.windowX + self.listW + 50, self.windowY + self.textFont:getHeight(self.windowTitle) + self.windowMargin

    local imports, libs = mImports()

    self.visibility = false
    
    local function patternSelected()
        self.selected.title = "Nada Selecionado"
        self.selected.description = "Não há nada selecionado"
        self.selected.action = function () end
    end
    patternSelected()

    function listInventaryLoad()
        inventaryList = libs.list:new(self.listX, self.listY, self.listW, self.listH)

        local shopList = consultShopList()
        for i = 1, #imports.stats:get().inventary do
            inventaryList:add( shopList[imports.stats:get().inventary[i]].title, shopList[imports.stats:get().inventary[i]].description, imports.stats:get().inventary[i] )
        end

        inventaryList:done()
    end

    function removeFromList(index)
        for i = index, #inventaryList.items do
            inventaryList.items[i] = inventaryList.items[i + 1]
        end
    end

    local function useButtonClick()
        print(#inventaryList.items)
        if type(self.selected.action) == "table" then
            if self.selected.action.target == "life" then
                if imports.stats:get().life + self.selected.action.effect <= 100 then
                    imports.stats:setLife(imports.stats:get().life + self.selected.action.effect)
                    removeFromList(self.selected.id)
                elseif imports.stats:get().life - 100 ~= 0 then
                    imports.stats:setLife(100)
                    removeFromList(self.selected.id)
                end
            elseif self.selected.action.target == "force" then
                if imports.stats:get().force + self.selected.action.effect <= 40 then
                    imports.stats:setForce(imports.stats:get().force + self.selected.action.effect)
                    removeFromList(self.selected.id)
                elseif imports.stats:get().force - 40 ~= 0 then
                    imports.stats:setForce(40)
                    removeFromList(self.selected.id)
                end
            elseif self.selected.action.target == "magic" then
                if imports.stats:get().magic + self.selected.action.effect <= 40 then
                    imports.stats:setMagic(imports.stats:get().magic + self.selected.action.effect)
                    removeFromList(self.selected.id)
                elseif imports.stats:get().magic - 40 ~= 0 then
                    imports.stats:setMagic(40)
                    removeFromList(self.selected.id)
                end
            end
        end
        print(#inventaryList.items)
    end

    listInventaryLoad()

    useButton = libs.button:new(self.useButtonTitle, self.useButtonWidth, self.useButtonHeight, self.useButtonX, self.useButtonY, { 255, 255, 255 }, function() useButtonClick() end)
end

function inventary:refresh(index)
    local oldList = inventaryList.items
    inventaryList = libs.list:new(self.listX, self.listY, self.listW, self.listH)
    inventaryList.items = oldList

    local shopList = consultShopList()
    inventaryList:add( shopList[index].title, shopList[index].description, index )

    inventaryList:done()
end

function inventary:setList(list)
    
end

function inventary:update(dt)
    inventaryList:update(dt)
    if (self.currentSelectedItem) then
        local shopList = consultShopList()
        for i = 1, #shopList do
            if (shopList[i].title == self.currentSelectedItem) then
                self.selected.id = self.currentSelectedItemID
                self.selected.title = self.currentSelectedItem
                self.selected.description = shopList[i].description
                self.selected.action = shopList[i].action
            end
        end
        self.currentSelectedItem = false
    end
end

function inventary:toggleVisibility()
    self.visibility = not self.visibility
end

function inventary:draw()
    if (self.visibility) then
        love.graphics.setColor(0, 0, 0, 0.9)
        love.graphics.rectangle("fill", 0, 0, self.screenWidth, self.screenHeight)

        love.graphics.setColor(255, 255, 255, 0.4)
        love.graphics.rectangle("fill", self.windowX, self.windowY, self.windowWidth, self.windowHeight)

        love.graphics.setColor(255, 255, 255, 1)
        love.graphics.setFont(self.textFont)
        love.graphics.print(self.windowTitle, self.windowX + self.windowMargin, self.windowY + self.windowMargin)

        love.graphics.print(self.selected.title, self.selected.titleX, self.selected.titleY)
        love.graphics.print(self.selected.description, self.selected.titleX, self.selected.titleY + self.textFont:getHeight(self.selected.title))

        inventaryList:draw()
        useButton.draw()
    end
end

function inventary:mousemoved(x,y)
    if (self.visibility) then
        inventaryList:mousemoved(x,y)
        useButton.mousemoved(x,y)
    end
end

function inventary:mousepressed(x,y,b,it)
    if (self.visibility) then
        self.currentSelectedItem, self.currentSelectedItemID = inventaryList:mousepressed(x,y,b,it)
        print(self.currentSelectedItem, self.currentSelectedItemID)
        useButton.mousepressed(x,y,b,it)
    end
end

function inventary:mousereleased(x,y,b)
    if (self.visibility) then
        inventaryList:mousereleased(x,y,b,it)
    end
end

function inventary:wheelmoved(x,y)
    if (self.visibility) then
        inventaryList:wheelmoved(x,y)
    end
end

return inventary