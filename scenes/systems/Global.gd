extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var territory_tile = get_node_or_null("/root/World/Navigation2D/Territory")
onready var world_tile = get_node_or_null("/root/World/Navigation2D/TileMap")
onready var astar_tile = get_node_or_null("/root/World/Navigation2D/Astar_Tilemap")

export (PackedScene) var Tree_Instance

export (PackedScene) var House_Instance
export (PackedScene) var Wheat_Field_Instance

export (PackedScene) var Worker_Instance
export (PackedScene) var Swordman_Instance

var team_list = []
var number_team = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
func change_territory(source_position, large, additon, team, force = false):
	if territory_tile:
		var tilepos = territory_tile.world_to_map(source_position)
		tilepos += Vector2(large, large) 
		large += large+additon
		var tile = tilepos
		for y in large:
			tile.y = tilepos.y - y
			for x in large:
				tile.x = tilepos.x - x
				if force:
					territory_tile.set_cell(tile.x, tile, MasterData.team_list.find(team))
				elif territory_tile.get_cell(tile.x, tile.y)  == -1 :
					territory_tile.set_cell(tile.x, tile.y, MasterData.team_list.find(team))

func add_building(object_target):
	var building_container = get_node_or_null("/root/World/Houses")
	if building_container and object_target:
		building_container.add_child(object_target)

func add_people(object_target):
	var people_container = get_node_or_null("/root/World/Map/Char")
	if people_container and object_target:
		people_container.add_child(object_target)

func _on_refresh_resource_timer_timeout():
	get_tree().call_group("Resource", "increase_resource")
