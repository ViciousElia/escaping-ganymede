class_name NavigationMap
extends Control
## Screen region that controls the in-game navigation map.
##
## Includes the move command, which enables the primary navigation method, and
## an abstract minimap that serves as a way to navigate for both visible and
## non-visible exits, so long as they are active.

## Import of the [AbstractExit] class for use in [method rebuild_map]
var abstr_ext = load("res://interfaces/abstract_exit.tscn")

## Uniform exit size to be passed around as necessary. Used to assure that
## [AbstractExit]s are positioned and sized correctly. Default behaviour is for 
## the exit texture to scale to the height and width defined here, ignoring
## aspect ratio.
const EXIT_SIZE = Vector2(16,16)

## Emitted when an [AbstractExit] is clicked. Serves as a pass-through event
## to allow [ScreenInterface] to handle the next steps. Passes whether
## [member MoveCommand] is pressed.
signal exit_clicked(move_pressed : bool,exit_node : ExitsNode,abst_node : AbstractExit)

func _ready() : pass
func _process(_delta: float) : pass

## To be called from [ScreenInterface] when a room loads. Removes old
## [AbstractExit]s and re-initialises them to match the new room.
func rebuild_map(exits : Control) :
	for child in $AbstractMap.get_children() :
		child.queue_free()
	for child in exits.get_children() :
		var newExit = abstr_ext.instantiate()
		newExit.initialise(child)
		newExit.custom_minimum_size = EXIT_SIZE
		$AbstractMap.add_child(newExit)
		newExit.connect("exit_clicked",pass_click)
	_on_resized()

## Listener for resize events. Places the exits around the room. Also called on
## rebuild so that the map is arranged nicely from room entry.
func _on_resized():
	var refSize = $AbstractMap.size
	for child in $AbstractMap.get_children() :
		child.position.x = child.up_left.x * refSize.x - EXIT_SIZE.x
		child.position.y = child.up_left.y * refSize.y - EXIT_SIZE.y

## Pass-through method for clicked exits. Assigned from [method rebuild_map].
func pass_click(exit_node : ExitsNode,abst_node : AbstractExit) :
	exit_clicked.emit($MoveCommand.button_pressed,exit_node,abst_node)
