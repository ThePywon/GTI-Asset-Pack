@tool
extends ConfirmationDialog


var search_input: LineEdit
var search_result: Button
var hide_disabled_toggle: Button
var item_list: ItemList


#region boilerplate
func _ready():
	get_ok_button().disabled = true
	set_meta("plugins", [])

func _process(delta):
	if get_tree().edited_scene_root == self:
		return # This is the scene opened in the editor!
	
	update_meta()
#endregion


#region plugin_list
var plugin_list: Dictionary
func update_plugin_list(plugins):
	item_list = $margin/body/plugin_list
	search_input = $margin/body/search/input
	search_result = $margin/body/search/results
	hide_disabled_toggle = $margin/body/hide_disabled_toggle
	
	plugin_list = plugins;
	
	show_plugin_list()

func show_plugin_list():
	item_list.clear()
	get_ok_button().disabled = true
	
	var editor_theme = EditorInterface.get_editor_theme();
	var idx = 0
	for plugin in plugin_list:
		if not matches_filter(plugin):
			continue
		
		item_list.add_item(plugin_list[plugin]["display_name"],
			editor_theme.get_icon("EditorPlugin", "EditorIcons"))
		item_list.set_item_metadata(idx, plugin)
		item_list.set_item_disabled(idx, not plugin_list[plugin]["enabled"])
		
		idx += 1
	
	search_result.text = "Found: %s" % idx
	
	update_meta()

func update_meta():
	var selected_items := item_list.get_selected_items()
	if selected_items.is_empty(): return
	
	get_ok_button().disabled = false
	var plugins_meta := []
	for i in selected_items:
		plugins_meta.push_back(item_list.get_item_metadata(i))
	
	set_meta("plugins", plugins_meta)

func _clear_search_bar():
	search_input.text = "";
	show_plugin_list()

func _on_search_input_change(_filter):
	show_plugin_list()

func _on_hide_toggle_pressed():
	show_plugin_list()

func matches_filter(plugin: String) -> bool:
	var hide_disabled: bool = hide_disabled_toggle.button_pressed
	var item_enabled: bool = plugin_list[plugin]["enabled"]
	
	if search_input.text.length() == 0:
		return not hide_disabled or item_enabled
	
	var item_name: String = plugin_list[plugin]["display_name"].to_lower()
	var filter: String = search_input.text.to_lower()
	
	var display_match: bool = item_name.contains(filter)
	var file_match: bool = plugin.to_lower().contains(filter)
	
	if(hide_disabled):
		return (display_match or file_match) and item_enabled
	else:
		return display_match or file_match
#endregion
