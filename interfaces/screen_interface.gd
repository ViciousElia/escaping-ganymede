class_name ScreenInterface
extends PanelContainer

var navigation_map
var side_panel
var menu_panel
var message_panel

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
	var widthPercent = max(min(0.1875*size.x,240),120)
	
	navigation_map.custom_minimum_size = Vector2(widthPercent,heightPercent)
	navigation_map.set_deferred("size",Vector2(widthPercent,heightPercent))
	side_panel.custom_minimum_size.x = widthPercent
	side_panel.set_deferred("size",Vector2(widthPercent,side_panel.size.y))
	message_panel.custom_minimum_size.y = heightPercent
	message_panel.set_deferred("size",Vector2(message_panel.size.x,heightPercent))
