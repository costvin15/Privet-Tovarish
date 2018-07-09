inputLove = {}

local function pointIsInsideRectangle(px, py, x, y, w, h) return px >= x and px <= (x + w) and py >= y and py <= (y + h) end

inputHover = false
function inputLove:new(placeholder, x, y, width, fonttext, fontsize)
    local current = {}
    current.text = placeholder
    current.oldText = placeholder
    current.position = {}
    current.position.x, current.position.y = x, y
    current.fonttext = {}
    current.fonttext.font = fonttext and love.graphics.newFont(fonttext, fontsize) or love.graphics.newFont(fontsize)
    current.fonttext.width, current.fonttext.height = current.fonttext.font:getWidth(placeholder), current.fonttext.font:getHeight(placeholder)
    current.layout = {}
    current.layout.width = width
    current.layout.margin = 15

    current.selected = false
    current.editing = false
    current.barCount = 0
    current.lastTimeBar = os.time()

    love.keyboard.setKeyRepeat(true)
    
    current.update = function(dt)
        if (not current.selected) then
            current.barCount = 0
        elseif current.selected and not current.editing then
            if current.barCount < 5 then
                if os.difftime(os.time(), current.lastTimeBar) >= 1 then
                    if string.sub(current.text, -1) == "|" then
                        current.text = string.sub(current.text, 1, -3)
                    else
                        current.text = current.text .. " |"
                    end
                    current.lastTimeBar = os.time()
                end
            else
                current.barCount = 0
            end
        end

        if inputHover then
            love.mouse.setCursor(love.mouse.getSystemCursor("ibeam"))
        else
            love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
        end
    end

    current.draw = function()
        love.graphics.setColor(255, 255, 255, 1)
        love.graphics.setFont(current.fonttext.font)
        love.graphics.rectangle("fill", current.position.x, current.position.y, current.layout.width + current.layout.margin * 2, current.fonttext.height + current.layout.margin * 2)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.print(current.text, current.position.x + current.layout.margin, current.position.y + current.layout.margin)
    end

    current.mousemoved = function(x,y)
        if (pointIsInsideRectangle(x,y, current.position.x, current.position.y, current.layout.width + current.layout.margin * 2, current.fonttext.height + current.layout.margin * 2)) then
            inputHover = true
        else
            inputHover = false
        end
    end

    current.mousepressed = function(x,y,b,it)
        if (b == 1 and pointIsInsideRectangle(x,y, current.position.x, current.position.y, current.layout.width + current.layout.margin * 2, current.fonttext.height + current.layout.margin * 2)) then
            current.selected = true
            if current.text == current.oldText then
                current.text = ""
            end
        else
            current.selected = false
            current.editing = false
        end
    end
    
    current.keypressed = function(key)
        if key == "backspace" and current.selected then
            if string.sub(current.text, -1) == "|" then
                current.text, current.oldText = string.sub(current.text, 1, -4)
            else
                current.text, current.oldText = string.sub(current.text, 1, -2)
            end
        end
    end

    current.textinput = function(text)
        if current.selected and text ~= "ç" then
            current.editing = true
            if string.sub(current.text, -1) == "|" then
                current.text = string.sub(current.text, 1, -3)
            end

            current.text = current.text .. text
        end

        return current.text
    end

    return current
end

return inputLove