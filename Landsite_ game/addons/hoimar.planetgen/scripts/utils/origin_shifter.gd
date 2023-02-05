# Presun vsetkych node do stredu, tak aby boli blizko rodičovi
extends Node

const MAX_DISTANCE := 2000.0 # maximálna vzdialenosť


export(NodePath) var world_node_path
onready var world_node: Spatial = get_node_or_null(world_node_path)
onready var parent := get_parent()


# Zavolaná vtedy ak node prvy krat vstupi do generacie 
func _ready():
	if !world_node:
		world_node = get_node("../..")

func _process(delta):
	if parent.global_transform.origin.length() > MAX_DISTANCE:
		shift_origin()

# posun
func shift_origin():
	var offset: Vector3 = parent.global_transform.origin
	for child in world_node.get_children():
		if child is Spatial:
			child.global_translate(-offset)
