class_name MessageInterface
extends PanelContainer
## Container for displaying queued text and saving text in a history buffer.
##
## Default message interface for displaying text to the player. Contains methods
## for displaying immediate, progressive, or flash text with
## [member MessageInterface.delay]. Newly queued text may be set to any of these
## modes, or advancing text may be sped up once for flash or again for instant.
## In the context of this class, "flash" refers to the text appearing one character
## per frame.[br][br]
## Currently, three formatting tags and two commands are recognised. They are
## [code][[pause]][/code], [code][[wait]][/code], [code][i][/code],
## [code][b][/code], and [code][s][/code]. All other commands and tags may still
## work, but their behaviour is not directly predictable. Future versions will
## explicitly disallow unsupported tags, causing them to display verbatim.

## Emitted when two flags are met: [member MessageInterface.waited] has been
## switched from [code]true[/code] to [code]false[/code] [b]and[/b]
## [member MessageInterface.message_progress] is greater than the length of the
## current message.
signal cleared_message()

## Array of the last 256 messages to be queued. May be used as a sort of messaging
## log if desired.
var message_history : Array[String] = []
## Time in seconds before the next character should be displayed. This value should
## only be set as a queue operation [method MessageInterface.queue_text] or
## [method MessageInterface.flash_text], or as an update operation via
## [method MessageInterface.rush_text] or [method MessageInterface.instant_text].[br][br]
## This is reset to zero as part of the [signal MessageInterface.cleared_message]
## sequence.
var delay : int = 0
## Flag to indicate that a message should be in progress. Technically this is
## superfluous, but it serves a good point when determining how to progress from
## frame to frame.
var queued : bool = false
## Flag to indicate whether progress is unpaused. Used in conjunction with
## [code][[pause]][/code] command.
var active : bool = false
## Flag to indicated that progress is on hold until user input, which is currently
## not listened for, but will be in a later update. In addition, the flag may
## be cleared manually using [method MessageInterface.advance], which will be how
## [ScreenInterface] interacts with [code]waited[/code] messages.
var waited : bool = false
## Symbol(s) to display while text is [code]waited[/code]. Not used when
## [code]active[/code] is [code]false[/code].
var blinker : String = ""
## Index of current message. Once the message_history is full, this will be held
## at [code]255[/code].
var current_message : int = -1
## Index of caret within message text.
var message_progress : int = -1
## Timer for update events within the process function. This is reset to a known
## value after each value. Counts time in milliseconds.
var adhoc_timer : int = -1

## Time in milliseconds for [member MessageInterface.blinker] to (dis)appear
const BLINK : int = 500
## Time in milliseconds for pauses caused by [code][[pause]][/code] signals
const PAUSE : int = 750

func _ready() : queue_text("This is some[[pause]] text [[ for [b]testing [i]the [s]features") # pass #
func _process(delta: float) :
	if !visible : return
	if waited :
		if adhoc_timer <= 0 :
			adhoc_timer = BLINK
			if $RichText.text.ends_with(blinker) : $RichText.text = $RichText.text.trim_suffix(blinker)
			else : $RichText.text = $RichText.text + blinker
	elif queued :
		if active :
			var nextChar : bool = false
			if delay == 0 :
				nextChar = true
			elif delay < 0 :
				pass # TODO : figure out how to advance text until it's full
			else :
				if adhoc_timer <= 0 :
					nextChar = true
					adhoc_timer = delay
				else : nextChar = false
			if nextChar :
				var currentString = message_history[current_message]
				var isCommand = false
				var nextChunk : String = ""
				if currentString[message_progress] == "[":
					if currentString[message_progress+1] == "[":
						var closeTag = currentString.find("]]",message_progress)
						if closeTag > 0 :
							var commandText = currentString.substr(message_progress,closeTag+2-message_progress)
							match commandText :
								"[[pause]]" :
									isCommand = true
									active = false
									adhoc_timer = PAUSE
									message_progress += 9
								"[[wait]]" :
									isCommand = true
									message_progress += 8
									wait_text()
								_: nextChunk = currentString[message_progress]
						else : nextChunk = currentString[message_progress]
					else:
						var closeTag = currentString.find("]",message_progress)
						if closeTag > 0 :
							var commandText = currentString.substr(message_progress,closeTag+1-message_progress)
							match commandText :
								"[i]","[b]","[s]","[/i]","[/b]","[/s]" :
									message_progress = closeTag+1
									nextChunk = commandText+currentString[message_progress]
								_: nextChunk = currentString[message_progress]
						else : nextChunk = currentString[message_progress]
				else :
					nextChunk = currentString[message_progress]
				if !isCommand :
					$RichText.text += nextChunk
					message_progress += 1
					if message_progress >= currentString.length() : wait_text()
				pass # TODO : identify when the buffer is full
		elif adhoc_timer <= 0 : active = true
	else :
		delay = 0
		queued = false
		active = false
		waited = false
		adhoc_timer = -1
		cleared_message.emit()
		return
	adhoc_timer = adhoc_timer - int(delta * 1000)
	pass

## Adds new text to [member MessageInterface.message_history], which saves the
## most recent 256 messages the player has seen. These are cleared when the
## game is exited in order to prevent wasted space in saved games. In addition
## the [member MessageInterface.queued] and [member MessageInterface.active]
## flags are set, and [member MessageInterface.delay] is configured.
func queue_text(text : String,localDelay : float = 0.0625) :
	if message_history.size() == 256 : message_history.pop_front()
	queued = true
	active = true
	delay = int(localDelay * 1000)
	current_message = message_history.size()
	message_history.push_back(text)
	message_progress = 0

## Adds new text to [member MessageInterface.message_history], which saves the
## most recent 256 messages the player has seen. These are cleared when the
## game is exited in order to prevent wasted space in saved games. In addition
## the [member MessageInterface.queued] and [member MessageInterface.active]
## flags are set, and [member MessageInterface.delay] is set to zero.
func flash_text(text : String) :
	if message_history.size() == 256 : message_history.pop_front()
	queued = true
	active = true
	delay = 0
	current_message = message_history.size()
	message_history.push_back(text)
	message_progress = 0

## Sets [member MessageInterface.waited] flag and configures
## [member MessageInterface.blinker] as a symbol to blink at the end of the
## currently displayed text. While waiting, the blinker will blink at a rate set
## in [member MessageInterface.BLINK]. Upon a GUI input,
## [method MessageInterface.advance] is called.
func wait_text(localBlinker : String = "->") :
	waited = true
	blinker = localBlinker

## Sets text to advance frame-by-frame.
func rush_text() : set_deferred("delay",0)
## Sets text to display instantly.
func instant_text() : set_deferred("delay",-1)

## Advances text from a wait state. Checks if the message is finished displaying
## and signals [ScreenInterface] that it's time to clear the [MessageInterface].
func advance() :
	if waited :
		waited = false
		## TODO : clear visible lines ... somehow
		if message_progress >= message_history[current_message].length() :
			delay = 0
			queued = false
			active = false
			waited = false
			cleared_message.emit()
	else :
		pass
