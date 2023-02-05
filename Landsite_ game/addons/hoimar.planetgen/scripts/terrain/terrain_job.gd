tool
class_name TerrainJob

# Tato classa sa stará o vygenerovanie jednej časťi terénu

const TERRAIN_PATCH_SCENE = preload("../../scenes/terrain/terrain_patch.tscn")

signal job_finished(job, result)

var _data: PatchData setget , get_data
var _is_aborted: bool setget abort, is_aborted


func _init(var data: PatchData):
	_data = data


func run():
	if _is_aborted:    # Skontrolj pre bežaním úlohy
		emit_signal("job_finished", self, null)
		return
	# BVybuduj časť terénu
	var patch: TerrainPatch = TERRAIN_PATCH_SCENE.instance()
	patch.build(_data)
	if _is_aborted:    # Spontroluj po dokončení
		emit_signal("job_finished", self, null)
	else:
		emit_signal("job_finished", self, patch)   # Vráť Výsledky


# "Setter" iba ak by nastali komplikácie
func abort(var b := true):
	_is_aborted = true

# je zohodený
func is_aborted() -> bool:
	return _is_aborted

# získaj dáta
func get_data() -> PatchData:
	return _data
