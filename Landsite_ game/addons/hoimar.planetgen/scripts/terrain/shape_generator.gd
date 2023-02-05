tool
class_name ShapeGenerator
extends Resource

const Const := preload("../constants.gd")

export(Array) var noise_generators: Array
var _planet
var mask: float
var ng_array: Array   
var min_max: MinMax
var min_max_mutex := Mutex.new()
var planet_radius: float   # pre rýchli prístup

func init(var _planet):
	self._planet = _planet
	self.min_max = MinMax.new()
	for ng in noise_generators:
		ng.init(_planet)
	ng_array = range(1, noise_generators.size())
	planet_radius = _planet.settings.radius
	calculate_min_max()


# Získaj nadmorskú výšku 
func get_unscaled_elevation(var point_on_unit_sphere: Vector3) -> float:
	var first_ng: NoiseGenerator = noise_generators[0]
	var first_layer_value: float = first_ng.evaluate(point_on_unit_sphere)
	var elevation: float = first_layer_value * first_ng.enabled_int
	
	for i in ng_array:
		var ng: NoiseGenerator = noise_generators[i]
		var use_first_as_mask := ng.use_first_as_mask_int
		elevation += ng.evaluate(point_on_unit_sphere) * ng.enabled_int \
				* (first_layer_value * use_first_as_mask + 1 - use_first_as_mask)
	return elevation


#Vráť nadmorskú výšku
func get_scaled_elevationa(var elevation: float) -> float:
	return _planet.settings.radius * (1.0 + elevation)


# Vráť nadmorskú výšku v pomere z planétou
func get_scaled_elevation(var elevation: float) -> float:
	return planet_radius * (1.0 + elevation)


# Odhaduje približne maximálnu a minimálnu velkosť nadmorskej výsky
func calculate_min_max():
	var elevation: float
	var first_layer_value: float = noise_generators[0].strength * Const.MIN_MAX_APPROXIMATION
	if noise_generators[0].enabled:
		elevation = first_layer_value
	
	for i in ng_array:
		var ng: NoiseGenerator = noise_generators[i]
		if ng.enabled:
			var mask: float = first_layer_value if ng.use_first_as_mask else 1.0
			elevation += ng.strength * mask * Const.MIN_MAX_APPROXIMATION
	min_max.min_value = -elevation
	min_max.max_value = elevation
