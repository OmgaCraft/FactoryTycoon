extends Node
## Autoload: RD minimale mais fonctionnelle — une amélioration achetable qui prend
## du temps (ticks de simulation) avant de s'appliquer. Base à étendre en arbre tech.

signal research_progress(current: int, total: int)
signal research_completed(id: String)

const UPGRADES := {
	"speed_1": {
		"label": "Machines plus rapides (-25% temps de cycle)",
		"cost": 400.0,
		"duration_ticks": 10,
		"speed_multiplier": 0.75,
	},
}

var completed: Dictionary = {}
var active_id: String = ""

var _progress_ticks := 0


func _ready() -> void:
	TimeManager.sim_tick.connect(_on_sim_tick)


func can_start(id: String) -> bool:
	return UPGRADES.has(id) and not completed.has(id) and active_id == ""


func start_research(id: String) -> bool:
	if not can_start(id):
		return false
	var def: Dictionary = UPGRADES[id]
	if not EconomyManager.try_spend(def.cost):
		return false
	active_id = id
	_progress_ticks = 0
	research_progress.emit(0, def.duration_ticks)
	return true


func machine_speed_multiplier() -> float:
	var mult := 1.0
	for id in completed.keys():
		mult *= float(UPGRADES[id].get("speed_multiplier", 1.0))
	return mult


func _on_sim_tick(_delta: float) -> void:
	if active_id == "":
		return
	_progress_ticks += 1
	var def: Dictionary = UPGRADES[active_id]
	research_progress.emit(_progress_ticks, def.duration_ticks)
	if _progress_ticks >= def.duration_ticks:
		completed[active_id] = true
		research_completed.emit(active_id)
		active_id = ""
