extends KinematicBody2D

enum {IDLE, CHASE, SLASH, HURT}
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
	change_team(team)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		IDLE:
			idle()
	
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

func chase():
	if !target_node:
		state = IDLE
		return
		
	if target_node.get_node('Body') in $Body.get_overlapping_areas():
		state = SLASH
		state_anim_machine.travel(str("Slash_" + dir_animation))
		return
	
	if last_tile_position != Global.astar_tile.local_world_to_map(position) and target_node:
		last_tile_position = Global.astar_tile.local_world_to_map(position)
		var target_pos = target_node.position
		path = Global.astar_tile.get_astar_path(position, target_pos)
		
	move_navigation()

func _on_Sight_area_entered(area):
	if area.get_parent() != self and area.name == "Body" and area.get_parent().team != team:
		if !target_node or (position - area.get_parent().position).length() < (position - area.get_parent().position).length():
			target_node = area.get_parent()
			if state != CHASE:
				state = CHASE
				last_tile_position = null


func _on_Sight_area_exited(area):
	if target_node :
		if target_node == area :
			target_node = null
			if state == CHASE:
				state = IDLE
				last_tile_position = null

func slash():
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
