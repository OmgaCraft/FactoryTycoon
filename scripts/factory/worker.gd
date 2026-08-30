extends Node2D
class_name Worker
## Ouvrier : soit affecté manuellement à un poste précis par le joueur, soit
## "multitâche" (le WorkerManager le fait alors basculer automatiquement entre
## opérateur de machine et transporteur, selon les besoins de la ligne).

enum State { IDLE, WALKING_TO_OPERATE, OPERATING, WALKING_TO_PICKUP, CARRYING }

const SPEED := 140.0

var worker_id: int = 0
var worker_name: String = ""
var skill_tier: String = ""
var skill_label: String = ""
var skill_multiplier: float = 1.0
var daily_salary: float = 0.0

var assigned_building = null ## Bâtiment choisi manuellement par le joueur, ou null (auto).
var shift_start: int = 0
var shift_end: int = 0 ## shift_start == shift_end -> continu (24h/24).

var state: int = State.IDLE

@onready var _tag: Label = $Tag


func setup(id: int, tier: String, def: Dictionary, display_name: String) -> void:
	worker_id = id
	skill_tier = tier
	skill_label = def.label
	skill_multiplier = def.speed_multiplier
	daily_salary = def.daily_salary
	worker_name = display_name


func display_name() -> String:
	return "%s (%s)" % [worker_name, skill_label]


func set_assigned_building(building) -> void:
	assigned_building = building


func set_shift(start: int, end: int) -> void:
	shift_start = start
	shift_end = end


func is_on_shift() -> bool:
	if shift_start == shift_end:
		return true
	var hour: int = TimeManager.hour
	if shift_start < shift_end:
		return hour >= shift_start and hour < shift_end
	return hour >= shift_start or hour < shift_end


func is_busy() -> bool:
	return state != State.IDLE


func start_operating(building) -> void:
	state = State.WALKING_TO_OPERATE
	_tag.text = "-> poste"
	_move_to(building.global_position, func() -> void:
		state = State.OPERATING
		_tag.text = "OP"
	)


func start_transport(source, dest, resource_id: String) -> void:
	state = State.WALKING_TO_PICKUP
	_tag.text = "-> collecte"
	_move_to(source.global_position, func() -> void:
		state = State.CARRYING
		_tag.text = "livraison"
		_move_to(dest.global_position, func() -> void:
			dest.add_input(resource_id)
			state = State.IDLE
			_tag.text = ""
		)
	)


func _move_to(target: Vector2, on_arrive: Callable) -> void:
	var dist := global_position.distance_to(target)
	var duration: float = max(0.15, dist / SPEED)
	var tween := create_tween()
	tween.tween_property(self, "global_position", target, duration)
	tween.finished.connect(on_arrive, CONNECT_ONE_SHOT)
