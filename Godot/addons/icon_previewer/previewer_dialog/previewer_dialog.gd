@tool
extends Window

signal on_texture_copy(Texture2D)
signal texture_copy_confirmed(bool)

var icon_container: GridContainer
var search_input: LineEdit
var search_results: Button
var preview_name: Label
var preview_tex: TextureRect
var preview_size: Label
var copy_text: Label
var code_copy: Button
var texture_copy: Button
var themes_container: TabContainer


#region boilerplate
var is_initialized := false
func init() -> void:
	if is_initialized: return
	
	preview_name = $background/global_margin/VBoxContainer/HSplitContainer/preview_container/info/icon_name
	search_input = $background/global_margin/VBoxContainer/HSplitContainer/icons_container/search/input
	search_results = $background/global_margin/VBoxContainer/HSplitContainer/icons_container/search/results
	preview_tex = $background/global_margin/VBoxContainer/HSplitContainer/preview_container/info/icon_texture
	preview_size = $background/global_margin/VBoxContainer/HSplitContainer/preview_container/info/icon_size
	copy_text = $background/global_margin/VBoxContainer/HSplitContainer/preview_container/info/copy_text
	code_copy = $background/global_margin/VBoxContainer/HSplitContainer/preview_container/info/buttons/code_copy
	texture_copy = $background/global_margin/VBoxContainer/HSplitContainer/preview_container/info/buttons/texture_copy
	icon_container = $background/global_margin/VBoxContainer/HSplitContainer/icons_container/PanelContainer/icons/icon_grid
	themes_container = $background/global_margin/VBoxContainer/themes
	
	texture_copy_confirmed.connect(_on_texture_copy_confirmed)
	code_copy.pressed.connect(_on_code_copy)
	texture_copy.pressed.connect(_on_texture_copy)
	
	# Populate themes
	var editor_theme := EditorInterface.get_editor_theme()
	for icon_type in editor_theme.get_icon_type_list():
		var tab := Control.new()
		tab.name = icon_type
		themes_container.add_child(tab)
	
	is_initialized = true

func _ready() -> void: init()
#endregion


#region display
func clear_icons() -> void:
	var previous_icons = icon_container.get_children()
	for icon in previous_icons:
		icon_container.remove_child(icon)
		icon.queue_free()

func show_icons() -> void:
	init()
	
	clear_icons()
	
	var editor_theme := EditorInterface.get_editor_theme()
	var theme := themes_container.get_current_tab_control().name
	var icons = editor_theme.get_icon_list(theme)
	for icon in icons:
		if not matches_filter(icon):
			continue
		
		var icon_node = Button.new()
		var texture = editor_theme.get_icon(icon, theme)
		var size = texture.get_size()
		icon_node.icon = texture
		icon_node.flat = true
		icon_node.tooltip_text = icon
		icon_node.expand_icon = true
		icon_node.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		icon_node.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		icon_node.custom_minimum_size = Vector2i(28, 28)
		icon_node.pressed.connect(func(): update_preview(icon, texture))
		icon_container.add_child(icon_node)
	
	search_results.text = "Found: %s" % icon_container.get_children().size()

func _clear_search_bar() -> void:
	search_input.text = ""
	
	show_icons()

func _on_theme_container_tab_change(_tab: int) -> void:
	show_icons()

func _on_search_input_change(_filter: String) -> void:
	show_icons()

func matches_filter(icon: String) -> bool:
	if search_input.text.length() == 0:
		return true
	
	var item_name: String = icon.to_lower()
	var filter: String = search_input.text.to_lower()
	
	var display_match: bool = item_name.contains(filter)
	
	return item_name.contains(filter)

func update_preview(name, texture) -> void:
	preview_name.text = "%s/%s" % [themes_container.get_current_tab_control().name, name]
	preview_tex.texture = texture
	preview_size.text = str(texture.get_size())
	code_copy.disabled = false
	texture_copy.disabled = false
#endregion


#region copy_paste
func _on_code_copy():
	var info := preview_name.text.split('/')
	DisplayServer.clipboard_set("EditorInterface.get_editor_theme().get_icon(\"%s\", \"%s\")" % [info[1], info[0]])
	_display_copy_text("Copied to clipboard!")

func _on_texture_copy():
	on_texture_copy.emit(preview_tex.texture)

func _display_copy_text(message: String):
	copy_text.text = message
	
	copy_text.visible = true
	get_tree().create_timer(2).timeout.connect(func(): copy_text.visible = false)

func _on_texture_copy_confirmed(success: bool):
	_display_copy_text("Copied to property!" if success else "Invalid property type!")
#endregion
