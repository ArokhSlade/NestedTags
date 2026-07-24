#include "nested_tags_definition.h"
#include <godot_cpp/core/class_db.hpp>
#include "nested_tag.h"

namespace NestedTags {

NestedTagsDefinition::NestedTagsDefinition()
	: names(), parents() {
		names.push_back(StringName(""));
		parents.push_back(0);
}

Ref<NestedTagsDefinition> NestedTagsDefinition::get_singleton()
{
    static Ref<NestedTagsDefinition> singleton_instance = Ref<NestedTagsDefinition>(memnew(NestedTagsDefinition{}));
	return singleton_instance;
}

void NestedTagsDefinition::add(const StringName &p_name, id_t p_parent_id, id_t p_id) {
	if (names.size() != parents.size()) {
		UtilityFunctions::printerr("NestedTagsDefinition::add(): names and parents size mismatch");
	}
	if (p_id == 0) {
		names.push_back(p_name);
		parents.push_back(p_parent_id);
	} else {
		names.insert(p_id, p_name);
		parents.insert(p_id, p_parent_id);
	}
}

Ref<NestedTag> NestedTagsDefinition::get_tag(id_t p_id) const{
	if (!is_id_valid(p_id)) {
		UtilityFunctions::printerr("NestedTagsDefinition::get_tag(): invalid id");
		return Ref<NestedTag>(memnew(NestedTag()));
	}
	return Ref<NestedTag>(memnew(NestedTag(p_id)));
}

StringName NestedTagsDefinition::get_name(id_t p_id) const {
	if (!is_id_valid(p_id)) {
		UtilityFunctions::printerr("NestedTagsDefinition::get_name(): invalid id");
		return StringName("");
	}
	return names[p_id];
}

id_t NestedTagsDefinition::get_parent_id(id_t p_id) const{
	if (!is_id_valid(p_id)) {
		UtilityFunctions::printerr("NestedTagsDefinition::get_parent_id(): invalid id");
		return 0;
	}
	return parents[p_id];
}

void NestedTagsDefinition::_bind_methods() {
		ClassDB::bind_method(D_METHOD("_to_string"), &NestedTagsDefinition::_to_string);
		ClassDB::bind_method(D_METHOD("is_id_valid", "p_id"), &NestedTagsDefinition::is_id_valid);
		ClassDB::bind_method(D_METHOD("add", "p_name", "p_parent_id", "p_id"), &NestedTagsDefinition::add, DEFVAL(0));
		ClassDB::bind_method(D_METHOD("get_tag", "p_id"), &NestedTagsDefinition::get_tag);
		ClassDB::bind_method(D_METHOD("get_name", "p_id"), &NestedTagsDefinition::get_name);
		ClassDB::bind_method(D_METHOD("get_parent_id", "p_id"), &NestedTagsDefinition::get_parent_id);
		ClassDB::bind_static_method("NestedTagsDefinition", D_METHOD("get_singleton"), &NestedTagsDefinition::get_singleton);
}

String NestedTagsDefinition::_to_string() const
{
    return String("NestedTagsDefinition");
}
}