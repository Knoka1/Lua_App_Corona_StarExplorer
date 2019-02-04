
local composer = require('composer')

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via 'composer.removeScene()"
-- -----------------------------------------------------------------------------------
local physics = require('physics')
physics.start()
physics.setGravity(0, 0)

local sheetOptions =
{
    frames =
    {
        {   -- 1.asteroid 1
            x = 0,
            y = 0,
            width = 102,
            height = 85
        },
        {   -- 2.asteroid 2
            x = 0,
            y = 85,
            width = 90,
            height = 83
        },
        {   -- 3.asteroid 3
            x = 0,
            y = 168,
            width = 100,
            height = 97
        },
        {   -- 4.ship
            x = 0,
            y = 265,
            width = 98,
            height = 79
        },
        {   -- 5.laser
            x = 98,
            y = 265,
            width = 14,
            height = 40
        },
    },
}
local objectSheet = graphics.newImageSheet('gameObjects.png', sheetOptions)

--Setting up variables
local lives = 3
local score = 0
local died = false

local asteroidsTable = {}

local explosion_effect
local ship
local gameLoopTimer
local livesText
local scoreText
local resumeButton
local menuButton
local starGod--First boss
local galaxyConqueror--Second boss
bossActive = false
--MUSIC AND SOUND
local backgroundMusic = audio.loadStream('The Process.wav') -- Setting up BG music
local hitSound = audio.loadSound('explosion.wav') -- Ship got hit sound
local audioOn = true--tell the game weather sound is on or not
paused = false--tells the paused condition of the game
local displayAudioOn
local displayAudioOff

local backGroup
local mainGroup
local uiGroup

local mov = 0--Define movimento ida e volta atirando(mov1 = ida direita)
local pos = 50
audio.play(backgroundMusic, {channel = 1})
audio.setVolume(0.5, {channel = 1})
local function endGame()
   composer.setVariable('finalScore', score)
   composer.gotoScene('highscores', {time = 800, effect = 'crossFade'})
end

local function updateText()
	livesText.text = 'Lives: ' .. lives
	scoreText.text = 'Score: ' .. score
end

local function createAsteroid()
  
  local newAsteroid = display.newImageRect(mainGroup, objectSheet, 1, 102, 85)
  table.insert(asteroidsTable, newAsteroid)
  physics.addBody(newAsteroid, 'dynamic', {radius = 40, bounce = 0.8})
  newAsteroid.myName = 'asteroid'
  
  local whereFrom = math.random(3)
  if whereFrom == 1 then
    --Left corner
    newAsteroid.x = -60
    newAsteroid.y = math.random(500) 
    newAsteroid:setLinearVelocity(math.random(40, 120), math.random(20, 60))
  elseif whereFrom == 2 then
    --Top
    newAsteroid.x = math.random(display.contentWidth)
    newAsteroid.y = -60
    newAsteroid:setLinearVelocity(math.random(-40, 40), math.random(40, 120))
  elseif whereFrom == 3 then
    --Right corner
    newAsteroid.x = display.contentWidth + 60 
    newAsteroid.y = math.random(500)
    newAsteroid:setLinearVelocity(math.random(-120, -40), math.random(20, 60))
  end
  newAsteroid:applyTorque(math.random(-6, 6))
end

--BOSS FIGHT 1
function bossRockets()
  local newRocket = display.newImageRect(mainGroup, 'spaceMissiles_018.png', 14, 40)
  newRocket.rotation = 180
  physics.addBody(newRocket, 'dynamic', {isSensor = true})
  newRocket.isBullet = true
  newRocket.myName = 'rocket'
  newRocket.x = starGod.x
  newRocket.y = starGod.y
  newRocket:toBack() --Back in comparison to the display group
  transition.to(newRocket, {y = display.contentHeight + 40, time = 5000,
      onComplete = function() display.remove(newRocket) end
        })
end

function bossMove()--Move from posIni
      if starGod.x >= (display.contentWidth - starGod.width - 90) then
        pos = -50
        mov = mov + 1
      end
      if starGod.x <= 150 then
        pos = 50
        mov = mov + 1
      end
      if mov >= 3 then
        timer.cancel(bossPattern1timer) 
        transition.to(starGod, {x = display.contentCenterX, time == 1000})--TRANSITIONS SE ATRAPALHAM(tem que haver um tempo para que não se interrompam)
      else
        transition.to(starGod, {x = starGod.x + pos, time == 1000, 
            onComplete = function()
              local shotNum2 = 2
              while shotNum2 > 0 do 
                bossRockets() 
                shotNum2 = shotNum2 - 1
              end
        end})
      end
