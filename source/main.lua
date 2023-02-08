import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"
import "glitterbomb"
import "glitterglue"

local vector2 <const> = playdate.geometry.vector2D
local gfx <const> = playdate.graphics
local screenWidth <const> = 400
local screenHeight <const> = 240

local sparkImg = gfx.image.new("spark")
local smokeSheet = gfx.imagetable.new("smokeSheet")
local sparkSheet = gfx.imagetable.new("sparkSheet")

local voice = gfx.font.new("Voice-9p-48-o")

dt = 0
lasttime = 0

local startWidth, startRate, startAngle, startSpread
local smokeSpawner, sparkSpawner, orbitSpawner, hoseSpawner, burstSpawner, shapeSpawner

local currentSpawner
local demoMode = 1
local modes

function myGameSetUp()

    sparkImg = sparkImg:scaledImage(.02)

    --can un-comment this to generate a sprite sheet
    --animating a particle's size/opacity

    -- local sparkSheetSpawner = ParticleEmitter.new(sparkImg)
    -- sparkSheetSpawner:setParticleOpacity(1,0)
    -- sparkSheetSpawner:setParticleSize(1,0)
    -- sparkSheetSpawner:setParticleLifetime(1)
    -- glueSheet(sparkSheetSpawner,"/sparkSheet.gif",30)
    
    --can either create emitters by passing a table with all the variable settings
    -- or by setting each variable manually (below)
    smokeSpawner=AnimatedParticleEmitter.new(smokeSheet)
    smokeSpawner:setNumFrames(60)
    smokeSpawner:setPosition({x=screenWidth/2,y=screenHeight/2})
    smokeSpawner:setEmissionRate(0)
    smokeSpawner:setParticleLifetime(3)
    smokeSpawner:setParticleUpdateDelay(2)
    smokeSpawner:setEmissionForce(1)
    smokeSpawner:setEmitterWidth(5.5)
    smokeSpawner:setEmissionSpread(15)
    smokeSpawner:setEmissionAngle(270)
    smokeSpawner:setGravity(0)
    smokeSpawner:setInheritVelocity(false)

    sparkSpawner=ParticleEmitter.new(sparkImg)
    sparkSpawner:setPosition({x=screenWidth/2,y=screenHeight/2})
    sparkSpawner:setEmissionRate(0)
    sparkSpawner:setParticleLifetime(1)
    sparkSpawner:setParticleUpdateDelay(2)
    sparkSpawner:setEmissionForce(7.5)
    sparkSpawner:setEmitterWidth(5.5)
    sparkSpawner:setEmissionSpread(90)
    sparkSpawner:setEmissionAngle(270)
    sparkSpawner:setGravity(9.8)
    sparkSpawner:setInheritVelocity(true)

    orbitSpawner=AnimatedParticleEmitter.new(smokeSheet)
    orbitSpawner:setNumFrames(60)
    orbitSpawner:setPosition({x=screenWidth/2,y=screenHeight/2})
    orbitSpawner:setEmissionRate(8)
    orbitSpawner:setParticleLifetime(3)
    orbitSpawner:setParticleUpdateDelay(2)
    orbitSpawner:setEmissionForce(0)
    orbitSpawner:setEmitterWidth(0)
    orbitSpawner:setEmissionSpread(0)
    orbitSpawner:setEmissionAngle(270)
    orbitSpawner:setGravity(0)
    orbitSpawner:setInheritVelocity(true)

    hoseSpawner=ParticleEmitter.new(sparkImg)
    hoseSpawner:setPosition({x=screenWidth/2,y=screenHeight/2})
    hoseSpawner:setEmissionRate(100)
    hoseSpawner:setParticleLifetime(1)
    hoseSpawner:setParticleUpdateDelay(2)
    hoseSpawner:setEmissionForce(7.5)
    hoseSpawner:setEmitterWidth(0)
    hoseSpawner:setEmissionSpread(15)
    hoseSpawner:setEmissionAngle(270)
    hoseSpawner:setGravity(9.8)
    hoseSpawner:setInheritVelocity(false)

    shapeSpawner=ShapeEmitter.new({shape = circle, filled = false, startSize = 5,endSize = 5, color = kColorBlack, lineWidth = 2})
    shapeSpawner:setPosition({x=screenWidth/2,y=screenHeight/2})
    shapeSpawner:setEmissionRate(50)
    shapeSpawner:setParticleLifetime(1)
    shapeSpawner:setParticleUpdateDelay(2)
    shapeSpawner:setEmissionForce(2)
    shapeSpawner:setEmitterWidth(0)
    shapeSpawner:setEmissionSpread(15)
    shapeSpawner:setEmissionAngle(90)
    shapeSpawner:setGravity(9.8)
    shapeSpawner:setInheritVelocity(false)

    burstSpawner=ShapeEmitter.new({shape = circle, filled = true})
    -- burstSpawner=AnimatedParticleEmitter(smokeSheet)
    -- burstSpawner:setNumFrames(60)
    burstSpawner:setPosition({x=screenWidth/2,y=screenHeight/2})
    burstSpawner:setParticleLifetime(.5)
    burstSpawner:setParticleUpdateDelay(2)
    burstSpawner:setEmissionForce(2)
    burstSpawner:setEmitterWidth(1)
    burstSpawner:setEmissionSpread(0)
    burstSpawner:setEmissionAngle(270)
    burstSpawner:setGravity(0)
    burstSpawner:setParticleSize(25,0)

    modes = {shapeSpawner,smokeSpawner,sparkSpawner,orbitSpawner,hoseSpawner, burstSpawner}
    currentSpawner = modes[demoMode]
    currentSpawner:play()
