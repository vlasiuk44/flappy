-- Основные параметры
local bird
local pipes
local gravity = 800
local jumpHeight = -300
local pipeSpawnTimer = 0
local pipeSpawnInterval = 2
local score = 0
local font

function love.load()
    love.window.setTitle("Flappy Bird")
    love.window.setMode(400, 600)

    bird = {x = 50, y = 300, width = 30, height = 30, velocity = 0}

    pipes = {}

    font = love.graphics.newFont(20)
end

function love.update(dt)
    -- Обработка движения птицы
    bird.velocity = bird.velocity + gravity * dt
    bird.y = bird.y + bird.velocity * dt

    -- Проверка столкновений
    if bird.y < 0 then
        bird.y = 0
        bird.velocity = 0
    end

    if bird.y + bird.height > love.graphics.getHeight() then
        bird.y = love.graphics.getHeight() - bird.height
        bird.velocity = 0
    end

    -- Генерация труб
    pipeSpawnTimer = pipeSpawnTimer + dt
    if pipeSpawnTimer > pipeSpawnInterval then
        spawnPipe()
        pipeSpawnTimer = 0
    end

    -- Обновление положения труб
    for i, pipe in ipairs(pipes) do
        pipe.x = pipe.x - 100 * dt

        -- Увеличение счета при прохождении труб
        if pipe.x + pipe.width < bird.x and not pipe.passed then
            score = score + 1
            pipe.passed = true
        end
    end

    -- Удаление труб, вышедших за пределы экрана
    for i = #pipes, 1, -1 do
        if pipes[i].x + pipes[i].width < 0 then table.remove(pipes, i) end
    end
end

function love.keypressed(key)
    -- Прыжок при нажатии на пробел
    if key == "space" then bird.velocity = jumpHeight end
end

function love.draw()
    -- Отрисовка птицы
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", bird.x, bird.y, bird.width, bird.height)

    -- Отрисовка труб
    for i, pipe in ipairs(pipes) do
        love.graphics.rectangle("fill", pipe.x, 0, pipe.width, pipe.topHeight)
        love.graphics.rectangle("fill", pipe.x, pipe.bottomY, pipe.width,
                                pipe.bottomHeight)
    end

    -- Отрисовка счета
    love.graphics.setFont(font)
    love.graphics.print("Score: " .. score, 10, 10)
end

function spawnPipe()
    local pipeSpace = 150
    local gapHeight = 100
    local pipeHeight = love.math.random(50, love.graphics.getHeight() -
                                            gapHeight - 50)
    local pipe = {
        x = love.graphics.getWidth(),
        topHeight = pipeHeight,
        bottomY = pipeHeight + gapHeight,
        bottomHeight = love.graphics.getHeight() - (pipeHeight + gapHeight),
        width = 50,
        passed = false
    }
    table.insert(pipes, pipe)
end

function checkCollision(a, b)
    return a.x < b.x + b.width and a.x + a.width > b.x and a.y < b.topHeight or
               a.y + a.height > b.bottomY
end
