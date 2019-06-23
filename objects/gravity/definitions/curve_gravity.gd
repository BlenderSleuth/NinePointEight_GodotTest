extends GravityDefinition

class_name CurveGravity

export (Curve3D) var curve: Curve3D

func get_gravity_direction(player_transform: Transform) -> Vector3:
    return Vector3.ZERO