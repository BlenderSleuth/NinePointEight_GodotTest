extends GravityDefinition

class_name CylinderGravity, "res://misc/icons/icon_grav_surface.svg"

export (Vector3) var centre_line_direction: Vector3
#warning-ignore:unused_class_variable
export (bool) var inside = true

func get_gravity_direction(player_transform: Transform) -> Vector3:

    # Define gravity line: point on line (a) and vector (n) in direction of line
    var a := global_transform.origin
    var n := centre_line_direction
    # Point to find closest point on line to
    var p := player_transform.origin

    # Closest point from player position to line from a to a+n
    var closest_point := Geometry.get_closest_point_to_segment_uncapped(p, a, a+n)

    # Gravity vector from p to closest point
    var grav_vec := (closest_point - p).normalized()

    # Vector pointing perpindicular to line and player
    return grav_vec * (1 if inside else -1)