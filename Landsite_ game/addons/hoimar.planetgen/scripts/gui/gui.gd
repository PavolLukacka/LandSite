extends Node
# GUI prew zobrazenie debugovych info

# funguje to cez label 2D
onready var lbl_status := $LabelStatus
onready var ship := get_node_or_null("../Ship")


func _process(_delta):
	lbl_status.text = " FPS: %d" % Engine.get_frames_per_second() #zobrazi fps
	lbl_status.text += "\n wireframe:? %s\n vyfarbene casti: %s" \
			% [PGGlobals.wireframe, PGGlobals.colored_patches]
	show_planet_info() # zobraz info o planete
	check_input() # pozri stavy

#planetarne informacie
func show_planet_info():
	if PGGlobals.solar_systems.empty():
		return
	var num_jobs: int = PGGlobals.job_queue.get_number_of_jobs()
	lbl_status.text += "\n Velkost QUEUE terenu %d" % num_jobs
	for planet in PGGlobals.solar_systems[0]._all_planets:
		lbl_status.text += "\n %s%s  |  %d casti terenu generovanych" % \
				[planet.name, str(planet), planet._terrain.get_children().size()]

# input check
func check_input():
	if Input.is_action_just_pressed("toggle_colored_patches"):
		PGGlobals.colored_patches = !PGGlobals.colored_patches
	if Input.is_action_just_pressed("toggle_wireframe"):
		PGGlobals.wireframe = !PGGlobals.wireframe
