import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"
import "glitterbomb"

local vector2 <const> = playdate.geometry.vector2D
local gfx <const> = playdate.graphics
local screenWidth = 400
local screenHeight = 240

local smoke = gfx.image.new("smoke")
local spark = gfx.image.new("spark")

local voice = gfx.font.new("Voice-9p-48-o")

dt = 0
lasttime = 0

local startWidth, startRate, startAngle, startSpread
local particleSpawner

function myGameSetUp()

    -- particleSpawner=ParticleEmitter.new(smoke)
    -- particleSpawner:setPosition(vector2.new(screenWidth/2,screenHeight/2))
    -- particleSpawner:setEmissionRate(5)
    -- particleSpawner:setParticleLifetime(3)
    -- particleSpawner:setParticleSize(0.08,0.4)
    -- particleSpawner:setParticleOpacity(0.9,0)

    -- particleSpawner:setEmissionForce(1)
    -- particleSpawner:setEmitterWidth(0.0)
    -- particleSpawner:setEmissionSpread(15)
    -- particleSpawner:setEmissionAngle(270)
    -- particleSpawner:setGravity(0)
    -- particleSpawner:setInheritVelocity(false)

    particleSpawner=ParticleEmitter.new(spark)
    particleSpawner:setPosition({x=screenWidth/2,y=screenHeight/2})
    particleSpawner:setEmissionRate(0)
    particleSpawner:setParticleLifetime(1)
    particleSpawner:setGravity(2.5)
    particleSpawner:setParticleSize(0.02,0.02)
    particleSpawner:setParticleOpacity(1,1)
    particleSpawner:setParticleUpdateDelay(2)
    particleSpawner:setEmissionForce(4)
    particleSpawner:setEmitterWidth(5.5)
    particleSpawner:setEmissionSpread(90)
    particleSpawner:setEmissionAngle(270)
    particleSpawner:setInheritVelocity(true)

    startAngle = particleSpawner.emissionAngle
    startWidth = particleSpawner.emitterWidth
    startRate = particleSpawner.emissionRate
    startSpread = particleSpawner.emissionSpread
end

myGameSetUp()

local function changeWidth(percent)
    percent*=2
    percent += particleSpawner.emitterWidth
    if percent < 0 then percent = 0 end
    particleSpawner:setEmitterWidth(percent)
    particleSpawner:setEmissionRate(startRate * (percent+1)/(startWidth+1))
end

local function changeRate(percent)
    percent *= 5
    percent += particleSpawner.emissionRate
    if percent < 0 then percent = 0 end
    particleSpawner:setEmissionRate(percent)

end

local function changeAngle(percent)
    percent*=50
    percent += particleSpawner.emissionAngle
    if percent < 0 then percent = 0
    elseif percent > 360 then percent = 360 end
    particleSpawner:setEmissionAngle(percent)
end

local function changeSpread(percent)
    percent*=50
    percent += particleSpawner.emissionSpread
    if percent < 0 then percent = 0
    elseif percent > 360 then percent = 360 end
    particleSpawner:setEmissionSpread(percent)
    particleSpawner:setEmissionRate(startRate * (percent+1)/(startSpread+1))
end

local function changeForce(percent)
    percent*=1
    percent += particleSpawner.emissionForce
    if percent < 0 then percent = 0 end
    particleSpawner:setEmissionForce(percent)
end

local function changeDelay(percent)
    percent*=1
    percent += particleSpawner.particleUpdateDelay
    if percent < 0 then percent = 0 end
    particleSpawner:setParticleUpdateDelay(percent)
end

local function Draw()
    gfx.clear()
    voice:drawText("glitterbomb",screenWidth/2-26*5.5,screenHeight/2-26)
    particleSpawner:draw()
    playdate.drawFPS(0, 0)
    gfx.drawText(particleSpawner.emissionRate,screenWidth/2, 0)
end

local percent = 270
local crankSpeed = 1/12

function playdate.update()
    if playdate.buttonIsPressed( playdate.kButtonRight ) then
		particleSpawner.velocity.x += 25*dt
        if particleSpawner.velocity.x < 0 then
            particleSpawner.velocity.x += 25*dt
        end
	elseif playdate.buttonIsPressed( playdate.kButtonLeft ) then
		particleSpawner.velocity.x -= 25*dt
        if particleSpawner.velocity.x > 0 then
            particleSpawner.velocity.x -= 25*dt
        end
    elseif playdate.buttonIsPressed( playdate.kButtonDown ) then
		particleSpawner.velocity.y += 25*dt
        if particleSpawner.velocity.y < 0 then
            particleSpawner.velocity.y += 25*dt
        end
	elseif playdate.buttonIsPressed( playdate.kButtonUp ) then
		particleSpawner.velocity.y -= 25*dt
        if particleSpawner.velocity.y > 0 then
            particleSpawner.velocity.y -= 25*dt
        end
    else
        if math.abs(particleSpawner.velocity.x) > 25*dt then
            particleSpawner.velocity.x = particleSpawner.velocity.x - 25*particleSpawner.velocity.x*dt/math.abs(particleSpawner.velocity.x)
        end
        if math.abs(particleSpawner.velocity.y) > 25*dt then
            particleSpawner.velocity.y = particleSpawner.velocity.y - 25*particleSpawner.velocity.y*dt/math.abs(particleSpawner.velocity.y)
        end
	end

    local crankChange = playdate.getCrankChange()
    if crankChange ~= 0 then
        percent = crankChange * crankSpeed * dt
        -- changeDelay(percent)
        changeRate(percent)
        -- changeAngle(percent)
        -- changeForce(percent)
        -- changeSpread(percent)
        -- changeWidth(percent)

    end

    dt = (playdate.getCurrentTimeMilliseconds() - lasttime)/1000
	lasttime = playdate.getCurrentTimeMilliseconds()

    particleSpawner:update()
    Draw()
end