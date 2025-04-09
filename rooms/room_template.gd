extends Control

signal exit_clicked(who : ExitsNode)
signal structure_clicked(who : StructuresNode)
signal item_clicked(who : ItemsNode)

func _ready() :
	# TODO : Check global flags [template task]
	# TODO : Adjust room based on global flags

	for node in $Structures.get_children() : node.connect("clicked",_on_structure_clicked)
	for node in $Exits.get_children() : node.connect("clicked",_on_exit_clicked)
	for node in $Items.get_children() : node.connect("clicked",_on_item_clicked)
	connect("resized",_on_resized)
	connect("tree_exiting",_destructor)
func _process(_delta: float) : pass
func _destructor() :
	for node in $Structures.get_children() : node.queue_free()
	for node in $Exits.get_children() : node.queue_free()
	for node in $Items.get_children() : node.queue_free()
	for node in get_children() : node.queue_free()

func _on_resized():
	for node in $Structures.get_children() :
		# The following lines will need to be changed to be more general, but it'll hold for now.
		# In order to make it more robust, we need a global variable for aspect and default size.
		node.position = node.proportion * $Background.size.x / 3
		node.size = node.custom_minimum_size * ($Background.size.x / 240)
	for node in $Exits.get_children() :
		# The following lines will need to be changed to be more general, but it'll hold for now.
		# In order to make it more robust, we need a global variable for aspect and default size.
		node.position = node.proportion * $Background.size.x / 3
		node.size = node.custom_minimum_size * ($Background.size.x / 240)
	for node in $Items.get_children() :
		# The following lines will need to be changed to be more general, but it'll hold for now.
		# In order to make it more robust, we need a global variable for aspect and default size.
		node.position = node.proportion * $Background.size.x / 3
		node.size = node.custom_minimum_size * ($Background.size.x / 240)

func _on_exit_clicked(who : ExitsNode) :
	exit_clicked.emit(who)
func _on_structure_clicked(who : StructuresNode) :
	structure_clicked.emit(who) 
func _on_item_clicked(who : ItemsNode) :
	item_clicked.emit(who)
