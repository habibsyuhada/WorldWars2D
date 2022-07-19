extends KinematicBody2D

enum {IDLE, SLASH, HURT, FORAGING, GATHERING}
export var state: int = IDLE
var speed = 25
var velocity = Vector2.ZERO

var path = []
var cur_path_idx = 0

var dir_animation = "Down"
export var team = ""
onready var state_anim_machine = $AnimationTree.get("parameters/playback")
var target_node = null
var last_tile_position = null


# Called when the node enters the scene tree for the first time.
func _ready():
	init_team()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_in_group("Worker Foraging " + team) and state != FORAGING:
		state = FORAGING
	elif is_in_group("Worker Gathering " + team) and state != GATHERING:
		state = GATHERING
	elif is_in_group("Worker Idle " + team) and state != IDLE:
		state = IDLE
	match state:
		IDLE:
			idle()
		FORAGING:
			foraging()
		GATHERING:
			gathering()
	
func move_navigation():
	velocity = Vector2.ZERO
	if path.size() > 0:
		if Vector2(position).distance_to(Vector2(path[cur_path_idx].x, path[cur_path_idx].y)) < 1:
			path.remove(0)
		else:
			var direction = path[cur_path_idx] - position
			
			var accel = null
			var cur_speed = speed
#			for area in $Body.get_overlapping_areas():
#				if area.is_in_group("Tree"):
#					var deccel = -0.3
#					if !accel or accel > deccel:
#						accel = deccel
#			var tilepos = Global.world_tile.world_to_map(position)
#			var tilecell = Global.world_tile.get_cell(tilepos.x, tilepos.y)
#			if tilecell in [6]:
#				var deccel = -0.1
#				if !accel or accel > deccel:
#					accel = deccel
#			if tilecell in [7]:
#				var deccel = -0.5
#				if !accel or accel > deccel:
#					accel = deccel
			if accel :
				cur_speed = cur_speed * (1 + accel)
			
			velocity = direction.normalized() * cur_speed
			
			if abs(velocity.x) > abs(velocity.y):
				if velocity.x > 0 :
					dir_animation = "Right"
				else:
					dir_animation = "Left"
			else:
				if velocity.y > 0 :
					dir_animation = "Down"
				else:
					dir_animation = "Up"
			if velocity != Vector2.ZERO:
				state_anim_machine.travel(str("Walk_" + dir_animation))
	move_and_slide(velocity)

func idle():
	if path.size() == 0:
		var radius = 64
		var target_pos = Vector2(rand_range(-radius, radius), rand_range(-radius, radius))
		target_pos = position + target_pos
		path = Global.astar_tile.get_astar_path(position, target_pos)
	
	move_navigation()

func foraging():
	AICore.data_ai[team]["wood"]
	var req_level = AICore.get_level_req(AICore.max_level_reached[team])
	if AICore.data_ai[team]["wood"] >= req_level["wood"]:
		change_group_state("Worker Idle " + team)
		return
	
	if !target_node:
		var forecast_target_node = null
		for tree in $Sight.get_overlapping_areas():
			if tree.get("object_name") and tree.object_name == "tree":
				if tree.resource_available and !tree.forecast_worker:
					if !forecast_target_node or (position - tree.position).length() < (position - forecast_target_node.position).length():
						forecast_target_node = tree
		target_node = forecast_target_node
		if forecast_target_node:
			forecast_target_node.forecast_worker = self
	
	if last_tile_position != Global.astar_tile.local_world_to_map(position) and target_node:
		last_tile_position = Global.astar_tile.local_world_to_map(position)
		var target_pos = target_node.position
		path = Global.astar_tile.get_astar_path(position, target_pos)
	
	if target_node:
		if target_node and target_node.resource_available:
			if target_node in $Body.get_overlapping_areas():
				state_anim_machine.travel(str("Slash_" + dir_animation))
			else:
				move_navigation()
		else:
			target_node = null
	else:
		idle()

