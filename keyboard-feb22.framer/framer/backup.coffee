document.body.style.cursor = "auto"

screenWidth = 640
screenHeight = 1130

codeLayer = new Layer
	height: screenHeight * 0.7,
	width: screenWidth,
	backgroundColor: "blue",
	scrollHorizontal: false
	
codeLayer.customData = {text: ''}
codeLayer.html = ''
	
keyboardLayer = new Layer
	name: 'keyboardLayer',
	y: codeLayer.height,
	height: screenHeight * 0.3,
	width: screenWidth,
	backgroundColor: "red",
	z: 1,
	index: 2

  
addToCode = (char) ->
	codeLayer.customData.text += char
	codeLayer.html = "<h1 style='padding: 30px; white-space: normal; word-wrap: break-word'>" + codeLayer.customData.text + "</h1>"
	
drawKeyboardRow = (startX, startY, line, parentLayer) ->
	buttonHeight = 100
	buttonWidth = 60
	padding = 5

	curX = startX
	for key in line
		width = buttonWidth
		backgroundColor = 'black'
		html = "<h2 style='padding: 20px'>" + key.disp + "</h2>"
		if key.disp is null
			html = "<i class=\"#{key.icon}\"></i>";
			
		buttonLayer = new Layer
			superLayer: parentLayer,
			x: curX,
			y: startY,
			height: buttonHeight,
			width: width,
			backgroundColor: backgroundColor
			
		curX += width + padding
		buttonLayer.bringToFront()
		buttonLayer.html = html
		buttonLayer.keyData = key
		
		buttonLayer.on Events.Click, handleKeyClick

	# Return y position of next row for chaining
	return startY + buttonHeight + padding
	

handleKeyClick = (event, layer) ->
  switch layer.keyData.action
    when 'data' then addToCode(layer.keyData.value)
    when 'showView' then showKeyboardView(layer.keyData.value)
    else console.log "Unsupport key action", layer.keyData


# For each view, create a view layer with keys as its sublayer. When toggling between views,
# simply bring the view to the front
viewLayers = {}

showKeyboardView = (viewName) ->

  if viewName of viewLayers
    viewLayers[viewName].bringToFront();
  else
    print "View " + viewName + " does not exist"


renderKeyboard = (kbLayer) ->

  _.forOwn keymap.views, (lines, viewName) ->

    viewLayers[viewName] = new Layer
      superLayer: kbLayer,
      x: kbLayer.x,
      y: kbLayer.y,
      height: kbLayer.height,
      width: kbLayer.width
      backgroundColor: kbLayer.backgroundColor,
      name: viewName

      ypos = 0
      _.forEach lines, (line) ->
        ypos = drawKeyboardRow 0, ypos, line, viewLayers[viewName]

  showKeyboardView(keymap.meta.startView);


# render the keyboard
#renderKeyboard keyboardLayer
