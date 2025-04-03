class_name MessageInterface
extends PanelContainer
## Container for displaying queued text and saving text in a history buffer.
##
## Default message interface for displaying text to the player. Contains methods
## for displaying immediate, progressive, or flash text with [member _delay].
## Newly queued text may be set to any of these modes, or advancing text may be
## sped up once for flash or again for instant. In the context of this class,
## "flash" refers to the text appearing one character per frame.[br][br]
## Currently, three formatting tags and two commands are recognised. They are
## [code][[pause]][/code], [code][[wait]][/code], [code][i][/code],
## [code][b][/code], and [code][s][/code]. All other commands and tags may still
## work, but their behaviour is not directly predictable. Future versions will
## explicitly disallow unsupported tags, causing them to display verbatim.

## Emitted when two flags are met: [member _waited] has been switched from
## [code]true[/code] to [code]false[/code] [b]and[/b] [member _message_progress]
## is greater than the length of the current message.
signal cleared_message()

## Array of the last 256 messages to be queued. May be used as a sort of messaging
## log if desired. This history is public at present, but it should be privatised
## in the future and only accessed with appropriate "get" methodology.
var message_history : Array[String] = []
## Time in seconds before the next character should be displayed. This value should
## only be set as a queue operation [method queue_text] or [method flash_text],
## or as an update operation via [method _rush_text] or [method _instant_text].[br][br]
## This is reset to zero as part of the [signal cleared_message] sequence.
var _delay : int = 0
## Flag to indicate that a message should be in progress. Technically this is
## superfluous, but it serves a good point when determining how to progress from
## frame to frame.
var _queued : bool = false
## Flag to indicate whether progress is unpaused. Used in conjunction with
## [code][[pause]][/code] command.
var _active : bool = false
## Flag to indicated that progress is on hold until user input, which is currently
## not listened for, but will be in a later update. In addition, the flag may
## be cleared manually using [method advance], which will be how [ScreenInterface]
## interacts with [code]_waited[/code] messages.
var _waited : bool = false
## Symbol(s) to display while text is [code]_waited[/code]. Not used when
## [code]_active[/code] is [code]false[/code].
var _blinker : String = ""
## Index of current message. Once the message_history is full, this will be held
## at [code]255[/code].
var _current_message : int = -1
## Index of caret within message text.
var _message_progress : int = -1
## Timer for update events within the process function. This is reset to a known
## value after each value. Counts time in milliseconds.
var _adhoc_timer : int = -1

var _clearing : bool = false
var _lines : Array[int] = []
@export var line_size : Vector2i
@export var char_size : Vector2i

## Time in milliseconds for [member _blinker] to (dis)appear
const _BLINK : int = 500
## Time in milliseconds for pauses caused by [code][[pause]][/code] signals
const _PAUSE : int = 750
const _CLEAR : int = 125

func _ready() : pass
	#queue_text("123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890") # pass #
	#queue_text("This is some[[pause]] text [[ for [b]testing [i]the [s]features") # pass #
