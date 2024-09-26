@tool
extends PanelContainer


signal reload_plugins()
signal reload_selected(plugins)
signal settings_updated(settings)


var reload_button: Button
var selector_button: Button
var settings_button: Button

var plugin_list_dialog: ConfirmationDialog
var settings_dialog: ConfirmationDialog


#region boilerplate
func _ready() -> void:
	var editor_theme := EditorInterface.get_editor_theme();
	var panel_container_style := preload("res://addons/plugin_reloader/styles/panel_container_style.tres")
	
	plugin_list_dialog = preload("res://addons/plugin_reloader/plugin_list_dialog/plugin_list_dialog.tscn").instantiate()
	plugin_list_dialog.confirmed.connect(_on_reload_selection_confirmed)
	plugin_list_dialog.canceled.connect(_on_reload_selection_cancel)
	
	settings_dialog = preload("res://addons/plugin_reloader/settings_dialog/settings_dialog.tscn").instantiate()
	settings_dialog.confirmed.connect(_on_setting_selection_confirmed)
	settings_dialog.canceled.connect(_on_setting_selection_cancel)
	
	reload_button = $buttons/reload_button
	selector_button = $buttons/selector_button
	settings_button = $buttons/settings_button

	reload_button.icon = editor_theme.get_icon("Reload", "EditorIcons")
	selector_button.icon = editor_theme.get_icon("PopupMenu", "EditorIcons")
	settings_button.icon = editor_theme.get_icon("GDScript", "EditorIcons")
	
	if get_tree().edited_scene_root == self:
		return # This is the scene opened in the editor!
	
	get_parent().move_child(self, 5) # Place after scene editor buttons

func _exit_tree() -> void:
	if get_tree().edited_scene_root == self:
		return # This is the scene opened in the editor!

	plugin_list_dialog.queue_free()
	settings_dialog.queue_free()
#endregion


#region reload_button
func _on_reload_button_pressed() -> void:
	emit_signal("reload_plugins")

func set_tooltip_keybind(keybind: Dictionary) -> void:
	var shift: String = "Shift+" if keybind["shift"] else ""
	var ctrl: String = "Ctrl+" if keybind["ctrl"] else ""
	var alt: String = "Alt+" if keybind["alt"] else ""
	var key := OS.get_keycode_string(keybind["key"])
	
	reload_button.tooltip_text = shift + ctrl + alt + key
#endregion


#region selector_button
func _on_selector_button_pressed() -> void:
	add_child(plugin_list_dialog)
	plugin_list_dialog.popup_centered(Vector2(400, 500))

func _on_reload_selection_confirmed() -> void:
	var plugins = plugin_list_dialog.get_meta("plugins")
	emit_signal("reload_selected", plugins)
	remove_child(plugin_list_dialog)

func _on_reload_selection_cancel() -> void:
	remove_child(plugin_list_dialog)

func update_plugins(plugins) -> void:
	plugin_list_dialog.update_plugin_list(plugins)
	
	get_parent().move_child(self, 5) # Place after scene editor buttons
#endregion


#region settings_button
func _on_settings_button_pressed() -> void:
	add_child(settings_dialog)
	settings_dialog.popup_centered(Vector2(300, 300))

func _on_setting_selection_confirmed() -> void:
	var settings = settings_dialog.get_meta("settings")
	emit_signal("settings_updated", settings)
	remove_child(settings_dialog)

func _on_setting_selection_cancel() -> void:
	remove_child(settings_dialog)

func set_settings(settings) -> void:
	set_tooltip_keybind(settings["keybind"])
	settings_dialog.set_settings(settings)
#endregion
