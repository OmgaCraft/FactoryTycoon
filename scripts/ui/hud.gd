extends CanvasLayer

const WorkerScript := preload("res://scripts/factory/worker.gd")

@onready var _budget_label: Label = %BudgetLabel
@onready var _time_label: Label = %TimeLabel
@onready var _build_mode_label: Label = %BuildModeLabel

@onready var _pause_button: Button = %PauseButton
@onready var _speed_1: Button = %Speed1Button
@onready var _speed_2: Button = %Speed2Button
@onready var _speed_3: Button = %Speed3Button

@onready var _construct_button: Button = %ConstructButton
@onready var _personnel_button: Button = %PersonnelButton
@onready var _research_toggle_button: Button = %ResearchToggleButton

@onready var _construct_panel: PanelContainer = %ConstructPanel
@onready var _personnel_panel: PanelContainer = %PersonnelPanel
@onready var _research_panel: PanelContainer = %ResearchPanel

@onready var _import_iron_button: Button = %ImportIronButton
@onready var _import_wood_button: Button = %ImportWoodButton
@onready var _press_button: Button = %PressButton
@onready var _carpentry_button: Button = %CarpentryButton
@onready var _assembly_gadget_button: Button = %AssemblyGadgetButton
@onready var _assembly_furniture_button: Button = %AssemblyFurnitureButton
@onready var _export_button: Button = %ExportButton

@onready var _hire_debutant_button: Button = %HireDebutantButton
@onready var _hire_confirme_button: Button = %HireConfirmeButton
@onready var _hire_expert_button: Button = %HireExpertButton
@onready var _worker_list: VBoxContainer = %WorkerList

@onready var _research_label: Label = %ResearchLabel
@onready var _research_progress_label: Label = %ResearchProgressLabel
@onready var _start_research_button: Button = %StartResearchButton

const RESEARCH_ID := "speed_1"

var _factory_grid: Node = null


func _ready() -> void:
	_factory_grid = get_tree().get_first_node_in_group("factory_grid")

	EconomyManager.budget_changed.connect(_on_budget_changed)
	TimeManager.paused_changed.connect(_on_paused_changed)
	TimeManager.speed_changed.connect(_on_speed_changed)
	TimeManager.hour_changed.connect(_on_time_changed)
	TimeManager.day_changed.connect(_on_time_changed)
	WorkerManager.workers_changed.connect(_on_workers_changed)
	ResearchManager.research_progress.connect(_on_research_progress)
	ResearchManager.research_completed.connect(_on_research_completed)

	if _factory_grid:
		_factory_grid.armed_kind_changed.connect(_on_armed_kind_changed)

	_pause_button.pressed.connect(TimeManager.toggle_pause)
	_speed_1.pressed.connect(TimeManager.set_speed.bind(1))
	_speed_2.pressed.connect(TimeManager.set_speed.bind(2))
	_speed_3.pressed.connect(TimeManager.set_speed.bind(3))

	_construct_button.pressed.connect(_on_category_pressed.bind("construct"))
	_personnel_button.pressed.connect(_on_category_pressed.bind("personnel"))
	_research_toggle_button.pressed.connect(_on_category_pressed.bind("research"))

	_setup_build_buttons()

	_hire_debutant_button.pressed.connect(_on_hire_pressed.bind("debutant"))
	_hire_confirme_button.pressed.connect(_on_hire_pressed.bind("confirme"))
	_hire_expert_button.pressed.connect(_on_hire_pressed.bind("expert"))
	_hire_debutant_button.text = _hire_button_text("debutant")
	_hire_confirme_button.text = _hire_button_text("confirme")
	_hire_expert_button.text = _hire_button_text("expert")

	_start_research_button.pressed.connect(_on_start_research)
	var upgrade: Dictionary = ResearchManager.UPGRADES[RESEARCH_ID]
	_research_label.text = "%s\nCoût : %d $ · Durée : %d h" % [upgrade.label, upgrade.cost, upgrade.duration_ticks]

	_on_budget_changed(EconomyManager.budget)
	_on_paused_changed(TimeManager.paused)
	_on_speed_changed(TimeManager.speed)
	_on_time_changed(0)
	_on_armed_kind_changed("")
	_update_research_button()


func _setup_build_buttons() -> void:
	var build_buttons := {
		"import_iron": _import_iron_button,
		"import_wood": _import_wood_button,
		"press": _press_button,
		"carpentry": _carpentry_button,
		"assembly_gadget": _assembly_gadget_button,
		"assembly_furniture": _assembly_furniture_button,
		"export": _export_button,
	}
	for kind in build_buttons.keys():
		var button: Button = build_buttons[kind]
		var def: Dictionary = Recipes.BUILDING_DEFS[kind]
		button.text = "%s (%d $)" % [def.label, def.cost]
		button.pressed.connect(_arm.bind(kind))


func _hire_button_text(tier: String) -> String:
	var def: Dictionary = WorkerManager.SKILL_TIERS[tier]
	return "%s (%d $, %d $/j)" % [def.label, def.hire_cost, def.daily_salary]


func _arm(kind: String) -> void:
	if _factory_grid:
		_factory_grid.set_armed_kind(kind)


func _on_armed_kind_changed(kind: String) -> void:
	if kind == "":
		_build_mode_label.text = "Construction : aucune (choisis un bâtiment)"
	else:
		_build_mode_label.text = "Construction : %s (clic droit ou Échap pour annuler)" % Recipes.BUILDING_DEFS[kind].label


