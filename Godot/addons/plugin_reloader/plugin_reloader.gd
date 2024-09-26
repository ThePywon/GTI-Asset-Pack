@tool
extends EditorPlugin


const ADDONS_PATH := "res://addons/"


var plugin_config := ConfigFile.new()
var editor_buttons: PanelContainer


var keybind := {}


var reload_queue := []


#region boilerplate
func _enter_tree() -> void:
	editor_buttons = preload("res://addons/plugin_reloader/editor_buttons/editor_buttons.tscn").instantiate()
	add_control_to_container(CONTAINER_TOOLBAR, editor_buttons)
	editor_buttons.reload_plugins.connect(_reload_plugins)
	editor_buttons.reload_selected.connect(_reload_selected)
	editor_buttons.settings_updated.connect(_settings_updated)
	
	plugin_config.load("res://addons/plugin_reloader/plugin.cfg")
	if not plugin_config.has_section("settings"):
		plugin_config.set_value("settings", "verbose", true)
		plugin_config.set_value("settings", "auto", true)
		plugin_config.save("res://addons/plugin_reloader/plugin.cfg")
	
	keybind = plugin_config.get_value("settings", "keybind")
	var settings = { verbose=plugin_config.get_value("settings", "verbose"),
		auto=plugin_config.get_value("settings", "auto"),
		keybind=keybind }
	editor_buttons.set_settings(settings)
	
	var efs = EditorInterface.get_resource_filesystem()
	efs.connect("filesystem_changed", _on_filesystem_change)
	ProjectSettings.settings_changed.connect(_reload_plugin_list)
	_reload_plugin_list()

func _process(delta) -> void:
	if reload_queue.size() == 0: return
	
	_reload_selected(reload_queue)
	reload_queue = []

func _exit_tree() -> void:
	remove_control_from_container(CONTAINER_TOOLBAR, editor_buttons)
	editor_buttons.queue_free()
#endregion


#region keybind_handling
func _unhandled_key_input(event: InputEvent) -> void:
	var shift: bool = event.shift_pressed == keybind["shift"]
	var ctrl: bool = event.ctrl_pressed == keybind["ctrl"]
	var alt: bool = event.alt_pressed == keybind["alt"]
	var key: bool = event.keycode == keybind["key"]
	if shift && ctrl && alt && key:
		_reload_plugins()
#endregion


#region plugin_reload
func _on_filesystem_change() -> void:
	_reload_plugin_list()
	
	var files_to_reload = EditorInterface.get_open_scenes()
	var script = EditorInterface.get_script_editor().get_current_script()
	if script:
		files_to_reload.push_back(script.resource_path)
	
	var reloader_dir = get_script().resource_path.get_base_dir().get_file()
	var result = []
	
	for file in files_to_reload:
		if not file.begins_with("res://addons/"): continue
		
		var name = file.get_slice("/", 3)
		if name == reloader_dir: continue
		
		if not get_plugin_info(name): return
		result.push_back(name)
	
	for plugin in result:
		if reload_queue.has(plugin):
			continue
		
		reload_queue.push_back(plugin)

var plugins := {}
func _reload_plugin_list() -> void:
	var reloader_dir: String = get_script().resource_path.get_base_dir().get_file()
	plugins = {}
	var origins := {}

	var dir = DirAccess.open(ADDONS_PATH)
	dir.list_dir_begin()
	var file = dir.get_next()
	while file:
		if file == reloader_dir:
			file = dir.get_next()
			continue
	
		var info = get_plugin_info(file)
		if not info:
			file = dir.get_next()
			continue

		var display_name: String = info["display_name"]
		  
		if not display_name in origins:
			origins[display_name] = [file]
		else:
			origins[display_name].append(file)
		plugins[file] = info
		
		file = dir.get_next()
	
	# Specify the exact plugin name in parenthesis in case of naming collisions.
	for display_name: String in origins:
		var plugin_filenames: Array = origins[display_name]
		if plugin_filenames.size() > 1:
			for filename in plugin_filenames:
				plugins[filename]["display_name"] = "%s (%s)" % [display_name, filename]
	
	editor_buttons.update_plugins(plugins)

func get_plugin_info(plugin: String):
	var dir = DirAccess.open(ADDONS_PATH)
	var display_name := plugin
	var plugin_config_path = ADDONS_PATH + plugin + "/plugin.cfg"
	
	if not dir.file_exists(plugin_config_path):
		return
	
	var plugin_cfg = ConfigFile.new()
	plugin_cfg.load(plugin_config_path)
	display_name = plugin_cfg.get_value("plugin", "name", plugin)
	var enabled := EditorInterface.is_plugin_enabled(plugin)
	
	return { "display_name": display_name, "enabled": enabled }

func _reload_selected(selected_plugins: Array) -> void:
	for plugin in selected_plugins:
		reload_plugin(plugin)

func _reload_plugins() -> void:
	for plugin in plugins:
		if plugins[plugin]["enabled"]:
			reload_plugin(plugin)

func reload_plugin(plugin: String) -> void:
	if plugin_config.get_value("settings", "verbose"):
		print("Reloading plugin: ", plugins[plugin]["display_name"])
	
	var enabled = EditorInterface.is_plugin_enabled(plugin)
	if enabled: # can only reload an active plugin
		EditorInterface.set_plugin_enabled(plugin, false)
		EditorInterface.set_plugin_enabled(plugin, true)
#endregion


#region settings
func _settings_updated(settings) -> void:
	plugin_config.set_value("settings", "verbose", settings["verbose"])
	plugin_config.set_value("settings", "auto", settings["auto"])
	plugin_config.set_value("settings", "keybind", settings["keybind"])
	plugin_config.save("res://addons/plugin_reloader/plugin.cfg")
	editor_buttons.set_tooltip_keybind(settings["keybind"])
	print("Settings updated!")
#endregion