end

function bossPattern1(posIni)--Move from posIni all the way to the right and goes to left
  if bossHealth>0 then
    transition.to(starGod, {x = posIni, time == 1000, onComplete = function()
      pos = 50
      mov = 0--move qtde de movimentos
      bossPattern1timer = timer.performWithDelay(1000, bossMove, 0)
    end})
    bossRockets()
    
  end
end

function bossPattern2()--Boss behaviour and shooting pattern 2 STAGE

end

function bossPattern3()--Boss behaviour and shooting pattern 3 STAGE

end

function boss1AI()--Activates boss responses and patterns
  timer.cancel(boss1AItimer)
  if not bossActive then
    bossActive = true --Tells the game if a boss is currently active
    physics.addBody(starGod, {radius = 35, isSensor=true})
    starGod.myName = 'starGod'
  end
  if bossHealth>0 then
    bossPattern1(150)
  --elseif bossHealth>33 and bossHealth<66 then
    --bossPattern2()
  --else
    --bossPattern3()
  end
end

function bossFight1()--Activates the BossFight1 and loops the bossAI1
  bossHealth = 100
  timer.cancel(bossFight1Timer)
  timer.cancel(gameLoopTimer)
  starGod = display.newImageRect(mainGroup, 'spaceShips_007.png', 110, 90)
  starGod.x = display.contentCenterX
  starGod.y = -500
  transition.to(starGod, {y = starGod.height + 50, time = 3000, onComplete = function() boss1AItimer = timer.performWithDelay(3000, boss1AI,0)--Chama uma única vez a AI se não zera a posição do boss e buga
        end})
end--PENDENTE ADICIONAR COLISÃO DO BOSS NA FUNÇÃO onCollision!!!!!!!!!!!!!!!!!!!!!ATENÇÃO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--END OF BOSS FIGHT 1

local function displayRandom_explosions() --Randomizes the explosion effect shown when the ship gets hit and deals with its image
    local z = math.random(7)
    if z == 1 then
      explosion_effect00 = display.newImageRect('explosion00.png', 400, 500)
      explosion_effect00.x = ship.x
      explosion_effect00.y = ship.y
      transition.to(explosion_effect00, {
        time == 2000, alpha = 0, onComplete = function()
        display.remove(explosion_effect00) 
      end})
    elseif z == 2 then
      explosion_effect01 = display.newImageRect('explosion01.png', 400, 500)
      explosion_effect01.x = ship.x
      explosion_effect01.y = ship.y
      transition.to(explosion_effect01, {
        time == 2000, alpha = 0, onComplete = function()
        display.remove(explosion_effect01) 
      end})
    elseif z == 3 then
      explosion_effect02 = display.newImageRect('explosion02.png', 400, 500)
      explosion_effect02.x = ship.x
      explosion_effect02.y = ship.y
      transition.to(explosion_effect02, {
        time == 2000, alpha = 0, onComplete = function()
        display.remove(explosion_effect02) 
      end})
    elseif z == 4 then
      explosion_effect03 = display.newImageRect('explosion03.png', 400, 500)
      explosion_effect03.x = ship.x
      explosion_effect03.y = ship.y
      transition.to(explosion_effect03, {
        time == 2000, alpha = 0, onComplete = function()
        display.remove(explosion_effect03) 
      end})
    elseif z == 5 then
      explosion_effect04 = display.newImageRect('explosion04.png', 400, 500)
      explosion_effect04.x = ship.x
      explosion_effect04.y = ship.y
      transition.to(explosion_effect04, {
        time == 2000, alpha = 0, onComplete = function()
        display.remove(explosion_effect04) 
      end})
    elseif z == 6 then
      explosion_effect05 = display.newImageRect('explosion05.png', 400, 500)
      explosion_effect05.x = ship.x
      explosion_effect05.y = ship.y
      transition.to(explosion_effect05, {
        time == 2000, alpha = 0, onComplete = function()
        display.remove(explosion_effect05) 
      end})
    elseif z == 7 then
      explosion_effect06 = display.newImageRect('explosion06.png', 400, 500)
      explosion_effect06.x = ship.x
      explosion_effect06.y = ship.y
      transition.to(explosion_effect06, {
        time == 2000, alpha = 0, onComplete = function()
        display.remove(explosion_effect06) 
      end})
    end
  end

