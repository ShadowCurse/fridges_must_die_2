extends Node3D

class_name Pickup

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


func on_area_3d_body_entered(body: Node3D) -> void:
    if body is Player:
        var objects = self.anchor.get_children()
        if objects.size() == 1:
            self.anchor.remove_child(objects[0])
            if body.use_pickup(objects[0]):
                self.queue_free()
            else:
              self.anchor.add_child(objects[0])
