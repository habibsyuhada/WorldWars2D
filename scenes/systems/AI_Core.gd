extends Node2D

var is_ai_process = true
var is_waiting_process = false
var data_ai = {}
var max_level_reached = {}
var req_level = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_ai_process and !is_waiting_process:
		is_waiting_process = true
		for team in Global.team_list:
			if !data_ai.has(team):
				max_level_reached[team] = 0
				req_level[team] = get_level_req(max_level_reached[team])
				data_ai[team] = {
					"wood" : 0,
					"food" : 0,
				}
			yield(ai_process(team), "completed")
		is_waiting_process = false
		
func ai_process(team) :
	var level_up = true
	for no in (max_level_reached[team] + 1):
		var req_list = get_level_req(no)
		if level_up or no <= max_level_reached[team]:
			for req in req_list:
				if req in ["wood", "food"]:
					if req_list[req] > data_ai[team][req] :
						level_up = false
				elif req == "worker":
					if req_list[req] > get_tree().get_nodes_in_group("Worker " + team).size():
						level_up = false
				elif req == "max_people":
					if req_list[req] > get_tree().get_nodes_in_group("Unit " + team).size():
						level_up = false
	
	var division = []
	
	if req_level[team]["wood"] > data_ai[team]["wood"]:
		division.push_back("wood")
	if req_level[team]["food"] > data_ai[team]["food"]:
		division.push_back("food")
	
	if division.size() == 0:
		return yield(get_tree(), "idle_frame")
	var max_employee_division = req_level[team]["worker"] / division.size()
	var worker_list = get_tree().get_nodes_in_group("Worker " + team)
	for worker in worker_list:
		if !worker.is_in_group("Worker Foraging " + team) and !worker.is_in_group("Worker Gathering " + team):
	#		print([get_tree().get_nodes_in_group("Worker Foraging" + team).size(), get_tree().get_nodes_in_group("Worker Gathering" + team).size()])
			var min_worker_division = [get_tree().get_nodes_in_group("Worker Foraging " + team).size(), get_tree().get_nodes_in_group("Worker Gathering " + team).size()].min()
	#		print(get_tree().get_nodes_in_group("Worker Foraging" + team).size(), " ", max_employee_division, " ", min_worker_division)
			if "wood" in division and get_tree().get_nodes_in_group("Worker Foraging " + team).size() < max_employee_division and get_tree().get_nodes_in_group("Worker Foraging " + team).size() == min_worker_division :
				worker.change_group_state("Worker Foraging " + team)
			elif "food" in division and get_tree().get_nodes_in_group("Worker Gathering " + team).size() < max_employee_division and get_tree().get_nodes_in_group("Worker Gathering " + team).size() == min_worker_division :
				worker.change_group_state("Worker Gathering " + team)
		
	yield(get_tree(), "idle_frame")

func get_level_req(level_req):
	var based_req_level = {
		"wood" : 5,
		"food" : 5,
		"wheat_field" : 4,
		"max_people" : 2,
		"worker" : 2,
	}
	if level_req > 0 :
		based_req_level = {
			"wood" : 5 + floor(level_req * 10),
			"food" : 5 + floor(level_req * 8),
			"wheat_field" : 4 + floor(level_req * 0.3),
			"max_people" : 4 + floor(level_req * 0.3),
			"worker" : 4 + floor(level_req * 0.1),
		}
	return based_req_level
