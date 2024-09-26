@tool
extends PanelContainer

signal on_texture_copy(Texture2D)
signal texture_copy_confirmed(bool)

var button: Button
var previewer_dialog: Window

#region boilerplate
func _ready():
	button = $Button
	previewer_dialog = preload("res://addons/icon_previewer/previewer_dialog/previewer_dialog.tscn").instantiate()
	
	texture_copy_confirmed.connect(_on_texture_copy_confirmed)
	button.pressed.connect(_on_button_pressed)
	previewer_dialog.connect("on_texture_copy", _on_texture_copy)
	previewer_dialog.close_requested.connect(_on_close_request)
	
	if get_tree().edited_scene_root == self:
		return # This is the scene opened in the editor!
	
	previewer_dialog.show_icons()
	
	get_parent().move_child(self, 5)

func _exit_tree():
	if get_tree().edited_scene_root == self:
		return # This is the scene opened in the editor!
	
	previewer_dialog.queue_free()
#endregion

#region dialog
var dialog_open = false
func _on_button_pressed():
	if dialog_open:
		previewer_dialog.grab_focus()
		return
	
	add_child(previewer_dialog)
	previewer_dialog.popup_centered(Vector2(800, 600))
	dialog_open = true

func _on_close_request():
	remove_child(previewer_dialog)
	dialog_open = false
	
func _on_texture_copy(texture: Texture2D):
	on_texture_copy.emit(texture)

func _on_texture_copy_confirmed(success: bool):
	previewer_dialog.emit_signal("texture_copy_confirmed", success)
#endregion
