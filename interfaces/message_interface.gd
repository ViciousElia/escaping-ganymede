class_name MessageInterface
extends PanelContainer

signal cleared_message()

var message_history : Array[String] = []
var delay : int = 0
var queued : bool = false
var active : bool = false
var waited : bool = false
var inTag : bool = false
var blinker : String = ""
var current_message : int = -1
var message_progress : int = -1

var adhoc_timer : int = -1

const BLINK : int = 500

func _ready() : pass
func _process(delta: float) :
	if !visible : return
	if waited :
		if adhoc_timer <= 0 :
			adhoc_timer = BLINK
			if $RichText.text.endswith(blinker) : $RichText.text = $RichText.text.trim_suffix(blinker)
			else : $RichText.text = $RichText.text + blinker
	elif queued :
		if active :
			var nextChar : bool = false
			var nextChunk : String = ""
			if delay == 0 : nextChar = true
			elif delay < 0 :
				nextChar = true
				pass # TODO : figure out how to advance text until it's full
			else :
				if adhoc_timer <= 0 :
					nextChar = true
					adhoc_timer = delay
					pass # TODO : figure out how to read commands and tags from text.
			pass # TODO : identify when the buffer is full
		else :
			if adhoc_timer <= 0 : active = true
# else check queued ... if so, check active ... if so, do letter process
#		letter process -> check timer, if <=0, next letter
#		next letter -> check if command. check if bbcode tag. if neither, letter
#				command -> interpret, advance, do not add command to history
#				bbcode tag -> interpret, set nesting, add tag to history
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
func queue_text(text : String,localDelay : float = 0.25) :
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
	delay = -1
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
