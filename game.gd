extends Node3D

@export var LEVEL_SCENE: PackedScene
@export var PLAYER_SCENE: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var level = LEVEL_SCENE.instantiate() as Node3D
    self.add_child(level)

    var player = PLAYER_SCENE.instantiate() as Node3D
    self.add_child(player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
