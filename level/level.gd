extends Node3D

var FLOOR: PackedScene = preload("./floor.tscn")
var BLOCK: PackedScene = preload("./block.tscn")
var GATE: PackedScene = preload("./gate.tscn")

var LEVEL_SIZE: int = 20
var BLOCK_SIZE: float = 1.0
var BLOCK_HIGHT: float = 3.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var grid = generate_grid(LEVEL_SIZE)
    spawn_grid(grid)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

enum CellType {
  Empty,
  Block,
  Gate,
}

func generate_grid(grid_size: int) -> Array:
    var grid: Array = [[]]
    grid.resize(grid_size)
    for y in range(grid_size):
      grid[y] = []
      grid[y].resize(grid_size)

    # walls
    for x in range(grid_size):
      grid[0][x] = CellType.Block 
    for x in range(grid_size):
      grid[grid_size - 1][x] = CellType.Block 
    for y in range(grid_size):
      grid[y][0] = CellType.Block 
    for y in range(grid_size):
      grid[y][grid_size - 1] = CellType.Block 

    var gate_pos: Vector2
    var gate_rand = 1 + (randi() % (grid_size - 2))
    match randi() % 4:
        # top
        0: gate_pos = Vector2(0, gate_rand)
        # bot
        1: gate_pos = Vector2(grid_size - 1, gate_rand)
        # right
        2: gate_pos = Vector2(gate_rand, grid_size - 1)
        # left
        3: gate_pos = Vector2(gate_rand, 0)

    # use x/y insead y/x because this is how we created vector
    grid[gate_pos.x][gate_pos.y] = CellType.Gate

    return grid

func grid_pos(grid_x: int, grid_y: int) -> Vector3:
    var x = (LEVEL_SIZE / 2.0) - BLOCK_SIZE * grid_y;
    var y = BLOCK_HIGHT / 2.0;
    var z = (-LEVEL_SIZE / 2.0) + BLOCK_SIZE * grid_x;

    return Vector3(x, y, z)

func spawn_grid(grid: Array): 
    var floor = FLOOR.instantiate() as Node3D
    self.add_child(floor)

    for y in range(grid.size()):
      for x in range(grid.size()):
        match grid[y][x]:
          CellType.Empty: pass
          CellType.Block: 
            var wall = BLOCK.instantiate() as Node3D
            wall.position = grid_pos(x, y)
            self.add_child(wall)
          CellType.Gate:
            var gate = GATE.instantiate() as Node3D
            gate.position = grid_pos(x, y)

            # rotate if gate is on the left/right/bot wall
            var gate_rotation: float = 0
            if x == 0:
              gate_rotation = -PI / 2.0
            if x == grid.size() - 1:
              gate_rotation = PI / 2.0
            if y == 0:
              gate_rotation = PI
            gate.rotate_y(gate_rotation)

            self.add_child(gate)

