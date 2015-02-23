document.body.style.cursor = "auto"

screenWidth = 640
screenHeight = 1130

codeLayer = new Layer
	height: screenHeight * 0.7,
	width: screenWidth,
	backgroundColor: "blue"
codeLayer.customData = {text: ''}
codeLayer.html = ''
	
keyboardLayer = new Layer
	y: codeLayer.height,
	height: screenHeight * 0.3,
	width: screenWidth
	backgroundColor: "red",
	z: 1,
	index: 2

addToCode = (char) ->
	codeLayer.customData.text += char
	codeLayer.html = "<h1 style='padding: 30px'>" + codeLayer.customData.text + "</h1>"
	
drawKeyboardRow = (startX, startY, buttonsText) ->
	buttonHeight = 100
	buttonWidth = 60
	padding = 5

	curX = startX
	for txt in buttonsText
		width = buttonWidth
		backgroundColor = 'black'
		html = "<h2 style='padding: 20px'>" + txt + "</h2>"
		if txt is ''
			width = buttonWidth/2
			backgroundColor = 'transparent'
			html = ''
			
		buttonLayer = new Layer
			superLayer: keyboardLayer,
			x: curX,
			y: startY,
			height: buttonHeight,
			width: width,
			backgroundColor: backgroundColor
			
		curX += width + padding
		buttonLayer.bringToFront()
		buttonLayer.html = html
		buttonLayer.customData = {text: txt}
		
		buttonLayer.on Events.Click, (event, layer) ->
			addToCode(layer.customData.text)		
	# Return y position of next row for chaining
	return startY + buttonHeight + padding
	
	
newY = drawKeyboardRow 0, 0, ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p']
newY = drawKeyboardRow 0, newY, ['', 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', '']
drawKeyboardRow 0, newY, ['\\b', '', 'z', 'x', 'c', 'v', 'b', 'n', 'm', '', '\\n']
