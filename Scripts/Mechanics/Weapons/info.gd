extends Node

@export var weapon: Node
@export var on_mag: Label
@export var on_inv: Label

func _process(delta: float) -> void:
	if weapon:
		on_mag.text = str(weapon.municion_actual)
		on_inv.text = str(weapon.municion_inventario)
