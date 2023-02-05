tool
class_name SolarSystem, "../../resources/icons/solar_system.svg"
extends Spatial

var _all_planets: Array
var _logger := Logger.get_for(self)

# funkcia na registrivanie planety
func register_planet(var planet: Planet):
	_all_planets.append(planet)

# funkcia na odregistrivanie planety
func unregister_planet(var planet: Planet):
	_all_planets.erase(planet)

# vstup do stromu
func _enter_tree():
	PGGlobals.register_solar_system(self)

# vystup zo stromu
func _exit_tree():
	PGGlobals.unregister_solar_system(self)
