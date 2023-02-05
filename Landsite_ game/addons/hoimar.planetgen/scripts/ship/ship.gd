extends KinematicBody
# Kontrolovaci skript pre postavu, zároveň aj pre kameru

# konštanty postavy
const TRASENIE_MAX_STUPNE := Vector3(0.005, 0.005, 0.015) # vektor ktorý spôsobuje trasenie kamery
const RYCHLOSTNY_KROK = 0.001 # krok ak hrac pridava vykon jetpacku
const MAX_RYCHLOST = 2.0 # maximalna rychlost postavy
const MIN_RYCHLOST= 0.0 # minimalna rychlost postavy
const ROTACNA_RYCHLOST = 0.04 # rotacna rychlost
const ZIVOTNA_DLZKA_PARTIKLOV = 0.1 # doba trvanlivosti častic, ktore vydava jetpack


enum STAV_KAMERY {FOLLOW, ROTATE} # 2 tyopy stavov - following a manual

var odpor_vakua = 0.005 # rezistance vákua
var odpor_padakup = 0.0 # pridana rezistance ak hrác nemá padák 
var mys_rychlost := Vector2() #rýchlosť myši
var aktualna_rychlost: float # aktuána rýchlosť postavy
var hluk_kamery := OpenSimplexNoise.new() # hluk kamery
var partikly # pomocna premmená pre častice

# adresy na nodes
onready var _padak := $Parachute # Našiel som ako 3D asset kodom sa bude ovladať jeho otvorenie a zatvorenie
onready var _popisok := $Popisoook
onready var _lampasik := $Lampasik
onready var _otoc_kam := $Otacanie_kamery
onready var _kamera := $Otacanie_kamery/Kamera_postavy
onready var _kamera_tween := $Otacanie_kamery/Tween
onready var _partikle_lave := $SK_erb_partikle_left
onready var _partikle_prave := $SK_erb_partikle_right
onready var _org_transform := self.get_transform()
onready var _org_pivot_transform: Transform = _otoc_kam.get_transform()
onready var _org_kamera_rotation: Vector3 = _kamera.rotation


func _ready():
	uvod()
	hluk_kamery.seed = randi() # rondom seed
	hluk_kamery.period = 0.4 
	if not Engine.editor_hint: # ošetrenie zobrazenia cursora
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	set_process_input(true)


