extends Node

## Prints something like "FOO | BAR" for an enum flags values.
static func flags_to_str(flags, flags_type : Dictionary):
	var ret_val = ""
	
	if flags == 0:
		ret_val = flags_type.find_key(flags)
		return ret_val
	
	var first = true
	for idx in 32:
		var flag = 1 << idx
		if flag & flags:
			if not first:
				ret_val += " | "
			else: 
				first = false
			ret_val += flags_type.find_key(flag)
	return ret_val


static func enum_to_str(enum_val, enum_type):
	return str(enum_type.find_key(enum_val))


static func get_type_string(variable : Variant):
	var ret_val = "<unknown_type>"
	if not variable is Object:
		ret_val = type_string(typeof(variable))
	else:
		var inst_dict = inst_to_dict(variable)
		var path = inst_dict["@path"]
		if not path.is_empty():
			var script = load(path)
			var glob_name = script.get_global_name()
			if not glob_name.is_empty():
				ret_val = glob_name
			else:
				ret_val = path
			var subpath = inst_dict["@subpath"]
			if not subpath.is_empty():
				ret_val += "::%s" % subpath
		else:
			var _class = variable.get_class()
			if not _class.is_empty():
				ret_val = _class
	return ret_val
