display.setDefault("textColor",150,150,150)
--progress variables
local mAccel = 0
local mAccelCurrent = 0
local mAccelLast = 0
local legitShake = 0.5
local difficulty = 5
local progress = 0
local gameStop = false
local startTime = os.time()
local duration = 0

--initial screen
local initialGroup = display.newGroup()
local imgTripod = display.newImage(initialGroup,"tripod.png")
imgTripod.x = display.contentWidth / 2
imgTripod.y = display.contentHeight / 2
local txtTripod = display.newText(initialGroup, "Designed by Tripod", 30, imgTripod.y+50, "Arial",30)

--countdown group
local countGroup = display.newGroup()
local img1 = display.newImage(countGroup, "1.png")
local img2 = display.newImage(countGroup, "2.png")
local img3 = display.newImage(countGroup, "3.png")
img1.x = display.contentWidth / 2
img1.y = display.contentHeight / 2
img2.x = display.contentWidth / 2
img2.y = display.contentHeight / 2
img3.x = display.contentWidth / 2
img3.y = display.contentHeight / 2
img1.isVisible = false
img2.isVisible = false
img3.isVisible = false

--background group
local bgGroup = display.newGroup()
local bgImage = display.newImage(bgGroup, "ketchup.png")
bgGroup.isVisible = false

--onScreen debug group
local bgDebug = display.newGroup()
local myTextObject = display.newText(bgDebug,"Hello World!",100,50,"Arial",30)
local myTextObject2 = display.newText(bgDebug,"Debug!",100,100,"Arial",30)
--uncomment following line to see actual readings on device
bgDebug.isVisible = false

--progress bar group
local barGroup = display.newGroup()
local progBar = display.newRect(barGroup,100,200,100,20)
progBar:setReferencePoint(display.BottomLeftReferencePoint)
progBar.x, progBar.y = 100, 200
progBar:setFillColor(120,120,120)
local progBarFill = display.newRect(barGroup,100,200,0,20)
progBarFill:setFillColor(234,183,30)
barGroup.isVisible = false

--face group
local faceGroup = display.newGroup()
local faceImage = display.newImage(faceGroup, "sadface.JPG")
faceGroup.isVisible = false

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
    loopCount = 15,   -- Optional. Default is 0 (loop indefinitely)
    loopDirection = "forward"    -- Optional. Values include: "forward","bounce"
}
local sheet = graphics.newImageSheet("runningcat-full.png",options)
local catSprite = display.newSprite(animateGroup, sheet, sequenceData)
function spriteListener( event )
    if event.phase == "ended" then
    	print(tostring(duration))
    	showScore()
    end
end
catSprite:addEventListener("sprite", spriteListener )
animateGroup.isVisible = false

--information group
local infoGroup = display.newGroup()
local lblScore = display.newText(infoGroup,"score:",100,150,"Arial",20)
local txtScore = display.newText(infoGroup,"songcan",200,150,"Arial",20)
local widget = require("widget")
local function newGameHandler(event)
	if event.phase == "ended" then
		faceGroup.isVisible = false
		animateGroup.isVisible = false
		barGroup.isVisible = false
		infoGroup.isVisible = false
		countGroup:toFront()
		countDown()
		--startGame()
	end
end
local btnNewGame = widget.newButton
{
	left = 100,
    top = 300,
    width = 150,
    height = 50,
    --defaultFile = "default.png",
    --overFile = "over.png",
    id = "btnNewGame",
    label = "New Game",
    onEvent = newGameHandler,
}
infoGroup:insert(btnNewGame)
infoGroup.isVisible = false
function showScore()
	txtScore.text = tostring(duration) .. " sec!"
	infoGroup.isVisible = true
	infoGroup:toFront()
end
infoGroup.isVisible = false

--media control variables
soundPlayed = {}
function setSoundPlayed(value)
	for i = 0, 2 do
		soundPlayed[i] = value
	end
end
setSoundPlayed(false)
function showSuccessView(value)
	gameStop = value
	bgGroup.isVisible = not value
	barGroup.isVisble = not value
	faceGroup.isVisible = value
	animateGroup.isVisible = value
