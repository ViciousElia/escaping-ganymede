class_name NavigationMap
extends VBoxContainer

var abstr_ext = load("res://interfaces/abstract_exit.tscn")

const EXIT_SIZE = Vector2(16,16)

func _ready() : pass
func _process(delta: float) : pass

func rebuild_map(exits : Control) :
	for child in $AbstractMap.get_children() :
		child.queue_free()
	for child in exits.get_children() :
		var newExit = abstr_ext.instantiate()
		newExit.initialise(child)


func _on_resized() -> void:
	var refSize = $AbstractMap.size
	for child in $AbstractMap.get_children() :
		child.position.x = child.up_left.x * refSize.x - EXIT_SIZE.x
		child.position.y = child.up_left.y * refSize.y - EXIT_SIZE.y
