extends GravityDefinition

class_name CurveGravity

export (Curve3D) var curve: Curve3D

func _ready() -> void:
    assert(curve != null)
    # Bake first
# warning-ignore:unused_variable
    var t := curve.get_baked_length()

func get_gravity_direction(player_transform: Transform) -> Vector3:
    # Transform to local coordinates
    var local := self.to_local(player_transform.origin)
    # Closest point on curve  is the point the player will attract to
    var closest := curve.get_closest_point(local)
    # Convert back to global coordinates
    var global := self.to_global(closest)
    # Find normalised gravity vector
    var grav_vec := (global - player_transform.origin).normalized()

    return grav_vec