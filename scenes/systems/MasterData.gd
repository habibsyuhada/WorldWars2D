extends Node2D


var building = {
	"house":{
		"cost":{
			"wood": 10,
			"food": 10,
		},
		"territory": 4,
		"max_people": 2,
		"max_storage": 0,
	},
}

var team_list = ['Lime', 'Cyan', 'Red', 'Purple']

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
