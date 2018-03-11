require("professor")

function love.load()
  money = 1000
  lives = 5
  gridVal = {}

  grid = {}
  grid.nRows = 10
  grid.nCols = 15
  grid.topY = 100
  grid.topX = 100

  arraySize = grid.nCols * grid.nRows


  file = io.open("assets/map/map1.txt")
  data = file:read("*a")
  data = data:gsub('%W', '')
  map = {}
  direction = {}

  difficulty = 2

  for i = 0, arraySize - 1 do
    map[i] = string.sub(data, i+1, i+1)
    direction[i] = string.sub(data, arraySize + i + 1, arraySize + i + 1)
    gridVal[i] = {} -- map[i] -- Value 1: Buildable, 2: Path
    gridVal[i].path = tonumber(map[i])
    gridVal[i].direction = tonumber(direction[i])
    gridVal[i].hover = 0
  end

  cell = {}
  cell.h = 40
  cell.w = 40

  images = {}
  images.background = love.graphics.newImage("assets/images/wall.jpg")
  images.wizard = love.graphics.newImage("assets/images/wizard.png")
  images.student = love.graphics.newImage("assets/images/StudentL.png")
  images.studentR = love.graphics.newImage("assets/images/StudentR.png")
  images.book = love.graphics.newImage("assets/images/book.png")
  images.prof = love.graphics.newImage("assets/images/professorL.png")
  images.pavement = love.graphics.newImage("assets/images/pavement.png")

  buildProf = true

  students = {}
  profs = {}
  missiles = {}

  local student = {}
  student.dir = 3
  student.x = 640
  student.y = 440

  student.moveSpeed = math.random(1.0, 2.0)
  student.HP = 100

  table.insert(students, student)
end

function checkInside(i, x, y)
  return
    (x >= (grid.topX + ((i % grid.nCols) * cell.w))) and
    (x < grid.topX + ((i % grid.nCols) * cell.w) + 40) and
    (y >= grid.topY + ((math.floor (i / grid.nCols)) * cell.h)) and
    (y < grid.topY + ((math.floor (i / grid.nCols)) * cell.h) + 40)
end

function checkCircleInside(i, x, y)
  return
    (x - 15 >= (grid.topX + ((i % grid.nCols) * cell.w))) and
    (x + 15< grid.topX + ((i % grid.nCols) * cell.w) + 40) and
    (y - 15 >= grid.topY + ((math.floor (i / grid.nCols)) * cell.h)) and
    (y + 15 < grid.topY + ((math.floor (i / grid.nCols)) * cell.h) + 40)
end

function pixelX(i)
  return grid.topX + ((i % grid.nCols) * cell.w)
end

function pixelY(i)
  return grid.topY + ((math.floor (i / grid.nCols)) * cell.h)
end

function getClosestStudent(prof, students)
  local index = 0
  local distance = 10000

  for i = #students, 1, -1 do
    newD = math.sqrt((prof.x - students[i].x)^2 + (prof.y - students[i].y)^2)
    if newD < distance then
      distance = newD
      index = i
    end
  end

  return index, distance
end

