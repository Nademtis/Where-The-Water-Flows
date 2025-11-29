extends Node2D
class_name ElevatorParticles
@onready var cpu_particles_2d_2: CPUParticles2D = $CPUParticles2D2

func _ready() -> void:
	cpu_particles_2d_2.emitting = false

func start_emit() -> void:
	cpu_particles_2d_2.emitting = true

func stop_emit() -> void:
	cpu_particles_2d_2.emitting = false
	
