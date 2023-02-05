extends Control

#highlight
func _ready():
	$VBoxContainer/SpatNaMainMenuTlacidlo.grab_focus()

# Návrat na main menu
func _on_SpatNaMainMenuTlacidlo_pressed():
	get_tree().change_scene("res://Menu/StartMenu.tscn")
