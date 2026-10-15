@tool
extends Node2D

@export_custom(PROPERTY_HINT_NONE, "nested_tag") var tag : int = 3
@export_tool_button("print tag", "Anchor") var refresh_button = print_tag

@export var definition = load(ProjectSettings.get_setting("nested_tags/nested_tags_definition"))
var stylebox = load("res://addons/nested_tags/ui/nested_tags_definition/root_button_style_default.tres")


@export var curve : Curve = Curve.new()


class Spaceship:
	pass

class Frigate extends Spaceship:
	pass

func get_tag():
	return tag


func ship_handler(object):
	if object is Spaceship:
		handle_spaceship(object)
	if definition.contains(self.get_tag(), object.get_tag()):
		handle_spaceship(object)


func handle_spaceship(ship):
	print("spaceship")


func test_features():
	var definition = NestedTagsDefinition.new()
	definition.add_tag(&"building", 0)
	var building = definition.get_tag(&"building")
	var tower = definition.add_tag(&"tower", building)
	var house = definition.add_tag(&"house", building)
	var match_building = definition.match(tower, house)
	var is_match = match_building == building
	var is_building = definition.contains(building, tower)
	var full_name_tower = definition.get_full_name(tower)
	print(full_name_tower)
	var full_name_ok = &"building.tower" == full_name_tower
	var tower_by_name = definition.get_tag(full_name_tower)
	var by_name_ok = tower == tower_by_name
	
	print(is_match)
	print(is_building)
	print(full_name_ok)
	print(by_name_ok)
	
	var data = definition.get("data")
	print(data)


func _ready():
	print_tag()
	test_features()


func print_tag():
	var tag_name = definition.get_full_name(tag)
	print("tag: %s" % [tag_name])
