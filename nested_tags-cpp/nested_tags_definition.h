#pragma once

#include <cstdint>
#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/variant/string_name.hpp>
#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/classes/wrapped.hpp>
#include "nested_tag_id.h"

using namespace godot;

namespace NestedTags {

class NestedTagsDefinition : public Resource {
	GDCLASS(NestedTagsDefinition, Resource)

public:
	NestedTagsDefinition();
	~NestedTagsDefinition() override = default;

	bool is_id_valid(id_t p_id) const {
		return p_id != 0 &&parents.size() > p_id;
	}

	void add(const StringName &p_name, id_t p_parent_id, id_t p_id = 0) {
		if (names.size() != parents.size()) {
			UtilityFunctions::printerr("NestedTagsDefinition: names and parents size mismatch");
		}
		if (p_id == 0) {
			names.push_back(p_name);
			parents.push_back(p_parent_id);
		} else {
			names.insert(p_id, p_name);
			parents.insert(p_id, p_parent_id);
		}
	}

protected:
	static void _bind_methods();
	String _to_string() const;

protected:
	Vector<StringName> names;
	Vector<id_t> parents;
};
}