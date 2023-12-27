extends CharacterBody3D

const SPEED: float = 10.0
const DECELERATION: float = 5.0
const JUMP_VELOCITY: float = 4.5
const MOUSE_SENSE: float = 0.002

const CAMERA_TILT: float = 0.15
const CAMERA_TILT_SPEED: float = 5.0

const GUN_TILT: float = 0.2
const GUN_TILT_SPEED: float = 10.0
const GUN_SWAY: float = 0.005
const GUN_SWAY_SPEED: float = 10.0
const GUN_BOB_STOP: float = 0.01
const GUN_BOB_MOVE: float = 0.03
const GUN_BOB_MOVE_FREQ: float = 0.01
const GUN_BOB_STOP_FREQ: float = 0.001
const GUN_BOB_SPEED: float = 10.0

@onready var CAMERA: Camera3D = $camera
@onready var GUN_NODE: Node3D = $camera/gun_node
@onready var GUN_NODE_DEFAULT_POSITION: Vector3 = GUN_NODE.position

# Get the GRAVITY from the project settings to be synced with RigidBody nodes.
var GRAVITY: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var LAST_MOUSE_MOTION: Vector2

func _ready():
    pass

func _physics_process(delta: float) -> void:
    # Add the GRAVITY.
    if not self.is_on_floor():
        self.velocity.y -= GRAVITY * delta

    # Handle jump.
    if Input.is_action_just_pressed("game_jump") and self.is_on_floor():
        self.velocity.y = JUMP_VELOCITY

    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var input_dir := Input.get_vector("game_left", "game_right", "game_front", "game_back")
    var direction := (self.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
        self.velocity.x = direction.x * SPEED
        self.velocity.z = direction.z * SPEED
    else:
        self.velocity.x = lerpf(self.velocity.x, 0, DECELERATION * delta)
        self.velocity.z = lerpf(self.velocity.z, 0, DECELERATION * delta)

    self.move_and_slide()

    camera_tilt(input_dir.x, delta)
    gun_tilt(input_dir.x, delta)
    gun_sway(delta)
    gun_bob(delta)
    
func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        self.rotate_y(-event.relative.x * MOUSE_SENSE)
        CAMERA.rotate_x(-event.relative.y * MOUSE_SENSE)
        CAMERA.rotation.x = clampf(CAMERA.rotation.x, -deg_to_rad(70), deg_to_rad(70))
        LAST_MOUSE_MOTION = event.relative

func camera_tilt(intput_dir_x: float, delta: float):
    CAMERA.rotation.z = lerpf(CAMERA.rotation.z, -intput_dir_x * CAMERA_TILT, delta * CAMERA_TILT_SPEED)

func gun_tilt(intput_dir_x: float, delta: float):
    GUN_NODE.rotation.z = lerpf(GUN_NODE.rotation.z, -intput_dir_x * GUN_TILT, delta * GUN_TILT_SPEED)

func gun_sway(delta: float):
    LAST_MOUSE_MOTION = lerp(LAST_MOUSE_MOTION, Vector2.ZERO, delta * GUN_SWAY_SPEED)
    GUN_NODE.rotation.x = lerp(GUN_NODE.rotation.x, LAST_MOUSE_MOTION.y * GUN_SWAY, delta * GUN_SWAY_SPEED)
    GUN_NODE.rotation.y = lerp(GUN_NODE.rotation.y, LAST_MOUSE_MOTION.x * GUN_SWAY, delta * GUN_SWAY_SPEED)
    
func gun_bob(delta):
    if self.velocity.length_squared() > 1.0 && self.is_on_floor():
      GUN_NODE.position.x = lerp(GUN_NODE.position.x, GUN_NODE_DEFAULT_POSITION.x + sin(Time.get_ticks_msec() * GUN_BOB_MOVE_FREQ) * GUN_BOB_MOVE, delta * GUN_BOB_SPEED)
      GUN_NODE.position.y = lerp(GUN_NODE.position.y, GUN_NODE_DEFAULT_POSITION.y + abs(sin(Time.get_ticks_msec() * GUN_BOB_MOVE_FREQ) * GUN_BOB_MOVE), delta * GUN_BOB_SPEED)
    else:
      GUN_NODE.position.x = lerp(GUN_NODE.position.x, GUN_NODE_DEFAULT_POSITION.x + sin(Time.get_ticks_msec() * GUN_BOB_STOP_FREQ) * GUN_BOB_STOP, delta * GUN_BOB_SPEED)
      GUN_NODE.position.y = lerp(GUN_NODE.position.y, GUN_NODE_DEFAULT_POSITION.y + abs(sin(Time.get_ticks_msec() * GUN_BOB_STOP_FREQ) * GUN_BOB_STOP), delta * GUN_BOB_SPEED)
