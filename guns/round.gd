extends Node3D

class_name Round

var speed: float = 1.0

func _ready() -> void:
    pass


func _process(delta: float) -> void:
    self.position += self.transform.basis * Vector3.FORWARD * self.speed * delta
