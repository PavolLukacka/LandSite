tool
extends Control

#tlacidla adresy
onready var start_tlacidlo = $MarginContainer/VBoxContainer/StartTlacidlo
onready var nastavenia_tlacidlo = $MarginContainer/VBoxContainer/NastaveniaTlacidlo
onready var ukoncit_tlacidlo = $MarginContainer/VBoxContainer/UkoncitTlacidlo
onready var info_tlacidlo = $MarginContainer/VBoxContainer/InfoTlacidlo

#grafika -sprites adresy
onready var planeta = $MarginContainer/VBoxContainer/Planeta
onready var logo = $MarginContainer/VBoxContainer/LogoNaOblaku

#oblaky adresy
onready var oblak1 = $Oblacik1Player/Oblacik1
onready var oblak2 = $Oblacik2Player/Oblacik2

#animacie pre padaciky - zobrazia sa na hover kurzoru
onready var padak1 = $AnimationPlayer1/Balon1
onready var padak2 = $AnimationPlayer2/Balon2
onready var padak3 = $AnimationPlayer3/Balon3
onready var padak4 = $AnimationPlayer4/Balon4

#nastavenia menu
onready var settings_menu = $SettingsMenu
onready var pause_menu = preload("res://Menu/Pause.gd")

#fukcia, ktora sa vola kazdy frame
func _ready():
	start_tlacidlo.grab_focus()
	Music.stream = load("res://assets/music/doodle.mp3")
	padak1.hide() #padaky su defaultne neviditelne
	padak2.hide()
	padak3.hide()
	padak4.hide()
	$Oblacik1Player.play("Oblacik1")
	$Oblacik2Player.play("Oblacik2")

	
#Signaly na stlacenie tlacidel  - zmeny scén

func _on_StartTlacidlo_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://demos/solar_system_demo.tscn") 
	
	
func _on_NastaveniaTlacidlo_pressed(): # pri staceni tlacidla settings sa odstrani mesto a oblaky
	settings_menu.popup_centered()

func _on_UkoncitTlacidlo_pressed(): 
	get_tree().quit()

func _on_InfoTlacidlo_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Menu/AboutMenu.tscn")
	

func _on_StartTlacidlo_mouse_entered():
	$AnimationPlayer1.play("Balon1")
	padak1.show()

func _on_StartTlacidlo_mouse_exited():
	padak1.hide()
	
func _on_NastaveniaTlacidlo_mouse_entered():
	$AnimationPlayer2.play("Balon2")
	padak2.show()
	
func _on_NastaveniaTlacidlo_mouse_exited():
	padak2.hide()
	
func _on_UkoncitTlacidlo_mouse_entered():
	$AnimationPlayer3.play("Balon3")
	padak3.show()
	
func _on_UkoncitTlacidlo_mouse_exited():
	padak3.hide()
	
func _on_InfoTlacidlo_mouse_entered():
	$AnimationPlayer4.play("Balon4")
	padak4.show()
	
func _on_InfoTlacidlo_mouse_exited():
	padak4.hide()

# pre ucely settings menu
func _on_SettingsMenu_popup_hide():
	planeta.visible = true
	oblak1.visible = true
	oblak2.visible = true

# pre ucely settings menu
func _on_SettingsMenu_about_to_show():
	planeta.visible = false
	oblak1.visible = false
	oblak2.visible = false





