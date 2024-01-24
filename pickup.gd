extends Node3D

class_name Pickup

@onready var anchor: Node3D = $anchor
@onready var omni_light_3d: OmniLight3D = $anchor/OmniLight3D

@export var object: PackedScene
@export var hilight_color: Color
@export var frequency: float = 0.001
@export var ampitude: float = 0.3
@export var rotation_speed: float = 0.1

var attached_object: Node3D

func _ready() -> void:
    var o = object.instantiate() as Node3D
    self.attached_object = o;
    self.anchor.add_child(o)
    
    self.omni_light_3d.light_color = hilight_color

func _process(delta: float) -> void:
    self.anchor.position.y = sin(Time.get_ticks_msec() * frequency) * ampitude
    self.anchor.rotation.y += delta * rotation_speed


func on_area_3d_body_entered(body: Node3D) -> void:
    if body is Player:
        if self.attached_object:
            self.anchor.remove_child(self.attached_object)
            if body.use_pickup(self.attached_object):
                self.queue_free()
            else:
              self.anchor.add_child(self.attached_object)
