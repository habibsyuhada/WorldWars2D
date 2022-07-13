extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var territory_tile = get_node_or_null("/root/World/Navigation2D/Territory")
onready var world_tile = get_node_or_null("/root/World/Navigation2D/TileMap")
onready var astar_tile = get_node_or_null("/root/World/Navigation2D/Astar_Tilemap")


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
