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

function glueSheet(emitter,name,fps)

    local fileName = name or "/glueSheet.gif"
    local frameRate = fps or 30

    local numFrames = frameRate*emitter.particleLifetime
    local frameWidth,frameHeight = emitter.image:getSize()
    local frameSize = math.max(frameWidth,frameHeight) * math.max(emitter.startSize,emitter.endSize)
    local sheetDimension = math.ceil(math.sqrt(numFrames))
    local canvas = gfx.image.new(sheetDimension*frameSize,sheetDimension*frameSize)

    local currentOpacity = emitter.startOpacity
    local currentSize = emitter.startSize

    local currentFrame

    local percent = 0

    gfx.pushContext(canvas)
    for y=0,sheetDimension-1 do
        for x=0,sheetDimension-1 do
            percent = (y*sheetDimension+x)/numFrames
            if percent <= 1 then
                currentSize = lerp(emitter.startSize,emitter.endSize,percent)
                currentOpacity = lerp(emitter.startOpacity,emitter.endOpacity,percent)
                currentFrame = emitter.image:scaledImage(currentSize)
                currentFrame = currentFrame:fadedImage(currentOpacity,gfx.image.kDitherTypeBayer8x8)
                currentFrame:drawCentered((x+.5)*frameSize,(y+.5)*frameSize)
            end
        end
    end
    playdate.datastore.writeImage(canvas,fileName)
end