@tool extends Control

signal add_button_pressed()
signal text_changed(new_text)

enum State {
	NONE,
	BUTTON,
	TEXT
}

var state : State = State.BUTTON

func _ready():
	focus_mode = Control.FOCUS_ALL

func switch_state(value):
	match(state):
		State.BUTTON:
			%AddButton.hide()
		State.TEXT:
			%TagEdit.hide()
	
	state = value
	
	match(state):
		State.BUTTON:
			%AddButton.show()
		State.TEXT:
			%TagEdit.show()


func _on_add_button_pressed():
	add_button_pressed.emit()


func _on_tag_edit_text_submitted(new_text):
	text_changed.emit(new_text)
	%TagEdit.text = ""


func open():
	%TagEdit.text = ""
	show()
	%TagEdit.grab_focus()


func reposition(global_position_):
	global_position = global_position_
	switch_state(State.BUTTON)
