extends Node2D

@onready var _workers_root: Node2D = $Workers


func _ready() -> void:
	WorkerManager.register_workers_root(_workers_root)
