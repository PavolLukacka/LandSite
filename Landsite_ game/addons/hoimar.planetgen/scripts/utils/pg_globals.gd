# Global settings for Planet Generator.
tool
extends Node

const MOUSE_SENSITIVITY: float = 0.05 # senzitivita- nemnená konštanta

var wireframe: bool = false setget set_wireframe       # Wireframe mód pre debugovanie
var colored_patches: bool   # Náhodne farebné časti
var benchmark_mode: bool   # regenerovanie planét cez benchmark , jeho implementáciu nemám hotovú
var prev_auto_accept_quit: bool 
var solar_systems: Array = []
var job_queue := JobQueue.new()  # Queue pre generator povrchu

# vstup do stromu
func _enter_tree():
	prev_auto_accept_quit = ProjectSettings.get_setting("application/config/auto_accept_quit")

# vystup zo stromu
func _exit_tree():
	job_queue.clean_up()

#Queue štýl upravy terénu
func queue_terrain_patch(var data: PatchData) -> TerrainJob:
	var job := TerrainJob.new(data)
	job_queue.queue(job)
	return job

# registrácia
func register_solar_system(var sys: Node):
	solar_systems.append(sys)

# de-registrácia
func unregister_solar_system(var sys: Node):
	solar_systems.erase(sys)

# Nastav priehladný mód
func set_wireframe(new):
	wireframe = new
	VisualServer.set_debug_generate_wireframes(new)
	if new:
		get_viewport().set_debug_draw(Viewport.DEBUG_DRAW_WIREFRAME)
	else:
		get_viewport().set_debug_draw(Viewport.DEBUG_DRAW_DISABLED);
