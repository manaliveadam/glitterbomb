import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"

local vector2 <const> = playdate.geometry.vector2D
local gfx <const> = playdate.graphics
local screenWidth = 400
local screenHeight = 240

local function spriteInit(image,position)
    local newSprite = gfx.sprite.new(image)
    newSprite:setOpaque(false)
    newSprite:moveTo(position.x,position.y)
    newSprite:add()
    return newSprite
end

--make local
 local function lerp(starting,ending,percent)
    local amt = starting+(ending-starting)*percent
    return amt
end

--maybe pass as variable?
local function forceRandomRange(angle,range,force)
    angle = angle + range * (math.random()-0.5)
    local x = math.cos(math.rad(angle))
    local y = math.sin(math.rad(angle))
    return({x=x*force,y=y*force})
end

local function forceRandom(force)
    return({x=(math.random()-.5)*force,y=(math.random()-.5)*force})
end

class('Particle').extends()

function Particle.new(newParticle)
    return Particle(newParticle)
end

function Particle:init(newParticle)
    self.active = true
    self.position = newParticle.position
    self.velocity = newParticle.velocity
    -- self.image = newParticle.image
    -- self.drawImage = newParticle.image
    self.skipped = 0

    self:setSize(newParticle.size)
    self:setOpacity(newParticle.opacity)

    self.lifetime = 0
    self.emissionSize = newParticle.emissionSize
    self.lastUpdate = 0
end

function Particle:setActive(state)
    self.active = state
end

--maybe combine size + opacity into one function to avoid ordering issue
function Particle:setSize(size)
    -- self.drawImage = self.image:scaledImage(size)
end

function Particle:setOpacity(opacity)
    -- self.drawImage = self.drawImage:fadedImage(opacity, gfx.image.kDitherTypeBayer8x8)
end

function Particle:setFrameDelay(delay)
    self.frameDelay = delay
end

function Particle:addForce(force)
    self.velocity.x += force.x
    self.velocity.y += force.y
end

