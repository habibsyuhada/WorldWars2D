extends CanvasLayer

export (PackedScene) var HUD

# Called when the node enters the scene tree for the first time.
func _ready():
	toogle_hud(true)
	
func toogle_hud(status):
	if status == true:
		var hud = HUD.instance()
		add_child(hud)
	else: 
		var hud = get_node_or_null("HUD")
		if hud != null:
			hud.queue_free()
