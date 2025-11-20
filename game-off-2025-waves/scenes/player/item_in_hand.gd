extends Area2D
class_name ItemInHand

@onready var item_float_pos: Node2D = $itemFloatPos
@onready var item_deposit_pos: Node2D = $itemDepositPos

var item_in_hand : Item
var potential_item_to_pickup : Item

func _ready() -> void:
	Events.connect("player_use", maybe_pickup_item)
	Events.connect("player_drop", maybe_drop_item)
	
func _process(_delta: float) -> void:
	if item_in_hand:
		item_in_hand.global_position = item_float_pos.global_position

func _on_area_entered(area: Area2D) -> void:
	var potential_item : Node = area.get_parent()
	if potential_item.is_in_group("item"):
		var item : Item = potential_item
		potential_item_to_pickup = item



func maybe_pickup_item() -> void:
	if potential_item_to_pickup:
		item_in_hand = potential_item_to_pickup
		item_in_hand.pick_up(item_float_pos.global_position)
		
		#potential_item_to_pickup = null

func maybe_drop_item() -> void:
	if item_in_hand:
		item_in_hand.drop(item_deposit_pos.global_position)
		item_in_hand = null

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("item"):
		potential_item_to_pickup = null
		print("cannot pickup item")