local function fireLaser()
  local newLaser = display.newImageRect(mainGroup, objectSheet, 5, 14, 40)
  physics.addBody(newLaser, 'dynamic', {isSensor = true})
  newLaser.isBullet = true
  newLaser.myName = 'laser'
  newLaser.x = ship.x
  newLaser.y = ship.y
  newLaser:toBack() --Back in comparison to the display group
  transition.to(newLaser, {y=-40, time = 500,
      onComplete = function() display.remove(newLaser) end
        })
end

local function dragShip(event)
 
    local ship = event.target
    local phase = event.phase
 
    if 'began' == phase then
      -- Set touch focus on the ship
      display.currentStage:setFocus(ship)
      -- Store initial offset position
      ship.touchOffsetX = event.x - ship.x
 
    elseif 'moved' == phase then
      -- Move the ship to the new touch position
      ship.x = event.x - ship.touchOffsetX
      if ship.x + ship.width > display.contentWidth then
        ship.x = display.contentWidth-ship.width
      elseif ship.x < ship.width then
        ship.x = ship.width
      end
    elseif 'ended' == phase or 'cancelled' == phase then
      -- Release touch focus on the ship
      display.currentStage:setFocus(nil)
    end
    return true  -- Prevents touch propagation to underlying objects
end
 
local function gameLoop()
    -- Create new asteroids
    createAsteroid()
    -- Remove asteroids off screen
    for i = #asteroidsTable, 1, -1 do
        local thisAsteroid = asteroidsTable[i]
 
        if thisAsteroid.x < -100 or
             thisAsteroid.x > display.contentWidth + 100 or
             thisAsteroid.y < -100 or
             thisAsteroid.y > display.contentHeight + 100
        then
            display.remove(thisAsteroid)
            table.remove(asteroidsTable, i)
        end
    end
end
 
local function restoreShip()
 
    ship.isBodyActive = false
    ship.x = display.contentCenterX
    ship.y = display.contentHeight - 100
 
    -- Fade in the ship
    transition.to(ship, { alpha=1, time=4000,
        onComplete = function()
            ship.isBodyActive = true
            died = false
        end
    } )
end
 
local function onCollision(event)
 
    if event.phase == 'began' then
 
        local obj1 = event.object1
        local obj2 = event.object2
        
        if obj1.myName == 'laser' and obj2.myName == 'asteroid' or
             obj1.myName == 'asteroid' and obj2.myName == 'laser'
        then
            -- Remove both the laser and asteroid
            display.remove(obj1)
            display.remove(obj2)
 
            for i = #asteroidsTable, 1, -1 do
                if asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 then
                    table.remove(asteroidsTable, i)
                    break
                end
            end
 
            -- Increase score
            score = score + 100
            scoreText.text = 'Score: ' .. score
 
        elseif obj1.myName == 'ship' and obj2.myName == 'asteroid' or
                 obj1.myName == 'asteroid' and obj2.myName == 'ship'
        then
          audio.play(hitSound, {channel = 2})-- Ship gets hit
          displayRandom_explosions()
            if died == false then
                died = true
 
                -- Update lives
                lives = lives - 1
                livesText.text = 'Lives: ' .. lives
 
                if lives == 0 then
                    display.remove(ship)
                    timer.performWithDelay(2000, endGame)
                else
                    ship.alpha = 0
                    timer.performWithDelay(1000, restoreShip)
                end
            end
        end
    end
end

--PAUSE FUNCTION
function audioControl(event)--Sets all game sound on/off
  if event.phase == 'began' then
    if audioOn then
      audio.setVolume(0, {channel = 1})
      audio.setVolume(0, {channel = 2})
      displayAudioOn:removeSelf()
      displayAudioOff = display.newImageRect(uiGroup, 'audioOff.png', 100, 100)
      displayAudioOff.x = 150
      displayAudioOff.y = 950
      displayAudioOn:removeEventListener('touch', audioControl)
      displayAudioOff:addEventListener('touch', audioControl)
      audioOn = false
    else
      audio.setVolume(0.5, {channel = 1})
      audio.setVolume(1, {channel = 2})
      displayAudioOff:removeSelf()
      displayAudioOn = display.newImageRect(uiGroup, 'audioOn.png', 100, 100)
      displayAudioOn.x = 150
      displayAudioOn.y = 950
      displayAudioOff:removeEventListener('touch', audioControl)
      displayAudioOn:addEventListener('touch', audioControl)
      audioOn = true
    end
  end
end

