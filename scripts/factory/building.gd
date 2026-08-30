extends Node2D
## Bâtiment générique de la chaîne de production (Import / Machine / Export).
## Le comportement est piloté par sa définition dans Recipes.BUILDING_DEFS, et
## les ressources échangées sont identifiées par leur id (string), pas par un
## simple numéro d'étape : ça permet plusieurs chaînes de production en parallèle.

var kind: String = ""
var cell: Vector2i
var input_stock: int = 0
var output_stock: int = 0
var operator = null ## Worker en poste, si needs_worker() est vrai.
var total_processed: int = 0
var total_revenue: float = 0.0

var _def: Dictionary = {}
var _process_progress := 0

@onready var _visual: Polygon2D = $Visual
@onready var _label: Label = $Label
@onready var _stock_label: Label = $StockLabel


func setup(building_kind: String, grid_cell: Vector2i) -> void:
	kind = building_kind
	cell = grid_cell
	_def = Recipes.BUILDING_DEFS[kind]
	_visual.color = _def.color
	_label.text = _def.label
	_update_stock_label()


func _ready() -> void:
	add_to_group("building")
	TimeManager.sim_tick.connect(_on_sim_tick)


func get_display_name() -> String:
	return "%s (%d,%d)" % [_def.get("label", kind), cell.x, cell.y]


func needs_worker() -> bool:
	return _def.get("needs_worker", false)


func is_source() -> bool:
	return _def.get("is_source", false)


func is_sink() -> bool:
	return _def.get("is_sink", false)


func input_resource() -> String:
	return _def.get("input_resource", "")


func output_resource() -> String:
	return _def.get("output_resource", "")


func accepts_resource(resource_id: String) -> bool:
	if is_sink():
		return Recipes.RESOURCES.get(resource_id, {}).has("sell_price")
	return input_resource() == resource_id


func can_accept_input() -> bool:
	if is_sink():
		return true
	return input_resource() != "" and input_stock < Recipes.MAX_STOCK


func take_output() -> void:
	output_stock -= 1
	_update_stock_label()


func add_input(resource_id: String) -> void:
	if is_sink():
		var price: float = Recipes.RESOURCES.get(resource_id, {}).get("sell_price", 0.0)
		EconomyManager.add_funds(price)
		total_processed += 1
		total_revenue += price
		_pulse()
		_update_stock_label()
		return
	input_stock += 1
	_update_stock_label()


func _on_sim_tick(_delta: float) -> void:
	if _def.is_empty():
		return
	if is_source():
		_process_source()
	elif not is_sink():
		_process_machine()


func _process_source() -> void:
	if output_stock >= Recipes.MAX_STOCK:
		return
	_process_progress += 1
	if _process_progress >= int(_def.process_hours):
		_process_progress = 0
		output_stock += 1
		_pulse()
		_update_stock_label()


func _process_machine() -> void:
	if operator == null or not operator.is_on_shift():
		return
	if input_stock <= 0 or output_stock >= Recipes.MAX_STOCK:
		return
	_process_progress += 1
	var mult: float = ResearchManager.machine_speed_multiplier() * float(operator.skill_multiplier)
	var required: int = max(1, int(round(int(_def.process_hours) * mult)))
	if _process_progress >= required:
		_process_progress = 0
		input_stock -= 1
		output_stock += 1
		total_processed += 1
		_pulse()
		_update_stock_label()


func _update_stock_label() -> void:
	var parts: Array = []
	if input_resource() != "":
		parts.append("In:%d" % input_stock)
	if is_source() or output_resource() != "":
		parts.append("Out:%d" % output_stock)
	if is_sink():
		parts.append("Vendus:%d" % total_processed)
		parts.append("%.0f $" % total_revenue)
	if needs_worker():
		parts.append("Op:%s" % ("oui" if operator != null else "non"))
	_stock_label.text = "\n".join(parts)


func _pulse() -> void:
	var tween := create_tween()
	tween.tween_property(_visual, "scale", Vector2(1.15, 1.15), 0.08)
	tween.tween_property(_visual, "scale", Vector2(1.0, 1.0), 0.12)