func _on_category_pressed(category: String) -> void:
	var target_visible: bool = false
	match category:
		"construct":
			target_visible = not _construct_panel.visible
		"personnel":
			target_visible = not _personnel_panel.visible
		"research":
			target_visible = not _research_panel.visible

	_construct_panel.visible = false
	_personnel_panel.visible = false
	_research_panel.visible = false
	_construct_button.button_pressed = false
	_personnel_button.button_pressed = false
	_research_toggle_button.button_pressed = false

	match category:
		"construct":
			_construct_panel.visible = target_visible
			_construct_button.button_pressed = target_visible
		"personnel":
			_personnel_panel.visible = target_visible
			_personnel_button.button_pressed = target_visible
			if target_visible:
				_refresh_personnel_panel()
		"research":
			_research_panel.visible = target_visible
			_research_toggle_button.button_pressed = target_visible


func _on_hire_pressed(tier: String) -> void:
	WorkerManager.hire_worker(tier)
	if _personnel_panel.visible:
		_refresh_personnel_panel()


func _refresh_personnel_panel() -> void:
	for child in _worker_list.get_children():
		child.queue_free()

	var assignable: Array = []
	for building in get_tree().get_nodes_in_group("building"):
		if building.needs_worker():
			assignable.append(building)

	for worker in WorkerManager.workers:
		_worker_list.add_child(_build_worker_row(worker, assignable))


func _build_worker_row(worker, assignable: Array) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)

	var name_label := Label.new()
	name_label.text = worker.display_name()
	name_label.custom_minimum_size = Vector2(150, 0)
	row.add_child(name_label)

	var status_label := Label.new()
	status_label.text = _worker_status_text(worker)
	status_label.custom_minimum_size = Vector2(170, 0)
	row.add_child(status_label)

	var assign_option := OptionButton.new()
	assign_option.add_item("Auto (multitâche)")
	assign_option.set_item_metadata(0, null)
	var selected_index := 0
	for i in range(assignable.size()):
		var building = assignable[i]
		assign_option.add_item(building.get_display_name())
		assign_option.set_item_metadata(i + 1, building)
		if worker.assigned_building == building:
			selected_index = i + 1
	assign_option.selected = selected_index
	assign_option.item_selected.connect(_on_worker_assignment_selected.bind(worker, assign_option))
	row.add_child(assign_option)

	var shift_option := OptionButton.new()
	shift_option.add_item("Continu (24h)")
	shift_option.add_item("Jour (6h-18h)")
	shift_option.add_item("Nuit (18h-6h)")
	shift_option.selected = _shift_index(worker)
	shift_option.item_selected.connect(_on_worker_shift_selected.bind(worker))
	row.add_child(shift_option)

	return row


func _worker_status_text(worker) -> String:
	if not worker.is_on_shift():
		return "Repos (hors service)"
	match worker.state:
		WorkerScript.State.OPERATING:
			if worker.assigned_building != null:
				return "Poste : %s" % worker.assigned_building.get_display_name()
			return "En poste"
		WorkerScript.State.CARRYING, WorkerScript.State.WALKING_TO_PICKUP:
			return "Transport en cours"
		WorkerScript.State.WALKING_TO_OPERATE:
			return "En route vers son poste"
		_:
			return "Disponible"


func _shift_index(worker) -> int:
	if worker.shift_start == worker.shift_end:
		return 0
	if worker.shift_start == 6 and worker.shift_end == 18:
		return 1
	return 2


func _on_worker_assignment_selected(index: int, worker, option: OptionButton) -> void:
	var building = option.get_item_metadata(index)
	worker.set_assigned_building(building)
	_refresh_personnel_panel()


func _on_worker_shift_selected(index: int, worker) -> void:
	match index:
		0:
			worker.set_shift(0, 0)
		1:
			worker.set_shift(6, 18)
		2:
			worker.set_shift(18, 6)
	_refresh_personnel_panel()


func _on_start_research() -> void:
	ResearchManager.start_research(RESEARCH_ID)
	_update_research_button()


func _update_research_button() -> void:
	if ResearchManager.completed.has(RESEARCH_ID):
		_start_research_button.text = "Recherche terminée"
		_start_research_button.disabled = true
	elif ResearchManager.active_id == RESEARCH_ID:
		_start_research_button.text = "Recherche en cours..."
		_start_research_button.disabled = true
	else:
		_start_research_button.text = "Lancer la recherche"
		_start_research_button.disabled = not ResearchManager.can_start(RESEARCH_ID)


func _on_research_progress(current: int, total: int) -> void:
	_research_progress_label.text = "Progression : %d / %d h" % [current, total]
	_update_research_button()


func _on_research_completed(_id: String) -> void:
	_research_progress_label.text = "Amélioration active !"
	_update_research_button()


func _on_budget_changed(new_amount: float) -> void:
	_budget_label.text = "Budget : %s $" % _format_amount(new_amount)


func _on_paused_changed(paused: bool) -> void:
	_pause_button.text = "Reprendre" if paused else "Pause"


func _on_speed_changed(speed: int) -> void:
	_speed_1.button_pressed = speed == 1
	_speed_2.button_pressed = speed == 2
	_speed_3.button_pressed = speed == 3


func _on_time_changed(_value) -> void:
	_time_label.text = TimeManager.time_string()


func _on_workers_changed(_count: int) -> void:
	if _personnel_panel.visible:
		_refresh_personnel_panel()


func _format_amount(amount: float) -> String:
	return "%.0f" % amount
