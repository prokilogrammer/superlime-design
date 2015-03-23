document.body.style.cursor = "auto"

log = (args...) ->
  $.ajax
    type: "POST",
    url: '/log',
    data: JSON.stringify(args),
    processData: false,
    dataType: 'application/json'

screenWidth = 640
screenHeight = 1130

codeLayer = new Layer
    height: screenHeight * 0.65,
    width: screenWidth,
    backgroundColor: "blue",
    scrollHorizontal: false

codeLayer.customData = {text: ''}
codeLayer.html = ''

keyboardLayer = new Layer
    name: 'keyboardLayer',
    y: codeLayer.height,
    height: screenHeight * 0.35,
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
  charstats: {}  # Mean time to type a character

  # Used internally for tracking
  _internal: {
    startTime: 0,
    endTime: 0,
    lastCharTime: 0
  }
}

metrics = {};
tracking = false;

remoteReportMetric = () ->
  # Hacky as fuck reporting of metrics back to hosting server
  xmlhttp = new XMLHttpRequest();
  xmlhttp.open("GET", "/report?val=" + JSON.stringify(metrics, null,2), true)
  xmlhttp.send()

stopTracking = () ->
  tracking = false
  metrics._internal.endTime = Date.now();
  metrics.totalDuration = metrics._internal.endTime - metrics._internal.startTime
  console.log "METRICS", JSON.stringify(metrics, null, 2)
  remoteReportMetric()

startTracking = () ->
  tracking = true
  metrics = _.cloneDeep(defaultMetrics)
  metrics._internal.startTime = Date.now();

reportAction = (key) ->
  if !tracking
    return

  # If first key typed is an action key, record it. This will accurately track time taken to type first char.
  if !metrics._internal.lastCharTime
    metrics._internal.lastCharTime = Date.now();

  metrics.numStrokes.action += 1

reportChar = (char) ->
  if !tracking
    return

  now = Date.now()

  metrics.numBackspaces += if char is '\b' then 1 else 0
  metrics.numStrokes.char += 1

  ## Store char stats
  if !_.has(metrics.charstats, char)
    metrics.charstats[char] = {timeToType: 0, count: 0}

  lastCharTime = metrics._internal.lastCharTime
  metrics._internal.lastCharTime = now

  # Not enough data to store for first character
  if lastCharTime
    timeToType = now - lastCharTime
    metrics.charstats[char].timeToType += timeToType
    metrics.charstats[char].count += 1

addToCode = (char) ->

    if char is null
      # Nothing to add if char is null
      return
    else if char is '\b'
      codeLayer.customData.text = codeLayer.customData.text.slice(0, -1);
    else
      if char == '\t'
        char = '  '  # one tab = two spaces
      codeLayer.customData.text += char

    codeLayer.html = "<div class='code'><pre>" + codeLayer.customData.text + "<span class='blink'>|</span></pre></div>"

isFixedWidthKey = (key) ->
  return key.moreClasses is 'action'

keyboardRowDimensions = (startX, startY, line, lineno, parentLayer) ->

  # Calculate dimensions and coordinates for each row of the keyboard
  #   - Stretch all character keys and use fixed width for action keys
  #   - line 2 must always have extra left and right padding
  #   - To make the clickable area fill the gutter between keys, all keys get a right border. Since
  #     borders are within the div's height/width, don't add the border size when calculate key size.

  # Constants
  padding = 5
  actionKeyWidth = 75
  buttonHeight = 85
  line2Padding = 30

  lineWidth = if lineno isnt 2 then parentLayer.width else (parentLayer.width - 2*line2Padding)

  # Calculate width fixed size buttons
  fixedSize = 0
  totalPadding = padding   # account for left padding for first button
  numNonActionKeys = 0
  _.forEach line, (key) ->
    if isFixedWidthKey(key)
      fixedSize += actionKeyWidth
    else
      numNonActionKeys++

  # Distribute remaining space to character keys
  buttonWidth = (lineWidth - fixedSize - totalPadding)/numNonActionKeys

  # first key gets a left padding
  startX = if lineno is 2 then (startX + line2Padding + padding) else (startX + padding)

  return [startX, startY, buttonWidth, buttonHeight, padding, actionKeyWidth]


drawKeyboardRow = (startX, startY, line, lineno, parentLayer, viewName) ->

    interlinePadding = 10
    [startX, startY, buttonWidth, buttonHeight, padding, actionKeyWidth] = keyboardRowDimensions(startX, startY, line, lineno, parentLayer)

