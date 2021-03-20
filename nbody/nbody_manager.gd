extends Node

const G = 6.67
const TOO_SMALL_R = 0.01

var physics_ticks_per_frame = 0
var initial_frame = true

func _init():
	set_process(true)

func _enter_tree():
	pass

func _exit_tree():
	pass

func calc_force(b1 : Node2D, b2 : Node2D) -> Array:
	# need r anyway for the final fvec calculation
	var r = b1.position.distance_to(b2.position)
	if r < TOO_SMALL_R:
		print("nbody error: r is less than ", TOO_SMALL_R)

	# use 1e18 as a rough conversion to screen pixel space units
	#var rsquared = b1.position.distance_squared_to(b2.position)
	var rsquared = r * r
	var f = G * b1.mass * b2.mass / rsquared
	
	var delta_pos = b2.position - b1.position
	var fvec = f * (delta_pos / r)

	return fvec

func move_bodies(particles : Array, delta : float):
	if len(particles) < 2:
		print("nbody info: not enough particles to move: ", len(particles))
		return

	var particle_forces = []
	for i in range(len(particles)):
		particle_forces.append(Vector2.ZERO)

	# TODO: using the naive n^2 algo between all particles for now
	# build the summed forces on each particle
	for i in range(len(particles)):
		for j in range(i + 1, len(particles)):
			var b1 : Node2D = particles[i]
			var b2 : Node2D = particles[j]
			var f = calc_force(b1, b2)
			particle_forces[i] += f
			particle_forces[j] += -1 * f

	# apply the summed forces on each particle
	for i in range(len(particles)):
		var f = particle_forces[i]
		var p = particles[i]
		p.velocity = p.velocity + (delta * (f / p.mass))
		p.position = p.position + (p.velocity * delta)
		p.update()

func _get_active_particles() -> Array:
	var particles : Array = []
	for particle in get_tree().get_nodes_in_group("nbody"):
		if particle.nbody_enabled:
			particles.append(particle)
	return particles

# bespoke _physics_process
func _process(delta):
	var particles = _get_active_particles()

	# applying multiple physics ticks in the initial frames causes artifacts
	if initial_frame:
		initial_frame = false
		move_bodies(particles, delta)
	else:
		for x in range(physics_ticks_per_frame):
			move_bodies(particles, delta)