func gathering():
	AICore.data_ai[team]["food"]
	var req_level = AICore.get_level_req(AICore.max_level_reached[team])
	if AICore.data_ai[team]["food"] >= req_level["food"]:
		change_group_state("Worker Idle " + team)
		return
	
	if !target_node:
		var forecast_target_node = null
		for white_fied in get_tree().get_nodes_in_group("Wheat Field " + team):
			if white_fied.resource_available and !white_fied.forecast_worker:
				forecast_target_node = white_fied
		target_node = forecast_target_node
		if forecast_target_node:
			forecast_target_node.forecast_worker = self
	
	if (last_tile_position != Global.astar_tile.local_world_to_map(position) or path.size() == 0) and target_node:
		last_tile_position = Global.astar_tile.local_world_to_map(position)
		var target_pos = target_node.position
		path = Global.astar_tile.get_astar_path(position, target_pos)
	
	if target_node:
		if target_node.resource_available:
			if target_node in $Body.get_overlapping_areas():
				state_anim_machine.travel(str("Slash_" + dir_animation))
			else:
				move_navigation()
		else:
			target_node = null
	else:
		idle()

func _on_Sight_area_entered(area):
	if area.get_parent() != self and area.name == "Body" and area.get_parent().team != team:
		pass


func _on_Sight_area_exited(area):
	if target_node :
		pass

func slash():
	if target_node:
		if state == FORAGING:
			var random = randi()%100+1
			if random <= 50:
				AICore.data_ai[team]["wood"] += randi()%3 + 1
				target_node.hurt(dir_animation)
		elif state == GATHERING:
			var random = randi()%100+1
			if random <= 50:
				AICore.data_ai[team]["food"] += randi()%3 + 1
				target_node.hurt(dir_animation)
		else:
			target_node.hurt(dir_animation)

func hurt(attack_dir_animation):
	state = HURT
	if attack_dir_animation == "Right":
		state_anim_machine.travel(str("Idle_Left"))
		position = position - Vector2(-8, 0)
	elif attack_dir_animation == "Left":
		state_anim_machine.travel(str("Idle_Right"))
		position = position - Vector2(8, 0)
	elif attack_dir_animation == "Up":
		state_anim_machine.travel(str("Idle_Down"))
		position = position - Vector2(0, 8)
	elif attack_dir_animation == "Down":
		state_anim_machine.travel(str("Idle_Up"))
		position = position - Vector2(0, -8)

func change_team(team_target):
	team = team_target
	$Sprite.texture = load(str("res://assets/characters/workers/Farmer" + team + ".png"))

func init_team():
	var tile_position = Global.world_tile.world_to_map(position)
	if Global.territory_tile.get_cellv(tile_position) != -1:
		team = MasterData.team_list[Global.territory_tile.get_cellv(tile_position)]
	else:
		var terrority = Global.territory_tile.get_used_cells()
		if terrority.size() > 0:
			var closest_tile = null
			for tilepos in terrority:
				if !closest_tile or (tile_position - tilepos).length() < (tile_position - closest_tile).length():
					closest_tile = tilepos
			if (tile_position - closest_tile).length() < 40:
				team = MasterData.team_list[Global.territory_tile.get_cellv(closest_tile)]
		
		if team == "":
			team = MasterData.team_list[Global.number_team]
			Global.number_team += 1
			Global.team_list += [team]
			var house = Global.House_Instance.instance()
			house.position = Global.world_tile.map_to_world(tile_position)
			house.position += Vector2(8, 8)
			house.team += team
			house.first_territory = true
			add_to_group("Worker " + team)
			add_to_group("Unit " + team)
			$"/root/World/Houses".add_child(house)
	
	add_to_group("Worker " + team)
	add_to_group("Units " + team)
	change_group_state("Worker Idle " + team)
	
	change_team(team)

func change_group_state(group_name):
	print(group_name)
	remove_from_group("Worker Foraging " + team)
	remove_from_group("Worker Gathering " + team)
	remove_from_group("Worker Idle " + team)
	add_to_group(group_name)
