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

class NestedTagsDefinition : public Resource {
	GDCLASS(NestedTagsDefinition, Resource)

	friend class NestedTag;

public:
	NestedTagsDefinition();
	~NestedTagsDefinition() override = default;
	static Ref<NestedTagsDefinition> try_get_singleton();
	static void initialize_singleton(Ref<NestedTagsDefinition> p_singleton);

	bool is_id_valid(id_t p_id) const {
		UtilityFunctions::print("NestedTagsDefinition::is_id_valid(): p_id: " + String::num_int64(p_id));
		return p_id != 0 && size() > p_id;
	}

	void add(const StringName &p_name, id_t p_parent_id, id_t p_id = 0);

	Ref<NestedTag> get_tag(id_t p_id) const;

	void reparent(id_t p_id, id_t p_parent_id);	
	void rename(id_t p_id, const StringName& p_name);

	StringName get_name(id_t p_id) const;

	id_t get_parent_id(id_t p_id) const;

    Variant _iter_init(Array p__iter);
    Variant _iter_next(Array p__iter);
    Variant _iter_get(const Variant &p_iter);

	int size() const;

protected:
	static void _bind_methods();
	String _to_string() const;

protected:
	Vector<StringName> names;
	Vector<id_t> parents;
	Vector<Ref<NestedTag>> tags;
	static Ref<NestedTagsDefinition> singleton;
};
}