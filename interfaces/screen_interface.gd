class_name ScreenInterface
extends PanelContainer
## Screen layout that contains the various interactable elements available during play.

var project_theme = load(ProjectSettings.get_setting("gui/theme/custom"))

## Placeholder for the [NavigationMap] interface.
var navigation_map
var side_panel
var menu_panel
var message_panel

var cursors = {
	"navigation" : load("res://themes/cursors/cursor_brown.png"),
	"interaction" : load("res://themes/cursors/cursor_green.png"),
	"agression" : load("res://themes/cursors/cursor_red.png"),
	"Understanding" : load("res://themes/cursors/cursor_yellow.png")
}
# EXAMPLE : Input.set_custom_mouse_cursor(arrow)

var flags : Array[String]

func _ready() -> void:
	side_panel = $MarginAllowance/MainSplit/Control
	navigation_map = $MarginAllowance/MainSplit/LeftSplit/MenuSplit/NavigationMap
	menu_panel = $MarginAllowance/MainSplit/LeftSplit/MenuSplit
	message_panel = $MarginAllowance/MainSplit/LeftSplit/MessageInterface
func _process(_delta: float) -> void:
	pass

func _on_resized() -> void:
	var heightPercent = max(min(0.25 * size.y, 240),120)
	var widthPercent = max(min(0.1875 * size.x,240),120)
	var replace_this_with_durable_code = size.x - widthPercent - 48
	# TODO : replace that with durable code, for fuck's sake
	
	navigation_map.custom_minimum_size = Vector2(widthPercent,heightPercent)
	navigation_map.set_deferred("size",Vector2(widthPercent,heightPercent))
	side_panel.custom_minimum_size.x = widthPercent
	side_panel.set_deferred("size",Vector2(widthPercent,side_panel.size.y))
	message_panel.custom_minimum_size.y = heightPercent
	message_panel.set_deferred("size",Vector2(replace_this_with_durable_code,heightPercent))
	message_panel.line_size.x = replace_this_with_durable_code / message_panel.char_size.x
	message_panel.line_size.y = heightPercent / message_panel.char_size.y


func _on_message_interface_cleared_message() -> void:
	$MarginAllowance/MainSplit/LeftSplit/MessageInterface.set_deferred("visible",false)
	$MarginAllowance/MainSplit/LeftSplit/MenuSplit.visible = true
	pass # Replace with function body.
