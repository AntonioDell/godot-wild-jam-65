extends VBoxContainer

@onready var rocket_type_option_button = %RocketTypeOptionButton
@onready var rocket_decimal_based_params = %RocketDecimalBasedParams
@onready var rocket_step_based_params = %RocketStepBaasedParams

func _ready():
	rocket_type_option_button.item_selected.connect(_on_rocket_type_selected)
	
func _on_rocket_type_selected(index: int):
	if index == 0:
		rocket_decimal_based_params.show()
		rocket_step_based_params.hide()
	elif index == 1:
		rocket_decimal_based_params.hide()
		rocket_step_based_params.show()
