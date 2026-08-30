extends Node
## Autoload: recrutement, compétences et affectation des ouvriers.
## Sans affectation manuelle, un ouvrier est "multitâche" : priorité à un poste
## d'opérateur libre, sinon transport entre bâtiments compatibles. Avec une
## affectation manuelle (choisie par le joueur), il rejoint ce poste précis et
## attend qu'il se libère plutôt que de basculer sur autre chose.

signal workers_changed(count: int)
signal salary_charged(amount: float)

const WorkerScene := preload("res://scenes/factory/Worker.tscn")

const FIRST_NAMES := ["Alex", "Sam", "Léa", "Noah", "Emma", "Louis", "Chloé", "Hugo", "Manon", "Nathan"]

const SKILL_TIERS := {
	"debutant": {"label": "Débutant", "hire_cost": 150.0, "daily_salary": 40.0, "speed_multiplier": 1.0},
	"confirme": {"label": "Confirmé", "hire_cost": 280.0, "daily_salary": 65.0, "speed_multiplier": 0.8},
	"expert": {"label": "Expert", "hire_cost": 450.0, "daily_salary": 100.0, "speed_multiplier": 0.6},
}

var workers: Array = []

var _workers_root: Node2D = null
var _next_worker_id := 1


func register_workers_root(root: Node2D) -> void:
	_workers_root = root


func _ready() -> void:
	TimeManager.sim_tick.connect(_on_sim_tick)
	TimeManager.day_changed.connect(_on_day_changed)


func hire_worker(tier: String) -> bool:
	if _workers_root == null or not SKILL_TIERS.has(tier):
		return false
	var def: Dictionary = SKILL_TIERS[tier]
	if not EconomyManager.try_spend(def.hire_cost):
		return false

	var worker = WorkerScene.instantiate()
	_workers_root.add_child(worker)
	worker.global_position = _workers_root.global_position
	var display_name: String = "%s #%d" % [FIRST_NAMES[_next_worker_id % FIRST_NAMES.size()], _next_worker_id]
	worker.setup(_next_worker_id, tier, def, display_name)
	_next_worker_id += 1

	workers.append(worker)
	workers_changed.emit(workers.size())
	return true


func _on_day_changed(_day: int) -> void:
	if workers.is_empty():
		return
	var total := 0.0
	for worker in workers:
		total += float(worker.daily_salary)
	EconomyManager.add_funds(-total)
	salary_charged.emit(total)


func _on_sim_tick(_delta: float) -> void:
	_assign_jobs()


func _assign_jobs() -> void:
	var buildings := get_tree().get_nodes_in_group("building")
	for worker in workers:
		if not worker.is_on_shift():
			continue
		if worker.is_busy():
			continue
		if worker.assigned_building != null:
			_try_operate_assigned(worker)
			continue
		if _try_assign_operator(worker, buildings):
			continue
		_try_assign_transport(worker, buildings)


func _try_operate_assigned(worker) -> void:
	var building = worker.assigned_building
	if not is_instance_valid(building):
		worker.set_assigned_building(null)
		return
	if building.operator == null:
		building.operator = worker
		worker.start_operating(building)


func _try_assign_operator(worker, buildings: Array) -> bool:
	for building in buildings:
		if building.needs_worker() and building.operator == null:
			building.operator = worker
			worker.start_operating(building)
			return true
	return false


func _try_assign_transport(worker, buildings: Array) -> bool:
	var best_source = null
	var best_dest = null
	var best_dist := INF

	for source in buildings:
		var resource_id: String = source.output_resource()
		if resource_id == "" or source.output_stock <= 0:
			continue
		for dest in buildings:
			if dest == source:
				continue
			if not dest.accepts_resource(resource_id):
				continue
			if not dest.can_accept_input():
				continue
			var dist: float = source.global_position.distance_to(dest.global_position)
			if dist < best_dist:
				best_dist = dist
				best_source = source
				best_dest = dest

	if best_source == null:
		return false

	var resource_id: String = best_source.output_resource()
	best_source.take_output()
	worker.start_transport(best_source, best_dest, resource_id)
	return true
