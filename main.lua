-- Four Way Shootout

function love.load()
  
  bg = love.graphics.newImage("Sprites/bg.png")
  asteroidTexture = love.graphics.newImage("Sprites/asteroid.png")
  spaceshipTexture = love.graphics.newImage("Sprites/spaceship.png")
  
  music = love.audio.newSource("Audio/FutureSpace.wav")
  music:setVolume(0.3)
  music:setLooping(true)
  
  shootSound = love.audio.newSource("Audio/Shoot.wav", "static")
  shootSound:setVolume(0.5)
  
  asteroidExplosion = love.audio.newSource("Audio/AsteroidExplosion.wav", "static")
  asteroidExplosion:setVolume(0.5)
  
  playerExplosion = love.audio.newSource("Audio/PlayerExplosion.wav")
  asteroidExplosion:setVolume(0.7)
  
  state = {start = 0, play = 1, pause = 2, win = 3, lose = 4}
  state = 0
  levelNumber = 1
  score = 0
  waitTime = 3
	
	hero = {} -- new table for the hero
	hero.x = 300	-- x,y coordinates of the hero
	hero.y = 450
	hero.width = 30
	hero.height = 30
	hero.speed = 400
	hero.shots = {} -- holds our fired shots
  hero.shots.width = 5
  hero.shots.height = 5
  hero.position = {up = 0, left = 1, down = 2, right = 3}  -- stores the position the player is facing
  
  enemies = {}
  
  for i=0, (levelNumber * 3) do
		enemy = {}
		enemy.width = 40
		enemy.height = 40
		enemy.x = math.random(0, love.graphics.getWidth())
		enemy.y = enemy.height + 100
    enemy.moveX = math.random(-200, 200) 
    enemy.moveY = math.random(-200, 200) 
		table.insert(enemies, enemy)
	end
  
end

function reload()
  
  waitTime = 3
  hero.x = 300	-- x,y coordinates of the hero
	hero.y = 450
  
  for i=0, (levelNumber * 3) do
		enemy = {}
		enemy.width = 40
		enemy.height = 40
		enemy.x = math.random(0, love.graphics.getWidth())
		enemy.y = enemy.height + 100
    enemy.moveX = math.random(-200, 200) 
    enemy.moveY = math.random(-200, 200) 
		table.insert(enemies, enemy)
	end
  
end

function love.keypressed(key)
  
  if (state == 0) then
    if (key == "space") then
      state = 3
    end
  elseif (state == 1) then
    if (key == "space") then
      shoot()
    end
    
    if (key == "p") then
      state = 2
    end
  
  elseif (state == 2) then
    if (key == "p") then
      state = 1
    end
  
  elseif (state == 4) then
    if (key == "space") then
      score = 0
      reload()
      state = 1
    end
  end
end

function love.update(dt)
  
  local remEnemy = {}
	local remShot = {}
  
  if (state == 0) then
    
    music:stop()
    
  elseif (state == 1) then
    
    music:play()
    
    -- WASD controls for player
    if not (hero.y <= 0) then
      if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        hero.y = hero.y - hero.speed * dt
        hero.position = 0
      end
    end
  
    if not (hero.x <= 0) then
      if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
      hero.x = hero.x - hero.speed * dt
      hero.position = 1
      end
    end
  
    if not ((hero.y + hero.height) >= love.graphics.getHeight()) then
      if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        hero.y = hero.y + hero.speed * dt
        hero.position = 2
      end
    end
  
    if not ((hero.x + hero.width) >= love.graphics.getWidth()) then
      if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        hero.x = hero.x + hero.speed * dt
        hero.position = 3
      end
    end
  
    -- update the shots
    for i,v in ipairs(hero.shots) do
    
      if hero.position == 0 then   -- move shots up
        v.y = v.y - dt * 800
      elseif hero.position == 1 then   -- move shots left
        v.x = v.x - dt * 800
      elseif hero.position == 2 then   -- move shots down
        v.y = v.y + dt * 800
      elseif hero.position == 3 then   -- move shots right
        v.x = v.x + dt * 800
      end
		
      -- mark shots that are not visible for removal
      if v.y < 0 or v.y > love.graphics.getHeight() or v.x < 0 or v.x > love.graphics.getWidth() then
        table.insert(remShot, i)
      end
		
      -- check for collision with enemies
      for ii,vv in ipairs(enemies) do
        if CheckCollision(v.x,v.y,2,5,vv.x,vv.y,vv.width,vv.height) then
				
          -- mark that enemy for removal
          table.insert(remEnemy, ii)
          -- mark the shot to be removed
          table.insert(remShot, i)
          
          score = score + (10 * levelNumber)
          
          if asteroidExplosion:isPlaying() then
            asteroidExplosion:stop()
            asteroidExplosion:play()
          else
            asteroidExplosion:play()
          end
				
        end
      end
		    
    end

    -- update enemies
    for i,v in ipairs(enemies) do
      -- move the enemies
      v.x = v.x + dt * v.moveX
      v.y = v.y + dt * v.moveY
    
      if ((v.y + v.height) >= love.graphics.getHeight())  then
        v.moveY = -200
      end
    
      if ((v.x + v.width) >= love.graphics.getWidth()) then
        v.moveX = -200
      end
      
      if (v.x <= 0) then
        v.moveX = 200
      end
      
      if (v.y <= 0) then
        v.moveY = 200
      end
      
      
    
      -- check collision between player and enemies
      if CheckCollision(v.x,v.y,v.width,v.height,hero.x,hero.y,hero.width,hero.height) then
        
        playerExplosion:play()
        state = 4
        levelNumber = 1
          
      end
      
    end
    
    if next(enemies) == nil then
      table.insert(remShot, i)
      levelNumber = levelNumber + 1
      state = 3
    end
  elseif (state == 2) then
    
    music:pause()
    
  elseif (state == 3) then
    
    waitTime = waitTime - dt
    
    if waitTime < 0 then
      reload()
      state = 1
    end
  
  elseif (state == 4) then
  
    music:stop()
  
    for i,v in ipairs(enemies) do        
        -- mark that enemy for removal
        table.insert(remEnemy, i)
    end
    
  end
  
  -- remove the marked enemies
	for i,v in ipairs(remEnemy) do
		table.remove(enemies, v)
	end
	
  -- remove the shot that killed the enemy
	for i,v in ipairs(remShot) do
		table.remove(hero.shots, v)
	end