end
function onSensorChanged(event)
	local x = event.xInstant
	local y = event.yInstant
	local z = event.zInstant
	myTextObject2.text = "x: " .. string.format("%f",x) .. " y: " .. string.format("%f",y) .. " z: " .. string.format("%f",z)
	mAccelLast = mAccelCurrent
	mAccelCurrent = math.sqrt(x * x + y * y + z * z)
	local delta = mAccelCurrent - mAccelLast
	mAccel = mAccel * 0.9 + delta
	print(tostring(mAccel))
	if math.abs(mAccel) > legitShake and progress < 100 and not gameStop then
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
--combine play sound and vibrate for now
function notifyUser(value)
		--audio doesn't support mp3!
		--local yesSound = audio.loadSound("yes.mp3")
		--local yesChannel = audio.play(yesSound)
	if value >= 25 and not soundPlayed[0]  then
		media.setSoundVolume(1.0)
		soundPlayed[0] = true
		media.playSound('fire.mp3')
		system.vibrate(3000)
	elseif value >= 75 and not soundPlayed[1] then
		media.setSoundVolume(1.0)
		soundPlayed[1] = true
		media.playSound('effect2.mp3')
		system.vibrate(3000)
	elseif value >= 100 and not soundPlayed[2] then
		media.setSoundVolume(1.0)
		soundPlayed[2] = true
		media.playSound('button.mp3')
		system.vibrate(3000)
	end
end
function updateProgBar(value)
	progBarFill:setReferencePoint(display.BottomLeftReferencePoint)
	progBarFill.x, progBarFill.y = 100, 200
	
	--sound + vibrate
	notifyUser(value)
	
	if value >= 100 then
		duration = os.time() - startTime
		Runtime:removeEventListener("accelerometer",onSensorChanged)
		myTextObject.text = "You Won!!"
		progress = 0
		mAccel = 0
		mAccelLast = 0
		mAccelCurrent = 0
		showSuccessView(true)
		setSoundPlayed(false)
		catSprite:setSequence("slowRun")
		catSprite:play()
	else
		progBarFill.width = value
	end
	print (string.format("%f", progress))
end
function startGame()
	infoGroup.isVisible = false
	--weird bug had to reset progBarFill
	progBarFill:removeSelf()
	progBarFill = nil
	progBarFill = display.newRect(barGroup,100,200,0,20)
	progBarFill:setFillColor(234,183,30)
	progBarFill:setReferencePoint(display.BottomLeftReferencePoint)
	progBarFill.x, progBarFill.y = 100, 200
	progBarFill.width = 0
	print (string.format("%d", progBarFill.width))
	barGroup.isVisible = true
	startTime = os.time()
	showSuccessView(false)
	Runtime:addEventListener("accelerometer",onSensorChanged)
end
function countDown()
	countGroup:toFront()
	img3.isVisible = true
	timer.performWithDelay(500, function() img3.isVisible = false end)
	timer.performWithDelay(1000, function() img2.isVisible = true end)
	timer.performWithDelay(1500, function() img2.isVisible = false end)
	timer.performWithDelay(2000, function() img1.isVisible = true end)
	timer.performWithDelay(2500, function() img1.isVisible = false end)
	timer.performWithDelay(3000, function() startGame() end)
	countGroup:toBack()
	
	--timer.performWithDelay(1000, transition.to(img3, {time=200,delay=0,alpha=0}))
	--timer.performWithDelay(3000, function() img3.isVisible = false  img2.isVisible = true end)
	--timer.performWithDelay(3001, transition.to(img2, {time=200,delay=0,alpha=0}))
	--timer.performWithDelay(5000, function() img2.isVisible = false  img1.isVisible = true end)
	--timer.performWithDelay(5001, transition.to(img1, {time=200,delay=0,alpha=0}))
	--timer.performWithDelay(7000, function() img1.isVisible = false startGame() end)
end
function endInitial()
	initialGroup.isVisible = false
	initialGroup.remove(imgTripod)
	initialGroup.remove(txtTripod)
	initialGroup = nil
	countDown()
end
local initialTimer = timer.performWithDelay(2000,endInitial)

Runtime:addEventListener("accelerometer",onSensorChanged)