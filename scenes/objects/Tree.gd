extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var object_name = "tree"
var resource_available = true


# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.frame = randi()%($Sprite.hframes * $Sprite.vframes - 1) + 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func hurt(attack_dir_animation):
	var random = randi()%100+1
	if random > 50:
		resource_available = false
		$Sprite.frame = 0
