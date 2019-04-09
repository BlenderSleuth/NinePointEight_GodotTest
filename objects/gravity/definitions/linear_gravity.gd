extends GravityDefinition

class_name LinearGravity, "res://misc/icons/icon_grav_linear.svg"

export (Vector3) var direction: Vector3


func get_gravity_direction(player_transform: Transform) -> Vector3:
    return direction