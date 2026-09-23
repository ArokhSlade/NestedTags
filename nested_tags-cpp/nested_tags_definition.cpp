#include "nested_tags_definition.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/string_name.hpp>
#include <godot_cpp/variant/array.hpp>
#include "nested_tag.h"

namespace NestedTags {

NestedTagsDefinition::NestedTagsDefinition()
	: names{}
	, parents{}
	, tags{Ref<NestedTag>(memnew(NestedTag{0}))} // Initialize with a default "null" tag
	, last_tag_id{0}
	{
		names.push_back(StringName("<NULL>"));
		parents.push_back(0);
		if (!singleton.is_valid()) {
			singleton = Ref<NestedTagsDefinition>{};
		}
	}

Ref<NestedTagsDefinition> NestedTagsDefinition::singleton = Ref<NestedTagsDefinition>{};

Ref<NestedTagsDefinition> NestedTagsDefinition::try_get_singleton() {
	if (!singleton.is_valid()) {
		UtilityFunctions::push_error("NestedTagsDefinition::try_get_singleton(): singleton is invalid.");
	}
	return singleton;
}

void NestedTagsDefinition::initialize_singleton(Ref<NestedTagsDefinition> p_singleton) {	
	//ERR_FAIL_COND_EDMSG(singleton.is_valid(), "NestedTagsDefinition::initialize_singleton(): singleton is already initialized.");
	if (singleton.is_valid()) {
		WARN_PRINT_ED("NestedTagsDefinition::initialize_singleton(): singleton is already initialized");
	}
	singleton = p_singleton;
}

bool NestedTagsDefinition::is_id_valid(id_t p_id) const {
		return p_id != 0 && size() > p_id;
	}

bool NestedTagsDefinition::is_root_tag(id_t p_id) const {
    return 0 == get_parent_id(p_id);
}

// TODO: why is p_id needed?
void NestedTagsDefinition::add(const StringName &p_name, id_t p_parent_id, id_t p_id) {
    if (names.size() != parents.size()) {
		ERR_PRINT("NestedTagsDefinition: names and parents size mismatch.");
		return;
	}
	if (p_id >= names.size()) {
		p_id = 0; // If the provided ID is out of bounds, treat it as 0 (add to the end)
	} 
	if (p_id == 0) {
		names.push_back(p_name);
		parents.push_back(p_parent_id);
		tags.push_back(Ref<NestedTag>(memnew(NestedTag{id_t(++last_tag_id)})));
	} else {
		names.insert(p_id, p_name);
		parents.insert(p_id, p_parent_id);
		tags.insert(p_id, Ref<NestedTag>(memnew(NestedTag{p_id})));
	}
}

Ref<NestedTag> NestedTagsDefinition::get_tag(id_t p_id) const {
	if (p_id >= size()) { 
		UtilityFunctions::push_error("NestedTagsDefinition::get_tag(): id out of range");
		return tags[0]; // Return a default "null" tag for IDs 
	}
	return tags[p_id];
}

void NestedTagsDefinition::reparent(id_t p_id, id_t p_parent_id) {
	ERR_FAIL_COND_EDMSG(!is_id_valid(p_id), "NestedTagsDefinition::reparent(): invalid id");
	ERR_FAIL_COND_EDMSG(!is_id_valid(p_parent_id), "NestedTagsDefinition::reparent(): invalid parent id");
	parents[p_id] = p_parent_id;
}

void NestedTagsDefinition::rename(id_t p_id, const StringName &p_name) {
	ERR_FAIL_COND_EDMSG(!is_id_valid(p_id), "NestedTagsDefinition::rename(): invalid id");
	ERR_FAIL_COND_EDMSG(p_name.is_empty(), "NestedTagsDefinition::rename(): invalid name (empty)");
	names[p_id] = p_name;
}

StringName NestedTagsDefinition::get_name(id_t p_id) const {
	if (!is_id_valid(p_id)) {
		UtilityFunctions::printerr("NestedTagsDefinition::get_name(): invalid id");
		return names[0]; // Return a default name for invalid IDs
	}
	return names[p_id];
}

id_t NestedTagsDefinition::get_parent_id(id_t p_id) const {
	if (!is_id_valid(p_id)) {
		UtilityFunctions::printerr("NestedTagsDefinition::get_parent_id(): invalid id");
		return parents[0]; // Return a default parent ID for invalid IDs
	}
	return parents[p_id];
}

Variant NestedTagsDefinition::_iter_init(Array p_iter) {
	if (names.size() != parents.size()) {
		ERR_PRINT("NestedTagsDefinition: names and parents size mismatch.");
		return false;
	}
	p_iter[0] = Variant(1);

	UtilityFunctions::print("NestedTagsDefinition::_iter_init(): iterator index set to 1, size: " + String::num_int64(names.size()));

	if (names.size() <= 1)
	{
		UtilityFunctions::print("NestedTagsDefinition::_iter_init(): No valid tags to iterate over.");
		return false;
	}

	return true;
}

Variant NestedTagsDefinition::_iter_next(Array p_iter) {
	p_iter[0] = Variant(int64_t(p_iter[0]) + 1); 
	return (int64_t((p_iter)[0]) < names.size());
}

Variant NestedTagsDefinition::_iter_get(const Variant& p_iter) {
	UtilityFunctions::print("NestedTagsDefinition::_iter_get(): iterator_index: " + String::num_int64(int64_t(p_iter)));
	Ref<NestedTag> tag = get_tag(int64_t(p_iter));
	return tag;
}

int NestedTagsDefinition::size() const {
	if (names.size() != parents.size()) {
		ERR_PRINT("NestedTagsDefinition: names and parents size mismatch.");
		return 0;
	}
	return names.size(); 
}

void NestedTagsDefinition::_bind_methods() {
	ClassDB::bind_method(D_METHOD("_to_string"), &NestedTagsDefinition::_to_string);
	ClassDB::bind_method(D_METHOD("is_id_valid", "p_id"), &NestedTagsDefinition::is_id_valid);
	ClassDB::bind_method(D_METHOD("is_root_tag", "p_id"), &NestedTagsDefinition::is_root_tag);
	ClassDB::bind_method(D_METHOD("add", "p_name", "p_parent_id", "p_id"), &NestedTagsDefinition::add, DEFVAL(0));
	ClassDB::bind_method(D_METHOD("get_tag", "p_id"), &NestedTagsDefinition::get_tag);
	ClassDB::bind_method(D_METHOD("get_name", "p_id"), &NestedTagsDefinition::get_name);
	ClassDB::bind_method(D_METHOD("get_parent_id", "p_id"), &NestedTagsDefinition::get_parent_id);
	ClassDB::bind_method(D_METHOD("size"), &NestedTagsDefinition::size);
	ClassDB::bind_method(D_METHOD("_iter_init", "p_iter"), &NestedTagsDefinition::_iter_init);
	ClassDB::bind_method(D_METHOD("_iter_next", "p_iter"), &NestedTagsDefinition::_iter_next);
	ClassDB::bind_method(D_METHOD("_iter_get", "p_iter"), &NestedTagsDefinition::_iter_get);
	ClassDB::bind_method(D_METHOD("reparent", "p_id", "p_parent_id"), &NestedTagsDefinition::reparent);
	ClassDB::bind_method(D_METHOD("rename", "p_id", "p_name"), &NestedTagsDefinition::rename);

	ClassDB::bind_static_method("NestedTagsDefinition", D_METHOD("try_get_singleton"), &NestedTagsDefinition::try_get_singleton);
	ClassDB::bind_static_method("NestedTagsDefinition", D_METHOD("initialize_singleton", "p_singleton"), &NestedTagsDefinition::initialize_singleton);
}

String NestedTagsDefinition::_to_string() const {
    return String("NestedTagsDefinition");
}

bool NestedTagsDefinition::_set(const StringName &p_name, const Variant &p_value) {
    if (p_name == StringName("names")) {
		names = p_value;
		update_tags();
		return true;
	} else if (p_name == StringName("parents")) {
		parents = p_value;
		update_tags();
		return true;
	}
	return false;
}

void NestedTagsDefinition::update_tags() {
	tags.clear();
	last_tag_id = -1;
	if (names.size() == parents.size()) {
		int tags_count = size();
		for (int i = 0 ; i < tags_count; i++) {
			tags.push_back(Ref<NestedTag>(memnew(NestedTag{id_t(++last_tag_id)})));
		}
	}
}

bool NestedTagsDefinition::_get(const StringName &p_name, Variant &r_ret) const {
	if (p_name == StringName("names")) {
		r_ret = names;
	} else if (p_name == StringName("parents")) {
		r_ret = parents;
	} else if (p_name == StringName("tags")) {
		r_ret = tags;
	} else {
		return false;
	}

    return true;
}

void NestedTagsDefinition::_get_property_list(List<PropertyInfo> *p_list) const {
	p_list->push_back(PropertyInfo(Variant::ARRAY, "names", PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NO_EDITOR | PROPERTY_USAGE_INTERNAL));
	p_list->push_back(PropertyInfo(Variant::ARRAY, "parents", PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NO_EDITOR | PROPERTY_USAGE_INTERNAL));
	p_list->push_back(PropertyInfo(Variant::ARRAY, "tags", PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NONE));
}
}