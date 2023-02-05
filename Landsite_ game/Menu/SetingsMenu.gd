extends Popup

# Video Nastavenia
onready var display_options = $SettingTabs/Video/MarginContainer/VideoSettings/DisplayOptions
onready var vsync_btn = $SettingTabs/Video/MarginContainer/VideoSettings/VsyncBtn
onready var display_debug = $SettingTabs/Video/MarginContainer/VideoSettings/DisplayDebug
onready var max_fps_val = $SettingTabs/Video/MarginContainer/VideoSettings/MaxFpsOption/MaxFpsVal
onready var max_fps_slider = $SettingTabs/Video/MarginContainer/VideoSettings/MaxFpsOption/MaxFpsSlider

# Audio Nastavenia
onready var master_slider = $SettingTabs/Audio/MarginContainer2/AudioSettings/MasterSlider
onready var music_slider = $SettingTabs/Audio/MarginContainer2/AudioSettings/MusicSlider
onready var sfx_slider = $SettingTabs/Audio/MarginContainer2/AudioSettings/SfxSlider
# GUI debug nfo
onready var gui = $Gui

var toggle:bool

func _ready():
	display_options.grab_focus()
	toggle = false 
	display_options.select(1 if Save.game_data.fullscreen_on else 0)
	GlobalSettings.toggle_fullscreen(Save.game_data.fullscreen_on)
	vsync_btn.pressed = Save.game_data.vsync_on
	display_debug.pressed = Save.game_data.display_fps
	max_fps_slider.value = Save.game_data.max_fps
	master_slider.value = Save.game_data.master_vol
	



#VSYNC tlacidlo - nastavi fps na obnovovacu frekvenciu monitoru
func _on_CheckButton_toggled(button_pressed):
	GlobalSettings.toggle_vsync(button_pressed)

#FPS tlacidlo - ukaze fps v rohu
func _on_DisplayFpsBtn_toggled(button_pressed):
	GlobalSettings.toggle_fps_display(button_pressed)
	
#MAX fps - nastaví max fps	
func _on_MaxFpsSlider_value_changed(value):
	GlobalSettings.set_max_fps(value)
	max_fps_val.text = str(value) if value < max_fps_slider.max_value else "max"

#Master zvuk slider
func _on_MasterSlider_value_changed(value):
	GlobalSettings.update_master_vol(value)
	
#Music zvuk slider
func _on_MusicSlider_value_changed(value):
	GlobalSettings.update_music_vol(value)

#VFX slider 
func _on_SfxSlider_value_changed(value):
	GlobalSettings.update_sfx_vol(value)

#Velkosť
func _on_DisplayOptions_item_selected(index):
	GlobalSettings.toggle_fullscreen(true if index == 1 else false)

#Debugovacie informacie
func _on_DisplayDebug_toggled(button_pressed):
	if button_pressed == true:
		gui.visible = true
	if button_pressed == false:
		gui.visible = false
	
