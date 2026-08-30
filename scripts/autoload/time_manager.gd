extends Node
## Autoload: gère l'horloge de simulation (temps réel avec pause et vitesse x1/x2/x3).

signal speed_changed(speed: int)
signal paused_changed(paused: bool)
signal sim_tick(delta: float)

const TICK_INTERVAL := 1.0 ## secondes de jeu entre deux "sim_tick", à vitesse x1.

var speed: int = 1
var paused: bool = false

var _tick_accumulator := 0.0


func _process(delta: float) -> void:
	if paused:
		return
	_tick_accumulator += delta * speed
	while _tick_accumulator >= TICK_INTERVAL:
		_tick_accumulator -= TICK_INTERVAL
		sim_tick.emit(TICK_INTERVAL)


func set_speed(new_speed: int) -> void:
	speed = clampi(new_speed, 1, 3)
	paused = false
	speed_changed.emit(speed)
	paused_changed.emit(paused)


func toggle_pause() -> void:
	paused = not paused
	paused_changed.emit(paused)
