extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var no = 0
	$ItemList.add_item("None")
	$ItemList.set_item_metadata(no, "None")
	no += 1
	$ItemList.add_item("Worker")
	$ItemList.set_item_metadata(no, "Worker")
	no += 1
	$ItemList.add_item("Swordman")
	$ItemList.set_item_metadata(no, "Swordman")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