end

myGameSetUp()

--helper functions to convert crank input into emitter value changes
local function changeWidth(widthChange)
    widthChange*=2
    widthChange += currentSpawner.emitterWidth
    if widthChange < 0 then widthChange = 0 end
    currentSpawner:setEmitterWidth(widthChange)
    currentSpawner:setEmissionRate(startRate * (widthChange+1)/(startWidth+1))
end

local function changeRate(rateChange)
    rateChange *= 10
    rateChange += currentSpawner.emissionRate
    if rateChange < 0 then rateChange = 0 end
    currentSpawner:setEmissionRate(rateChange)

end

local function changeAngle(angleChange)
    angleChange*=360
    angleChange += currentSpawner.emissionAngle
    if angleChange < 0 then angleChange = 360
    elseif angleChange > 360 then angleChange = 0 end
    currentSpawner:setEmissionAngle(angleChange)
end

local function changeSpread(spreadChange)
    spreadChange*=50
    spreadChange += currentSpawner.emissionSpread
    if spreadChange < 0 then spreadChange = 0
    elseif spreadChange >= 360 then spreadChange = 0 end
    currentSpawner:setEmissionSpread(spreadChange)
    currentSpawner:setEmissionRate(startRate * (spreadChange+1)/(startSpread+1))
end

local function changeForce(forceChange)
    forceChange*=1
    forceChange += currentSpawner.emissionForce
    if forceChange < 0 then forceChange = 0 end
    currentSpawner:setEmissionForce(forceChange)
end

local function changeDelay(delayChange)
    delayChange*=1
    delayChange += currentSpawner.particleUpdateDelay
    if delayChange < 0 then delayChange = 0 end
    currentSpawner:setParticleUpdateDelay(delayChange)
end

--functions for different demo modes
local function sparkEffect(amount)
    changeRate(amount)
    if currentSpawner.emissionRate > 100 then currentSpawner.emissionRate = 100 end
end

local function smokeEffect(amount)
    changeRate(amount/4)
    if currentSpawner.emissionRate > 20 then currentSpawner.emissionRate = 20 end
end

local orbitAngle=270
local function orbitEffect(amount)
    amount*=50
    orbitAngle+=amount
    currentSpawner:setPosition({x=screenWidth/2 + math.cos(math.rad(orbitAngle))*screenHeight/4,y=screenHeight/2 + math.sin(math.rad(orbitAngle))*screenHeight/4})
end

local function hoseEffect(amount)
    changeAngle(amount)
end

local function switchModes(direction)
    currentSpawner:pause()
    demoMode+=direction
    if demoMode > #modes then demoMode = 1
    elseif demoMode < 1 then demoMode = #modes end
    currentSpawner = modes[demoMode]
    if currentSpawner == orbitSpawner then
        currentSpawner:setPosition({x=screenWidth/2,y=screenHeight/4})
    else
        currentSpawner:setPosition({x=screenWidth/2,y=screenHeight/2})
    end
    if currentSpawner ~= burstSpawner then
        currentSpawner:play()
    end
end

local function Draw()
    gfx.clear()
    for i,v in ipairs(modes) do if #v.particles+#v.burstParticles>0 then v:draw() end end
    voice:drawTextAligned("glitterbomb",screenWidth/2,screenHeight/2-40,kTextAlignment.center)
    if currentSpawner == burstSpawner then
        gfx.drawTextAligned("press a to burst",screenWidth/2,screenHeight/2+15,kTextAlignment.center)
    else
        gfx.drawTextAligned("crank to engage",screenWidth/2,screenHeight/2+15,kTextAlignment.center)
    end
    gfx.drawTextAligned(demoMode,screenWidth/2,screenHeight/2+40,kTextAlignment.center)

    playdate.drawFPS(0, 0)
    gfx.drawText(currentSpawner.emissionRate,screenWidth/2, 0)
end

local crankSpeed = 1/12
local crankChange
local crankAmount

function playdate.update()
    if playdate.buttonJustPressed( playdate.kButtonRight ) then
        switchModes(1)
	elseif playdate.buttonJustPressed( playdate.kButtonLeft ) then
        switchModes(-1)
    elseif playdate.buttonJustPressed( playdate.kButtonDown ) then
        switchModes(-1)
	elseif playdate.buttonJustPressed( playdate.kButtonUp ) then
        switchModes(1)
	end

    crankChange = playdate.getCrankChange()
    if crankChange ~= 0 then
        crankAmount = crankChange * crankSpeed * dt
        if currentSpawner == sparkSpawner then
            sparkEffect(crankAmount)
        elseif currentSpawner == smokeSpawner then
            smokeEffect(crankAmount)
        elseif currentSpawner == orbitSpawner then
            orbitEffect(crankAmount)
        elseif currentSpawner == hoseSpawner then
            hoseEffect(crankAmount)
        elseif currentSpawner == shapeSpawner then
            changeRate(crankAmount)
        end        
    elseif currentSpawner == sparkSpawner or currentSpawner == smokeSpawner then
        changeRate(-.1)
    end

    if playdate.buttonJustPressed( playdate.kButtonA ) and currentSpawner == burstSpawner then
        currentSpawner:burst(10)
    end

    dt = (playdate.getCurrentTimeMilliseconds() - lasttime)/1000
	lasttime = playdate.getCurrentTimeMilliseconds()

    for i,v in ipairs(modes) do if v.spawning or #v.particles+#v.burstParticles>0 then v:update() end end
    
    Draw()
end