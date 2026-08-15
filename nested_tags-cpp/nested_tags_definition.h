#pragma once

#include <cstdint>
#include <godot_cpp/variant/array.hpp>
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

	bool is_id_valid(id_t p_id) const;

	bool is_root_tag(id_t p_id) const;

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
	bool _set(const StringName &p_name, const Variant &p_value);
	bool _get(const StringName &p_name, Variant &r_ret) const;
	void _get_property_list(List<PropertyInfo> *p_list) const;
	
private:
	void update_tags();

private:
	Array names;	
	Array parents;
	Array tags;
	int last_tag_id;
	static Ref<NestedTagsDefinition> singleton;
};
}