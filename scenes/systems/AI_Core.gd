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
				var max_people = 0
				for building in get_tree().get_nodes_in_group("Building " + team):
					max_people += MasterData.building[building.object_name]["max_people"]
				data_ai[team] = {
					"wood" : 0,
					"food" : 0,
					"max_people" : max_people,
				}
			yield(ai_process(team), "completed")
		is_waiting_process = false

func buy_building(building_name, team):
	var buyable = true
	for cost in MasterData.building[building_name]["cost"]:
		if data_ai[team][cost] < MasterData.building[building_name]["cost"][cost] :
			buyable = false
	if buyable:
		for cost in MasterData.building[building_name]["cost"]:
			data_ai[team][cost] -= MasterData.building[building_name]["cost"][cost] 
			
		var req_tile = [1, 2] # wheat_field is default
		var building = Global.Wheat_Field_Instance.instance()
		if building_name == "house":
			building = Global.House_Instance.instance()
			
		var territory_tilemap = Global.territory_tile.get_used_cells_by_id (MasterData.team_list.find(team))
		var tilemap = []
		for tile in territory_tilemap:
			var tilecell = Global.world_tile.get_cell(tile.x, tile.y)
			if tilecell in req_tile:
				var world_position = Global.world_tile.map_to_world(tile) + Vector2(8, 8)
				#world_position = get_node("/root/World/Map/Building/Keep").position
				var space_state = get_world_2d().direct_space_state
				var result = space_state.intersect_point(world_position, 32, [], 0x7FFFFFFF, false, true)
				var count_colider = 0
				for object_col in result:
					if object_col.collider.is_in_group("Buildings"):
						count_colider += 1
				if count_colider == 0:
					tilemap.push_back(tile)
		
		var select_tile = null
		var field_list = []
		if building_name == "wheat_field":
			field_list += get_tree().get_nodes_in_group("Wheat Field " + team)
		
		var field_list_sort = []
		for field in field_list:
			field = Global.world_tile.world_to_map(field.position)
			field_list_sort.push_back(field)
		field_list_sort.sort()
		
		
		var district_list = []
		for field in field_list_sort:
			var district_selected = false
			var no_dist = 0
			for district in district_list:
				for member_dist in district:
					if floor((field - member_dist).length()) < 2:
						district_selected = true
						district_list[no_dist].push_back(field)
						break
				no_dist += 1
			if !district_selected:
				district_list.push_back([field])
				
		var random_dist = randi()%(district_list.size()+1)
		if random_dist == district_list.size():
			select_tile = tilemap[randi()%tilemap.size()]
		else:
			var random = randi()%(district_list[random_dist].size())
			var radius = 3
			var tile = district_list[random_dist][random]
			tile += Vector2(randi()%radius-1, randi()%radius-1) # Random -1 to 1
			if tile in tilemap:
				select_tile = tile
			else:
				for cost in MasterData.building[building_name]["cost"]:
					data_ai[team][cost] += MasterData.building[building_name]["cost"][cost] 
			
		if select_tile:
			var world_position = Global.world_tile.map_to_world(select_tile) + Vector2(8, 8)
			building.position = world_position
			building.team = team
			Global.add_building(building)

func buy_worker(team):
	var buyable = true
	var house_target = null
	for cost in MasterData.unit["worker"]["cost"]:
		if data_ai[team][cost] < MasterData.unit["worker"]["cost"][cost] :
			buyable = false
			
	if buyable:
		var house_list = get_tree().get_nodes_in_group("House " + team)
		if house_list.size() > 0:
			var random = randi()%(house_list.size() - 1)
			house_target = house_list[random]
	
	if buyable and house_target:
		pass
		

func ai_process(team) :
	var level_up = true
	for no in (max_level_reached[team] + 1):
		var req_list = get_level_req(no)
		if level_up or no <= max_level_reached[team]:
			for req in req_list:
				if req in ["wood", "food"]:
					if req_list[req] > data_ai[team][req] :
						level_up = false
				if req == "wheat_field":
					if req_list[req] > get_tree().get_nodes_in_group("Wheat Field " + team).size():
						level_up = false
						buy_building(req, team)
				elif req == "worker":
					if req_list[req] > get_tree().get_nodes_in_group("Worker " + team).size():
						level_up = false
				elif req == "max_people":
					if req_list[req] > get_tree().get_nodes_in_group("Units " + team).size():
						if get_tree().get_nodes_in_group("Units " + team).size() < data_ai[team][req] :
#							buy_building("house", team)
							pass
						else:
							buy_worker(team)
	
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
		"wheat_field" : 2,
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
