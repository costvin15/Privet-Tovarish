local socket = require "socket"
-- recebe o ip e a porta
CURRENTIP, CURRENTPORT = love.thread.getChannel("configs_ip"):pop(), love.thread.getChannel("configs_port"):pop()
-- conecta-se com uma conexao tcp no ip e porta informado
local client = socket.connect(CURRENTIP, CURRENTPORT or 8080)
-- se a conexao for realizada
if client then
    -- define o tempo limite para 0
    client:settimeout(0)
    -- envia para o servidor a seguinte mensagem
    love.thread.getChannel("resultConnection"):push("Conectado com sucesso")

    -- executa enquanto client existir
    repeat
        -- criando a corotina que enviara os dados para o servidor
        toServer = coroutine.create(function()
                -- recebendo da thread principal a mensagem que sera enviada
                local message = love.thread.getChannel("toServer"):pop()
                -- se a mensagem existir, ela sera enviada
                if message then client:send(message .. "\n") end
                -- executando a corotina fromServer
                coroutine.resume(fromServer)
                -- suspendendo a execucao da corotina atual
                coroutine.yield()
        end)
        -- criando a corotina que recebera os dados do servidor
        fromServer = coroutine.create(function()
                -- recebendo a mensagem do servidor
                local message, status = client:receive()
                -- se status e 'closed', isto implica que a conexao foi perdida
                if status ~= "closed" then
                    -- se mensagem existir
                    if message then
                        -- ela sera enviada para a thread principal
                        love.thread.getChannel("fromServer"):push(message)
                    end
                    -- suspendendo a execucao da corotina atual
                    coroutine.yield()
                else
                    -- enviando para a thread principal a seguinte menssagem
                    love.thread.getChannel("resultConnection"):push("A conexão com o servidor foi perdida.")
                    -- fechando a tentativa de conexao
                    client:close()
                end
        end)
        -- executando a corotina toServer
        coroutine.resume(toServer)
    until not client
else
    love.thread.getChannel("resultConnection"):push("Nao foi possivel conectar-se ao servidor.")
end