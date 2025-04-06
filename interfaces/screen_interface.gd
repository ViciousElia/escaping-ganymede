class_name ScreenInterface
extends PanelContainer
## Screen layout that contains the various interactable elements available during play.

var project_theme = load(ProjectSettings.get_setting("gui/theme/custom"))

## Placeholder for the [NavigationMap] interface.
var navigation_map
var side_panel
var menu_panel
var message_panel
var commands_group = load("res://interfaces/command_button_group.tres")

var cursors : Dictionary = {
	"default" : load("res://themes/cursors/cursor_default.png"),
	"navigation" : load("res://themes/cursors/cursor_navigation.png"),
	"interaction" : load("res://themes/cursors/cursor_interaction.png"),
	"aggression" : load("res://themes/cursors/cursor_aggression.png"),
	"investigation" : load("res://themes/cursors/cursor_investigation.png"),
	"unassigned1" : load("res://themes/cursors/cursor_yellow.png"),
	"unassigned2" : load("res://themes/cursors/cursor_brown.png")
}
# EXAMPLE : Input.set_custom_mouse_cursor(arrow)

var flags : Array[String]

func _ready():
	side_panel = $MarginAllowance/MainSplit/Control
	navigation_map = $MarginAllowance/MainSplit/LeftSplit/MenuSplit/NavigationMap
	menu_panel = $MarginAllowance/MainSplit/LeftSplit/MenuSplit
	message_panel = $MarginAllowance/MainSplit/LeftSplit/MessageInterface
	commands_group.connect("pressed",command_changed)
	Input.set_custom_mouse_cursor(cursors.default)
func _process(_delta: float):
	pass

func _on_resized():
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

func command_changed(button : BaseButton) :
	if !button.button_pressed :
		Input.set_custom_mouse_cursor(cursors.default)
	else :
		match button.name :
			"MoveCommand","OpenCommand","CloseCommand" : Input.set_custom_mouse_cursor(cursors.navigation)
			"TakeCommand","UseCommand","DropCommand","InteractCommand" : Input.set_custom_mouse_cursor(cursors.interaction)
			"ExamineCommand","SpeakCommand" : Input.set_custom_mouse_cursor(cursors.investigation)
			"HitCommand" : Input.set_custom_mouse_cursor(cursors.aggression)
			_: Input.set_custom_mouse_cursor(cursors.default)
