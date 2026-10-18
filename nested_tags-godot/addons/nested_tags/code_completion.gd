@tool
extends Node

var s_singleton_name = r"Tags"
var s_dot = r"."
var s_quote = r"\""
var s_open_parent = r"("
var s_identifier = r"(?:[A-Za-z_][A-Za-z0-1_]*)"
var s_optional_alphanum_string = r"(?:[A-Za-z0-1_]*)"

var arg_idx = -1
var method_name = ""
 
var state : State


var code_left : String
var code_right : String
var tag_names_left := ""
var tag_names_right := ""
var tag_names_full := ""

func get_completion_options(editor, left, right):
	var parent_tag = 0
	var tags = Tags.get_child_tags(parent_tag)
	for tag in tags:
		var tag_text = Tags.name(tag)
		editor.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, tag_text, tag_text)
	editor.update_code_completion_options(true)

func get_completion_options_2(left, right):
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


func get_last_complete_compound(tag_name_stub):
	pass


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
			host.tag_names_left = ""
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
			var methods = Tags.get_singleton().get_method_list()
			for method in methods:
				if method.name == host.method_name:
					string = string.trim_suffix(host.s_singleton_name)
					assert(host.arg_idx >= 0)
					if method.args.size() > host.arg_idx:
						var arg = method.args[host.arg_idx]
						if arg.hint_string == "nested_tag":
							return State6.new(host, string)
		return FailState.new(host, string)

class State6 extends State:
	func process(string):
		host.tag_names_right = ""
		var regex
		if host.tag_names_left:
			regex = RegEx.create_from_string(host.s_optional_alphanum_string)
		else:
			regex = RegEx.create_from_string(host.s_identifier)
		var rex_match = regex.search(host.code_right)
		if rex_match:
			host.tag_names_right = rex_match.get_string()
		host.tag_names_full = host.tag_names_left + host.tag_names_right
		if host.tag_names_full:
			return State7.new(host, host.tag_names_full) # TODO: figure out how to manage string variable ownership
		else:
			return FailState.new(host, string)


class State7 extends State:
	func process(tag_full_name_stub):
		#Tags.get_child_tags()
		pass
