extends Area2D


var team = ""
var object_name = "house"
var need_build = true
var worker_build = null
var first_territory = false

# Called when the node enters the scene tree for the first time.
func _ready():
	change_team(team)
#	add_to_group("House " + team)
	add_to_group("Building " + team)
	if first_territory:
		Global.change_territory(position, 16, 1, team)
	else:
		Global.change_territory(position, MasterData.building[object_name]["territory"], 1, team)

func change_team(team_target):
	team = team_target
	$Sprite.texture = load(str("res://assets/buildings/" + team + "Houses.png"))
