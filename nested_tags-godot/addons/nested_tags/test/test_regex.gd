@tool
extends EditorScript

func _run():
	test_regex()


func test_regex():
	var text = "(abc, \"1234\", ten, \"hello\")"
	var regex = RegEx.create_from_string("(?<arg>.*?,)")
	var done = false
	var offset = 0
	var match_count = 0
	
	while not done:
		var rmatch = regex.search(text, offset)
		if rmatch:
			print(rmatch.get_string("arg"))
			offset = rmatch.get_end("arg")
			match_count += 1
		else:
			done = true
