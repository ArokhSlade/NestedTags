@tool
extends Node

const TypeUtils = preload("uid://bxx6f7forwdg1")

var s_singleton_name = r"Tags"
var s_dot = r"."
var s_quote = "\""
var s_open_paren = r"("
var s_identifier = r"(?:[A-Za-z_][A-Za-z0-1_]*)"
var s_optional_alphanum_string = r"(?:[A-Za-z0-1_]*)"
var s_tag_compound_name_prefix = r"(?:{identifier}\.)+".format({"identifier":s_identifier})
var s_alphanum = r"(?:[A-Za-z0-1_])"

var state : State
var arg_idx = -1
var method_name = "" 
var code_right : String
var tag_names_left := ""
var tag_names_right := ""
var tag_names_full := ""
var parent_tag = 0
var last_name_stub := ""
var matches = {}

func get_completion_options_old(editor, left, right):
	var parent_tag = 0
	var tags = Tags.get_child_tags(parent_tag)
	for tag in tags:
		var tag_text = Tags.name(tag)
		editor.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, tag_text, tag_text)
	editor.update_code_completion_options(true)


func get_completion_options(editor, left, right):
	code_right = right
	var suggestions_available = process(left)
	update_completion_options(editor)


func process(string):
	reset(string)
	while not state is EndState:
		var state_name = TypeUtils.get_type_string(state)
		print(state_name)
		state = state.process()
	if state is FailState:
		print("processsing failed: ", state.error_message)
		return false
	elif state is SuccessState:
		print("processing succeeded")
		return true
	else:
		push_error("unknown end state")
		return false


func reset(string):
	state = State0.new(self, string)
	arg_idx = -1
	method_name = "" 
	code_right = "" 
	tag_names_left = "" 
	tag_names_right = "" 
	tag_names_full = "" 
	parent_tag = 0
	last_name_stub = ""
	matches = {}


func update_completion_options(editor):
	print(matches)
	if not matches:
		return
	for tag_match in matches:
		var tag_text = tag_match
		# TODO: need to mark the end of the name stub to properly replace it / move the cursor rather than insert too many characters at the cursor position
		var insertion_text = tag_match.trim_prefix(last_name_stub)
		editor.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, tag_text, insertion_text)
	editor.update_code_completion_options(true)


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


func string_ends_with_identifier(string):
	var identifier_suffix = get_identifier_suffix(string)
	var ret_val = not identifier_suffix.is_empty()
	return ret_val


func get_identifier_suffix(string : String):
	var regex = RegEx.create_from_string(s_identifier + "$")
	var rex_match = regex.search(string)
	var ret_val = "" if not rex_match else rex_match.get_string()
	return ret_val


func print_excerpt(string):
	var excerpt = string.substr(string.length() - 32)
	print(excerpt)


@abstract class State:
	const StringUtils = preload("uid://b3ovshcx20auw")
	var host
	var string
	
	func _init(host_, string_ = ""):
		host = host_
		string = string_

	@abstract func process() -> State

class EndState extends State:
	func process():
		return self

class FailState extends EndState:
	var error_message = ""
	
	func _init(host_, string_):
		super(host_, string_)
		error_message = StringUtils.end_of_string(string, 32)
	
	func process():
		print(error_message)
		return self

class SuccessState extends EndState:
	pass

class State0 extends State:
	func process():
		host.tag_names_left = ""
		host.arg_idx = 0
		if string.ends_with(host.s_alphanum): # TODO: can we skip this test?
			var regex = RegEx.create_from_string(host.s_identifier + "$")
			var rex_match = regex.search(string)
			if rex_match:
				host.tag_names_left = rex_match.get_string()
				string = string.trim_suffix(host.tag_names_left)
				return State0_1.new(host, string)
		return State1.new(host, string) # not inside a tag name, check if right of "

class State0_1 extends State:
	func process():
		if string.ends_with(host.s_dot):
			host.tag_names_left = host.s_dot + host.tag_names_left
			string = string.trim_suffix(host.s_dot)
			return State0_2.new(host, string)
		return State1.new(host, string) # no compound name, proceed to parse "

