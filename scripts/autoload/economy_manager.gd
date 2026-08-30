extends Node
## Autoload: trésorerie de l'usine. Point d'entrée unique pour toute variation de budget
## (production, salaires, entretien, achats...) une fois ces systèmes ajoutés.

signal budget_changed(new_amount: float)

const STARTING_BUDGET := 10000.0

var budget: float = STARTING_BUDGET


func add_funds(amount: float) -> void:
	budget += amount
	budget_changed.emit(budget)


func try_spend(amount: float) -> bool:
	if amount > budget:
		return false
	budget -= amount
	budget_changed.emit(budget)
	return true