function Particle:update()
    self.lifetime+=dt
    self.position.x+=self.velocity.x*dt
    self.position.y+=self.velocity.y*dt
    --spriteonly
    -- self.sprite:moveTo(self.position.x//1,self.position.y//1)
end

class('ParticleEmitter').extends()
function ParticleEmitter.new(image, newEmitter)
    return ParticleEmitter(image, newEmitter)
end

function ParticleEmitter:init(image, newEmitter)

    newEmitter = newEmitter or {}

    self.image=image
    self.drawOffset = {x=0,y=0}
    self.drawOffset.x,self.drawOffset.y= self.image:getSize()

    self.position = newEmitter.position or {x=0,y=0}

    self.emissionRate = newEmitter.emissionRate or 1
    self.emissionForce=newEmitter.emissionForce or 0
    self.emitterWidth =newEmitter.emitterWidth or 0
    self.emissionAngle =newEmitter.emissionAngle or  270
    self.emissionSpread =newEmitter.emissionSpread or  0

    self.spawning = self.spawning or false
    self.particles = {}
    self.particleIndex = 1

    self.particleLifetime=newEmitter.particleLifetime or 1
    local particleSize = newEmitter.particleSize or 1
    local particleOpacity = newEmitter.particleOpacity or 1
    self.particleUpdateDelay = newEmitter.particleUpdateDelay or  0

    self.maxParticles = math.ceil(self.emissionRate * self.particleLifetime + 2)

    self:setParticleSize(particleSize)
    self:setParticleOpacity(particleOpacity)

    self.velocity={x=0,y=0}
    self.inheritVelocity =newEmitter.inheritVelocity or true
    self.gravity = newEmitter.gravity or 9.8
    self.worldScale =newEmitter.worldScale or  50
    self.looping = newEmitter.looping or false

    self.spawnTime = 0
end

--emitter settings
function ParticleEmitter:setPosition(pos)
    self.position = pos
end

function ParticleEmitter:setEmissionRate(rate)
    self.emissionRate = rate
    self.maxParticles = math.ceil(self.emissionRate * self.particleLifetime + 2)
end

function ParticleEmitter:setEmissionForce(force)
    self.emissionForce = force
end

function ParticleEmitter:setEmitterWidth(width)
    self.emitterWidth = width
end

function ParticleEmitter:setEmissionAngle(angle)
    self.emissionAngle = angle
end

function ParticleEmitter:setEmissionSpread(spread)
    self.emissionSpread = spread
end

function ParticleEmitter:setEmissionDelay(delay)
    self.emissionDelay = delay
end

--particle settings
function ParticleEmitter:setParticleLifetime(life)
    self.particleLifetime = life
    self.maxParticles = math.ceil(self.emissionRate * self.particleLifetime + 2)
end

--maybe add these to init
function ParticleEmitter:setParticleSize(startSize,endSize)
    self.startSize = startSize
    self.endSize = endSize or startSize
    if self.startSize == self.endSize then self.animateSize = false
    else self.animateSize = true end
end

function ParticleEmitter:setParticleOpacity(startO,endO)
    self.startOpacity = startO
    self.endOpacity = endO or startO
    if self.startOpacity == self.endOpacity then self.animateOpacity = false
    else self.animateOpacity = true end
end

function ParticleEmitter:setParticleUpdateDelay(delay)
    self.particleUpdateDelay = delay
end

--other settings
function ParticleEmitter:setInheritVelocity(iv)
    self.inheritVelocity = iv
end

function ParticleEmitter:setGravity(g)
    self.gravity = g
end

function ParticleEmitter:setWorldScale(scale)
    self.worldScale = scale
end

function ParticleEmitter:setLooping(looping)
    self.looping = looping
end

function ParticleEmitter:pause()
    self.spawning = false
end

function ParticleEmitter:play()
    self.spawnTime = 0
    self.spawning = true
end

function ParticleEmitter:draw()
    local xoff = self.drawOffset.x/2
    local yoff = self.drawOffset.y/2
    for i,v in ipairs(self.particles) do
        if v.active then
            self.image:draw(v.position.x+xoff,v.position.y+yoff)
        end
    end
    -- for i,v in ipairs(self.particles) do if v.active then v.drawImage:drawCentered((v.position.x+.5)//1,(v.position.y+.5)//1) end end
end

function ParticleEmitter:spawn(spawnForce, emissionSize)
    local spawnOffset
    local perpAngle
    local newParticle

    spawnOffset = (math.random() - 0.5) * self.emitterWidth * self.worldScale
    perpAngle = math.rad(self.emissionAngle+90)
    if #self.particles >= self.maxParticles then
        newParticle = self.particles[self.particleIndex]

        newParticle.position.x = self.position.x + math.cos(perpAngle)*spawnOffset
        newParticle.position.y =  self.position.y + math.sin(perpAngle)*spawnOffset
        newParticle.velocity = spawnForce

        newParticle.lifetime = 0
        newParticle.lastUpdate = 0
        newParticle.emissionSize = emissionSize

        newParticle:setActive(true)

        self.particleIndex += 1
        if self.particleIndex > self.maxParticles then
            self.particleIndex = 1
        end
    else
        newParticle={position = {x=self.position.x + math.cos(perpAngle)*spawnOffset, y=self.position.y + math.sin(perpAngle)*spawnOffset}, velocity = spawnForce, image = self.image, size = self.startSize, opacity = self.startOpacity, emissionSize = emissionSize, number = #self.particles+1}
        self.particles[#self.particles+1] = Particle.new(newParticle)
    end
    if self.inheritVelocity then
        newParticle.velocity.x += self.velocity.x
        newParticle.velocity.y += self.velocity.y
    end
end

function ParticleEmitter:update()
    local currentParticle
    local currentParticleTime
    local randomForce
    local numParticles
    local gForce = {x=0,y=self.gravity*self.worldScale*dt}

    self.spawnTime+=dt
    self.position.x+=self.velocity.x*dt
    self.position.y+=self.velocity.y*dt

    if self.spawnTime>(1/self.emissionRate) and self.spawning then
        numParticles = math.floor(self.spawnTime*self.emissionRate)
        for i=1, numParticles do
            randomForce = forceRandomRange(self.emissionAngle,self.emissionSpread,self.emissionForce)
            self:spawn({x=randomForce.x*self.worldScale,y=randomForce.y*self.worldScale},numParticles-i)
        end

        self.spawnTime -= numParticles/self.emissionRate
    end
    for i=#self.particles,1,-1 do
        currentParticle = self.particles[i]
        if currentParticle.active then
            currentParticleTime = currentParticle.lifetime
            lifePercent = currentParticleTime/self.particleLifetime
            if lifePercent > 1 then
                if #self.particles > self.maxParticles or self.spawning~=true then
                    table.remove(self.particles,i)
                    if i< self.particleIndex then
                        self.particleIndex -= 1
                    end

                    if self.particleIndex>#self.particles then
                        self.particleIndex = 1
                    end
                else
                    currentParticle:setActive(false)
                end
            else
                if currentParticleTime - currentParticle.lastUpdate >= (self.particleUpdateDelay-.5) * dt then
                    currentParticle.skipped = 0
                    currentParticle:addForce({x=gForce.x*(1+self.particleUpdateDelay),y=gForce.y*(1+self.particleUpdateDelay)})
                    currentParticle.lastUpdate = currentParticleTime
                else
                    currentParticle.skipped+=1
                end
                currentParticle:update()
                if currentParticle.lifetime > self.particleLifetime then currentParticle.lifetime = self.particleLifetime end
                -- if self.animateSize then
                --     currentParticle:setSize(lerp(self.startSize,self.endSize,lifePercent))
                -- end
                -- if self.animateOpacity then
                --     currentParticle:setOpacity(lerp(self.startOpacity,self.endOpacity,lifePercent))
                -- end

            end
        end
    end
end

class('AnimatedParticleEmitter').extends(ParticleEmitter)
function AnimatedParticleEmitter.new(image, newEmitter)
    return AnimatedParticleEmitter(image, newEmitter)
end

function AnimatedParticleEmitter:init(image, newEmitter)
    AnimatedParticleEmitter.super:init(image,newEmitter)
    self.drawOffset.x,self.drawOffset.y= self.image:getImage(1):getSize()
end

function AnimatedParticleEmitter:draw()
    local xoff = self.drawOffset.x/2
    local yoff = self.drawOffset.y/2
    local totalFrames = self.image:getLength()
    local currentFrame
    local currentImage
    for i,v in ipairs(self.particles) do
        if v.active then
            currentFrame = lerp(1,totalFrames,v.lifetime/self.particleLifetime)//1
            currentImage = self.image:getImage(currentFrame)
            currentImage:draw(v.position.x-xoff,v.position.y-yoff)
        end
    end
end