function love.update(dt)
  for i = #students, 1, -1 do
    if students[i].HP <= 0 then
      table.remove(students, i)
      for j = #missiles, 1, -1 do
        if missiles[j].target == i then
          table.remove(missiles, j)
        end
      end
    end
  end
  for i = #students, 1, -1 do
    if students[i].y < 100 then
      table.remove(students, i)
      lives = lives - 1
      for j = #missiles, 1, -1 do
        if missiles[j].target == i then
          table.remove(missiles, j)
        end
      end
    end
  end
  if #students > 0 then
    for i = #missiles, 1, -1 do
      local xD = (students[missiles[i].target].x - missiles[i].x)
      local yD = (students[missiles[i].target].y - missiles[i].y)
      missiles[i].x = missiles[i].x + xD * 0.1
      missiles[i].y = missiles[i].y + yD * 0.1
      if math.sqrt(xD^2 + yD^2) < 30  then
        students[missiles[i].target].alive = false
        money = money + 100
        students[missiles[i].target].HP = students[missiles[i].target].HP - 25
        table.remove(missiles, i)
      end
    end
  end

  if money > 500 and love.mouse.isDown(1) and buildProf == true then
    local x, y = love.mouse.getPosition()
    for i = 0, arraySize - 1 do
      if checkInside (i, x, y) then
        local mProfessor = Professor:new(pixelX(i), pixelY(i))
        table.insert(profs, mProfessor)
        gridVal[i].build = 1
        money = money - 500
      end
    end
  end

  if buildProf == true then
    local x, y = love.mouse.getPosition()
    for i = 0, arraySize - 1 do
      if checkInside (i, x, y) then
        gridVal[i].hover = 1
      else
        gridVal[i].hover = 0
      end
    end
  end

  if math.random(0, 100) < difficulty then
    local student = {}
    student.dir = 3
    student.x = 640
    student.y = 440

    student.alive = true

    student.moveSpeed = math.random(1.0, 2.0)
    student.HP = 100

    table.insert(students, student)
  end

  difficulty = difficulty + 0.001

  for i = #students, 1, -1 do
    for j = 0, arraySize - 1 do
      if checkCircleInside (j, students[i].x, students[i].y) then
        students[i].dir = gridVal[j].direction
      end
    end

    local deltaY, deltaX = 0, 0

    if students[i].dir == 3 then
      deltaX = -1
    elseif students[i].dir == 4 then
      deltaX = 1
    elseif students[i].dir == 2 then
      deltaY = 1
    elseif students[i].dir == 1 then
      deltaY = -1
    end

    students[i].x = students[i].x + (deltaX * students[i].moveSpeed)
    students[i].y = students[i].y + (deltaY * students[i].moveSpeed)
  end

  for i = #profs, 1, -1 do
    index, distance = getClosestStudent(profs[i], students)
    if profs[i].counter == 0 and distance < profs[i].range then
      profs[i].counter = 50

      local mMissile = {}
      mMissile.x = profs[i].x
      mMissile.y = profs[i].y
      mMissile.target = index

      table.insert(missiles, mMissile)
    else
      if profs[i].counter > 0 then
        profs[i].counter = profs[i].counter - 1
      end
    end
  end
end

function love.draw()

  for i = 0, arraySize - 1 do
    love.graphics.setColor(100, 100, 100)
    love.graphics.draw(images.pavement, pixelX(i), pixelY(i), 0, 0.2, 0.2)

    if gridVal[i].hover == 1 then
      love.graphics.setColor(255, 0, 0, 100)
      love.graphics.rectangle('fill', pixelX(i), pixelY(i), 40, 40)
    end

    if gridVal[i].build == 1 then
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.draw(images.prof, pixelX(i), pixelY(i), 0, 0.2, 0.2)
    end

    if gridVal[i].path == 1 then
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.rectangle('fill', pixelX(i), pixelY(i), 40, 40)
      love.graphics.draw(images.background, pixelX(i), pixelY(i), 0, 0.4, 0.4)
      love.graphics.setColor(0, 0, 0, 255)
    end

    for i = #students, 1, -1 do
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.setColor(255, 255, 255, 255)

      img = images.student
      if students[i].dir == 4 then
        img = images.studentR
      end
      love.graphics.draw(img, students[i].x - 15, students[i].y - 25, 0, 0.15, 0.15)
    end
  end

  for i = #missiles, 1, -1 do
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(images.book, missiles[i].x, missiles[i].y, 0, 0.1, 0.1)
  end

  love.graphics.print('Money: ' .. money, 0, 0)
  love.graphics.print('Lives: ' .. lives, 700, 0)
  love.graphics.print('Difficulty: '.. difficulty, 350, 0)
end
