extends Node

func _ready() -> void:
    var screen_size = OS.get_screen_size(OS.current_screen)
    var window_size = OS.window_size
    OS.window_position = screen_size*0.5 - window_size*0.5 - Vector2(OS.get_screen_size(0).x, 0)
