extends Camera

const MIN_WEIGHT: float = 0.05 # minimalna váha 
const MAX_WEIGHT: float = 0.6 # maximalna váha

export(NodePath) onready var target # ciel
export(float) var weight: float = 0.6 # váha


func _ready():
	set_as_toplevel(true) # nastavenie ako vrchný level


func _physics_process(delta):
	var targetTransform: Transform = get_node(target).global_transform # transformácia
	var distance = targetTransform.origin.distance_to(transform.origin) # vrzdialenosť
	# Calculate dynamic weight.
	var dynamicWeight = max(MIN_WEIGHT, min(MAX_WEIGHT,  
			range_lerp(distance, 0.1, 2.0, MIN_WEIGHT, MAX_WEIGHT))) # dynamicka vaha z lerpu
	transform = transform.interpolate_with(targetTransform, dynamicWeight)
