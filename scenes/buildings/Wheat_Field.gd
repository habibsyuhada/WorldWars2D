extends Area2D

var object_name = "wheat_field"
var team = ""
var resource_available = false
var forecast_worker = null

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Building " + team)
	add_to_group("Wheat Field " + team)
	Global.change_territory(position, MasterData.building[object_name]["territory"], 1, team)

func increase_resource():
	if !resource_available:
		var random = randi()%100+1
		if random > 50:
			if $Sprite.frame < 3: 
				$Sprite.frame += 1
		
		if $Sprite.frame == 3:
			resource_available = true

func hurt(attack_dir_animation):
	resource_available = false
	$Sprite.frame = 0
	forecast_worker = null
