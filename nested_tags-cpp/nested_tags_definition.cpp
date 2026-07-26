#include "nested_tags_definition.h"
#include <godot_cpp/core/class_db.hpp>
#include "nested_tag.h"

namespace NestedTags {

NestedTagsDefinition::NestedTagsDefinition()
	: names{StringName("<NULL>")}
	, parents{0}
	, tags{Ref<NestedTag>(memnew(NestedTag{0}))} // Initialize with a default "null" tag
	{}

Ref<NestedTagsDefinition> NestedTagsDefinition::get_singleton()
{
    static Ref<NestedTagsDefinition> singleton_instance = Ref<NestedTagsDefinition>(memnew(NestedTagsDefinition{}));
	return singleton_instance;
}

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
		tags.push_back(Ref<NestedTag>(memnew(NestedTag{id_t(names.size() - 1)})));
	} else {
		names.insert(p_id, p_name);
		parents.insert(p_id, p_parent_id);
		tags.insert(p_id, Ref<NestedTag>(memnew(NestedTag{p_id})));
	}
}

Ref<NestedTag> NestedTagsDefinition::get_tag(id_t p_id) const{
	if (!is_id_valid(p_id)) {
		UtilityFunctions::printerr("NestedTagsDefinition::get_tag(): invalid id");
		return tags[0]; // Return a default "null" tag for invalid IDs
	}
	return tags[p_id];
}

StringName NestedTagsDefinition::get_name(id_t p_id) const {
	if (!is_id_valid(p_id)) {
		UtilityFunctions::printerr("NestedTagsDefinition::get_name(): invalid id");
		return names[0]; // Return a default name for invalid IDs
	}
	return names[p_id];
}

id_t NestedTagsDefinition::get_parent_id(id_t p_id) const{
	if (!is_id_valid(p_id)) {
		UtilityFunctions::printerr("NestedTagsDefinition::get_parent_id(): invalid id");
		return parents[0]; // Return a default parent ID for invalid IDs
	}
	return parents[p_id];
}

Variant NestedTagsDefinition::_iter_init(const Variant &p_iter) {
	if (names.size() != parents.size()) {
		ERR_PRINT("NestedTagsDefinition: names and parents size mismatch.");
		return false;
	}
	iterator_index = 1; // Start from 1 to skip the "null" tag

	if (names.size() < 1)
	{
		return false;
	}

	return true;
}

Variant NestedTagsDefinition::_iter_next(const Variant &p_iter) {
	iterator_index++;
	return (iterator_index < names.size());
}

Variant NestedTagsDefinition::_iter_get(const Variant &p_iter) {
	Ref<NestedTag> tag = get_tag(iterator_index);
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
		ClassDB::bind_method(D_METHOD("add", "p_name", "p_parent_id", "p_id"), &NestedTagsDefinition::add, DEFVAL(0));
		ClassDB::bind_method(D_METHOD("get_tag", "p_id"), &NestedTagsDefinition::get_tag);
		ClassDB::bind_method(D_METHOD("get_name", "p_id"), &NestedTagsDefinition::get_name);
		ClassDB::bind_method(D_METHOD("get_parent_id", "p_id"), &NestedTagsDefinition::get_parent_id);
		ClassDB::bind_method(D_METHOD("size"), &NestedTagsDefinition::size);
		ClassDB::bind_method(D_METHOD("_iter_init", "p_iter"), &NestedTagsDefinition::_iter_init);
		ClassDB::bind_method(D_METHOD("_iter_next", "p_iter"), &NestedTagsDefinition::_iter_next);
		ClassDB::bind_method(D_METHOD("_iter_get", "p_iter"), &NestedTagsDefinition::_iter_get);
		ClassDB::bind_static_method("NestedTagsDefinition", D_METHOD("get_singleton"), &NestedTagsDefinition::get_singleton);
}

String NestedTagsDefinition::_to_string() const
{
    return String("NestedTagsDefinition");
}
}