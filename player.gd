extends CharacterBody3D

class_name Player

const SPEED: float = 10.0
const SLIDING_SPEED: float = 20.0
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

@onready var camera: Camera3D = $camera
@onready var gun_node: Node3D = $camera/gun_node
@onready var gun_node_default_position: Vector3 = gun_node.position
@onready var speed_boost_timer: Timer = $speed_boost_timer

@export var speed_boost_multiplier: float = 2.0
@export var speed_boost_duration_slide: float = 1.0
@export var speed_boost_duration_slide_end: float = 0.2
@export var speed_boost_duration_jump: float = 0.5

const GUN_STACK_SIZE: int = 5;
var gun_stack: Array[Node3D] = []

var speed_boost: bool = false
var sliding: bool = false
var sliding_direction: Vector3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var last_mouse_motion: Vector2

func _ready() -> void:
    pass

func _process(delta: float) -> void:
    if Input.is_action_pressed("game_rmb"):
        self.shoot_weapon()
        
    if Input.is_action_just_pressed("game_throw_weapon"):
        self.throw_weapon()

func _physics_process(delta: float) -> void:
    # Add the gravity.
    if not self.is_on_floor():
        self.velocity.y -= gravity * delta

    # Handle jump.
    if Input.is_action_just_pressed("game_jump") and self.is_on_floor():
        self.velocity.y = JUMP_VELOCITY
        self.scale.y = 1.0
        self.speed_boost_timer.start(self.speed_boost_duration_jump)

    # Handle movement
    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var input_dir := Input.get_vector("game_left", "game_right", "game_front", "game_back")
    var direction := (self.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    # Handle crouch.
    if Input.is_action_just_pressed("game_crouch") and self.is_on_floor():
        self.scale.y = 0.5
        self.sliding = true
        self.speed_boost = true
        self.sliding_direction = direction
        self.speed_boost_timer.start(self.speed_boost_duration_slide)

    if Input.is_action_just_released("game_crouch"):
        self.scale.y = 1.0
        self.sliding = false
        self.speed_boost_timer.start(self.speed_boost_duration_slide_end)

    if self.sliding and self.speed_boost:
        direction = self.sliding_direction

    if direction:
        if self.speed_boost:
            self.velocity.x = direction.x * SPEED * self.speed_boost_multiplier 
            self.velocity.z = direction.z * SPEED * self.speed_boost_multiplier
        else:
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
        camera.rotate_x(-event.relative.y * MOUSE_SENSE)
        camera.rotation.x = clampf(camera.rotation.x, -deg_to_rad(70), deg_to_rad(70))
        last_mouse_motion = event.relative

func camera_tilt(intput_dir_x: float, delta: float):
    camera.rotation.z = lerpf(camera.rotation.z, -intput_dir_x * CAMERA_TILT, delta * CAMERA_TILT_SPEED)

func gun_tilt(intput_dir_x: float, delta: float):
    gun_node.rotation.z = lerpf(gun_node.rotation.z, -intput_dir_x * GUN_TILT, delta * GUN_TILT_SPEED)

func gun_sway(delta: float):
    last_mouse_motion = lerp(last_mouse_motion, Vector2.ZERO, delta * GUN_SWAY_SPEED)
    gun_node.rotation.x = lerp(gun_node.rotation.x, last_mouse_motion.y * GUN_SWAY, delta * GUN_SWAY_SPEED)
    gun_node.rotation.y = lerp(gun_node.rotation.y, last_mouse_motion.x * GUN_SWAY, delta * GUN_SWAY_SPEED)
    
func gun_bob(delta):
    if self.velocity.length_squared() > 1.0 && self.is_on_floor():
        gun_node.position.x = lerp(gun_node.position.x, gun_node_default_position.x + sin(Time.get_ticks_msec() * GUN_BOB_MOVE_FREQ) * GUN_BOB_MOVE, delta * GUN_BOB_SPEED)
        gun_node.position.y = lerp(gun_node.position.y, gun_node_default_position.y + abs(sin(Time.get_ticks_msec() * GUN_BOB_MOVE_FREQ) * GUN_BOB_MOVE), delta * GUN_BOB_SPEED)
    else:
        gun_node.position.x = lerp(gun_node.position.x, gun_node_default_position.x + sin(Time.get_ticks_msec() * GUN_BOB_STOP_FREQ) * GUN_BOB_STOP, delta * GUN_BOB_SPEED)
        gun_node.position.y = lerp(gun_node.position.y, gun_node_default_position.y + abs(sin(Time.get_ticks_msec() * GUN_BOB_STOP_FREQ) * GUN_BOB_STOP), delta * GUN_BOB_SPEED)

func use_pickup(node: Node3D) -> bool:
    if node is Gun:
        if gun_stack.size() == GUN_STACK_SIZE:
            return false
        else:
          var attached_gun = gun_node.get_child(0)
          if attached_gun == null:
              gun_node.add_child(node)
          gun_stack.append(node)
          return true
    return false

func shoot_weapon() -> void:
      var attached_guns = gun_node.get_children()
      if attached_guns.size() == 1:
          attached_guns[0].shoot()

func throw_weapon() -> void:
      var attached_gun = gun_node.get_child(0)
      if attached_gun != null:
          gun_node.remove_child(attached_gun)
          attached_gun.queue_free()

      var next_gun = gun_stack.pop_back()
      if next_gun != null:
          gun_node.add_child(next_gun)


func on_speed_boost_timer_timeout() -> void:
    self.speed_boost = false
