extends Node
## Autoload: secteur générique (V1) — plusieurs matières premières, plusieurs
## chaînes de production en parallèle, plusieurs produits finis avec leur propre
## tarif de vente. À terme, remplacé/complété par des ressources par secteur
## (voir data/sectors/).

const MAX_STOCK := 6

## sell_price présent uniquement sur les ressources vendables (produits finis).
const RESOURCES := {
	"iron_ore": {"name": "Minerai de fer"},
	"wood": {"name": "Bois"},
	"iron_part": {"name": "Pièce métallique"},
	"wood_part": {"name": "Pièce en bois"},
	"gadget": {"name": "Gadget électronique", "sell_price": 110.0},
	"furniture": {"name": "Meuble", "sell_price": 165.0},
}

## input_resource/output_resource: "" = aucune (source ou puits de la chaîne).
## "export" accepte n'importe quelle ressource vendable (input_resource == "").
const BUILDING_DEFS := {
	"import_iron": {
		"label": "Import Fer",
		"cost": 100.0,
		"color": Color(0.58, 0.58, 0.6),
		"input_resource": "",
		"output_resource": "iron_ore",
		"process_hours": 2,
		"needs_worker": false,
		"is_source": true,
		"is_sink": false,
	},
	"import_wood": {
		"label": "Import Bois",
		"cost": 100.0,
		"color": Color(0.55, 0.36, 0.2),
		"input_resource": "",
		"output_resource": "wood",
		"process_hours": 2,
		"needs_worker": false,
		"is_source": true,
		"is_sink": false,
	},
	"press": {
		"label": "Presse",
		"cost": 220.0,
		"color": Color(0.3, 0.55, 0.85),
		"input_resource": "iron_ore",
		"output_resource": "iron_part",
		"process_hours": 3,
		"needs_worker": true,
		"is_source": false,
		"is_sink": false,
	},
	"carpentry": {
		"label": "Menuiserie",
		"cost": 220.0,
		"color": Color(0.75, 0.6, 0.35),
		"input_resource": "wood",
		"output_resource": "wood_part",
		"process_hours": 3,
		"needs_worker": true,
		"is_source": false,
		"is_sink": false,
	},
	"assembly_gadget": {
		"label": "Atelier Gadgets",
		"cost": 320.0,
		"color": Color(0.85, 0.25, 0.35),
		"input_resource": "iron_part",
		"output_resource": "gadget",
		"process_hours": 4,
		"needs_worker": true,
		"is_source": false,
		"is_sink": false,
	},
	"assembly_furniture": {
		"label": "Atelier Meubles",
		"cost": 320.0,
		"color": Color(0.35, 0.75, 0.4),
		"input_resource": "wood_part",
		"output_resource": "furniture",
		"process_hours": 4,
		"needs_worker": true,
		"is_source": false,
		"is_sink": false,
	},
	"export": {
		"label": "Export",
		"cost": 150.0,
		"color": Color(0.9, 0.75, 0.2),
		"input_resource": "",
		"output_resource": "",
		"process_hours": 1,
		"needs_worker": false,
		"is_source": false,
		"is_sink": true,
	},
}
