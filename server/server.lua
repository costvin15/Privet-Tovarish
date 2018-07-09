local socket = require "socket"
local json = require "json"

function main()
    -- alterando o passo do coletor de lixo
    collectgarbage("step", 64)

    local users_list = {}
    local users_data = {}

    -- permitindo as conexoes tcps em todas as interfaces de rede locais e em uma porta qualquer disponivel
    server = socket.bind("*", 0)
    -- definindo o tempo limite para 0
    server:settimeout(0)
    -- desabilita o algoritmo de Nagle
    server:setoption("tcp-nodelay", true)

    -- ip e porta recebem respectivamente o ip e a porta do servidor atual
    local ip, port = server:getsockname()
    print("SERVIDOR: Iniciado em 127.0.0.1:" .. port)
    -- repete para sempre
    repeat
        -- criando a corotina que aceitara as conexoes
        acceptingconnections = coroutine.create(
            function (server, json)
                -- aceitando a conexao se ela for solicitada
                connectionaccepted = server:accept()
                -- se essa conexao existir
                if connectionaccepted then
                    -- obtem o ip da conexao
                    local ip = connectionaccepted:getpeername()
                    -- e insere-a na tabela
                    table.insert( users_list, connectionaccepted )
                    print(ip .. " entrou")
                end
            
                -- executa a corotina controlmessages
                coroutine.resume(controlmessages, server, json)
                -- suspende a execucao da corotina atual
                coroutine.yield()
            end
        )
        -- criando a corotina que recebera as conexoes
        controlmessages = coroutine.create(
            function (server, json)
                for i = 1, #users_list do
                    -- recebe a mensagem e seu status do usuario selecionado
                    local message, status = users_list[i]:receive()
                    -- se essa mensagem nao existir, a conexao com o usuario foi interropida
                    if type(message) == "nil" and status == "closed" then
                        print(users_list[i]:getpeername() .. " saiu")
                        table.remove( users_list, i )
                        table.remove( users_data, i )
                    else
                        -- decoda a mensagem recebida e insere-a na posicao i de users_data
                        users_data[i] = json.decode(message)
                        -- envia para o usuario i toda a tabela users_data
                        users_list[i]:send(json.encode(users_data) .. "\n")
                    end
                end
                -- suspende a execucao da corotina atual
                coroutine.yield()
            end
        )
        -- executa a corotina acceptingconnections
        coroutine.resume(acceptingconnections, server, json)
    until not true
end
-- executa main
main()