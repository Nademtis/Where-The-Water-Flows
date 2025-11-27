extends Area2D
class_name ItemInHand

@onready var item_float_pos: Node2D = $itemFloatPos
@onready var item_deposit_pos: Node2D = $itemDepositPos

@onready var item_pickup_sfx: AudioStreamPlayer2D = $itemPickupSFX
@onready var item_drop_sfx: AudioStreamPlayer2D = $itemDropSFX
@onready var item_drop_pos_visuals: Sprite2D = $itemDropPosVisuals

var item_in_hand : Item = null
var potential_item_to_pickup : Item = null

func _ready() -> void:
	Events.connect("player_use", maybe_pickup_item)
	Events.connect("player_drop", maybe_drop_item)
	item_drop_pos_visuals.visible = false
	
func _on_area_entered(area: Area2D) -> void:
	var potential_item : Node = area.get_parent()
	
	if potential_item.is_in_group("item"):
		var item : Item = potential_item
		potential_item_to_pickup = item
		
		if item_in_hand == null:
			item.interact_indicator.show_indicator()
		

		
func maybe_pickup_item() -> void:
	if item_in_hand:
		print("allready has item returning")
		return
	
	if potential_item_to_pickup:
		item_in_hand = potential_item_to_pickup
		
		potential_item_to_pickup.interact_indicator.hide_indicator()
		# reparent to player (ItemInHand node is already a child of player)
		#item_in_hand.
		item_in_hand.reparent(self)
		
		item_drop_pos_visuals.visible = true
		
		# tween local_position towards the float anchor
		item_in_hand.pick_up(item_float_pos.position)
		item_pickup_sfx.play()

func maybe_drop_item() -> void:
	if item_in_hand:
		# detach from player before tweening
		var item : Item = item_in_hand
		
		#item.reparent(get_tree().current_scene)
		item.reparent(item.original_parent)
		item_drop_sfx.play()

		item.drop(item_deposit_pos.global_position)
		item_drop_pos_visuals.visible = false
		
		item_in_hand = null

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("item"):
		#var potential_item : Node = area.get_parent()
		if potential_item_to_pickup and !item_in_hand:
			potential_item_to_pickup.interact_indicator.hide_indicator()
		
		potential_item_to_pickup = null
