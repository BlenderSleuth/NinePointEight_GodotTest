extends Node

func get_player() -> Player:
    var group := get_tree().get_nodes_in_group("player")
    if group.size() > 0:
        return group[0] as Player
    else:
        print("ERROR: no player found")
        return null

func get_player_grav_centre() -> Area:
    var group := get_tree().get_nodes_in_group("player_grav_centre")
    if group.size() > 0:
        return group[0] as Area
    else:
        print("ERROR: no player gravity centre found")
        return null