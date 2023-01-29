local numFrames = 30*smokeSpawner.particleLifetime
print(numFrames,"frames")
local frameWidth,frameHeight = smokeSpawner.image:getSize()
print(frameWidth,"x",frameHeight)
local frameSize = math.max(frameWidth,frameHeight) * math.max(smokeSpawner.startSize,smokeSpawner.endSize)
print(frameSize,"frame size")
local sheetDimension = math.ceil(math.sqrt(numFrames))
print(sheetDimension,"sheet size")
local smokeCanvas = gfx.image.new(sheetDimension*frameSize,sheetDimension*frameSize)

local currentOpacity = smokeSpawner.startOpacity
local currentSize = smokeSpawner.startSize

local currentFrame

local percent = 0

gfx.pushContext(smokeCanvas)
for y=0,sheetDimension-1 do
    for x=0,sheetDimension-1 do
        percent = (y*sheetDimension+x)/numFrames
        if percent <= 1 then
            currentSize = lerp(smokeSpawner.startSize,smokeSpawner.endSize,percent)
            currentOpacity = lerp(smokeSpawner.startOpacity,smokeSpawner.endOpacity,percent)
            currentFrame = smokeSpawner.image:scaledImage(currentSize)
            currentFrame = currentFrame:fadedImage(currentOpacity,gfx.image.kDitherTypeBayer8x8)
            currentFrame:drawCentered((x+.5)*frameSize,(y+.5)*frameSize)
        end
    end
end
playdate.datastore.writeImage(smokeCanvas,"smokeSheet.gif")