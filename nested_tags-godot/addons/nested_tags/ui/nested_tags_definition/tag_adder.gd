@tool
extends LineEdit

signal text_canceled(text)

func _ready():
	focus_mode = Control.FOCUS_ALL


func open():
	grab_focus()
	show()


func close():
	hide()
	text = ""


func _gui_input(event : InputEvent):
	if event.is_action_pressed("ui_cancel"):
		text_canceled.emit(text)
