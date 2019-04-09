extends Spatial

class_name GravityDefinition

func get_gravity_direction(player_transform: Transform) -> Vector3:
    print("ERROR: must inherit from GravityDefinition")
    assert(false)
    return Vector3.DOWN

