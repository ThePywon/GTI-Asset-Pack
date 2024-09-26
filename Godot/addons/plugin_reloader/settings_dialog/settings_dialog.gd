@tool
extends ConfirmationDialog


var verbose_button: CheckButton
var automatic_button: CheckButton

var main_key: Button
var clear: Button
var shift_key: CheckBox
var ctrl_key: CheckBox
var alt_key: CheckBox


#region boilerplate
var initialized := false
func init() -> void:
	if initialized: return
	
	verbose_button = $margin/panel/margin/toggles/verbose_setting
	automatic_button = $margin/panel/margin/toggles/automatic_setting
	main_key = $margin/panel/margin/toggles/MarginContainer/reload_setting/HBoxContainer/main_key
	clear = $margin/panel/margin/toggles/MarginContainer/reload_setting/HBoxContainer/clear
	shift_key = $margin/panel/margin/toggles/MarginContainer/reload_setting/HBoxContainer2/shift_key
	ctrl_key = $margin/panel/margin/toggles/MarginContainer/reload_setting/HBoxContainer2/ctrl_key
	alt_key = $margin/panel/margin/toggles/MarginContainer/reload_setting/HBoxContainer2/alt_key
	
	
	get_ok_button().disabled = true
	set_meta("settings", {})
	
	initialized = true

func _ready() -> void:
	init()

var previous_settings = {}
func _process(delta) -> void:
	if get_tree().edited_scene_root == self:
		return # This is the scene opened in the editor!
	
	var settings = {
		verbose=verbose_button.button_pressed,
		auto=automatic_button.button_pressed,
		keybind={
			shift=shift_key.button_pressed,
			ctrl=ctrl_key.button_pressed,
			alt=alt_key.button_pressed,
			key=main_key.get_meta("keycode")
		}
	}
	
	get_ok_button().disabled = editing_key || settings == previous_settings
	set_meta("settings", settings)
#endregion


#region handle_keybind
var editing_key := false
func _on_main_key_pressed() -> void:
	main_key.text = "Press Key..."
	main_key.icon = null
	
	editing_key = true

func _unhandled_key_input(event: InputEvent) -> void:
	if !editing_key: return
	
	main_key.icon = EditorInterface.get_editor_theme().get_icon("KeyboardPhysical", "EditorIcons")
	
	if event.keycode == KEY_SHIFT:
		shift_key.button_pressed = !shift_key.button_pressed
		main_key.text = get_key_name(main_key.get_meta("keycode"))
	elif event.keycode == KEY_CTRL:
		ctrl_key.button_pressed = !ctrl_key.button_pressed
		main_key.text = get_key_name(main_key.get_meta("keycode"))
	elif event.keycode == KEY_ALT:
		alt_key.button_pressed = !alt_key.button_pressed
		main_key.text = get_key_name(main_key.get_meta("keycode"))
	else:
		main_key.text = get_key_name(event.keycode)
		main_key.set_meta("keycode", event.keycode)
	
	editing_key = false

func get_key_name(keycode: int) -> String:
	var key_name := OS.get_keycode_string(keycode)
	if key_name.length() > 0:
		return "Key_%s" % key_name
	elif keycode == 0:
		return "None"
	else:
		return "Unknown"

func _on_clear_pressed() -> void:
	shift_key.button_pressed = false
	ctrl_key.button_pressed = false
	alt_key.button_pressed = false
	main_key.text = "None"
	main_key.set_meta("keycode", 0)
#endregion


#region set_settings
func _on_confirmed() -> void:
	set_settings(get_meta("settings"))

func set_settings(settings) -> void:
	init()
	
	verbose_button.button_pressed = settings["verbose"]
	automatic_button.button_pressed = settings["auto"]
	
	var keybind: Dictionary = settings["keybind"]
	shift_key.button_pressed = keybind["shift"]
	ctrl_key.button_pressed = keybind["ctrl"]
	alt_key.button_pressed = keybind["alt"]
	main_key.text = get_key_name(keybind["key"])
	main_key.set_meta("keycode", keybind["key"])
	
	get_ok_button().disabled = true
	previous_settings = settings
#endregion
