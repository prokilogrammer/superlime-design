#document.body.style.cursor = "auto"

screenWidth = 640
screenHeight = 1130

codeLayer = new Layer
    height: screenHeight * 0.67,
    width: screenWidth,
    backgroundColor: "blue",
    scrollHorizontal: false

codeLayer.customData = {text: ''}
codeLayer.html = ''

keyboardLayer = new Layer
    name: 'keyboardLayer',
    y: codeLayer.height,
    height: screenHeight * 0.33,
    width: screenWidth,
    backgroundColor: "red",
    z: 1,
    index: 2

modeSwitch = new Layer
    name: 'modeLayer'
    y: 0,
    x: screenWidth - 100,
    height: 100,
    width: 100,
    backgroundColor: "yellow",
    z: 5,
    index: 3,

modeSwitch.modeData = 'preview'
modeSwitch.on Events.Click, (event, layer) ->
  # toggle mode
  if layer.modeData is 'preview'
    layer.backgroundColor = 'green'
    layer.modeData = 'test'
    startTracking()
  else
    layer.backgroundColor = 'yellow'
    layer.modeData = 'preview'
    stopTracking()


## Track keyboard performance ##
defaultMetrics = {
  numBackspaces: 0,
  numStrokes: {
    action: 0,
    char: 0
  },
  numStrokesForKeywords: 0,
  totalDuration: 0,
  mttc: {}  # Mean time to type a character
}

metrics = defaultMetrics

stopTracking = () ->
  console.log "METRICS", metrics

startTracking = () ->
  metrics = defaultMetrics


addToCode = (char) ->
    if char is '\b'
      codeLayer.customData.text = codeLayer.customData.text.slice(0, -1);
    else
      codeLayer.customData.text += char

    codeLayer.html = "<div class='code'><pre>" + codeLayer.customData.text + "<span class='blink'>|</span></pre></div>"

isFixedWidthKey = (key) ->
  return key.moreClasses is 'action'

keyboardRowDimensions = (startX, startY, line, lineno, parentLayer) ->

  # Calculate dimensions and coordinates for each row of the keyboard
  #   - Stretch all character keys and use fixed width for action keys
  #   - All keys get a right padding. First key gets a left padding also
  #   - line 2 must always have extra left and right padding

  # Constants
  padding = 5
  actionKeyWidth = 70
  buttonHeight = 80
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

    interlinePadding = 10
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
    return startY + buttonHeight + interlinePadding


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