function resumeGame(event)--Resume game and delete the entire pause screen
  if event.phase == 'began' then
    resumeButton:removeSelf()
    menuButton:removeSelf()
    resumeButton:removeEventListener('touch', resumeGame)
    menuButton:removeEventListener('tap', endGame)
    pauseButton:addEventListener('touch', pauseGame)
    ship:addEventListener('tap',fireLaser)
    ship:addEventListener('touch',dragShip)
    if bossActive == false then
      gameLoopTimer = timer.performWithDelay(500, gameLoop, 0)
    end
    if audioOn then
      displayAudioOn:removeSelf()
    else
      displayAudioOff:removeSelf()
    end
    physics.start()
    paused = false
  end
end

function pauseGame(event)--Creates the pause screen and pauses game
  if event.phase == 'began' then
    physics.pause()
    resumeButton = display.newText(uiGroup, 'Resume', display.contentCenterX, 700, 'Kenney Future Narrow.ttf', 56)
    menuButton =  display.newText(uiGroup, 'Exit', display.contentCenterX, 600, 'Kenney Future Narrow.ttf', 44)
    if audioOn then
      displayAudioOn = display.newImageRect(uiGroup, 'audioOn.png',100, 100)
      displayAudioOn.x = 150
      displayAudioOn.y = 950
      displayAudioOn:addEventListener('touch', audioControl)
    else
      displayAudioOff = display.newImageRect(uiGroup, 'audioOff.png', 100, 100)
      displayAudioOff.x = 150
      displayAudioOff.y = 950
      displayAudioOff:addEventListener('touch', audioControl)
    end
    paused = true
    menuButton:addEventListener('tap', endGame)
    resumeButton:addEventListener('touch', resumeGame)
    pauseButton:removeEventListener('touch', pauseGame)
    ship:removeEventListener('tap',fireLaser)
    ship:removeEventListener('touch',dragShip)
    timer.cancel(gameLoopTimer)
  end
end
--END OF PAUSE FUNCTION

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

  physics.pause()

  backGroup = display.newGroup()
  sceneGroup:insert(backGroup)
  mainGroup = display.newGroup()
  sceneGroup:insert(mainGroup)
  uiGroup = display.newGroup()
  sceneGroup:insert(uiGroup)
  
  pauseButton = display.newImageRect(uiGroup, 'pause.png', 90, 90)
  pauseButton.x = 610
  pauseButton.y = 80
  pauseButton.alpha = 0.8
  pauseButton:addEventListener('touch', pauseGame)
  
  local background = display.newImageRect(backGroup, 'background.png', 800, 1400)
  background.x = display.contentCenterX
  background.y = display.contentCenterY

  ship = display.newImageRect(mainGroup, objectSheet, 4, 98, 79)
  ship.x = display.contentCenterX
  ship.y = display.contentHeight - 100
  physics.addBody(ship, {radius=30, isSensor=true})
  ship.myName = 'ship'
-- Display lives and score
  livesText = display.newText(uiGroup, 'Lives: ' .. lives, 200, 80, 'Kenney Future Narrow.ttf', 36)
  livesText.alpha = 0.8
  scoreText = display.newText(uiGroup, 'Score: ' .. score, 450, 80, 'Kenney Future Narrow.ttf', 36)
  scoreText.alpha = 0.8
  ship:addEventListener('tap',fireLaser)
  ship:addEventListener('touch',dragShip)
end


-- show()
function scene:show(event)

	local sceneGroup = self.view
	local phase = event.phase

	if (phase == 'will') then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
  
	elseif (phase == 'did') then
		-- Code here runs when the scene is entirely on screen
    physics.start()
    Runtime:addEventListener('collision', onCollision)
    gameLoopTimer = timer.performWithDelay(500, gameLoop, 0)
    --bossFight1Timer = timer.performWithDelay(1000, bossFight1, 0)
  end
end


-- hide()
function scene:hide(event)

	local sceneGroup = self.view
	local phase = event.phase

	if (phase == 'will') then
		-- Code here runs when the scene is on screen (but is about to go off screen)
    timer.cancel(gameLoopTimer)

	elseif (phase == 'did') then
		-- Code here runs immediately after the scene goes entirely off screen
    Runtime:removeEventListener('collision', onCollision)
    physics.pause()
    composer.removeScene('game')

	end
end


-- destroy()
function scene:destroy(event)

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
  audio.stop(1)
  audio.stop(2)
  audio.dispose(hitSound)
  audio.dispose(backgroundMusic)
  
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener('create', scene)
scene:addEventListener('show', scene)
scene:addEventListener('hide', scene)
scene:addEventListener('destroy', scene)
-- -----------------------------------------------------------------------------------

return scene
