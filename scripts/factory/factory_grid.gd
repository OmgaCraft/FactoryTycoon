extends Node2D
## Grille de placement de l'usine. Le joueur choisit un type de bâtiment dans le
## HUD (set_armed_kind), voit un aperçu sous la souris, puis clique pour construire.
## Clic droit ou Échap annule le mode construction en cours.

signal armed_kind_changed(kind: String)

const CELL_SIZE := 64
const GRID_WIDTH := 16
const GRID_HEIGHT := 10

const BuildingScene := preload("res://scenes/factory/Building.tscn")

var armed_kind: String = ""

var _occupied: Dictionary = {}

@onready var _buildings_root: Node2D = $Buildings


func _ready() -> void:
	add_to_group("factory_grid")
	queue_redraw()


func set_armed_kind(kind: String) -> void:
	armed_kind = kind
	armed_kind_changed.emit(kind)
	queue_redraw()


func _process(_delta: float) -> void:
	if armed_kind != "":
		queue_redraw()


func _draw() -> void:
	var grid_color := Color(1, 1, 1, 0.15)
	for x in range(GRID_WIDTH + 1):
		draw_line(Vector2(x * CELL_SIZE, 0), Vector2(x * CELL_SIZE, GRID_HEIGHT * CELL_SIZE), grid_color)
	for y in range(GRID_HEIGHT + 1):
		draw_line(Vector2(0, y * CELL_SIZE), Vector2(GRID_WIDTH * CELL_SIZE, y * CELL_SIZE), grid_color)

	if armed_kind == "":
		return
	var cell = _cell_at(get_local_mouse_position())
	if cell == null or _occupied.has(cell):
		return
	var def: Dictionary = Recipes.BUILDING_DEFS[armed_kind]
	var color: Color = def.color
	var rect := Rect2(cell.x * CELL_SIZE, cell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
	draw_rect(rect, Color(color.r, color.g, color.b, 0.35))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and armed_kind != "":
			_try_place(get_local_mouse_position())
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			set_armed_kind("")
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		set_armed_kind("")


func _cell_at(local_pos: Vector2):
	if local_pos.x < 0 or local_pos.y < 0:
		return null
	var cell := Vector2i(int(local_pos.x / CELL_SIZE), int(local_pos.y / CELL_SIZE))
	if cell.x >= GRID_WIDTH or cell.y >= GRID_HEIGHT:
		return null
	return cell


func _try_place(local_pos: Vector2) -> void:
	var cell = _cell_at(local_pos)
	if cell == null or _occupied.has(cell):
		return
	var def: Dictionary = Recipes.BUILDING_DEFS[armed_kind]
	if not EconomyManager.try_spend(def.cost):
		return

	var building := BuildingScene.instantiate()
	_buildings_root.add_child(building)
	building.position = Vector2(cell.x * CELL_SIZE + CELL_SIZE / 2.0, cell.y * CELL_SIZE + CELL_SIZE / 2.0)
	building.setup(armed_kind, cell)
	_occupied[cell] = building
