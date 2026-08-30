extends Node2D
## Grille de placement de l'usine (vue du dessus). Clic sur une case libre pour
## y construire une machine placeholder si le budget le permet.

const CELL_SIZE := 64
const GRID_WIDTH := 16
const GRID_HEIGHT := 10
const MACHINE_COST := 200.0

const MachineScene := preload("res://scenes/factory/Machine.tscn")

var _occupied: Dictionary = {} ## Vector2i -> Node2D


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var grid_color := Color(1, 1, 1, 0.15)
	for x in range(GRID_WIDTH + 1):
		draw_line(Vector2(x * CELL_SIZE, 0), Vector2(x * CELL_SIZE, GRID_HEIGHT * CELL_SIZE), grid_color)
	for y in range(GRID_HEIGHT + 1):
		draw_line(Vector2(0, y * CELL_SIZE), Vector2(GRID_WIDTH * CELL_SIZE, y * CELL_SIZE), grid_color)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_place_machine(get_local_mouse_position())


func _try_place_machine(local_pos: Vector2) -> void:
	if local_pos.x < 0 or local_pos.y < 0:
		return
	var cell := Vector2i(int(local_pos.x / CELL_SIZE), int(local_pos.y / CELL_SIZE))
	if cell.x >= GRID_WIDTH or cell.y >= GRID_HEIGHT:
		return
	if _occupied.has(cell):
		return
	if not EconomyManager.try_spend(MACHINE_COST):
		return

	var machine := MachineScene.instantiate()
	machine.position = Vector2(cell.x * CELL_SIZE + CELL_SIZE / 2.0, cell.y * CELL_SIZE + CELL_SIZE / 2.0)
	add_child(machine)
	_occupied[cell] = machine
