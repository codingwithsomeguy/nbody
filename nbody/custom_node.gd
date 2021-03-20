tool
extends EditorPlugin

const nbody_manager_script : Script = preload("nbody_manager.gd")

func _enter_tree():
	add_custom_type("Particle", "Node2D", preload("Particle.gd"), preload("icon.png"))

func _exit_tree():
	remove_custom_type("Particle")