func _physics_process(_delta):
	var input: Vector2 = Vector2() # vstup
	var rotation_z = 0.0 # rotácia
	var hyperspeed = .0 # pomocná premenná pre suprerýchlosť
	odpor_vakua = 0.002 # rezistance vákua2
	partikly = aktualna_rychlost # pomocné priradenie
	# pohyb postavy na vstupy
	if Input.is_action_pressed("dopredu"):
		input.x = 1
		odpor_vakua = 0.0
	if Input.is_action_pressed("dozadu"):
		partikly = 0
		input.x = -1
	if Input.is_action_pressed("boost"):
		input *= 10
	if Input.is_action_pressed("hyperspeed"):
		partikly = 30
		aktualna_rychlost = 10
	if Input.is_action_just_pressed("padak"):
		if _padak.visible == true:
			_padak.hide()
			odpor_padakup = 0.0
		else :
			_padak.show()
			odpor_padakup = 0.01
	if Input.is_action_pressed("dolava"):
		rotation_z += ROTACNA_RYCHLOST
	if Input.is_action_pressed("doprava"):
		rotation_z -= ROTACNA_RYCHLOST
	if Input.is_action_just_pressed("Spotlight"):  
		_lampasik.visible =  !_lampasik.visible #aktivacia lampasika
	
	if Input.is_action_just_released("toggle_camera_mode") \
		and not _kamera_tween.is_active(): # kamerovy mód
		_kamera_tween.interpolate_property(_otoc_kam, "transform:basis",
				null, _org_pivot_transform.basis, 1.2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		_kamera_tween.start()
	
	if rotation_z:
		rotate(transform.basis.z, rotation_z) # rotácia
		
	
	aktualna_rychlost += (RYCHLOSTNY_KROK * input.x ) - odpor_vakua - odpor_padakup  # vypocet konecnej rychlosti
	
	aktualna_rychlost = clamp(aktualna_rychlost, MIN_RYCHLOST, MAX_RYCHLOST) # ohraničenie finalnej rychlosti
	if abs(aktualna_rychlost) < RYCHLOSTNY_KROK: # zaokruhlenie
		aktualna_rychlost = 0
	
	# pohyb postavy
	move_and_collide(-transform.basis.z * aktualna_rychlost)
	move_and_collide(-transform.basis.x * aktualna_rychlost * input.y)
	
	shake_kamera()
	adjust_thrusters()

# pohyb podľa kurzoru
func _input(event):
	if event is InputEventMouseMotion:
		mys_rychlost = event.relative * PGGlobals.MOUSE_SENSITIVITY
		if Input.is_action_pressed("toggle_camera_mode"):
			_otoc_kam.rotate(_otoc_kam.transform.basis.y.normalized(), deg2rad(-mys_rychlost.x))
			_otoc_kam.rotate(_otoc_kam.transform.basis.x.normalized(), deg2rad(-mys_rychlost.y))
		else:
			rotate(transform.basis.y.normalized(), deg2rad(-mys_rychlost.x))
			rotate(transform.basis.x.normalized(), deg2rad(-mys_rychlost.y))
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			aktualna_rychlost += RYCHLOSTNY_KROK
		elif event.button_index == BUTTON_WHEEL_DOWN:
			aktualna_rychlost -= RYCHLOSTNY_KROK

# trasenie kamery
func shake_kamera():
	# Normalize the speed factor.
	var speed_factor: float = range_lerp(abs(aktualna_rychlost), 0, MAX_RYCHLOST, 0, 1)
	# Apply an exponential easing function.
	speed_factor = 1.0 if speed_factor == 1 else 1 - pow(2, -10 * speed_factor)
	# Constant change in noise.
	var time = wrapf(Engine.get_frames_drawn() / float(Engine.iterations_per_second), 0, 1000)
	_kamera.rotation = _org_kamera_rotation
	_kamera.rotation.x = TRASENIE_MAX_STUPNE.x * hluk_kamery.get_noise_1d(time) * speed_factor
	_kamera.rotation.y = TRASENIE_MAX_STUPNE.y * hluk_kamery.get_noise_1d(time*2) * speed_factor
	_kamera.rotation.z = TRASENIE_MAX_STUPNE.z * hluk_kamery.get_noise_1d(time*3) * speed_factor

# podla vykonu uprav vzhlad častíc
func adjust_thrusters():
	var lifetime = range_lerp(abs(partikly), 0, MAX_RYCHLOST, 0, ZIVOTNA_DLZKA_PARTIKLOV)
	_partikle_lave.visible = lifetime > 0.0
	_partikle_prave.visible = lifetime > 0.0
	_partikle_lave.lifetime = max(0.001, lifetime)
	_partikle_prave.lifetime = max(0.001, lifetime)

# how to play tutorial
func uvod():
	_popisok.visible = true
	_popisok.set_text("Víta Vás hra LANDSITE")
	yield(get_tree().create_timer(1.5), "timeout")
	_popisok.set_text("Návod na ovládanie")
	yield(get_tree().create_timer(1.5), "timeout")
	_popisok.set_text("WASD + Shift(BOOST)")
	yield(get_tree().create_timer(1.5), "timeout")
	_popisok.set_text("Padák aktivujete cez E")
	yield(get_tree().create_timer(1.5), "timeout")
	_popisok.set_text("Medzernik - HYPERSPEED ")
	yield(get_tree().create_timer(1.5), "timeout")
	_popisok.set_text("H - flashlight ")
	yield(get_tree().create_timer(1.5), "timeout")
	_popisok.set_text("CTRL + myška - natáčanie ")
	yield(get_tree().create_timer(1.5), "timeout")
	_popisok.set_text("Uloha není definovana")
	_popisok.visible = false
