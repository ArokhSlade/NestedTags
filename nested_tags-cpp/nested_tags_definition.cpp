#include "nested_tags_definition.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/string_name.hpp>
#include <godot_cpp/variant/array.hpp>

namespace NestedTags
{
NestedTagsDefinition::NestedTagsDefinition()
	: last_tag_id{0}
	, data(HashMap<id_t, TagData>())
	{
		names.push_back(StringName(null_tag_name));
		parents.push_back(0);
		data.insert(0, TagData{0, StringName(null_tag_name)});
	}

const char* NestedTagsDefinition::null_tag_name = "__NULL__TAG__";

bool NestedTagsDefinition::is_root_tag(id_t p_id) const {
	return 0 == get_parent_id(p_id);
}

bool NestedTagsDefinition::try_add(const StringName& p_name, id_t p_parent_id) {
	bool ret_val = true;
	ret_val &= is_tag_name_valid(p_name);
	ret_val &= !is_name_taken_among_siblings(p_name, p_parent_id);
	if (ret_val) {
		id_t new_id = ++last_tag_id;
		data[new_id] = TagData{p_parent_id, p_name};
	}
	return ret_val;
}

	//  treat invalid input as error because explicit should only be called with valid data.
	//  this function is allowed to add the null tag because it is used for loading serialized data
	bool NestedTagsDefinition::_try_add_explicit(id_t p_id, const StringName& p_name, id_t p_parent_id) {
	if (data.has(p_id)) {
		UtilityFunctions::push_error(FUNCTION_STR, ": tried adding existing tag: ", p_id, " (name: ", p_name, " parent: ", p_parent_id, ")");
		return false;
	}
	bool is_null_tag = p_name == StringName(null_tag_name);
	is_null_tag &= 0 == p_id;
	is_null_tag &= 0 == p_parent_id;
	
	if (!is_tag_name_valid(p_name)) {
		UtilityFunctions::push_error(FUNCTION_STR, ": invalid name: ", p_name);
		return false;
	}
	if (is_name_taken_among_siblings(p_name, p_parent_id)) {
		UtilityFunctions::push_error(FUNCTION_STR, ": name ", p_name, " not unique among siblings.");
		return false;
	}
	if (p_id > last_tag_id) {
		last_tag_id = p_id;
	}
	data[p_id] = TagData{p_parent_id, p_name};

	return true;
}

void NestedTagsDefinition::erase(id_t p_id) {
	if (!has_tag(p_id)) {
		UtilityFunctions::push_error(FUNCTION_STR, ": could not erase item with id ", p_id, " because it does not exist.");
	}
	if (0 == p_id) {
		UtilityFunctions::push_warning(FUNCTION_STR, ": request to erase null-tag denied because it's meant to exist at all times.");
		return;
	}
	_erase_recursively(p_id);	
}

void NestedTagsDefinition::_erase_recursively(id_t p_id) {
	if (0 == p_id) {
		return;
	}
	for (auto& item : data) {
		TagData tag_data = item.value;
		if (tag_data.parent_id == p_id) {
			_erase_recursively(item.key);
		}
		data.erase(p_id);
		tags.erase(p_id);
	}
}

bool NestedTagsDefinition::has_tag(id_t p_id) const {
	bool ret_val = data.has(p_id);
	return ret_val;
}

id_t NestedTagsDefinition::try_get_id(const StringName& p_tag_string) const {
	id_t ret_val = 0;
	PackedStringArray strings = p_tag_string.split(String("."));
	id_t last_tag_id = 0;
	
	for (String& string : strings) {
		last_tag_id = try_get_child_by_name(string, last_tag_id);
		if (0 == last_tag_id) {
			return 0;
		}
	}
	ret_val = last_tag_id;
	return ret_val;
}

id_t NestedTagsDefinition::try_get_child_by_name(const StringName& p_name, id_t p_parent_id) const {
	for (auto& id_and_data : data) {
		TagData tag_data = id_and_data.value;
		if (tag_data.name == p_name && tag_data.parent_id == p_parent_id) {
			return id_and_data.key;	
		}		
	}
	return 0;
}

StringName NestedTagsDefinition::get_full_name(id_t p_id) const {
	String result = StringName("");
	Vector<StringName> lineage_names = get_lineage_names(p_id);
	int parent_names_size = lineage_names.size();
	for (int i = 0; i < parent_names_size - 1 ; i++) {
		result += lineage_names[i];
		result += String(".");
	}
	// no trailing point for last one
	if (parent_names_size > 0) {
		result += lineage_names[parent_names_size - 1];
	}
	return StringName(result);
}

Vector<StringName> NestedTagsDefinition::get_lineage_names(id_t p_id) const {
	Vector<StringName> parent_names;
	id_t current_id = p_id;
	while (current_id != 0) {
		parent_names.push_back(get_name(current_id));
		current_id = get_parent_id(current_id);
	}
	parent_names.reverse(); // Reverse the order to have the root parent first
	return parent_names;
}

bool NestedTagsDefinition::try_reparent(id_t p_id, id_t p_parent_id) {
	bool ret_val = false;
	if (!has_tag(p_id) || 0 == p_id) {
		UtilityFunctions::push_error(FUNCTION_STR, ": invalid id: ", p_id);
	} else if (!has_tag(p_parent_id)) {
		UtilityFunctions::push_error(FUNCTION_STR, ": invalid parent id: ", p_parent_id);
	} else {
		id_t ancestor_id = get_closest_shared_ancestor(p_id, p_parent_id);
		if (p_id !=	ancestor_id) {
			data[p_id].parent_id = p_parent_id;
			ret_val = true;
		}
	}
	return ret_val;
}

bool NestedTagsDefinition::try_rename(id_t p_id, const StringName& p_name) {
	if (!has_tag(p_id) || 0 == p_id) {
		UtilityFunctions::push_error(FUNCTION_STR, ": invalid id: ", p_id);
		return false;
	} else if (!is_tag_name_valid(p_name)) {
		return false;
	} else {
		id_t parent = data[p_id].parent_id;
		if (is_name_taken_among_siblings(p_name, parent)) {
			return false;
		}
	}
	data[p_id].name = p_name;
	return true;
}

StringName NestedTagsDefinition::get_name(id_t p_id) const {
	if (!has_tag(p_id)) {
		return names[0]; // Return a default name for invalid IDs
	}
	return data[p_id].name;
}

id_t NestedTagsDefinition::get_parent_id(id_t p_id) const {
	if (!has_tag(p_id)) {
		UtilityFunctions::push_error(FUNCTION_STR, ": invalid id");
		return data[0].parent_id; // Return a default parent ID for invalid IDs
	}
	return data[p_id].parent_id;
}

Variant NestedTagsDefinition::_iter_init(Array p_iter) const {
	if (data.size() <= 1)
	{
		return false;
	}
	p_iter[0] = get_ids();
	
	return true;
}

Variant NestedTagsDefinition::_iter_next(Array p_iter) const {
	Array ids = p_iter[0];
	ids.pop_front();
	p_iter[0] = ids;
	return (ids.size() > 0);
}

Variant NestedTagsDefinition::_iter_get(const Variant& p_iter) const{
	Array ids = p_iter;
	id_t id = id_t(ids[0]);
	return id;
}

int NestedTagsDefinition::size() const {
	return data.size(); 
}

void NestedTagsDefinition::_bind_methods() {
	ClassDB::bind_method(D_METHOD("_to_string"), &NestedTagsDefinition::_to_string);
	ClassDB::bind_method(D_METHOD("is_root_tag", "p_id"), &NestedTagsDefinition::is_root_tag);
	ClassDB::bind_method(D_METHOD("try_add", "p_name", "p_parent_id"), &NestedTagsDefinition::try_add, DEFVAL(0));
	ClassDB::bind_method(D_METHOD("erase", "p_id"), &NestedTagsDefinition::erase);
	ClassDB::bind_method(D_METHOD("has_tag", "p_id"), &NestedTagsDefinition::has_tag);
	ClassDB::bind_method(D_METHOD("get_name", "p_id"), &NestedTagsDefinition::get_name);
	ClassDB::bind_method(D_METHOD("get_parent_id", "p_id"), &NestedTagsDefinition::get_parent_id);
	ClassDB::bind_method(D_METHOD("size"), &NestedTagsDefinition::size);
	ClassDB::bind_method(D_METHOD("_iter_init", "p_iter"), &NestedTagsDefinition::_iter_init);
	ClassDB::bind_method(D_METHOD("_iter_next", "p_iter"), &NestedTagsDefinition::_iter_next);
	ClassDB::bind_method(D_METHOD("_iter_get", "p_iter"), &NestedTagsDefinition::_iter_get);
	ClassDB::bind_method(D_METHOD("try_reparent", "p_id", "p_parent_id"), &NestedTagsDefinition::try_reparent);
	ClassDB::bind_method(D_METHOD("try_rename", "p_id", "p_name"), &NestedTagsDefinition::try_rename);
	ClassDB::bind_method(D_METHOD("_try_add_explicit", "p_id", "p_name", "p_parent_id"), &NestedTagsDefinition::_try_add_explicit);
	ClassDB::bind_method(D_METHOD("get_full_name", "p_id"), &NestedTagsDefinition::get_full_name);
}

String NestedTagsDefinition::_to_string() const {
    return String("NestedTagsDefinition");
}

bool NestedTagsDefinition::_set(const StringName &p_name, const Variant &p_value) {
	if (p_name == StringName("data"))
	{
		tags.clear();
		data.clear();
		Dictionary _data = Dictionary(p_value);
		auto keys = _data.keys();
		for (id_t id : keys)
		{
			Dictionary data_dict = _data[id];
			id_t parent_id = data_dict["parent_id"];
			StringName name = data_dict["name"];
			_try_add_explicit(id, name, parent_id);
		}
		return true;
	}
	return false;
}

bool NestedTagsDefinition::_get(const StringName &p_name, Variant &r_ret) const {
	if (p_name == StringName("data"))
	{
		Dictionary _data = Dictionary{};
		for (auto& kv : data)
		{
			id_t id = kv.key;
			Dictionary data_dict{};
			data_dict["parent_id"] = kv.value.parent_id;
			data_dict["name"] = kv.value.name;
			_data[id] = data_dict;
		}
		r_ret = _data;
	}
	else if (p_name == StringName("names")) {
		Array names = get_names();
		r_ret = names;
	} else if (p_name == StringName("parents")) {
		Array parent_ids = get_parent_ids();
		r_ret = parent_ids;
	} else if (p_name == StringName("tags")) {
		r_ret = tags;
	} else
	{
		return false;
	}
    return true;
}
	
Array NestedTagsDefinition::get_names() const {
	Array retval{};
	for (auto& tag_data : data)
	{
		retval.push_back(tag_data.value.parent_id);
	}
	return retval;
}

Array NestedTagsDefinition::get_parent_ids() const {
	Array retval{};
	for (auto& tag_data : data)
	{
		retval.push_back(tag_data.value.name);
	}
	return retval;
}
	
void NestedTagsDefinition::_get_property_list(List<PropertyInfo> *p_list) const {
	p_list->push_back(PropertyInfo(Variant::ARRAY, "names", PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NO_EDITOR | PROPERTY_USAGE_INTERNAL));
	p_list->push_back(PropertyInfo(Variant::ARRAY, "parents", PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NO_EDITOR | PROPERTY_USAGE_INTERNAL));
	p_list->push_back(PropertyInfo(Variant::ARRAY, "tags", PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NONE));
	p_list->push_back(PropertyInfo(Variant::DICTIONARY, "data", PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NO_EDITOR | PROPERTY_USAGE_INTERNAL));
}
 
id_t NestedTagsDefinition::get_closest_shared_ancestor(id_t p_id_1, id_t p_id_2) const {
	id_t ret_val = id_t{0};
		
	Array lineage_1 = get_lineage_ids(p_id_1);
	Array lineage_2 = get_lineage_ids(p_id_2);
	
	int max_count = std::min(lineage_1.size(), lineage_2.size());
	
	id_t ancestor_id = 0;
	for (int i = 0; i < max_count; i++) {
		if (lineage_1[i] == lineage_2[i]) {
			ancestor_id = lineage_1[i];
		} else {
			break;
		}
	}
	ret_val = ancestor_id;
	return ret_val;
}

Array NestedTagsDefinition::get_lineage_ids(id_t p_id) const {
	Array ret_val;
	
	id_t current = p_id;
	while (0 != current) {
		ret_val.push_back(current);
		current = get_parent_id(current);
	}
	ret_val.push_back(0);
	
	ret_val.reverse();	
	return ret_val;
}

Array NestedTagsDefinition::get_ids() const
{
	Array ret_val{};
	
	for (auto& item : data) {
		if (0 == item.key) {
			continue;
		}
		ret_val.push_back(int64_t(item.key));
	}
		
	return ret_val;
}

bool NestedTagsDefinition::is_tag_name_valid(const String& p_name) {
	bool ret_val = p_name.is_valid_identifier();
	return ret_val;
}

bool NestedTagsDefinition::is_name_taken_among_siblings(const String& p_name, id_t p_parent_id) {
	bool ret_val = false;

	Vector<id_t> siblings = get_child_ids(p_parent_id);
	for (id_t sibling : siblings) {
		const String& sibling_name = get_name(sibling);
		ret_val |= (sibling_name == p_name);
	}
	
	return ret_val;
}

Vector<id_t> NestedTagsDefinition::get_child_ids(id_t p_parent_id)
{
	Vector<id_t> ret_val{};
	for (auto& item : data) {
		if (item.value.parent_id == p_parent_id) {
			ret_val.push_back(item.key);
		}
	}
	return ret_val;
}
}

