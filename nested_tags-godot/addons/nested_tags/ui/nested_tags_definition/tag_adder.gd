@tool
extends LineEdit

signal text_canceled(text)

func _ready():
	focus_mode = Control.FOCUS_ALL


func open():
	reset_validity()
	grab_focus()
	show()


func close():
	hide()
	text = ""


func _gui_input(event : InputEvent):
	if event.is_action_pressed("ui_cancel"):
		text_canceled.emit(text)


func _on_text_changed(new_text):
	reset_validity()


func reset_validity():
	modulate = Color.WHITE


func signal_invalid_input():
	modulate = Color(0.95, 0.372, 0.342, 1.0)
