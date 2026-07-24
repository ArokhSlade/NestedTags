#pragma once

#include <cstdint>
#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/variant/string_name.hpp>
#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/classes/wrapped.hpp>
#include "nested_tag_id.h"
#include "nested_tag.h"

using namespace godot;

namespace NestedTags {

class NestedTag;

class NestedTagsDefinition : public Resource {
	GDCLASS(NestedTagsDefinition, Resource)

public:
	NestedTagsDefinition();
	~NestedTagsDefinition() override = default;

	static Ref<NestedTagsDefinition> get_singleton();

	bool is_id_valid(id_t p_id) const {
		return p_id != 0 && parents.size() > p_id;
	}

	void add(const StringName &p_name, id_t p_parent_id, id_t p_id = 0);

	Ref<NestedTag> get_tag(id_t p_id) const;

	StringName get_name(id_t p_id) const;

	id_t get_parent_id(id_t p_id) const;

protected:
	static void _bind_methods();
	String _to_string() const;

protected:
	Vector<StringName> names;
	Vector<id_t> parents;
};
}