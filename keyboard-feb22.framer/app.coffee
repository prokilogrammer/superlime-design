#document.body.style.cursor = "auto"

screenWidth = 640
screenHeight = 1130

codeLayer = new Layer
    height: screenHeight * 0.74,
    width: screenWidth,
    backgroundColor: "blue",
    scrollHorizontal: false

codeLayer.customData = {text: ''}
codeLayer.html = ''

keyboardLayer = new Layer
    name: 'keyboardLayer',
    y: codeLayer.height,
    height: screenHeight * 0.26,
    width: screenWidth,
    backgroundColor: "red",
    z: 1,
    index: 2


addToCode = (char) ->
    codeLayer.customData.text += char
    codeLayer.html = "<pre style='font-size: 56px; padding: 30px; word-wrap: break-word; line-height: 65px'>" + codeLayer.customData.text + "</pre>"

isFixedWidthKey = (key) ->
  return key.moreClasses is 'action'

keyboardRowDimensions = (startX, startY, line, lineno, parentLayer) ->

  # Calculate dimensions and coordinates for each row of the keyboard
  #   - Stretch all character keys and use fixed width for action keys
  #   - All keys get a right padding. First key gets a left padding also
  #   - line 2 must always have extra left and right padding

  # Constants
  padding = 10
  actionKeyWidth = 70
  buttonHeight = 60
  line2Padding = 30

  lineWidth = if lineno isnt 2 then parentLayer.width else (parentLayer.width - 2*line2Padding)

  # Calculate width fixed size buttons
  fixedSize = 0
  totalPadding = padding   # account for left padding for first button
  numNonActionKeys = 0
  _.forEach line, (key) ->
    totalPadding += padding
    if isFixedWidthKey(key)
      fixedSize += actionKeyWidth
    else
      numNonActionKeys++

  # Distribute remaining space to character keys
  buttonWidth = (lineWidth - fixedSize - totalPadding)/numNonActionKeys

  # first key gets a left padding
  startX = if lineno is 2 then (startX + line2Padding + padding) else (startX + padding)

  return [startX, startY, buttonWidth, buttonHeight, padding, actionKeyWidth]


drawKeyboardRow = (startX, startY, line, lineno, parentLayer) ->

    [startX, startY, buttonWidth, buttonHeight, padding, actionKeyWidth] = keyboardRowDimensions(startX, startY, line, lineno, parentLayer)

    console.log lineno, startX, startY, buttonWidth, buttonHeight, padding, actionKeyWidth

    curX = startX
    for key in line
        width = if isFixedWidthKey(key) then actionKeyWidth else buttonWidth
        backgroundColor = 'black'
        html = "<h2 style='padding: 20px'>" + key.disp + "</h2>"

        if key.disp is null
            html = "<h2><i class=\"#{key.icon}\"></i></h2>";


        buttonLayer = new Layer
            superLayer: parentLayer,
            x: curX,
            y: startY,
            height: buttonHeight,
            width: width,
            backgroundColor: backgroundColor

        curX += (width + padding)
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

    for name, layer of viewLayers
      layer.visible = if name is viewName then true else false

    viewLayers[viewName].bringToFront()

renderKeyboard = (kbLayer) ->

    # Some padding for top and bottom of view layer
    viewLayerPadding = 10
    _.forOwn keymap.views, (lines, viewName) ->

        viewLayers[viewName] = new Layer
            superLayer: kbLayer,
            x: 0,
            y: viewLayerPadding,
            height: kbLayer.height - viewLayerPadding,
            width: kbLayer.width,
            backgroundColor: kbLayer.backgroundColor,
            name: viewName

        ypos = 0
        lineno = 1
        _.forEach lines, (line) ->
            ypos = drawKeyboardRow 0, ypos, line, lineno, viewLayers[viewName]
            lineno++

    showKeyboardView(keymap.meta.startView);


# render the keyboard
renderKeyboard keyboardLayer