func _process(delta: float) :
	if !visible : return
	if _clearing :
		if _adhoc_timer <= 0 : 
			_adhoc_timer = _CLEAR
			$RichText.text = $RichText.text.substr(_lines[0])
			_lines.pop_front()
			if _lines.is_empty() :
				_clearing = false
				advance()
	elif _waited :
		if _adhoc_timer <= 0 :
			_adhoc_timer = _BLINK
			if $RichText.text.ends_with(_blinker) : $RichText.text = $RichText.text.trim_suffix(_blinker)
			else : $RichText.text = $RichText.text + _blinker
	elif _queued :
		if _active :
			var nextChar : bool = false
			if _delay == 0 :
				nextChar = true
			elif _delay < 0 :
				var currentString = message_history[_current_message].replace("[[pause]]","").replace("[[wait]]","")
				var maxLength = line_size.x * (line_size.y - 2)
				var fullStrip = currentString.replace("[b]","").replace("[/b]","").replace("[i]","").replace("[/i]","").replace("[s]","").replace("[/s]","")
				if fullStrip.length() < maxLength :
					_message_progress = currentString.length() + 1
					$RichText.text = currentString
					_lines.push_back($RichText.text.length())
					_queued = false
					_wait_text()
				else:
					
					pass
				pass # TODO : figure out how to advance text until it's done
			else :
				if _adhoc_timer <= 0 :
					nextChar = true
					_adhoc_timer = _delay
				else : nextChar = false
			if nextChar :
				var currentString = message_history[_current_message]
				var isCommand = false
				var nextChunk : String = ""
				if currentString[_message_progress] == "[":
					if currentString[_message_progress+1] == "[":
						var closeTag = currentString.find("]]",_message_progress)
						if closeTag > 0 :
							var commandText = currentString.substr(_message_progress,closeTag+2-_message_progress)
							match commandText :
								"[[pause]]" :
									_message_progress += 9
									isCommand = true
									_active = false
									_adhoc_timer = _PAUSE
								"[[wait]]" :
									_message_progress += 8
									isCommand = true
									var lines_length = _lines.reduce(func(accum,number):return accum+number,0)
									_lines.push_back($RichText.text.length()-lines_length)
									_wait_text()
								_: nextChunk = currentString[_message_progress]
						else : nextChunk = currentString[_message_progress]
					else:
						var closeTag = currentString.find("]",_message_progress)
						if closeTag > 0 :
							var commandText = currentString.substr(_message_progress,closeTag+1-_message_progress)
							match commandText :
								"[i]","[b]","[s]","[/i]","[/b]","[/s]" :
									_message_progress = closeTag+1
									nextChunk = commandText+currentString[_message_progress]
								_: nextChunk = currentString[_message_progress]
						else : nextChunk = currentString[_message_progress]
				else :
					nextChunk = currentString[_message_progress]
				if !isCommand :
					$RichText.text += nextChunk
					_message_progress += 1
					if _message_progress >= currentString.length() :
						var lines_length = _lines.reduce(func(accum,number):return accum+number,0)
						_lines.push_back($RichText.text.length()-lines_length)
						_wait_text()
					var reducedText = $RichText.text.replace("[b]","").replace("[/b]","").replace("[i]","").replace("[/i]","").replace("[s]","").replace("[/s]","")
					var lines_length = _lines.reduce(func(accum,number):return accum+number,0)
					if reducedText.length() - lines_length > line_size.x :
						var lastSpace = $RichText.text.rfind(" ")
						if reducedText.length() - lastSpace > line_size.x : _lines.push_back(line_size.x)
						elif lastSpace > 0 : _lines.push_back(lastSpace - lines_length)
					if _lines.size()+2 >= line_size.y :
						_lines.push_back(reducedText.length() - lines_length - _lines[-1])
						_wait_text()
		elif _adhoc_timer <= 0 : _active = true
	else :
		_delay = 0
		_queued = false
		_active = false
		_waited = false
		_adhoc_timer = -1
		cleared_message.emit()
		return
	_adhoc_timer = _adhoc_timer - int(delta * 1000)
	pass

## Adds new text to [member message_history], which saves the most recent 256
## messages the player has seen. These are cleared when the game is exited in order
## to prevent wasted space in saved games. In addition the [member _queued] and
## [member _active] flags are set, and [member _delay] is configured.
func queue_text(text : String,local_delay : float = 0.0625) :
	if message_history.size() == 256 : message_history.pop_front()
	_queued = true
	_active = true
	_delay = int(local_delay * 1000)
	_current_message = message_history.size()
	message_history.push_back(text)
	_message_progress = 0

## Adds new text to [member message_history], which saves the most recent 256
## messages the player has seen. These are cleared when the game is exited in order
## to prevent wasted space in saved games. In addition the [member _queued] and
## [member _active] flags are set, and [member _delay] is set to zero.[br][br]
## Short-hand for [code]queue_text(text,0)[/code]
func flash_text(text : String) : queue_text(text,0)

## Sets text to advance frame-by-frame.
func _rush_text() : set_deferred("_delay",0)
## Sets text to display instantly.
func _instant_text() : set_deferred("_delay",-1)

## Sets [member _waited] flag and configures [member _blinker] as a symbol to blink
## at the end of the currently displayed text. While waiting, the blinker will blink
## at a rate set in [constant _BLINK]. Upon a GUI input, [method advance] is called.
func _wait_text(local_blinker : String = "->") :
	_waited = true
	_blinker = "[right]"+local_blinker+"[/right]"

## Advances text from a wait state. Checks if the message is finished displaying
## and signals [ScreenInterface] that it's time to clear the [MessageInterface].
## This is public to allow external objects to unpause waiting or speed up text
## but should be used sparingly.
func advance() :
	if _clearing : return
	if _waited :
		if !_lines.is_empty() :
			_clearing = true
			return
		# clear blinker, if necessary
		if $RichText.text.ends_with(_blinker) : $RichText.text = $RichText.text.trim_suffix(_blinker)
		if _message_progress >= message_history[_current_message].length() :
			_delay = 0
			_queued = false
			_active = false
			_waited = false
			cleared_message.emit()
		_waited = false
	elif !_active : _active = true
	elif _delay > 0 : _rush_text()
	elif _delay == 0 : _instant_text()

## Listener for input events. If [code]_waited[/code], then [method advance] is
## called. If not [code]_waited[/code], progressively speeds up text from current
## [member _delay] to 0, from 0 to -1.
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion : return
	if event is InputEventMouseButton and !event.pressed : return
	if event is InputEventKey and !event.pressed : return
	if _waited : advance()
	elif !_active : _active = true
	elif _delay > 0 : _rush_text()
	elif _delay == 0 : _instant_text()
