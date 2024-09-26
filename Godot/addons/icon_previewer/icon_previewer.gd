@tool
extends EditorPlugin

var interface: PanelContainer

#region boilerplate
func _enter_tree():
	interface = preload("res://addons/icon_previewer/editor_buttons/editor_buttons.tscn").instantiate()
	interface.connect("on_texture_copy", _on_texture_copy)
	add_control_to_container(CONTAINER_TOOLBAR, interface)

func _exit_tree():
	remove_control_from_container(CONTAINER_TOOLBAR, interface)
	interface.queue_free()
#endregion

func _on_texture_copy(texture: Texture2D):
	var inspector := get_editor_interface().get_inspector()
	var selection := inspector.get_edited_object()
	var path := inspector.get_selected_path()
	
	var valid_property: bool = path.length() > 0 and typeof(selection[path]) == typeof(Texture2D)
	if valid_property:
		selection[path] = texture
	
	interface.emit_signal("texture_copy_confirmed", valid_property)
