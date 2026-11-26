extends Node2D

const ENEMIES: Dictionary = {
	"basic_shooter": {
		"scene": preload("res://enemies/ranged/shooters/basic_shooter.tscn"),
		"title": "Basic shooter",
		"text": "Fires a single bullet. Its ability increases firing speed, movement speed and grants death immunity",
		"melee": false
	},
	"spread_shooter": {
		"scene": preload("res://enemies/ranged/shooters/spread_shooter.tscn"),
		"title": "Spread shooter",
		"text": "Fires a fan of bullets. Every third shot, the bullet split into more bullets!",
		"melee": false
	},
	"sniper_shooter": {
		"scene": preload("res://enemies/ranged/shooters/sniper_shooter.tscn"),
		"title": "Sniper",
		"text": "Fires a slow, heavy shot. Its ability makes the shots home and pierce.",
		"melee": false
	},
	"burst_shooter": {
		"scene": preload("res://enemies/ranged/shooters/burst_shooter.tscn"),
		"title": "Burst shooter",
		"text": "Fires a short burst. Its ability adds another shot to the burst, every attack has a 10% chance to activate the ability.",
		"melee": false
	},
	"smite_shooter": {
		"scene": preload("res://enemies/ranged/shooters/smite_shooter.tscn"),
		"title": "Smite shooter",
		"text": "Fires bullets, then marks the ground. The mark explodes after a short delay.",
		"melee": false
	},
	"lazer_enemy": {
		"scene": preload("res://enemies/ranged/lazer_enemy.tscn"),
		"title": "Lazer",
		"text": "Aims a beam along its weapon. The beam hits whatever is in that line.",
		"melee": false
	},
	"aoe_dot_shooter": {
		"scene": preload("res://enemies/ranged/aoe_dot_shooter.tscn"),
		"title": "Pool shooter",
		"text": "Throws a shot that leaves a damaging pool where it lands.",
		"melee": false
	},
	"bomber": {
		"scene": preload("res://enemies/ranged/bomber.tscn"),
		"title": "Bomber",
		"text": "Lobs a bomb that grows and shrinks in flight, then explodes. Its ability is a larger bomb with a one second fuse.",
		"melee": false
	},
	"suicide_bomber": {
		"scene": preload("res://enemies/special/suicide_bomber.tscn"),
		"title": "Suicide bomber",
		"text": "Runs in and explodes. It cannot be possessed.",
		"melee": true
	},
	"hammer_enemy": {
		"scene": preload("res://enemies/melee/hammer_enemy.tscn"),
		"title": "Hammer",
		"text": "Swings a hammer. Its ability raises the hammer and slams, stunning anyone in the yellow circle.",
		"melee": true
	},
	"katana_enemy": {
		"scene": preload("res://enemies/melee/katana_enemy.tscn"),
		"title": "Katana",
		"text": "A fast sword swing that causes bleeding. It's ability enhances the next attack to deal double damage. On kill: instantly refreshes ability.",
		"melee": true
	},
	"jump_melee": {
		"scene": preload("res://enemies/melee/jump_melee.tscn"),
		"title": "Jumper",
		"text": "Swings up close. Its ability leaps into the air and slams down, stunning whoever it lands on.",
		"melee": true
	},
	"reflect_enemy": {
		"scene": preload("res://enemies/melee/reflect_enemy.tscn"),
		"title": "Reflector",
		"text": "A melee fighter. Its ability turns incoming shots around.",
		"melee": true
	},
	"spike_enemy": {
		"scene": preload("res://enemies/melee/spike_enemy.tscn"),
		"title": "Spike ball",
		"text": "Rolls across the room and bounces off walls. Touching it hurts.",
		"melee": false
	},
	"boulder_enemy": {
		"scene": preload("res://enemies/ranged/boulder_enemy.tscn"),
		"title": "Boulder thrower",
		"text": "Throws a slow rock that knocks the target back. Its ability charges a larger rock that rolls through a whole crowd.",
		"melee": false
	},
	"clone_enemy": {
		"scene": preload("res://enemies/melee/clone_enemy.tscn"),
		"title": "Clone",
		"text": "Swings in melee. Its ability splits off a copy of itself.",
		"melee": true
	},
	"mage_enemy": {
		"scene": preload("res://enemies/special/mage_enemy.tscn"),
		"title": "Mage",
		"text": "Keeps its distance and summons imps.",
		"melee": false
	},
	"paladin_enemy": {
		"scene": preload("res://enemies/melee/paladin_enemy.tscn"),
		"title": "Paladin",
		"text": "Swings a sword. Its ability raises a barrier and switches to a heavier blade.",
		"melee": true
	}
}

var current_enemy: Enemy
var current_id: String = ""

@onready var enemy_list: ItemList = $CanvasLayer/Panel/enemy_list
@onready var description: Label = $CanvasLayer/Panel/description

func _ready() -> void:
	var shown: Array[String] = []
	
	# Until the save exists, make the if statement obselte
	#If you dont understand that then lowkey u dumb ash
	for enemy_id in ENEMIES:
		if enemy_id in PlayerInfo.discovered:
			#shown.append(enemy_id)
			pass
		shown.append(enemy_id)
		
	shown.sort()
	
	for enemy_id in shown:
		enemy_list.add_item(ENEMIES[enemy_id]["title"])
		enemy_list.set_item_metadata(enemy_list.item_count - 1, enemy_id)
		
	if enemy_list.item_count > 0:
		enemy_list.select(0)
		_on_enemy_selected(0)

func _on_enemy_selected(index: int) -> void:
	current_id = enemy_list.get_item_metadata(index)
	description.text = ENEMIES[current_id]["title"] + "\n\n" + ENEMIES[current_id]["text"]
	_spawn_preview(ENEMIES[current_id]["scene"])

func _spawn_preview(packed: PackedScene) -> void:
	_clear_preview()
	current_enemy = packed.instantiate()
	current_enemy.position = Vector2(-120, 0)
	add_child(current_enemy)
	# _ready() already set this enemy's own speed. Ranged enemies hold still and shoot.
	# Melee enemies keep that speed and walk in until they are close enough to swing.
	if not ENEMIES[current_id]["melee"]:
		current_enemy.speed = 0
	# Stops enemies that cast their ability by themselves. The button turns this off.
	current_enemy.get_node("ability_cooldown").start(9999)

## Drops the previous enemy and anything it left in the room: shots, rocks, pools, beams, summons, damage numbers.
func _clear_preview() -> void:
	var keep: Array[String] = ["Camera2D", "dummy", "CanvasLayer", "walls"]
	for child in get_children():
		if child.name not in keep:
			child.queue_free()
	_clear_root_effects()
	_clear_root_effects.call_deferred()

func _clear_root_effects() -> void:
	for node in get_tree().root.get_children():
		if node == self:
			continue
		if node.is_in_group("projectile") or node.is_in_group("enemy_bullet"):
			node.queue_free()
		elif node.name in ["aoe_dot", "lazer", "damage_ui", "smite_area"]:
			node.queue_free()

func _on_ability_button_pressed() -> void:
	if not is_instance_valid(current_enemy):
		return
	current_enemy.get_node("ability_cooldown").stop()
	current_enemy.get_node("ability_active").stop()
	current_enemy.emit_signal("ability")

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
