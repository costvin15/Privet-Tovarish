local toastLove = {
    _VERSION = "toastLove v1.0.0",
    _COMPATIBILITY = "Tested on Love 11.1.0",
    _DEVELOPER = "Vinicius C. Castro",
    _DATE = "Jun. 2018",
    _DESCRIPTION = "A simple toast message library for Love2D",
    _WHERE = "UFMA, São Luís - MA, Brazil",
    _LICENSE = [[
        MIT LICENSE
    
        Copyright (c) 2018 Vinicius Costa Castro
    
        Permission is hereby granted, free of charge, to any person obtaining a
        copy of this software and associated documentation files (the
        "Software"), to deal in the Software without restriction, including
        without limitation the rights to use, copy, modify, merge, publish,
        distribute, sublicense, and/or sell copies of the Software, and to
        permit persons to whom the Software is furnished to do so, subject to
        the following conditions:
    
        The above copyright notice and this permission notice shall be included
        in all copies or substantial portions of the Software.
    
        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
        OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
        MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
        IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
        CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
        TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
        SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    ]]
}

toast = {}

--[[
@retorna: table
@param:
text: texto a ser impresso no botão
]]
function toast:new(text, ...)
    local varargs = {...}
    local current = {}
    current.text = text
    current.duration = varargs[1] or "infinite"
    current.textfont = ((varargs[3] and varargs[4]) and love.graphics.newFont(varargs[3], varargs[4]) or love.graphics.newFont())
    current.backgroundcolor = varargs[2] or {0,0,0,0.8}
    current.visible = false
    current.datatimecreation = false
    
    -- tamanho horizontal e vertical da janela
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    -- tamanho do texto a ser impresso
    local textWidth = current.textfont:getWidth(text)
    local textHeight = current.textfont:getHeight(text)

    -- quando chamada, a função retorna o estado atual da visibilidade
    current.isShowing = function()
        return current.visible
    end

    -- quando chamada, a função torna visível o toast, e define datatimecreation como o horário quando a função foi chamada
    current.show = function()
        current.visible = true
        current.datatimecreation = os.time()
    end

    current.update = function(dt)
        -- se duração for do tipo número
        if (type(current.duration) == "number") then
            -- se datatimecreation for do tipo número
            if type(current.datatimecreation) == "number" then
                -- se a diferença de tempo for maior do que o definido pelo usuário
                if (os.difftime(os.time(), current.datatimecreation) > current.duration) then
                    -- torne o toast invisível
                    current.visible = false
                end
            end
        -- se duração for do tipo string
        elseif (type(current.duration) == "string") then
            -- se seu texto for "infinite"
            if (current.duration == "infinite") then
                -- torne o toast visível
                current.visible = true
            else
                error("Number expected or \"infinite\"")
            end
        else
            error("Unexpected error")
        end
    end
    
    current.draw = function()
        if (current.visible) then
            love.graphics.setColor(current.backgroundcolor)
            love.graphics.setFont(current.textfont)
            love.graphics.rectangle("fill",
                (windowWidth / 2) - (textWidth / 2) - 25,
                (windowHeight - 150) - (textHeight / 2) - 25 / 2,
                textWidth + 50,
                textHeight + 25
            )
            
            cR,cG,cB = current.backgroundcolor[1],current.backgroundcolor[2],current.backgroundcolor[3]
            if cR == 0 and cG == 0 and cB == 0 then
                love.graphics.setColor(255,255,255)
            else
                love.graphics.setColor(0,0,0)
            end

            love.graphics.print(current.text, (windowWidth / 2) - (textWidth / 2), (windowHeight - 150) - (textHeight / 2))
        end
    end

    return current
end

return toast