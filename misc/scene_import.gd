tool
extends EditorScenePostImport

# Debug print of edited node tree
func print_all_nodes(node: Node, level: int):
    var name := node.name
    var s = ""
#warning-ignore:unused_variable
    for a in range(level):
        s += "  "
    print(s + name)

    for child in node.get_children():
        print_all_nodes(child, level+1)


var scene: Node


func setup_grav(node: Node) -> void:
    for child in node.get_children():
        setup_grav(child as Node)

    if node.name.match("*-attract*"):
        node.set_script(Attractor)
        node.name = node.name.split(" ")[0]

    # Create a gravity surface if required
    elif node.name.match("*-grav_definition*"):

        # Create a gravity surface
        if node is MeshInstance:
            var grav_surface := SurfaceGravity.new()
            grav_surface.name = "grav_definition"
            grav_surface.mesh = node.mesh
            node.get_parent().add_child(grav_surface)
            grav_surface.set_owner(scene)

        # Create a mathematically defined gravity field
        elif node is Spatial:
            if node.name.match("*-cylinder*"):
                # Cylindrical field
                var grav_cylinder = CylinderGravity.new()
                grav_cylinder.name = "grav_definition"
                grav_cylinder.transform.origin = (node as Spatial).transform.origin
                # Get vector point in orientation of cylinder
                grav_cylinder.centre_line_direction = (node as Spatial).transform.basis.xform(Vector3.FORWARD).normalized()
                # If an inverted cylinder:
                if node.name.match("*-cylinder!*"):
                    grav_cylinder.inside = false
                else:
                    grav_cylinder.inside = true

                node.get_parent().add_child(grav_cylinder)
                grav_cylinder.set_owner(scene)
            else:
                # Linear field
                var grav_linear := LinearGravity.new()
                grav_linear.name = "grav_definition"
                # Set direction based on node orientation
                grav_linear.direction = node.transform.basis.xform(Vector3.UP).normalized()
                node.get_parent().add_child(grav_linear)
                grav_linear.set_owner(scene)

        # Don't need node now
        node.free()

    # Option -grav is set, create a gravitational influence area
    elif node.name.match("*-grav_area*") and node is MeshInstance:
        # Create area
        var area := Area.new()
        area.name = "grav_influence"

        area.transform.origin = (node as Spatial).transform.origin
        node.get_parent().add_child(area)
        area.set_owner(scene)

        var collision_shape: Shape

        # Always create convex shape, area doesn't work with concave under bullet physics
        collision_shape = (node as MeshInstance).mesh.create_convex_shape()
        #collision_shape = (node as MeshInstance).mesh.create_trimesh_shape()

        # Create collision shape
        var col := CollisionShape.new()
        col.name = "shape"
        col.shape = collision_shape
        area.add_child(col)
        col.set_owner(scene)

        # Don't need mesh node now
        node.free()




func post_import(scene: Object) -> Object:
    self.scene = scene

    setup_grav(scene as Node)

    # print_all_nodes(scene, 0)

    return scene