#    console.log lineno, startX, startY, buttonWidth, buttonHeight, padding, actionKeyWidth

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

        clickLayer = new Layer
            superLayer: parentLayer,
            x: curX,
            y: startY,
            height: buttonLayer.height,
            width: buttonLayer.width,
            backgroundColor: 'transparent'

        buttonLayer.placeBehind(clickLayer);
        clickLayer.customData = {};
        clickLayer.customData.buttonLayer = buttonLayer;
        clickLayer.customData.original = {
          height: clickLayer.height,
          width: clickLayer.width
          x: clickLayer.x,
          y: clickLayer.y
        }
        clickLayers[key.value] = clickLayer;  # Store map of char to click layer.

        curX += (width)
        buttonLayer.style.borderRight = padding + "px solid red";
        buttonLayer.html = html
        buttonLayer.keyData = key

        addButtonToPrediction(viewName, buttonLayer.screenFrame.x, buttonLayer.screenFrame.y, buttonLayer.height, buttonLayer.width, key.value);
#        clickLayer.on Events.Click, handleKeyClick

    # Return y position of next row for chaining
    return startY + buttonHeight + interlinePadding


handleKeyClick = (event, clickLayer) ->
  layer = clickLayer.customData.buttonLayer;
  switch layer.keyData.action
      when 'data' then addToCode(layer.keyData.value); reportChar(layer.keyData.value); adjustClickArea();
      when 'showView' then showKeyboardView(layer.keyData.value); reportAction(layer.keyData)
      else console.log "Unsupport key action", layer.keyData


nextCharProbability = {};

loadNextCharProbability = (cb) ->
  allCharsInKeyboard = _.sortBy(_.keys(clickLayers));
  $.getJSON "/nextcharprob", (data) ->

    _.forOwn data, (freqmap, thischar) ->
      if !_.contains(allCharsInKeyboard, thischar)
        return

      total = freqmap.total
      nextCharProbability[thischar] = [];
      _.forOwn freqmap, (freq, nextchar) ->
        if !_.contains(allCharsInKeyboard, nextchar)
          return

        p = freq.freq/total
        if p > 0.01    # Keep only significant items here.
          nextCharProbability[thischar].push({char: nextchar, p: p})

    console.log(nextCharProbability);
    cb(null)


adjustClickArea = () ->

  # reset click area for all layers
  for layer in _.values(clickLayers)
    layer.x = layer.customData.original.x;
    layer.y = layer.customData.original.y;
    layer.width = layer.customData.original.width;
    layer.height = layer.customData.original.height;
#    layer.backgroundColor = "transparent";


  # Get current view contents
  code = codeLayer.customData.text;

  # For testing purposes, here is a static size map
  nextchar = nextCharProbability;

  # Additional size for clickable area
  extra = {width: 30, height: 30}

  prevchar = _.last(code)
  console.log(code, prevchar)
  if nextchar[prevchar]
    for next in nextchar[prevchar]
      if !_.has(clickLayers, next.char)
        continue

      layer = clickLayers[next.char]
      layer.width = layer.customData.original.width + extra.width * next.p
      layer.height = layer.customData.original.height + extra.height * next.p
      layer.x = layer.customData.original.x - Math.round((extra.width * next.p)/2)
      layer.y = layer.customData.original.y - Math.round((extra.height * next.p)/2)
#      layer.backgroundColor = "yellow"


  # Adjust z-index of click layers based on area of the layer. Bigger layers must be on the top
  clickLayerSmallToBig = _.sortBy _.values(clickLayers), (layer) ->
    return layer.width * layer.height;

  minZIndex = _.min(_.map(_.values(clickLayers), (layer) -> return layer.index ))
  prevArea = 0
  for layer in clickLayerSmallToBig
    layer.index = minZIndex

    # Layers with same area can get the same z-index. Only when area changes, I increment the index
    # Because layers are sorted, current layer is always bigger than previous layer.
    if prevArea != (layer.width * layer.height)
      prevArea = layer.width * layer.height
      minZIndex++


# For each view, create a view layer with keys as its sublayer. When toggling between views,
# simply bring the view to the front
viewLayers = {}
clickLayers = {}

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
            ypos = drawKeyboardRow 0, ypos, line, lineno, viewLayers[viewName], viewName
            lineno++

    showKeyboardView(keymap.meta.startView);

# render the keyboard
#renderKeyboard keyboardLayer
#loadNextCharProbability (err) ->
#  if err
#    return console.log err;

###################### Canvas Layer stuff ###################
drawClickFeedback = (x, y) ->

  feedbackCircle = new Layer
    name: 'feedbackCircle'
    x: x,
    y: y,
    width: 20,
    height: 20,
    backgroundColor: "magenta"

  feedbackCircle.style.border = "10px solid magenta"
  feedbackCircle.borderRadius = feedbackCircle.width/2

  feedbackCircle.animate({
    properties: {scale: 2, opacity: 0}
    time: 0.5,
#    curve: "ease-in-out"
  })

  feedbackCircle.on Events.AnimationEnd, (event, layer) ->
    layer.destroy()

