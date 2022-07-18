extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.astar_tile and Global.world_tile:
		for tile in Global.world_tile.get_used_cells():
			if Global.world_tile.get_cell(tile.x, tile.y) in [1] :
				var random = randi()%100+1
				if random > 95:
					var tree = Global.Tree_Instance.instance()
					tree.position = Global.world_tile.map_to_world(tile)
					tree.position += Vector2(8, 8)
					$Trees.add_child(tree)
					var id_astar = Global.astar_tile.astar_node.get_closest_point(Vector3(tile.x, tile.y, 0.0))
					Global.astar_tile.astar_node.set_point_weight_scale(id_astar, 1.5)
			elif Global.world_tile.get_cell(tile.x, tile.y) in [2] :
				var random = randi()%100+1
				if random > 70:
					var tree = Global.Tree_Instance.instance()
					tree.position = Global.world_tile.map_to_world(tile)
					tree.position += Vector2(8, 8)
					$Trees.add_child(tree)
					var id_astar = Global.astar_tile.astar_node.get_closest_point(Vector3(tile.x, tile.y, 0.0))
					Global.astar_tile.astar_node.set_point_weight_scale(id_astar, 1.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
