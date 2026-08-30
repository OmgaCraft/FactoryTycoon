extends CanvasLayer

const FactoryGridScript := preload("res://scripts/factory/factory_grid.gd")

@onready var _budget_label: Label = %BudgetLabel
@onready var _hint_label: Label = %HintLabel
@onready var _pause_button: Button = %PauseButton
@onready var _speed_1: Button = %Speed1Button
@onready var _speed_2: Button = %Speed2Button
@onready var _speed_3: Button = %Speed3Button


func _ready() -> void:
	EconomyManager.budget_changed.connect(_on_budget_changed)
	TimeManager.paused_changed.connect(_on_paused_changed)
	TimeManager.speed_changed.connect(_on_speed_changed)

	_pause_button.pressed.connect(TimeManager.toggle_pause)
	_speed_1.pressed.connect(TimeManager.set_speed.bind(1))
	_speed_2.pressed.connect(TimeManager.set_speed.bind(2))
	_speed_3.pressed.connect(TimeManager.set_speed.bind(3))

	_on_budget_changed(EconomyManager.budget)
	_on_paused_changed(TimeManager.paused)
	_on_speed_changed(TimeManager.speed)
	_hint_label.text = "Clique sur la grille pour construire une machine (%d $)" % FactoryGridScript.MACHINE_COST


func _on_budget_changed(new_amount: float) -> void:
	_budget_label.text = "Budget : %s $" % _format_amount(new_amount)


func _on_paused_changed(paused: bool) -> void:
	_pause_button.text = "Reprendre" if paused else "Pause"


func _on_speed_changed(speed: int) -> void:
	_speed_1.button_pressed = speed == 1
	_speed_2.button_pressed = speed == 2
	_speed_3.button_pressed = speed == 3


func _format_amount(amount: float) -> String:
	return "%.0f" % amount
