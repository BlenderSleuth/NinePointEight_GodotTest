extends Node

class_name Attractor, "res://misc/icons/icon_attractor.svg"


export (NodePath) var revert_attractor = null
var revert_attractor_node: Node = null

onready var grav_influence: Area = $grav_influence

onready var grav_definition: GravityDefinition = $grav_definition


func _ready() -> void:
    # Connect up signal to be notified when player comes along
    var e := grav_influence.connect("area_entered", self, "area_entered")
    assert(e == OK)

    e = grav_influence.connect("area_exited", self, "area_exited")
    assert(e == OK)

    # grav_influence.add_to_group("grav_influence")
    if revert_attractor:
        revert_attractor_node = get_node(revert_attractor)


## Area signals

func area_entered(area: Area) -> void:
    # If it's the player, set the attractor
    if area == PlayerData.get_player_grav_centre():
        PlayerData.get_player().attractor = self


func area_exited(area: Area) -> void:
    # If it's the player, revert to defined attractor or default
    if area == PlayerData.get_player_grav_centre():
        var player = PlayerData.get_player()
        if player.attractor == self:
            player.attractor = revert_attractor_node # null (default) or defined attractor



func get_gravity_direction(transform: Transform) -> Vector3:
    return grav_definition.get_gravity_direction(transform)
