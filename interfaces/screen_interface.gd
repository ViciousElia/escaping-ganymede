class_name ScreenInterface
extends PanelContainer

var navigation_map
var side_panel

func _ready() -> void:
	navigation_map = $MarginAllowance/MainSplit/Control
	side_panel = $MarginAllowance/MainSplit/LeftSplit/MenuSplit/Control
func _process(_delta: float) -> void:
	pass

func _on_resized() -> void:
	print(size)
	var heightPercent = max(min(0.25 * size.y, 240),120)
	var widthPercent = max(min(0.1875*size.x,240),120)
	
	navigation_map.custom_minimum_size.x = widthPercent
	side_panel.custom_minimum_size = Vector2(widthPercent,heightPercent)
	navigation_map.size.x = widthPercent
	side_panel.size = Vector2(widthPercent,heightPercent)
