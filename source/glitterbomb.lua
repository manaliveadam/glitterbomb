import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"

local vector2 <const> = playdate.geometry.vector2D
local gfx <const> = playdate.graphics
local cos <const> = math.cos
local sin <const> = math.sin
local rad <const> = math.rad
local random <const> = math.random
local screenWidth <const> = 400
local screenHeight <const> = 240

--todo make local?
function lerp(starting,ending,percent)
    local amt = starting+(ending-starting)*percent
    return amt
end

--todo: allow for other spawning patterns besides random
local function forceRandomRange(angle,range,force)
    angle = angle + range * (random()-0.5)
    local x = cos(rad(angle))
    local y = sin(rad(angle))
    return({x=x*force,y=y*force})
end

class('Particle').extends()

function Particle.new(newParticle)
    return Particle(newParticle)
end

function Particle:init(newParticle)
    self.active = true
    self.position = newParticle.position
    self.velocity = newParticle.velocity
    self.skipped = 0

    self.lifetime = 0
end

function Particle:setActive(state)
    self.active = state
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
    --todo: implement a sprite version
    -- self.sprite:moveTo(self.position.x//1,self.position.y//1)
end

class('ParticleEmitter').extends()
function ParticleEmitter.new(image, newEmitter)
    return ParticleEmitter(image, newEmitter)
end

function ParticleEmitter:init(image, newEmitter)

    newEmitter = newEmitter or {}

    self.image = image
    self.drawOffset = {x=0,y=0}
    self.drawOffset.x,self.drawOffset.y = self.image:getSize()
    self.drawOffset.x /= 2
    self.drawOffset.y /= 2

    self.position = newEmitter.position or {x=0,y=0}

    self.emissionRate = newEmitter.emissionRate or 1
    self.emissionForce = newEmitter.emissionForce or 0
    self.emitterWidth = newEmitter.emitterWidth or 0
    self.emissionAngle = newEmitter.emissionAngle or  270
    self.emissionSpread = newEmitter.emissionSpread or  0

    self.particles = {}
    self.particleIndex = 1

    self.particleLifetime = newEmitter.particleLifetime or 1
    self.particleUpdateDelay = newEmitter.particleUpdateDelay or  0

    self.maxParticles = math.ceil(self.emissionRate * self.particleLifetime)

    self.velocity={x=0,y=0}
    self.inheritVelocity = newEmitter.inheritVelocity or true
    self.gravity = newEmitter.gravity or 9.8
    self.worldScale = newEmitter.worldScale or  50

    self.spawning = newEmitter.spawning or false
    self.spawnTime = 0
end

--emitter settings
function ParticleEmitter:setPosition(pos)
    self.position = pos
end

function ParticleEmitter:setVelocity(v)
    self.velocity = v
end

function ParticleEmitter:setEmissionRate(rate)
    self.emissionRate = rate
    self.maxParticles = math.ceil(self.emissionRate * self.particleLifetime)
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

--particle settings
function ParticleEmitter:setParticleLifetime(life)
    self.particleLifetime = life
    self.maxParticles = math.ceil(self.emissionRate * self.particleLifetime)
end

function ParticleEmitter:setParticleUpdateDelay(delay)
    self.particleUpdateDelay = delay
end

--these are only used for generating sprite sheets
function ParticleEmitter:setParticleSize(startSize,endSize)
    self.startSize = startSize
    self.endSize = endSize or startSize
end

function ParticleEmitter:setParticleOpacity(startO,endO)
    self.startOpacity = startO
    self.endOpacity = endO or startO
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

function ParticleEmitter:pause()
    self.spawning = false
end

function ParticleEmitter:play()
    self.spawnTime = 0
    self.spawning = true
end

--particle emitter functions
function ParticleEmitter:draw()
    for i,v in ipairs(self.particles) do
        if v.active then
            self.image:draw(v.position.x+self.drawOffset.x,v.position.y+self.drawOffset.y)
        end
    end
end

function ParticleEmitter:spawnParticle(spawnForce,index)
    local spawnOffset = (random() - 0.5) * self.emitterWidth * self.worldScale
    local perpAngle = rad(self.emissionAngle+90)
    local offsetVector = {x = cos(perpAngle)*spawnOffset, y = sin(perpAngle)*spawnOffset}
    local spawnIndex = index or #self.particles+1

    local newParticle
        
    --if all particles have been spawned, reuse existing particles rather than spawn new ones
    if #self.particles >= self.maxParticles then
        newParticle = self.particles[self.particleIndex]

        newParticle.position.x = self.position.x + offsetVector.x
        newParticle.position.y =  self.position.y + offsetVector.y
        newParticle.velocity = spawnForce

        newParticle.lifetime = 0
        newParticle.lastUpdate = 0

        newParticle:setActive(true)

        self.particleIndex += 1
        if self.particleIndex > self.maxParticles then
            self.particleIndex = 1
        end
    else
        newParticle={position = {x=self.position.x + offsetVector.x, y=self.position.y + offsetVector.y}, velocity = spawnForce, image = self.image}
        table.insert(self.particles,spawnIndex,Particle.new(newParticle))
        if self.particleIndex > spawnIndex then self.particleIndex += 1 end
    end

    if self.inheritVelocity then
        newParticle.velocity.x += self.velocity.x
        newParticle.velocity.y += self.velocity.y
    end
end

--todo make this play nicely with other bursts
function ParticleEmitter:burst(burstSize)
    local insertPoint = self.particleIndex - 1
    if insertPoint <= 0 then insertPoint = #self.particles+1 end
    self.maxParticles += burstSize
    for i=1, burstSize do
        randomForce = forceRandomRange(self.emissionAngle,self.emissionSpread,self.emissionForce)
        self:spawnParticle({x=randomForce.x*self.worldScale,y=randomForce.y*self.worldScale},insertPoint)
    end
end

function ParticleEmitter:updateParticles()
    local currentParticle
    local currentParticleTime
    local randomForce
    local numParticles
    --todo: allow more forces than gravity
    local gForce = {x=0,y=self.gravity*self.worldScale*dt}

    for i=#self.particles,1,-1 do
        currentParticle = self.particles[i]
        if currentParticle.active then
            currentParticleTime = currentParticle.lifetime
            lifePercent = currentParticleTime/self.particleLifetime
            if lifePercent >= 1 then
                --remove particles if the maximum decreased or spawner has been stopped (otherwise save for pooling)
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
                if currentParticle.skipped >= self.particleUpdateDelay then
                    currentParticle.skipped = 0
                    currentParticle:addForce({x=gForce.x*(1+self.particleUpdateDelay),y=gForce.y*(1+self.particleUpdateDelay)})
                else
                    currentParticle.skipped+=1
                end
                currentParticle:update()
                if currentParticle.lifetime > self.particleLifetime then currentParticle.lifetime = self.particleLifetime end
            end
        end
    end
end

function ParticleEmitter:update()

    self.spawnTime+=dt
    self.position.x+=self.velocity.x*dt
    self.position.y+=self.velocity.y*dt

    if self.spawnTime>(1/self.emissionRate) and self.spawning then
        numParticles = math.floor(self.spawnTime*self.emissionRate)
        for i=1, numParticles do
            --todo: allow for other spawn patterns
            randomForce = forceRandomRange(self.emissionAngle,self.emissionSpread,self.emissionForce)
            self:spawnParticle({x=randomForce.x*self.worldScale,y=randomForce.y*self.worldScale})
        end

        self.spawnTime -= numParticles/self.emissionRate
    end
    
    self:updateParticles()

end

class('AnimatedParticleEmitter').extends(ParticleEmitter)
function AnimatedParticleEmitter.new(image, newEmitter)
    return AnimatedParticleEmitter(image, newEmitter)
end

function AnimatedParticleEmitter:init(image, newEmitter)
    AnimatedParticleEmitter.super.init(self,image,newEmitter)
    self.drawOffset.x,self.drawOffset.y= self.image:getImage(1):getSize()
    self.drawOffset.x /= 2
    self.drawOffset.y /= 2

    self.numFrames = self.image:getLength()
end

function AnimatedParticleEmitter:setNumFrames(num)
    self.numFrames = num
end

function AnimatedParticleEmitter:draw()
    local totalFrames = self.numFrames
    local currentFrame
    local currentImage
    for i,v in ipairs(self.particles) do
        if v.active then
            currentFrame = lerp(1,totalFrames,v.lifetime/self.particleLifetime)//1
            currentImage = self.image:getImage(currentFrame)
            currentImage:draw(v.position.x-self.drawOffset.x,v.position.y-self.drawOffset.y)
        end
    end
end