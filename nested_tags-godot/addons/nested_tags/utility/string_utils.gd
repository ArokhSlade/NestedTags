extends Node


static func end_of_string(string, max_length):
	var start_pos = maxi(string.length() - max_length, 0)
	var ret_val = string.substr(start_pos)
	return ret_val
