extends Node

const dict = {
	"__NULL__TAG__" : 0,
	"hello" : 1,
	"hello.world" : 2,
}

const dict2 = {
	"__NULL__TAG__" : 0,
	"hello" : { 
		"_" : 1,
		"world" : 2,
		"enum" : 3,
		},
}

enum enum_dict {
	THIS = 1,
	WORKS = 2,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func test():
	var loaded = dict.get("")
	loaded = enum_dict.THIS
	# enum_dict["NOW"] = 3 # cannot assign value to constant
	dict.hello # code completion works for constant dictionaries !!
	dict["hello.world"]
	dict2.hello._
	dict2.hello.world
	dict2.hello.enum
	Tags.tag("")
