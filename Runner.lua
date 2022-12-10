function GetSpriteSheet(sheet) 
	return gdt.ROM.User.SpriteSheets[sheet]
end

local isAlive = false
local cloudPos = 20
local obstaclePos = 0
local currentObstacle = {}
local score = 1
local scoreMultiplier = 1
local godMode = false
local playerYPos = 0
local jumpSpeed = 100
local gravity = -9
local targetYPos = 0 
local interpolationFactor = 0.1
local highscores = {}

local Render:VideoChip = gdt.VideoChip0
local ScoreDisplay:LcdDisplay = gdt.Lcd0
local AButton:LedButton = gdt.LedButton2
local BButton:LedButton = gdt.LedButton3
local Mem:FlashMemory = gdt.FlashMemory0
local screenHeight = gdt.Screen0.Height * 3
local screenWidth = gdt.Screen0.Width * 2
local spriteFont = gdt.ROM.System.SpriteSheets["StandardFont"]

local DebugDisplay:VideoChip = gdt.VideoChip1
local DebugKillButton:LedButton = gdt.LedButton5
local DebugGodModeButton:LedButton = gdt.LedButton4
local DebugClearScoresButton:LedButton = gdt.LedButton6
local DebugScoreMultiplierSlider:Slider = gdt.Slider0

Obstacles = {"Box", "DoubleBox","Bird", "DoubleBird"}
Buttons = {AButton, BButton}

function DrawMainMenu()
    DrawDebugInfo()
    Render:Clear(color.black)
    Render:DrawText(vec2(50, screenHeight / 2 - 15), spriteFont, "Runner", color.red, color.black)
    Render:DrawText(vec2(20, screenHeight / 2), spriteFont, "Press any button!", color.white, color.black)
    if isAlive == false and score > 0 then 
        table.insert(highscores,score)
        Mem:Save(highscores)
        log("Saved new Highscore:" .. tostring(score))
        log("New tablelen:" ..tostring(GetTableLng(highscores)))
        score = 0
    end
    for i, button in ipairs(Buttons) do
        if button.ButtonState == true then
            isAlive = true;
        end
    end
end

function MainGameLoop()
    DrawDebugInfo()
    highscores = Mem:Load()
    Render:Clear(color.cyan)
     -- this is the position we want the player to be at
    if(AButton.ButtonState == true and playerYPos == 0)then
        targetYPos = targetYPos - jumpSpeed
    end
    if playerYPos < 0 then
        targetYPos = targetYPos - gravity
    end
    if playerYPos > 0 then
        playerYPos = 0
        targetYPos = 0
	end
    playerYPos = playerYPos + (targetYPos - playerYPos) * interpolationFactor
    DrawPlayer(playerYPos)
    DrawClouds(cloudPos)
    DrawObstacles()
    Render:FillRect(vec2(0,screenHeight),vec2(screenWidth,screenHeight / 2 + 45), color.green)
    score = score + 1 * scoreMultiplier
    ScoreDisplay.Text = "Score: "..tostring(score)
end

function DrawObstacles()
    if obstaclePos == 0 then GenerateNewObstacleList() end
    for i, obstacle in ipairs(currentObstacle) do
        Render:DrawText(vec2(obstaclePos + i * 100 + screenWidth - 100, screenHeight - 20), spriteFont, obstacle, color.black, color.white)
    end
    if obstaclePos >= -screenWidth - 2050 then
        obstaclePos = obstaclePos - 3
    else
        obstaclePos = 0
    end
end

function GenerateNewObstacleList()
    currentObstacle = {}
    for i = 0, 20 do
        index = math.random(1, GetTableLng(Obstacles))
        table.insert(currentObstacle, Obstacles[index])
    end
end

function DrawPlayer(y:number)
    Render:FillRect(vec2(5, y + 97), vec2(15, y +82), color.magenta)
end

function DrawClouds(x:number)
    --Render:FillRect(vec2(1, 1), vec2(screenWidth, screenHeight), color.cyan)
    if cloudPos >= -79 then
        cloudPos = cloudPos - 3
    else
        cloudPos = 20
    end
    for i = 0, 20 do
        Render:FillCircle(vec2(x,10), 5, color.white)
        Render:FillCircle(vec2(x + 6,11), 3, color.white)
        Render:FillCircle(vec2(x - 8,8), 4, color.white)
        x = x + 25 
    end
end

function DrawDebugInfo()
    if(gdt.MagneticConnector0.IsConnected == true)then
        DebugDisplay:Clear(color.black)
        if(DebugKillButton.ButtonUp == true) then isAlive = false end
        if(DebugGodModeButton.ButtonUp == true) then godMode = not godMode end
        if(DebugClearScoresButton.ButtonUp == true) then Mem:Save({}) log("Scores cleared!") end
        scoreMultiplier = DebugScoreMultiplierSlider.Value + 1
        DebugDisplay:DrawText(vec2(5, 5), spriteFont, "PlayerPos: " ..tostring(playerYPos), color.white, color.black)
        DebugDisplay:DrawText(vec2(5, 15), spriteFont, "Cloudpos: " ..tostring(cloudPos), color.white, color.black)
        DebugDisplay:DrawText(vec2(5, 25), spriteFont, "Obstaclepos: " ..tostring(obstaclePos), color.white, color.black)
        DebugDisplay:DrawText(vec2(5, 35), spriteFont, "IsAlive: " ..tostring(isAlive), color.white, color.black)
        DebugDisplay:DrawText(vec2(5, 45), spriteFont, "Score: " ..tostring(score), color.white, color.black)
        DebugDisplay:DrawText(vec2(5, 55), spriteFont, "ScoreMultiplier: " ..tostring(scoreMultiplier), color.white, color.black)
        DebugDisplay:DrawText(vec2(5, 65), spriteFont, "GodMode: " ..tostring(godMode), color.white, color.black)
    else
        DebugDisplay:Clear(color.black)
    end
end

function update()
    if isAlive == false then DrawMainMenu() return end
    MainGameLoop()
end

function GetTableLng(tbl)
    local getN = 0
    for n in pairs(tbl) do 
      getN = getN + 1 
    end
    return getN
end
