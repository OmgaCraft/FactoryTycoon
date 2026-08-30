extends Node
## Autoload: horloge de simulation en jours/heures (pas juste des "ticks" abstraits),
## avec pause et vitesse x1/x2/x3. Permet de payer les employés à la journée et de
## leur donner des horaires (voir Worker.shift_start/shift_end).

signal speed_changed(speed: int)
signal paused_changed(paused: bool)
signal sim_tick(delta: float) ## émis à chaque heure de jeu écoulée.
signal hour_changed(hour: int)
signal day_changed(day: int)

const HOURS_PER_DAY := 24
const SECONDS_PER_GAME_HOUR := 4.0 ## à vitesse x1, 1h de jeu = 4s réelles (1 jour ~ 96s).

var speed: int = 1
var paused: bool = false
var day: int = 1
var hour: int = 8

var _hour_accumulator := 0.0


func _process(delta: float) -> void:
	if paused:
		return
	_hour_accumulator += delta * speed
	while _hour_accumulator >= SECONDS_PER_GAME_HOUR:
		_hour_accumulator -= SECONDS_PER_GAME_HOUR
		_advance_hour()


func _advance_hour() -> void:
	hour += 1
	if hour >= HOURS_PER_DAY:
		hour = 0
		day += 1
		day_changed.emit(day)
	hour_changed.emit(hour)
	sim_tick.emit(SECONDS_PER_GAME_HOUR)


func set_speed(new_speed: int) -> void:
	speed = clampi(new_speed, 1, 3)
	paused = false
	speed_changed.emit(speed)
	paused_changed.emit(paused)


func toggle_pause() -> void:
	paused = not paused
	paused_changed.emit(paused)


func time_string() -> String:
	return "Jour %d - %02dh00" % [day, hour]
