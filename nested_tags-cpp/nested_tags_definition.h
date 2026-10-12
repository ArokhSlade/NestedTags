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
	
struct TagData {
	id_t parent_id;
	StringName name;
	Ref<NestedTag> tag;
};
	
/** methods are supposed to work on ids, not tags. 
 *  tag param methods are supposed to be convenience fuznctions that live in NestedTag.
 *  whereas nested tags definition is supposed to be the raw, performance oriented layer below. 
 */
class NestedTagsDefinition : public Resource {
	GDCLASS(NestedTagsDefinition, Resource)

	friend class NestedTag;

public:
	NestedTagsDefinition();
	~NestedTagsDefinition() override = default;
	static Ref<NestedTagsDefinition> try_get_singleton();
	static void initialize_singleton(Ref<NestedTagsDefinition> p_singleton);

	bool is_root_tag(id_t p_id) const;

	void add(const StringName &p_name, id_t p_parent_id = 0);
	void erase(id_t p_id);
	void NestedTagsDefinition::_erase_recursively(id_t p_id);
	
	bool has_tag(id_t p_id) const;
	Ref<NestedTag> get_tag(id_t p_id) const;

	bool try_reparent(id_t p_id, id_t p_parent_id);
	void rename(id_t p_id, const StringName& p_name);

	StringName get_name(id_t p_id) const;

	id_t get_parent_id(id_t p_id) const;

    Variant _iter_init(Array p__iter) const;
    Variant _iter_next(Array p__iter) const;
    Variant _iter_get(const Variant &p_iter) const;
    
    Ref<NestedTag> get_child_tag_by_name(String& p_name, id_t p_parent_id) const;  
	
	int size() const;
	
	id_t get_closest_shared_ancestor(id_t p_id_1, id_t p_id_2) const;
	
protected:
	static void _bind_methods();
	String _to_string() const;
	bool _set(const StringName &p_name, const Variant &p_value);
	bool _get(const StringName &p_name, Variant &r_ret) const;
	void _get_property_list(List<PropertyInfo> *p_list) const;
	
	Array get_lineage_ids(id_t p_id) const ;
	Array get_ids() const;
	
private:
	void update_tags();
	Array get_parent_ids() const;
	Array get_names() const;
	bool try_add_explicit(id_t p_id, const StringName &p_name, id_t p_parent_id);

private:
	Array names;	
	Array parents;
	Array tags;
	id_t last_tag_id;
	static Ref<NestedTagsDefinition> singleton;
	
	HashMap<id_t, TagData> data;
};
}