moveCodeCharHighlight = () ->
  text = codeLayer.customData.text;
  prevHighlightChar = text[codeLayer.customData.highlightPos]

  codeLayer.customData.highlightPos += 1
  highlightPos = codeLayer.customData.highlightPos

  before = ''
  if (highlightPos > 0)
    before = text.slice(0, highlightPos)

  after = text.slice(highlightPos+1, text.length)

  at = ''
  if (highlightPos < text.length)
    at = text[highlightPos]

  codeLayer.html = "<div class='code'><pre>" + before + "<span class='highlight'>" + at + "</span>" + after + "</pre></div>"
  return prevHighlightChar

#registerCanvasCharClick = (char, x, y) ->
#  # save event that user touched at pos x,y to type 'char'
#  if !_.has(metrics, 'canvasClickTrack')
#    return
#
#  metrics.canvasClickTrack.push({char: char, x: x, y: y})
#
#canvasClickHandler = (event, canvasLayer) ->
#  drawClickFeedback(event.pageX, event.pageY)
#  clickedChar = moveCodeCharHighlight()
#  registerCanvasCharClick clickedChar, event.pageX, event.pageY

renderCanvasLayer = (kbLayer) ->
  codeLayer.customData.highlightPos = -1;

  canvasLayer = new Layer
    x: kbLayer.x,
    y: kbLayer.y,
    width: kbLayer.width,
    height: kbLayer.height,
    backgroundColor: "rgba(0,255,0,0.9)"
  canvasLayer.on Events.Click, canvasClickHandler

#modifyMetricForCanvas = () ->
#  defaultMetrics['canvasClickTrack'] = []
#
#renderCanvasLayer(keyboardLayer)
#addToCode("""def init self fun args
#name none app url
#namespaces none self kwargs
#if namespaces x for x in
#namespaces in x else self
#namespaces join if hasattr
#func name self path return
#resolvermatch func args
#repr getitem index""")
#moveCodeCharHighlight()
#modifyMetricForCanvas()



########### Predictive Keyboard Stuff ############
# Predictions layout:
# {
#  viewName1: {
#   x1: {y1: {}, y2: {}...},
#   x2: {y1: {}, y2: {}},
#   ....
#  },
#  viewName2: {.......}
# }
#
#  Prediction obj for each x,y pos has following structure:
#   { freq: [10], chars: [10] }
#
#  When the baseline qwerty is laid out, it will populate this map.
predictions = {}

addToPredictions = (viewName, x, y, char, incrementFn) ->
  EMPTY_HISTORY_ENTRY = {freq: 0, char: ''}
  MAX_HISTORY = 10

  if (!_.has(predictions, viewName)) then predictions[viewName] = {}
  if (!_.has(predictions[viewName], x)) then predictions[viewName][x] = {}
  if (!_.has(predictions[viewName][x], y)) then predictions[viewName][x][y] = []

  history = predictions[viewName][x][y]
  index = _.findIndex(history, 'char', char);
  if index == -1
    # Char not found. Add it
    # If history is not full, add to the end. We will sort the array later to keep in right order
    # If history is full, find the char with lowest frequency and replace it
    if history.length < MAX_HISTORY
      history.push(EMPTY_HISTORY_ENTRY)
      index = history.length-1
    else
      console.log("History for char " + char + " is full. ", history);
      leastFreqIx = -1; leastFreq = -Infinity
      _.forEach history, (obj, ix) ->
        if obj && obj.freq < leastFreq
          leastFreq = obj.freq
          leastFreqIx = ix
      history[leastFreqIx] = EMPTY_HISTORY_ENTRY
      index = leastFreqIx

  # Either char is found, or newly added. Anyway 'index' is the position of the char
  history[index].freq += if incrementFn then incrementFn(history[index].freq) else 1;
  history[index].char = char

  # Sort the history by frequency for quick predictions
  # NOTE: This creates a new array. Might bloat memory/gc
  predictions[viewName][x][y] = _.sortByAll(history, 'freq')

getPrediction = (viewName, x, y) ->
  if predictions && predictions[viewName] && predictions[viewName][x] && predictions[viewName][x][y] && predictions[viewName][x][y][0]
    return predictions[viewName][x][y][0]['char']
  else
    return null

