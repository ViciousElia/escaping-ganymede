class_name ItemsNode
extends Control

@export var proportion : Vector2 = Vector2.ZERO
@export var minimum_size : Vector2 = Vector2.ONE
@export var messages : Dictionary

signal clicked(me : ItemsNode)

func _ready() : custom_minimum_size = minimum_size
func _process(_delta : float) : pass

func _on_resized() : $ItemShape.scale = size / custom_minimum_size

func _on_shape_input(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton :
		if event.button_index == MOUSE_BUTTON_LEFT :
			clicked.emit(self)
