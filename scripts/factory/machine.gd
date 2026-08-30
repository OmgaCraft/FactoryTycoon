extends Node2D
## Machine placeholder : produit une valeur vendue automatiquement à chaque cycle.
## Sera remplacée par un vrai système de recettes/intrants-extrants.

const REVENUE_PER_CYCLE := 25.0
const CYCLES_TO_PRODUCE := 4 ## nombre de sim_tick avant une production.

@onready var _visual: Polygon2D = $Visual

var _cycles_elapsed := 0


func _ready() -> void:
	TimeManager.sim_tick.connect(_on_sim_tick)


func _on_sim_tick(_delta: float) -> void:
	_cycles_elapsed += 1
	if _cycles_elapsed >= CYCLES_TO_PRODUCE:
		_cycles_elapsed = 0
		_produce()


func _produce() -> void:
	EconomyManager.add_funds(REVENUE_PER_CYCLE)
	_pulse()


func _pulse() -> void:
	var tween := create_tween()
	tween.tween_property(_visual, "scale", Vector2(1.15, 1.15), 0.1)
	tween.tween_property(_visual, "scale", Vector2(1.0, 1.0), 0.15)
