extends CharacterBody3D

@onready var CAMERA: Camera3D = $camera

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5
const MOUSE_SENSE: float = 0.002

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
    # Add the gravity.
    if not is_on_floor():
        velocity.y -= gravity * delta

    # Handle jump.
    if Input.is_action_just_pressed("game_jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var input_dir := Input.get_vector("game_left", "game_right", "game_front", "game_back")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)

    move_and_slide()
    
func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * MOUSE_SENSE)
        CAMERA.rotate_x(-event.relative.y * MOUSE_SENSE)
        CAMERA.rotation.x = clampf(CAMERA.rotation.x, -deg_to_rad(70), deg_to_rad(70))
    if event.is_action_pressed("game_esc"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    if event.is_action_pressed("game_lmb"):
        if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
