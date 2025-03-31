class_name AbstractExit
extends TextureRect
## A node intended to represent an exit in an abstract way.
##
## Not intended to be used in isolation. Requires a resource to be defined as
## the exit design. Currently, I've used an SVG that defines a plain circle at
## 90% brightness. Any design can be used, but this one is nostalgic for me.

## Emitted when the node is initialised. Reports where the node should live
## inside its parent. The [signal NavigationMap.resized] action will handle this
## data for all subsequent display needs.
signal position_set(up_left : Vector2,me : AbstractExit)
## Emitted when the node is clicked. Expected to be passed through
## [NavigationMap] up to [ScreenInterface] so it can determine whether the
## necessary [member ScreenInterface.global_flags] are set to allow the player
## to pass through. If not, relevant failure to exit text will be pulled from
## the [ExitsNode] connected to the [AbstractExit] that threw the signal.
signal exit_clicked(exit_node : ExitsNode,me : AbstractExit)

## Top left corner of exit within map. Reported as a [Vector2] where
## [member Vector2.x] and [member Vector2.y] are given as percentages of the
## size of the space where the exit is found. (0,0) is the top left corner of
## the box. (1,1) is the bottom right corner of the box.
var up_left : Vector2
## Associated [ExitsNode] that defines this [AbstractExit]
var exit_node : ExitsNode

func _ready() : pass
func _process(_delta: float) : pass

## To be called when node is created. If not, the node will not function
## correctly.
func initialise(node : ExitsNode) :
	up_left = node.up_left
	exit_node = node
	position_set.emit(up_left,self)

## This is the listener for click events. It fires for any gui event, but it
## [color=red]only[/color] reacts if the event is a mouse click press event of the
## left button. In addition, it reacts when the
## [member InputEventMouseButton.pressed] is true, so the response is
## instantaneous on click.
func _on_click(event: InputEvent) -> void:
	if event is InputEventMouseButton :
		if event.pressed :
			if event.button_index == MOUSE_BUTTON_MASK_LEFT:
				exit_clicked.emit(exit_node,self)
