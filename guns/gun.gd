extends Node3D

@export var round_scene: PackedScene
@export var shell_scene: PackedScene

@export var round_points: Array[Marker3D]
@export var round_speed: float = 10.0

@export var shell_points: Array[Marker3D]
@export var shell_speed: float = 1.0

@export var recoil_rotation_x: Curve
@export var recoil_rotation_z: Curve
@export var recoil_position_z: Curve
@export var recoil_strength: Vector3 = Vector3.ONE
@export var recoil_speed: float = 1.0

@export var attack_timer: Timer

var target_rotation: Vector3
var target_position: Vector3
var progress: float

var ready_to_shoot: bool = true

func _ready() -> void:
    self.target_rotation = self.rotation
    self.target_position = self.position
    self.progress = 1.0

func _process(delta: float) -> void:
    if self.progress < 1.0:
        self.progress += delta * recoil_speed
        self.target_rotation.x = self.recoil_rotation_x.sample(self.progress) * self.recoil_strength.x
        self.target_rotation.z = self.recoil_rotation_z.sample(self.progress) * self.recoil_strength.y
        self.target_position.z = self.recoil_position_z.sample(self.progress) * self.recoil_strength.z
    else:
        self.target_rotation.x = 0.0
        self.target_rotation.z = 0.0
        self.target_position.z = 0.0

    self.rotation.x = lerpf(self.rotation.x, self.target_rotation.x, delta * recoil_speed)
    self.rotation.z = lerpf(self.rotation.z, self.target_rotation.z, delta * recoil_speed)
    self.position.z = lerpf(self.position.z, self.target_position.z, delta * recoil_speed)

func shoot():
    if self.ready_to_shoot:
      self.attack_timer.start()
      self.ready_to_shoot = false

      self.target_rotation.x = self.recoil_rotation_x.sample(0.0)
      self.target_rotation.z = self.recoil_rotation_z.sample(0.0)
      self.target_position.z = self.recoil_position_z.sample(0.0)
      self.progress = 0.0

      for point in self.round_points:
          var round = round_scene.instantiate() as Round
          round.transform = point.global_transform
          round.speed = self.round_speed
          get_node("/root").add_child(round)

      for point in self.shell_points:
          var shell = shell_scene.instantiate() as RigidBody3D
          shell.transform = point.global_transform
          shell.linear_velocity = (self.to_global(Vector3.RIGHT) - self.global_position) * self.shell_speed
          get_node("/root").add_child(shell)


func on_attack_timer_timeout() -> void:
    self.ready_to_shoot = true
