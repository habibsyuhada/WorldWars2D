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
	"wheat_field":{
		"cost":{
			"wood": 5
		},
		"territory": 6,
		"max_people": 0,
		"max_storage": 0,
	},
}

var unit = {
	"worker":{
		"cost":{
			"wood": 5,
			"food": 5,
		},
		"build_time": 15,
	},
	"swordman":{
		"cost":{
			"wood": 15,
			"food": 15,
		},
		"build_time": 25,
	},
}

var team_list = ['Lime', 'Cyan', 'Red', 'Purple'] #urut bedarasarkan territory tile set

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