wrongPrediction = (viewName, x, y, predictedChar, correctChar) ->
  PENALIZE = (val) -> return val*0.9  # Reduce val by 10%

  console.log("WRONG PREDICTION ", viewName, x, y, predictedChar, correctChar)

  # Predicted char is wrong. Find the history entry and penalize it
  history = predictions[viewName][x][y]
  ix = _.findIndex(history, 'char', predictedChar) # This should exist
  if ix != -1
    history[ix].freq = PENALIZE(history[ix].freq);
  else
    console.error("PREDICTED CHAR " + predictedChar + " DOESN'T EXIST IN HISTORY: " + x + ":" + y + " - " + history);

  # Add correct char to predictions. it will implicitly sort history
  addToPredictions(viewName, x, y, correctChar);


correctPrediction = (viewName, x, y, predictedChar) ->
  # No-op for now. I might reward correct predictions later.
  console.log("CORRECT PREDICTION ", viewName, x, y, predictedChar)
  return

# Store information about the latest unvalidated prediction. It will be used later to validate predictions
latestUnvalidatedPrediction = null;
lastCharIsBackspace = false;

validatePrediction = (currentChar, viewName, x, y) ->
  if !latestUnvalidatedPrediction || currentChar == null
    # no last known prediction (OR) no prediction for pos x,y at all
    # Either way store the position to be validated by next char press
    latestUnvalidatedPrediction = {char: currentChar, x: x, y: y, viewName: viewName}
    return

  # Here are the scenarios for correct/wrong predictions
  # - latestUnvalidatedChar == null && currentChar != 'backspace'
  #     addToPrediction() because last prediction resulted in no value. Assume next char to be the correct answer for last (x,y) pos
  # - latestUnvalidatedChar != null && currentChar != 'backspace'
  #     CorrectPrediction(): User has accepted the prev char and moved on to the next char. Accept my prediction
  # - latestUnvalidatedChar != null && currentChar == 'backspace' && lastCharIsBackspace == false
  #     Probably a wrong prediction: User deleted the prev char. It could be because the prediction was wrong or that they just didn't want the char
  #        Mark the backspace and continue
  # - currentChar == 'backspace' && lastCharIsBackspace == true
  #     Two backspaces in a row. User is deleting chars because she doesn't want them.
  #     Accept the lastUnvalidatedChar and reset it. Any alphanumeric char typed after backspace sequence will begin the prediction cycle afresh.

  if currentChar == '\b'
    if lastCharIsBackspace
      # Two backspaces in a row
      console.log("DOUBLE BACKSPACE");
      correctPrediction(latestUnvalidatedPrediction.viewName, latestUnvalidatedPrediction.x, latestUnvalidatedPrediction.y, latestUnvalidatedPrediction.char)
      latestUnvalidatedPrediction = null
    lastCharIsBackspace = true
  else
    if latestUnvalidatedPrediction.char == null
      addToPredictions(latestUnvalidatedPrediction.viewName, latestUnvalidatedPrediction.x, latestUnvalidatedPrediction.y, currentChar)
    else if lastCharIsBackspace
      # Sequence of char press: latestUnvalidatedChar, \b, non-backspace char. So latestUnvalidatedChar prediction is wrong
      wrongPrediction(latestUnvalidatedPrediction.viewName, latestUnvalidatedPrediction.x, latestUnvalidatedPrediction.y, latestUnvalidatedPrediction.char, currentChar)
    else
      correctPrediction(latestUnvalidatedPrediction.viewName, latestUnvalidatedPrediction.x, latestUnvalidatedPrediction.y, latestUnvalidatedPrediction.char)
    lastCharIsBackspace = false


addButtonToPrediction = (viewName, buttonX, buttonY, buttonHeight, buttonWidth, char) ->
  if viewName != 'view1'
    return

  buttonX = Math.round(buttonX)
  buttonY = Math.round(buttonY)
  console.log(buttonX, buttonY, char);
  for x in [buttonX..(buttonX + buttonWidth)] by 1
    for y in [buttonY..(buttonY + buttonHeight)] by 1
      addToPredictions(viewName, x, y, char)


canvasClickHandler = (event, layer) ->
  DEFAULT_VIEW = 'view1'

  x = event.pageX; y = event.pageY;
  drawClickFeedback(x, y)

  char = getPrediction(DEFAULT_VIEW, x, y)
  console.log("PREDICTED CHAR ", x, y, char);
  log("PREDICTED CHAR ", x, y, char);
  validatePrediction(char, DEFAULT_VIEW, x, y)
  addToCode(char)

savePredictions = () ->
  console.log("SAVING PREDICTIONS");
  $.ajax
    type: "POST"
    url: "/predictions",
    data: JSON.stringify(predictions),
    processData: false,
    contentType: 'application/json'

renderKeyboard(keyboardLayer)
renderCanvasLayer(keyboardLayer)
log("READY!")

