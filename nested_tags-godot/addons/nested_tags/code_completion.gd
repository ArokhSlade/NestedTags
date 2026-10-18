@tool
extends Node

var s_singleton_name = r"Tags"
var s_dot = r"."
var s_quote = r"\""
var s_open_parent = r"("
var s_identifier = r"(?:[A-Za-z_][A-Za-z0-1_]*)"

var arg_idx = -1
var method_name = ""
 
var state : State

func get_completion_options(editor, left, right):
	var parent_tag = 0
	var tags = Tags.get_child_tags(parent_tag)
	for tag in tags:
		var tag_text = Tags.name(tag)
		editor.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, tag_text, tag_text)
	editor.update_code_completion_options(true)

func autocomplete(left, right):
	var relevant_completable_string = extract_relevant_completable_string(left, right)


func suffix_search_result_index(success, string, suffix):
	var ret_val = -1 if not success else string.length() - suffix.length()
	return ret_val


func parse_end_singleton_name(string):
	var ret_val = parse_suffix(string, s_singleton_name)
	return ret_val


func parse_end_dot(string):
	var ret_val = parse_suffix(string, s_dot)
	return ret_val


func parse_suffix(string, suffix):
	var ret_val = string.ends_with(suffix)
	ret_val = suffix_search_result_index(ret_val, string, suffix)
	return ret_val

func extract_relevant_completable_string(left, right):
	var ret_val = ""
	return ret_val

func string_ends_with_identifier(string):
	var identifier_suffix = get_identifier_suffix(string)
	var ret_val = not identifier_suffix.is_empty()
	return ret_val


func get_identifier_suffix(string : String):
	var regex = RegEx.create_from_string(s_identifier + "$")
	var rex_match = regex.search(string)
	var ret_val = "" if not rex_match else rex_match.get_string()
	return ret_val


func process(string):
	var processing = true
	while processing:
		state = state.process(string)
		if state is EndState:
			processing = false


class State:
	var host
	var string
	
	func _init(host_, string_ = ""):
		host = host_
		string = string_

	func process(string : String):
		return -1

class EndState extends State:
	func process(string):
		return self

class FailState extends EndState:
	func process(string):
		print("fail!")
		return self

class SuccessState extends EndState:
	pass

class State1 extends State:
	func process(string):
		if string.ends_with(host.s_quote):
			string = string.trim_suffix(host.s_quote)
			return State2.new(host, string)
		else:
			return FailState.new(host, string)

class State2 extends State:
	func process(string):
		if string.ends_with(host.s_open_paren):
			string = string.trim_suffix(host.s_open_parent)
			return State3.new(host, string)
		else:
			return FailState.new(host, string)

class State3 extends State:
	func process(string : String):
		var identifier_suffix = host.get_identifier_suffix(string)
		if identifier_suffix:
			host.method_name = identifier_suffix
			string = string.trim_suffix(identifier_suffix)
			return State4.new(host, identifier_suffix)
		else:
			return FailState.new(host, string)

class State4 extends State:
	func process(string):
		if string.ends_with(host.s_dot):
			string = string.trim_suffix(host.s_dot)
			return State5.new(host, string)
		else:
			return FailState.new(host, string)

class State5 extends State:
	func process(string):
		if string.ends_with(host.s_singleton_name):
			var methods = Tags.get_method_list()
			for method in methods:
				if method.name == method_name:
					string = string.trim_suffix(host.s_singleton_name)
					return State6.new(host, string)
		return FailState.new(host, string)

class State6 extends State:
	func process(string):
		var 
		
