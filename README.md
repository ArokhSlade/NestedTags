# Nested Tags
## "Unreal Gameplay Tags for Godot"

## Purpose
I find it useful to have hierarchical tags/enums, for example for a hierarchy of request handlers, 
such as I've been recently been playing around with for UI.  
When handlers and requests are tagged, handlers can inspect the request, check if their tags match and, if so, handle the request.
But what if they don't match?  
In a linear chain of responsibility, they may forward to the next in line, and either the request gets handled or it falls off the chain eventually.  
I wanted to optimize use cases where my handlers are set up in a semantic hierarchy, which could be a taxonomy (inheritance hierarchy) or a part-whole hierarchy or a mix of both.  
For instance: BodyUI contains LegsUI and ArmsUI, or VehicleHandler contains CarHandler and PlaneHandler. 

## Example: 
Request is tagged "Vehicle.Car".
VehicleHandler is tagged "Vehicle" and contains CarHandler, which is tagged "Vehicle.Car".  
Now if VehicleHandler can handle any vehicles, it can match Vehicle.Car .
Alternatively, it knows to check its children whether any of them match Vehicle.Car .  

With a naive enum-based implementation either my VehicleHandler would need to carry an array with of all possible vehicle types 
or each vehicle object would need to carry all the ancestors in the hierarchy.  
Each incur a higher memory cost and more importantly, unfeasible maintenance cost and error surface.

## Goals
- Only one integer needed per tag, just like an enum
- Parents and Names are stored in a NestedTagsDefinition
- Tree-based inspector UI for defining a set of Nested Tags ("NestedTagsDefinition")
- Tree-based inspetor UI for assigning tags as properties
- @export NestedTag properties as int with type hint
- store and load NestedTagsDefinition as .tres files
- assign a project-wide NestedTagsDefinition in project settings
- add, rename, reparent and delete NestedTags from a Definition
- Godot-cpp Backend to save GDScript performance overhead

## Build Info
To generate debug info (pdb files),  
add custom.py in root folder with these contents:
>>>
target = "template_debug"
dev_build = "yes"
debug_symbols = "yes"