extends CharacterBody3D

const SPEED: float = 1.0
const ROTATION_SPEED: float = 1.0
const DECELERATION: float = 5.0
const MIN_DISTANCE: float = 5.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var player: Node3D = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
    if not self.is_on_floor():
        self.velocity.y -= gravity * delta

    if player:
        var direction = player.position - self.position

        # move
        if MIN_DISTANCE <= direction.length():
          direction = direction.normalized()
          self.velocity.x = direction.x * SPEED
          self.velocity.z = direction.z * SPEED
        else:
          self.velocity.x = 0.0
          self.velocity.z = 0.0

        # rotate
        var angle = direction.signed_angle_to(Vector3.FORWARD, Vector3.UP)
        self.rotation.y = lerp_angle(self.rotation.y, -angle, delta * ROTATION_SPEED)
        

    self.move_and_slide()
