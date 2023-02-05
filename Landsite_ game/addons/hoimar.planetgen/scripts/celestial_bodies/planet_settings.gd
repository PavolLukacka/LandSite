tool
class_name PlanetSettings # planetove nastavenia
extends Resource

export(int, 3, 9999) var resolution: int = 20 setget set_resolution # rozlisenie planety
export(float) var radius: float = 100 setget set_radius # polomer planety
export(bool) var has_water = true setget set_has_water # ma planeta voodu?
export(bool) var has_atmosphere = true setget set_has_atmosphere # ma planeta atmosferu
export(float, 1, 10000) var atmosphere_thickness: float = 1.15 setget set_atmosphere_thickness # hrubka atmosfery
export(Resource) var shape_generator # generator tvarov 

var _planet: Spatial setget , get_planet  # seter pre planetu


func init(var _planet): # inicializácia
	self._planet = _planet
	shape_generator.init(_planet)


func on_settings_changed(): # zahajenie generacie
	if not _planet:
		return
	_planet.generate()


func set_resolution(var new: int):  # seter pre zozlisenie
	resolution = new
	on_settings_changed()


func set_radius(var new: float):   # seter pre polomer
	radius = new
	on_settings_changed()


func set_has_water(var new: bool):   # seter pre vodu
	has_water = new
	on_settings_changed()


func set_has_atmosphere(var new: bool):   # seter pre atmosferu
	has_atmosphere = new
	on_settings_changed()


func set_atmosphere_thickness(var new: float):   # seter pre hrubku atmosfery
	atmosphere_thickness = new
	on_settings_changed()


func get_planet() -> Spatial: # ziskaj planetu
	return _planet
