extends Node3D

@export var LEVEL_SCENE: PackedScene
@export var PLAYER_SCENE: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

    var level = LEVEL_SCENE.instantiate() as Node3D
    self.add_child(level)

    var player = PLAYER_SCENE.instantiate() as Node3D
    self.add_child(player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("game_esc"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    if event.is_action_pressed("game_lmb"):
        if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
