class_name ExitsNode
extends Control

signal clicked(me : ExitsNode)

var next_room : int = -1
var up_left : Vector2
var exit_flags : Array[String]
@export var messages : Array[String]

func _ready() : pass
func _process(_delta: float) : pass
