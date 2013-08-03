print ("Hello World!")
display.setDefault("textColor",150,150,150)

--background group
local bgGroup = display.newGroup()
local bgImage = display.newImage(bgGroup, "sadface.JPG")

--onScreen debug group
local bgDebug = display.newGroup()
local myTextObject = display.newText(bgDebug,"Hello World!",100,50,"Arial",30)
local myTextObject2 = display.newText(bgDebug,"Debug!",100,100,"Arial",30)
local progBar = display.newRect(bgDebug,100,200,100,20)
progBar:setReferencePoint(display.BottomLeftReferencePoint)
progBar.x, progBar.y = 100, 200
local progBarFill = display.newRect(bgDebug,100,200,0,20)
progBarFill:setFillColor(234,183,30)

--sprite animation group
local animateGroup = display.newGroup()
local options = {
   width = 512,
   height = 256,
   numFrames = 8
}
local sequenceData =
{
    name="slowRun",
    start=1,
    count=8,
    time=300,        -- Optional. In ms.  If not supplied, then sprite is frame-based.
    loopCount = 30,   -- Optional. Default is 0 (loop indefinitely)
    loopDirection = "forward"    -- Optional. Values include: "forward","bounce"
}
local sheet = graphics.newImageSheet("runningcat-full.png",options)
local catSprite = display.newSprite(animateGroup, sheet, sequenceData)
function spriteListener( event )
    print(event.name, event.phase)
    if event.phase == "ended" then
    	animateGroup.isVisible = false
    end
end
catSprite:addEventListener("sprite", spriteListener )
animateGroup.isVisible = false

local mAccel = 0
local mAccelCurrent = 0
local mAccelLast = 0
local legitShake = 0.5
local difficulty = 5
local progress = 0
function onSensorChanged(event)
	local x = event.xInstant
	local y = event.yInstant
	local z = event.zInstant
	myTextObject2.text = "x: " .. string.format("%f",x) .. " y: " .. string.format("%f",y) .. " z: " .. string.format("%f",z)
	mAccelLast = mAccelCurrent
	mAccelCurrent = math.sqrt(x * x + y * y + z * z)
	local delta = mAccelCurrent - mAccelLast
	mAccel = mAccel * 0.9 + delta
	if math.abs(mAccel) > legitShake and progress < 100 then
		onShake("mAccel: " .. string.format("%f",mAccel))
		progress = progress + math.abs(mAccel) * 10
		updateProgBar(progress)
	end
end
function onShake(value)
	local r = math.random(0,255)
	local g = math.random(0,255)
	local b = math.random(0,255)
	myTextObject.text = value
	myTextObject:setTextColor(r,g,b)
end
function updateProgBar(value)
	progBarFill:setReferencePoint(display.BottomLeftReferencePoint)
	progBarFill.x, progBarFill.y = 100, 200
	if value >= 100 then
		progBarFill.width = 100
		myTextObject.text = "You Won!!"
		animateGroup.isVisible = true
		catSprite:setSequence("slowRun")
		catSprite:play()
	else
		progBarFill.width = value
	end
end 
Runtime:addEventListener("accelerometer",onSensorChanged)