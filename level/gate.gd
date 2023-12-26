extends Node3D

func _ready() -> void:
    pass

func _process(delta: float) -> void:
    pass

func on_door_sensor_body_entered(body: Node3D) -> void:
    $animation_player.play("open")

func on_door_sensor_body_exited(body: Node3D) -> void:
    $animation_player.play("close")