class State0_2 extends State:
	func process():
		if string.ends_with(host.s_alphanum):
			var regex = RegEx.create_from_string(host.s_identifier + "$")
			var rex_match = regex.search(string)
			if not rex_match: # NOTE: could be we found a name ending on an alphanumeric character that is not a valid identifier, such as "1"
				return FailState.new(host, str("expected identifier before ", host.tag_names_left, " but found ...", StringUtils.end_of_string(string, 32)))
			var parent_tag_name = rex_match.get_string()
			host.tag_names_left = parent_tag_name + host.tag_names_left
			string = string.trim_suffix(parent_tag_name)
			return State0_1.new(host, string) # loop back to parse more parents
		return FailState.new(host, str("expected identifier before ", host.tag_names_left, " but found ...", StringUtils.end_of_string(string, 32)))

# <tag name compound opt>| (empty) tag names (left) confirmed. parse "
class State1 extends State:
	func process():
		if string.ends_with(host.s_quote):
			string = string.trim_suffix(host.s_quote)
			return State2.new(host, string)
			
		else:
			return FailState.new(host, str("no match: ", host.s_quote))

# "| confirmed. now parse (
class State2 extends State:
	func process():
		if string.ends_with(host.s_open_paren):
			string = string.trim_suffix(host.s_open_paren)
			return State3.new(host, string)
		else:
			var excerpt = string.substr(string.length() - 32)
			string = str("no match: ", host.s_open_paren, " at the end of:\n", excerpt)
			return FailState.new(host, string)

# ("| confirmed. now parse potential method name prefix.
class State3 extends State:
	func process():
		var identifier_suffix = host.get_identifier_suffix(string)
		if identifier_suffix:
			host.method_name = identifier_suffix
			string = string.trim_suffix(identifier_suffix)
			return State4.new(host, string)
		else:
			return FailState.new(host, string)

# <identifier>("| confirmed. now parse dot prefix
class State4 extends State:
	func process():
		if string.ends_with(host.s_dot):
			string = string.trim_suffix(host.s_dot)
			return State5.new(host, string)
		else:
			return FailState.new(host, string)

# .<identifier>("| confirmed. now parse Tags class prefix
class State5 extends State:
	func process():
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

# Tags.<method>(" confirmed with arg count > 0 and arg_0 nested_tag. 
# now parse right tail of tag name under cursor
class State6 extends State:
	func process():
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
		return State7.new(host, host.tag_names_full) # TODO: figure out how to manage string variable ownership

# same as 6,  with full tag name stub parsed and cached. now compute parent tag.
class State7 extends State:
	# NOTE: the string might be empty. if we got here, it means that there is the beginning of a 
	# 		valid tags method call expression and we are somewhere in the middle of the string that
	# 		represents the possibly empty, possibly full prefix (stub) of a tag name
	func process():
		var tag_full_name_stub = string
		var regex = RegEx.create_from_string(host.s_tag_compound_name_prefix)
		var rex_match = regex.search(tag_full_name_stub)
		var compound_name_prefix = "" if not rex_match else rex_match.get_string()
		var names : Array = tag_full_name_stub.split(".")
		var last_name_stub = names.back()
		if not compound_name_prefix:
			host.parent_tag = 0
		elif not Tags.has_tag(compound_name_prefix):
			return FailState.new(host, "state7: cannot give suggestions for a tag name chain that does not exist")
		else:
			host.parent_tag = Tags.tag(compound_name_prefix)
		host.last_name_stub = last_name_stub # TODO: again, duplication of data in host state. perhaps pass a dictionary around? every state would know what data to expect in it? or seperate State.Data classes for more type safety?
		return State8.new(host, last_name_stub)

# same as 7, with parent tag parsed and cached. now compute candidates (child tags)
class State8 extends State:
	# NOTE: the parent tag is determined, now check if the last name stub has any matching tags
	func process():
		var last_name_stub = string
		var candidates = Tags.get_child_tags(host.parent_tag)
		host.matches = {}
		for tag in candidates:
			var tag_name = Tags.name(tag)
			if tag_name.begins_with(last_name_stub):
				host.matches[tag_name] = tag
		if host.matches.size() > 0:
			return SuccessState.new(host, last_name_stub)
		return FailState.new(host, last_name_stub)
