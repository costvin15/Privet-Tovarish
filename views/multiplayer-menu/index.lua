menu = {}

function menu:load()
    -- importando libraries
    buttonLove = require "libraries/graphics/buttonLove"
    inputLove = require "libraries/graphics/inputLove"

    -- inicializa a variavel
    ipaddress = ""

    -- criando um inputtext
    serverAddressInput = inputLove:new("IP do Servidor", 240, 100, 300, "sources/fonts/PixelUniCode.ttf", 25)
    nicknameInput = inputLove:new("Nome de Usuário", 240, 350, 300, "sources/fonts/PixelUniCode.ttf", 25)

    -- criando os botoes
    connectButton = buttonLove:new("Conectar", 250, 50, "center", "center", {255, 255, 255}, function () connectButtonAction(ipaddress) end)
    returnButton = buttonLove:new("Voltar", 250, 50, "left", "top", {255,255,255}, function() CURRENTSTATE = "menu" love.load() end)
end

function menu:update(dt)
    serverAddressInput.update(dt)
    nicknameInput.update(dt)
end

function menu:draw()
    serverAddressInput.draw()
    connectButton.draw()
    returnButton.draw()
    nicknameInput.draw()
end

function menu:mousemoved(x,y)
    serverAddressInput.mousemoved(x,y)
    connectButton.mousemoved(x,y)
    returnButton.mousemoved(x,y)
    nicknameInput.mousemoved(x,y)
end

function menu:mousepressed(x,y,b,it)
    serverAddressInput.mousepressed(x,y,b,it)
    connectButton.mousepressed(x,y,b,it)
    returnButton.mousepressed(x,y,b,it)
    nicknameInput.mousepressed(x,y,b,it)
end

function menu:keypressed(key)
    serverAddressInput.keypressed(key)
    nicknameInput.keypressed(key)
end

function menu:textinput(text)
    ipaddress = serverAddressInput.textinput(text)
    CURRENTNICKNAME = nicknameInput.textinput(text)
end

function connectButtonAction(ipaddress)
    -- inicializando variaveis
    local ip, port = "", ""
    local ipEndAt
    
    -- procurando o char ':'
    for i = 1, #ipaddress do
        local char = string.sub(ipaddress, i, #ipaddress - #ipaddress + i)
        if char ~= ":" then
            -- concatenando os char antes do ':'
            ip = ip .. char
        else
            -- ipEndAt armazena a posicao de ':'
            ipEndAt = i
            break;
        end
    end

    -- com o char encontrado, 
    if ipEndAt then
        for i = ipEndAt + 1, #ipaddress do
            local char = string.sub(ipaddress, i, #ipaddress - #ipaddress + i)
            -- concatenando os chars depois de ':'
            port = port .. char
        end
    end

    CURRENTIP, CURRENTPORT = ip, port
    CURRENTSTATE = "multiplayer"
    love.load()
end

return menu