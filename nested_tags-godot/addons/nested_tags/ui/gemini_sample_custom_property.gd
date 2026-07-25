@tool
extends ScrollContainer


# The object/resource whose properties you want to display.
# Starts as null until set by your main plugin script.
var target_object: Object:
	set(value):
		target_object = value
		# Rebuild the UI automatically whenever the object changes
		build_custom_inspector()

@onready var vbox = $VBoxContainer

func _ready():
	# Clean slate on startup since no object is selected yet
	build_custom_inspector()


func build_custom_inspector():
	# 1. Always clear old elements first
	if vbox:
		for child in vbox.get_children():
			child.queue_free()

	# 2. Hard guard: If target_object is null, stop here and leave the panel empty
	if not is_instance_valid(target_object):
		return
		
	var obj_id = target_object.get_instance_id()

	# 3. Loop through valid properties
	for prop in target_object.get_property_list():
		if prop["usage"] & PROPERTY_USAGE_EDITOR:
			var prop_name = prop["name"]
			
			var editor_property: EditorProperty = EditorInterface.get_inspector().instantiate_property_editor(
				target_object, 
				prop["type"], 
				prop_name, 
				prop["hint"], 
				prop["hint_string"], 
				prop["usage"]
				)
			if editor_property:
				editor_property.label = prop_name.capitalize()

				# CORRECT FOR GODOT 4.x:
				# Explicitly bind the target instance and string property path name
				editor_property.set_object_and_property(target_object, prop_name)

				# Bind synchronization logic
				editor_property.property_changed.connect(
					func(property, value, field, changing):
						if is_instance_valid(target_object):
							target_object.set(property, value)
				)

				vbox.add_child(editor_property)

				# Now it knows safely where to fetch the current live data value
				editor_property.update_property() 
