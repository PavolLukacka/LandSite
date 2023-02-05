tool
class_name Planet, "../../resources/icons/planet.svg"
extends Spatial
# Class pre planety atmosfera - credit Sebastian Lauge 

const MIN_ATMO_SCALE := 1.0  # minimalna velkost atmosfery
const MAX_ATMO_SCALE := 1.06 # maximalna velkost atmosfery

export(bool) var do_generate: bool = false setget set_do_generate # seter ktory si vieme zakliknut ak klikneme na planetu
export(Resource) var settings # nastavenia 
export(Material) var material: Material # material planety
export(NodePath) var solar_system_path: NodePath # pozicia planety
export(NodePath) var sun_path: NodePath # pozicia slnka
var _org_atmo_mesh: Mesh # Atmosfericky mesh
var _org_water_mesh: Mesh # Vodny mesh
var _atmo_material: ShaderMaterial # material atmosfery
var _sun: Spatial # slnko
var _solar_system: Node # solarny system
var _logger := Logger.get_for(self) # logger dát
onready var _terrain: TerrainManager = $TerrainManager # teren referencia na adresu informacii
onready var _atmosphere = $Atmosphere # atmosfera referencia na adresu informacii
onready var _water_sphere: MeshInstance = $WaterSphere # Vodna gula


func _ready(): # vygeneruj atmosferu, vodu, poziciu planet
	if not _org_atmo_mesh:
		_org_atmo_mesh = _atmosphere.mesh
	if not _org_water_mesh:
		_org_water_mesh = _water_sphere.mesh
	if solar_system_path:
		_sun = get_node(sun_path)
	generate()
	


func _process(_delta):
	var camera = get_viewport().get_camera() # pohlad na hraca
	if camera and settings.has_atmosphere:
		# Ak je bool true, tak udate shader planety aby vyhovovala nastaveniam
		var distance: float = global_transform.origin.distance_to(camera.global_transform.origin) # vzdialenost
		var scale: float = range_lerp(distance, settings.radius*1.75, settings.radius*5, # velkosť 
				MIN_ATMO_SCALE, MAX_ATMO_SCALE)
		scale = max(MIN_ATMO_SCALE, min(scale, MAX_ATMO_SCALE)) # ohraničenie atmosfery
		if _atmo_material:
			_atmo_material.set_shader_param("planet_radius", settings.radius*scale) # presny vypocet velkosti
			_atmo_material.set_shader_param("atmo_radius", settings.radius*settings.atmosphere_thickness*scale) # presny vypocet atmosfery na polomer, (velkost)
		if _sun and not self == _sun:
			var atmoDirection = global_transform.origin - (_sun.global_transform.origin - global_transform.origin)
			_atmosphere.look_at_from_position(global_transform.origin, atmoDirection, transform.basis.y)
	prc()
	
func prc():
	_terrain.rotate_y(0.0001) # automaticka rotacia zeme podobnej planéty
	
# Vygeneruj planetu
func generate():
	if not are_conditions_met(): # ak sú podmienky nesplnené vráť chybu
		return
	var time_before = OS.get_ticks_msec()
	settings.init(self) # inicializuj nastavenia
	_terrain.generate(settings, material) # vygeneruj terén
	
	# Vygeneruj vodu
	_water_sphere.visible = settings.has_water # ak sú podmienky splnene zacne sa generacia
	if settings.has_water: 
		_water_sphere.mesh = _org_water_mesh.duplicate(true)
		_water_sphere.mesh.radius = settings.radius
		_water_sphere.mesh.height = settings.radius*2
		var water_material = _water_sphere.mesh.surface_get_material(0)
		water_material.set_shader_param("planet_radius", settings.radius)
	#	Shader kód od Sebastiana - nemal som čas testovať ale koncept je jasný
	# Priprav atmosféru
	_atmosphere.visible = settings.has_atmosphere # podmienky musia byť splnené
	if settings.has_atmosphere:
		_atmosphere.mesh = _org_atmo_mesh.duplicate(true)
		_atmosphere.mesh.size = Vector3(settings.radius*2.5, settings.radius*2.5, settings.radius*2.5)
		_atmo_material = _atmosphere.mesh.surface_get_material(0)
		_atmo_material.set_shader_param("planet_radius", settings.radius)
		_atmo_material.set_shader_param("atmo_radius", settings.radius * settings.atmosphere_thickness)
	# shader na atmosféru - nemal som čas testovať ale koncept je jasný
	_logger.debug("%s%s started generating after %sms." % [name, str(self), str(OS.get_ticks_msec() - time_before)])


func are_conditions_met() -> bool: # funkcia ktora kontroluje ci su podmienky splnene
	if not settings or not material:
		_logger.warn("Nastavenia neboli nastavené, nemožem vygenerovať %s%s." %
			[name, str(self)])
		return false
	if not _terrain:
		_logger.warn("Povrch %s%s nebol inicializovaný" % [name, str(self)])
		return false
	var jobs: Array = PGGlobals.job_queue.get_jobs_for(self)
	if !jobs.empty() and not PGGlobals.benchmark_mode:
		_logger.warn("Čakám na %d prác ktoré sa musia vykonať pred generáciou \"%s%s\"." %
				[jobs.size(), name, str(self)])
		return false
	return true


func set_do_generate(_new):
	generate()


func _enter_tree(): # stromova hrierarchia planet
	if solar_system_path:
		_solar_system = get_node(solar_system_path)
	elif get_parent().has_method("register_planet"): # nedoriešena časť
		solar_system_path = ".."
		_solar_system = get_parent()
	if _solar_system:
		_solar_system.register_planet(self)


func _exit_tree(): # vyhodenie zo stromu
	if _solar_system:
		_solar_system.unregister_planet(self)


func _get_configuration_warning() -> String: # konfiguračné warningy
	if settings and settings.has_atmosphere and not solar_system_path:
		return "Cesta k slnku nebola definovanmá"
	if not solar_system_path:
		return "Cesta k solarnemu systemu nené stanovená'."
	return _get_common_config_warning()


# Shared configuration warnings between this class and subclasses.
func _get_common_config_warning() -> String:
	if not settings:
		return "Chýbajú 'PlanetSettings' ako zdroj v nastaveniach."
	if not material:
		return "Chýba 'Material' ako zdroj v nastaveniach.'."
	return ""
