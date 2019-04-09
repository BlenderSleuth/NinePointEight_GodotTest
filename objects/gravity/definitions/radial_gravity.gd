extends GravityDefinition

class_name RadialGravity

#warning-ignore:unused_class_variable
export (bool) var repel = false

func get_gravity_direction(player_transform: Transform) -> Vector3:
    var invert := -1 if repel else 1
    return (global_transform.origin - player_transform.origin).normalized() * invert