extends CharacterBody3D

#References
@export var head: Node3D
@export var standingCollision: CollisionShape3D
@export var crouchingCollision: CollisionShape3D
@export var head_raycast: RayCast3D

#Velocity
var currentSpeed = 3.0

#Input
var direction = Vector3.ZERO
@export var walkingSpeed = 5.0
@export var sprintingSpeed = 8.0
@export var crouchingSpeed = 2.0
@export var jumpVelocity = 3.5
@export var mouseSens = 0.25

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	crouchingCollision.disabled = true

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouseSens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouseSens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	#Movement States
	#Crouching
	if Input.is_action_pressed("crouch"):
		currentSpeed = crouchingSpeed
		head.position.y = lerp(head.position.y, 1.0, delta*8)
		standingCollision.disabled = true
		crouchingCollision.disabled = false
	elif !head_raycast.is_colliding():
		head.position.y = lerp(head.position.y, 1.65, delta*8)
		standingCollision.disabled = false
		crouchingCollision.disabled = true
		
	#Sprinting
		if Input.is_action_pressed("sprint"):
			currentSpeed = sprintingSpeed
		else:
			currentSpeed = walkingSpeed

	#Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpVelocity

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*10)
	if direction:
		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, currentSpeed)
		velocity.z = move_toward(velocity.z, 0, currentSpeed)

	move_and_slide()