end


function love.draw()
  font = love.graphics.setNewFont("Fonts/Gameplay.ttf", 20)
  
	-- background
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(bg)
  
  if (state == 0) then
    love.graphics.setColor(255,255,0,255)
    love.graphics.print("Four Way Shootout", (love.graphics.getWidth() / 2) - 120, (love.graphics.getHeight() / 2) - 100, 0, 1, 1, 0, 0)
    love.graphics.print("Press -SPACE- to start", (love.graphics.getWidth() / 2) - 150, (love.graphics.getHeight() / 2) - 20, 0, 1, 1, 0, 0)
  elseif (state == 1) then
  
    -- player
    love.graphics.draw(spaceshipTexture, hero.x, hero.y, 0, 1, 1, 0, 0)
  
    -- shots
    love.graphics.setColor(255,255,255,255)
    for i,v in ipairs(hero.shots) do
      love.graphics.rectangle("fill", v.x, v.y, hero.shots.width, hero.shots.height)
    end
  
    -- enemies
    for i,v in ipairs(enemies) do
      love.graphics.draw(asteroidTexture, v.x, v.y, 0, 1, 1, 0, 0)
    end
    
    love.graphics.setColor(255,255,0,255)
    love.graphics.print("Score: " .. tostring(score), 1, 1, 0, 1, 1, 0, 0)
    
  elseif (state == 2) then
    love.graphics.setColor(255,255,0,255)
    love.graphics.print("PAUSE", (love.graphics.getWidth() / 2) - 40, (love.graphics.getHeight() / 2) - 50, 0, 1, 1, 0, 0)
    
  elseif (state == 3) then
    love.graphics.setColor(255,255,0,255)
    love.graphics.print("Level " .. tostring(levelNumber), (love.graphics.getWidth() / 2) - 70, (love.graphics.getHeight() / 2) - 50, 0, 1, 1, 0, 0)
    love.graphics.print("Score: " .. tostring(score), 1, 1, 0, 1, 1, 0, 0)
    
  elseif (state == 4) then
    love.graphics.setColor(255,0,0,255)
    love.graphics.print("GAME OVER", (love.graphics.getWidth() / 2) - 80, (love.graphics.getHeight() / 2) - 50, 0, 1, 1, 0, 0)
    love.graphics.print("Press -SPACE- to Restart", (love.graphics.getWidth() / 2) - 180, (love.graphics.getHeight() / 2) - 20, 0, 1, 1, 0, 0)
    love.graphics.print("Score: " .. tostring(score), 1, 1, 0, 1, 1, 0, 0)
  end
  
 end

function shoot()

	local shot = {}
	shot.x = hero.x+hero.width/2
	shot.y = hero.y
	
  if table.getn(hero.shots) < 1 then
    table.insert(hero.shots, shot)
    shootSound:play()
  end
	
end

-- Collision detection
function CheckCollision(ax1,ay1,aw,ah, bx1,by1,bw,bh)
  
  --local dist = (ax1 - bx1)^2 + (ay1 - by1)^2
  --return dist <= ((aw / 2) + (bw / 2))^2

  local ax2,ay2,bx2,by2 = ax1 + aw, ay1 + ah, bx1 + bw, by1 + bh
  return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1
end