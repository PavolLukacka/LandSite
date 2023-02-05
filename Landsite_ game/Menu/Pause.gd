extends Control
#pauza pre ucely zastavenia hry
var pauza = false setget set_pauza

#tlacidla adresy
onready var pokracovat_tlacidlo = $VBoxContainer/PokracovatTlacidlo
onready var main_menu_tlacidlo = $VBoxContainer/SpatNaMainMenuTlacidlo
onready var nastavenia_tlacidlo = $VBoxContainer/NastaveniaTlacidlo
onready var ukoncit_tlacidlo = $VBoxContainer/UkoncitTlacidlo2

#nastavenia menu
onready var settings_menu = $SettingsMenu

#funkcia ktora reguje na signal slaceneho tlacidla
func _on_StartTlacidlo_pressed():
	self.pauza = false
	# warning-ignore:return_value_discarded
	# tento varning sa opravuje tymto komentom, ktory zamezpeci ze debuger sa nebude stazovat na nevyuzitu navratovu hodnotu
	
	#spôsob ako pauzovať - našiel som na internete
func _unhandled_input(event):
	if event.is_action_pressed("pause") and settings_menu.visible == false and get_tree().current_scene.name == "SolarSystemDemo"  :
		print(get_tree().current_scene.name)
		self.pauza =!pauza
		pokracovat_tlacidlo.grab_focus()

# setter 
func set_pauza(val):
	pauza = val
	get_tree().paused = pauza
	visible = pauza
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if pauza == true else Input.MOUSE_MODE_CAPTURED) # deaktivuje myš v hre
	
	# ako sulution k bugu, ktory vznikol kedy navrat do hlavneho menu sposobil to ze do hry sa nedalo vratit
func _on_PokracovatTlacidlo_pressed():
	self.pauza = false
	

# funkcia, ktora sa dostane na main menu, ak ale tam pojdete a spustite hru, bude seknuta, treba stlacit ESC
func _on_SpatNaMainMenuTlacidlo_pressed():
	# warning-ignore:return_value_discarded
	PauseMenu.visible = false
	get_tree().change_scene("res://Menu/StartMenu.tscn")
	
# SETTING je riesene ako popup
func _on_NastaveniaTlacidlo_pressed():
	settings_menu.popup_centered()

# ukoncenie hry 
func _on_UkoncitTlacidlo2_pressed():
	get_tree().quit()




