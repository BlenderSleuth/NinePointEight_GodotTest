extends GravityDefinition

class_name LinearGravity, "res://misc/icons/icon_grav_linear.svg"

export (Vector3) var direction: Vector3

func _ready() -> void:
    pass

func get_gravity_direction(player_transform: Transform) -> Vector3:
    return direction