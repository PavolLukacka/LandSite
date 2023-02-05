tool
class_name Sun, "../../resources/icons/sun.svg"
extends Planet

const CORONA_SIZE := Vector2(15, 14)  # velkosť corony
const LIGHT_OFFSET := 1.01 * Vector3.FORWARD # ofset svetla

onready var _corona: MeshInstance = $Corona
onready var _sunlight := $Sunlight



func _process(_delta):
	var cam = get_viewport().get_camera() 
	if cam:
		look_at(cam.global_transform.origin, Vector3.UP) 


func generate(): # generacia slnka
	yield(self, "ready")
	if settings:
		_corona.mesh.size = CORONA_SIZE * settings.radius
		_sunlight.translation = LIGHT_OFFSET * settings.radius
	.generate()


func _get_configuration_warning():
	return _get_common_config_warning()
