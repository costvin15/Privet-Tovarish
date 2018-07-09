pause = {}

local function mImports()
    local libraries = {}
    libraries.buttonLove = require "libraries/graphics/buttonLove"
    
    local imports = {}
    imports.playerstats = require "imports/playerstats"
    imports.savegame = require "imports/savegame"
    return libraries, imports
end

function pause:setContext()
    local libs = mImports()

    self.configs = {}
    
    self.configs.windowWidth = love.graphics.getWidth()
    self.configs.windowHeight = love.graphics.getHeight()
    
    self.configs.recWidth = self.configs.windowWidth * 0.6
    self.configs.recHeight = 325

    self.configs.recPosX = self.configs.windowWidth / 2 - self.configs.recWidth / 2
    self.configs.recPosY = self.configs.windowHeight / 2 - self.configs.recHeight / 2
    self.configs.visibility = false

    self.buttons = {}
    self.buttons.title = libs.buttonLove:new("Pausado", self.configs.recWidth - 50, 50, self.configs.recPosX + 25, self.configs.recPosY + 25, { 0, 0, 0 }, false, "sources/fonts/PixelUniCode.ttf")
    self.buttons.resume = libs.buttonLove:new("Continuar", self.configs.recWidth - 50, 50, self.configs.recPosX + 25, self.configs.recPosY + 115, { 255,255,255 },
        function ()
            game:togglePause()
        end, "sources/fonts/PixelUniCode.ttf")
    self.buttons.save = libs.buttonLove:new("Salvar e Sair", self.configs.recWidth - 50, 50, self.configs.recPosX + 25, self.configs.recPosY + 180, { 255,255,255 },
        function ()
            imports.savegame:write(imports.playerstats:get().position.x, imports.playerstats:get().position.y, imports.playerstats:get().life, imports.playerstats:get().magic, imports.playerstats:get().force, imports.playerstats:get().money, imports.playerstats:get().map, imports.playerstats:get().inventary, imports.playerstats:get().canReturn, imports.playerstats:get().lastestMap, imports.playerstats:get().lastestPositions)
            os.exit()
        end, "sources/fonts/PixelUniCode.ttf")
    self.buttons.exit = libs.buttonLove:new("Sair sem salvar", self.configs.recWidth - 50, 50, self.configs.recPosX + 25, self.configs.recPosY + 245, { 255,255,255 },
        function ()
            os.exit()
        end,"sources/fonts/PixelUniCode.ttf")
end

function pause:draw()
    if self.configs.visibility then
        love.graphics.setColor(0,0,0,0.8)
        love.graphics.rectangle("fill", self.configs.recPosX, self.configs.recPosY, self.configs.recWidth, self.configs.recHeight)
        
        self.buttons.title.draw()
        self.buttons.resume.draw()
        self.buttons.save.draw()
        self.buttons.exit.draw()
    end
end

function pause:mousemoved(x,y)
    if self.configs.visibility then
        self.buttons.resume.mousemoved(x,y)
        self.buttons.save.mousemoved(x,y)
        self.buttons.exit.mousemoved(x,y)
    end
end

function pause:mousepressed(x,y,b,it)
    if self.configs.visibility then
        self.buttons.resume.mousepressed(x,y,b,it)
        self.buttons.save.mousepressed(x,y,b,it)
        self.buttons.exit.mousepressed(x,y,b,it)
    end
end

function pause:toggle() self.configs.visibility = not self.configs.visibility end
function pause:isShowing() return self.configs.visibility end
return pause