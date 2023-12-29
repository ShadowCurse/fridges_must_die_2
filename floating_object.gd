extends Node3D

@onready var anchor: Node3D = $anchor

@export var object: PackedScene
@export var frequency: float = 0.001
@export var ampitude: float = 0.3
@export var rotation_speed: float = 0.1

func _ready() -> void:
    var o = object.instantiate() as Node3D
    self.anchor.add_child(o)

func _process(delta: float) -> void:
    self.anchor.position.y = sin(Time.get_ticks_msec() * frequency) * ampitude
    self.anchor.rotation.y += delta * rotation_speed
