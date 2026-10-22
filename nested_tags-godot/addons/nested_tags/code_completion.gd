@tool
extends Node

const TypeUtils = preload("uid://bxx6f7forwdg1")

var s_singleton_name = r"Tags"
var s_dot = r"."
var s_quote = "\""
var s_comma = r","
var s_open_paren = r"("
var s_open_paren_esc = r"\("
var s_identifier = r"(?:[A-Za-z_][A-Za-z0-1_]*)"
var s_identifier_named_group = r"(?<identifier>[A-Za-z_][A-Za-z0-1_]*)"
var s_optional_alphanum_string = r"(?:[A-Za-z0-1_]*)"
var s_tag_compound_name_prefix = r"(?:{identifier}\.)+".format({"identifier":s_identifier})
var s_space = r"[\t ]"

var state : State
var arg_idx = -1
var method_name = "" 
var code_right : String
var tag_names_left := ""
var tag_names_right := ""
var tag_names_full := ""
var parent_tag = 0
var compound_name_prefix := ""
var last_name_stub := ""
var matches = {}
var suggest_integers = false


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
	compound_name_prefix = ""
	last_name_stub = ""
	matches = {}
	suggest_integers = false

 
func update_completion_options(editor):
	print(matches)
	if not matches:
		return
	if suggest_integers:
		for tag_match in matches:
			var tag_id = matches[tag_match]
			print("adding ", tag_match, " as id: ", tag_id)
			editor = editor as CodeEdit
			editor.add_code_completion_option(CodeEdit.KIND_CONSTANT, tag_match, str(tag_id), Color(1, 1, 1, 1), null, tag_id)
	else:
		for tag_match in matches:
			var tag_text = tag_match
			var insertion_text = tag_text
			print("adding ", tag_text)
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
		error_message = string
	
	func process():
		print(error_message)
		return self

class SuccessState extends EndState:
	pass

class State0 extends State:
	func process():
		host.tag_names_left = ""
		host.arg_idx = 0
		var regex = RegEx.create_from_string(host.s_identifier + "$")
		var rex_match = regex.search(string)
		if rex_match:
			host.tag_names_left = rex_match.get_string()
			string = string.trim_suffix(host.tag_names_left)
		return State0_1.new(host, string) # whether or not we found a name (fragment), proceed to parse dot

class State0_1 extends State:
	func process():
		if string.ends_with(host.s_dot):
			host.tag_names_left = host.s_dot + host.tag_names_left
			string = string.trim_suffix(host.s_dot)
			return State0_2.new(host, string)
		# TODO: check edge case "1abc - 1 is not a dot, so is ignored... 
		return State1.new(host, string) # no more parent names, proceed to parse "

class State0_2 extends State:
	func process():
		var regex = RegEx.create_from_string(host.s_identifier + "$")
		var rex_match = regex.search(string)
		if not rex_match:
			return FailState.new(host, str("expected identifier before ", host.tag_names_left, " but found ...", StringUtils.end_of_string(string, 32)))
		var parent_tag_name = rex_match.get_string()
		host.tag_names_left = parent_tag_name + host.tag_names_left
		string = string.trim_suffix(parent_tag_name)
		return State0_1.new(host, string) # loop back to parse more parents

# parsed a comma, now try parse (...,...,... and count the commas
class State0_3 extends State:
	func process():
		var regex = RegEx.create_from_string(str(host.s_open_paren_esc, r"(?:<arg_w_comma>(?:<arg>.+?),)"))

# <tag name compound opt>| (empty) tag names (left) confirmed. parse "
class State1 extends State:
	func process():
		if string.ends_with(host.s_quote):
			string = string.trim_suffix(host.s_quote)
			return State2.new(host, string)
		if host.tag_names_left:
			return FailState.new(host, str("found name stub ", host.tag_names_left, " left of cursor, but missing a leading '\"'."))
		return State2_1.new(host, string)

# parsed quote, now check for comma
class State1_1 extends State:
	func process():
		var regex = RegEx.create_from_string(str(r"(?:<comma>",host.s_space, ")$"))
		var rex_match = regex.search(string)
		if rex_match:
			string = string.trim_suffix(rex_match.get_name("comma"))
			return State
		

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
		host.compound_name_prefix = "" if not rex_match else rex_match.get_string()
		var names : Array = tag_full_name_stub.split(".")
		var last_name_stub = names.back()
		var trimmed_prefix = host.compound_name_prefix.trim_suffix(host.s_dot) # trailing dot will confuse Tags name matcher
		if not trimmed_prefix:
			host.parent_tag = 0
		elif not Tags.has_tag(trimmed_prefix):
			return FailState.new(host, str("no suggestions for ", tag_full_name_stub))
		else:
			host.parent_tag = Tags.tag(trimmed_prefix)
		host.last_name_stub = last_name_stub # TODO: again, duplication of data in host state. perhaps pass a dictionary around? every state would know what data to expect in it? or seperate State.Data classes for more type safety?
		return State8.new(host, last_name_stub)

# same as 7, with parent tag parsed and cached. now compute candidates (child tags)
class State8 extends State:
	# NOTE: the parent tag is determined, now check if the last name stub has any matching tags
	func process():
		var last_name_stub = string
		var candidates = Tags.get_descendant_tags(host.parent_tag)
		host.matches = {}
		if "" == host.tag_names_full:
			for tag in candidates:
				host.matches[Tags.full_name(tag)] = tag
		else:
			for tag in candidates:
				if Tags.full_name(tag).contains(host.tag_names_full):
					host.matches[Tags.full_name(tag)] = tag
		if host.matches.size() > 0:
			return SuccessState.new(host, last_name_stub)
		return FailState.new(host, last_name_stub)

# confirmed no name stub and no " left of cursor. now parse (
class State2_1 extends State:
	func process():
		var regex_string = str(host.s_singleton_name , host.s_dot , host.s_identifier_named_group , host.s_open_paren_esc , "$")
		var regex = RegEx.create_from_string(regex_string)
		var rex_match = regex.search(string)
		if rex_match:
			host.method_name = rex_match.get_string("identifier")
			var methods = Tags.get_singleton().get_method_list()
			for method in methods:
				if method.name == host.method_name:
					assert(host.arg_idx >= 0)
					if method.args.size() > host.arg_idx:
						var arg = method.args[host.arg_idx]
						if arg.hint_string == "nested_tag":
							print(regex_string)
							return State8_1.new(host, string)
						return FailState.new(host, str("argument at index " , host.arg_idx + " does not seem to be a nested tag, at least it's missing a hint string nested_tag"))
					return FailState.new(host, str("method " , host.method_name , " only takes " , method.args.size() , " args, but arg index was " , host.arg_idx))
			return FailState.new(host, str("no method " , host.method_name , "found"))
		return FailState.new(host, str("could not match a valid identifier / method name before ( for regex ", regex_string, " in ", StringUtils.end_of_string(string, 32)))

# valid method and arg idx confirmed, with no string stub. now suggest all existing tags
class State8_1 extends State:
	func process():
		host.matches = {}
		Tags.ensure_definition()
		for tag in Tags.definition:
			host.matches[Tags.full_name(tag)] = tag
		if host.matches.size() > 0:
			host.suggest_integers = true
			return SuccessState.new(host, string)
		return FailState.new(host, "could not find any tags in Tags definition")
