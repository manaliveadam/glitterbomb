![glitterbomb-v1](https://user-images.githubusercontent.com/63170980/216749506-79eeb179-054f-4038-b187-d1ee6a7b2835.gif)

# The Basics

The basic building block of glitterbomb is the **ParticleEmitter** class.  You initialize a ParticleEmitter by passing it an image to use for its particles like so:

```
newEmitter = ParticleEmitter.new(particleImage)
```

There is also an **AnimatedParticleEmitter** class that you initialize by passing an image table:

```
newAnimatedEmitter = AnimatedParticleEmitter.new(particleImageTable)
```

You can manually position the emitter, or give it a velocity so it moves each frame.

Right now, the default behavior is to emit particles randomly given certain parameters (discussed below) but could easily be changed to whatever pattern you want.

# Emitter Paramaters

- **emissionRate** - How many particles are created per second
- **emissionForce** - Their initial velocity
- **emitterWidth** - If greater than 0, will randomize the start position of particles along a line
- **emissionAngle** - The direction they are emitted towards (0 degrees is right, 90 is down, 180 is left, etc.)
- **emissionSpread** - If greater than 0, will randomize the angle at which particles are emitted within +/- the spread amount
- **particleLifetime** - How long particles will exist (in seconds) before being destroyed (note, this along with emissionRate combine to give you the maximum number of particles that will exist at one time. So emitting 100 particles per second with a 1 second lifetime will have the same number of particles as 25 particles per second with a 4 second lifetime)
- **particleUpdateDelay** - Rather than update particles' velocity every frame, you can insert a delay to improve performance (at the cost of physical accuracy)
- **inheritVelocity** - Boolean. If set to true, particles will have the emitter's velocity added to their own when spawned.
- **gravity** - The amount of gravity particles experience (can set to 0 to turn off)
- **worldScale** - A helpful variable that lets you convert from your game's scale to the real world (for example, lets you think of particle velocity as m/s, 9.8 as physically accurate gravity, etc.)

You can either set these variables on initialization by passing them as a table, like so:
```
emitterSettings = {emissionRate = 10, emissionForce = 2, emissionSpread = 45, particleLifetime = 2, worldScale = 50}
newEmitter = ParticleEmitter.new(particleImage, emitterSettings)
```
or can set them manually with setter functions:
```
newEmitter = ParticleEmitter.new(particleImage)
newEmitter:setEmissionRate(10)
newEmitter:setEmissionForce(2)
newEmitter:setEmissionSpread(45)
newEmitter:setParticleLifetime(2)
newEmitter:setWorldScale(50)
```

To make an emitter start emitting, call
```
newEmitter:play()
```
and to stop it call
```
newEmitter:pause()
```
glitterbomb emitters are designed to continuously emit particles, however if you want to make a one time "burst" emission (for example, a dust cloud on landing or sparks from an explosion) you can call
```
newEmitter:burst(numParticles)
```

I've included a demo app so you can see some of the functionality and examples of how to use it.

Right now, you can get over 100 particles on device at 30FPS, though it's closer to 50 if they're animated

# Creating Particle Sprite Sheets

Originally I intended to support animating particle scale and opacity, but found it was too expensive to do every frame. To compensate I also created a second mini "app" called **glitterglue**. With glitterglue, you can create a ParticleEmitter, but rather than draw onscreen it draws a particle frame by frame to a sprite sheet so you can import it as an ImageTable to an AnimatedParticleEmitter later

Simply create a ParticleEmitter and set starting and ending size and opacity values like so:

```
local spriteSheetSpawner = ParticleEmitter.new(spriteImg)
spriteSheetSpawner:setParticleOpacity(1,0)
spriteSheetSpawner:setParticleSize(1,0)
```
The number of frames drawn to the sprite sheet is determined by the lifetime of the particle, as well as an option framerate value you can pass like so:
```
spriteSheetSpawner:setParticleLifetime(1)
glueSheet(spriteSheetSpawner,"spriteSheet.gif",30)
```
