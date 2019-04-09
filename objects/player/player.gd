extends KinematicBody

class_name Player

###############################
# Tweakable properties
const GRAVITY := 5.0
# Move speed
const RUN_SPEED := 8.0
const FLY_SPEED := 1.0
# Dampening
const RUN_DAMP := 0.87
const FLY_DAMP := 0.98
# Jump properties
const JUMP_SPEED := 16.0
const JUMP_TIME := 0.32 # Time in seconds for control over jump

# Interpolation speed for player rotation, deg/sec
const ROT_SPEED := deg2rad(180.0)

# Arbitrary multiplier for how much camera rotation for mouse move distance
const MOUSE_SENSITIVITY := 0.1
const CAM_KEY_SENSITIVITY := 1.0

###############################

# Object to be attracted to, set by attractor object
var attractor: Attractor = null

# Visual representation of player that is rotated
onready var player_control := $player_control as Spatial

# Camera
onready var player_camera := $camera_control/camera as Camera
onready var camera_control := $camera_control as Spatial


# Player velocity in global coordinates
var velocity := Vector3()

func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)



func _process(delta: float) -> void:

    # Control camera with arrow keys
    if Input.is_action_pressed("ui_left"):
        camera_control.rotation_degrees += Vector3(0, CAM_KEY_SENSITIVITY, 0)
    if Input.is_action_pressed("ui_right"):
        camera_control.rotation_degrees += Vector3(0, -CAM_KEY_SENSITIVITY, 0)

    # Let go of mouse if esc is pressed
    if Input.is_action_just_pressed("ui_cancel"):
        if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        else:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


var jumping := false
var timer := 0.0
func jump() -> float:
    var delta := get_physics_process_delta_time()

    var newjump := Input.is_action_just_pressed('ui_select')

    # Only reset if it is a new jump, and from the floor
    if newjump and not jumping and is_on_floor():
        jumping = true
        timer = 0.0

    # More of the current jump
    if jumping and timer < JUMP_TIME:
        var proportion_completed = timer / JUMP_TIME
        # Gradually decrease the jump speed over the time of the jump
        var jump_amount: float = lerp(JUMP_SPEED, 0, proportion_completed)
        timer += delta
        return jump_amount
    else:
        # Finished jumping
        jumping = false

    return 0.0


func get_movement() -> Vector3:
    # Input events
    var right := Input.is_action_pressed('right')
    var left := Input.is_action_pressed('left')
    var forward := Input.is_action_pressed("forward")
    var backward := Input.is_action_pressed("backward")
    var jump := Input.is_action_pressed('ui_select')

    # Movement velocity in local coordinates, relative to camera
    var move := Vector3()

    # Different speed on ground and in air
    var move_speed: float = RUN_SPEED if is_on_floor() else FLY_SPEED
    if right:
        move.x -= move_speed
    if left:
        move.x += move_speed
    if backward:
        move.z -= move_speed
    if forward:
        move.z += move_speed

    # Make sure player doesn't accelerate too much, clamp vector length
    move = move.normalized() * clamp(move.length(), -move_speed, move_speed)

    # Apply jump
    if jump:
        move.y += jump()
    else:
        jumping = false

    return move


var last_move = Vector3()
# Rotate mesh and collision to face direction of movement
func rotate_forward(local_player_movement: Vector3, delta: float) -> void:
    local_player_movement.y = 0 # Don't look up!

    var movement = camera_control.transform.basis.xform(local_player_movement).normalized()

    # If we have moved
    if movement.length() > 0:
        last_move = movement

    var mesh_basis = player_control.transform.basis

    # Find the angle between the current front and last_move vectors
    var front = mesh_basis.z
    var axis = front.cross(last_move).normalized()
    if axis.length_squared() > 0:
        var angle = front.angle_to(last_move)

        # Rotate around up direction
        var target_rotation = mesh_basis.rotated(axis, angle)
        # Interpolate to new rotation
        var slerped_rotation = Quat(mesh_basis).slerp(target_rotation, 10*delta)

        # Apply slerped rotation
        player_control.transform.basis = Basis(slerped_rotation).orthonormalized()


# Keep gravity direction even if outside of attractor
var grav_vec := Vector3.DOWN

func _physics_process(delta: float) -> void:

    # Gravity vector is calculated by attractor
    if attractor:
        # Only assign if not null
        var new_vec := attractor.get_gravity_direction(global_transform)
        if new_vec != Vector3.INF:
            grav_vec = new_vec

    # Rotate player so down faces gravity
    var down = -transform.basis.y
    var rot_axis = down.cross(grav_vec).normalized()
    if rot_axis.length_squared() > 0:
        # Find the angle to rotate
        var angle = down.angle_to(grav_vec)

        # Update rotation
        var target_rotation = Quat(transform.basis.rotated(rot_axis, angle))
        # Interpolate to new rotation
        var angle_this_frame = ROT_SPEED * delta
        var prop = clamp(angle_this_frame/angle, 0, 1)

        var slerped_rotation = Quat(transform.basis).slerp(target_rotation, prop)
        transform.basis = Basis(slerped_rotation).orthonormalized()

    # Add gravity to velocity
    velocity += grav_vec * GRAVITY

    # Player input, in local coordinates
    var movement := get_movement()

    # Movement is relative to camera, transform to global coordinates
    var global_movement := camera_control.global_transform.basis.xform(movement)
    ##### Change to camera_control.to_global(movement)

    # Apply player movement to velocity
    velocity += global_movement

    # Rotate to face direction of movement
    rotate_forward(movement, delta)

    # Apply friction or air resistance
    var damp = RUN_DAMP if is_on_floor() else FLY_DAMP

    velocity = move_and_slide(velocity, -grav_vec) * damp


func _input(event: InputEvent) -> void:
    # If the event is a mouse event
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        # Only use horizontal motion to control camera
        var rot_y = -event.relative.x * MOUSE_SENSITIVITY

        camera_control.rotation_degrees += Vector3(0, rot_y, 0)

    if event is InputEventMouseButton:
        if event.button_index == BUTTON_WHEEL_UP:
            player_camera.fov -= 4
        if event.button_index == BUTTON_WHEEL_DOWN:
            player_camera.fov += 4
        player_camera.fov = clamp(player_camera.fov, 10, 100)

