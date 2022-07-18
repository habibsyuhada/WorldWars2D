extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var object_name = "tree"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.frame = randi()%($Sprite.hframes * $Sprite.vframes - 1) + 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func hurt(attack_dir_animation):
	pass
