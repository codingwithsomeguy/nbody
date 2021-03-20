tool
extends Node2D

const nbody_manager_script : Script = preload("nbody_manager.gd")
export var nbody_enabled : bool = true
export var trail_enabled : bool = true
export var mass : float = 1.0
export var velocity : Vector2 = Vector2.ZERO
var trail : Line2D
var last_point = Vector2.ZERO
export var line_color = Color(0.4,0.5,1,1)

func get_class_name():
	return "Particle"

func _init():
	trail = Line2D.new()
	trail.set_as_toplevel(true)
	trail.width = 2.0
	trail.z_index -= 1

func _ready():
	trail.default_color = line_color

func _setup_nbody_physics():
	var nbody_manager : Node = Node2D.new()
	nbody_manager.name = "nbody"
	nbody_manager.set_script(nbody_manager_script)
	get_tree().root.call_deferred("add_child", nbody_manager)

func _enter_tree():
	# TODO: need a race-free election system (too slow on adding nodes to root)
	add_to_group("nbody")
	var particles : Array = get_tree().get_nodes_in_group("nbody")
	# trivially elect the first one... maybe
	if len(particles) == 1:
		_setup_nbody_physics()
	if trail_enabled:
		add_child(trail)

func _exit_tree():
	if trail in get_children():
		trail.queue_free()

func _draw():
	if last_point == Vector2.ZERO or self.position.distance_to(last_point) > 12.0:
		if len(trail.points) >= 8192:
			# TODO: do this better (faster to rebuild it?)
			for pt in range(1000):
				trail.remove_point(0)
		trail.add_point(self.position)
		last_point = self.position
