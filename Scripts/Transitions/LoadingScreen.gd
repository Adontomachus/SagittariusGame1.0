class_name LoadingScreen
extends CanvasLayer

@export var progress_bar: TextureProgressBar
@export var loading_label: Label

var scene_to_load: String = ""
var loader_status: ResourceLoader.ThreadLoadStatus

const PREWARM_SCENES := [
	"res://UnitInstances/Enemy Instances/Enemy.tscn",
	"res://UnitInstances/Enemy Instances/EnemyShooter.tscn",
	"res://UnitInstances/Enemy Instances/EliteEnemy.tscn",
	"res://UnitInstances/Enemy Instances/EnemyCharger.tscn",
	"res://UnitInstances/Enemy Instances/StationaryEnemy.tscn",
	"res://UnitInstances/Enemy Instances/SpawnerEnemy.tscn",
	"res://Objects/Instances With Collision/PrototypeProjectile.tscn",
	"res://Objects/Particle Effects/ShootEffect.tscn",
	"res://Objects/Particle Effects/WallHitEffect.tscn",
	"res://Objects/Particle Effects/UnitHitEffect.tscn"
]

func _ready() -> void:
	if scene_to_load.is_empty():
		push_error("LoadingScreen: scene_to_load was not assigned.")
		queue_free()
		return

	progress_bar.value = 0
	loading_label.text = "Loading..."
	ResourceLoader.load_threaded_request(scene_to_load)

func _process(_delta: float) -> void:
	var progress: Array = []
	loader_status = ResourceLoader.load_threaded_get_status(scene_to_load, progress)

	if progress.size() > 0:
		# Map file loading progress to 0% - 80% of the bar
		progress_bar.value = progress[0] * 80.0

	match loader_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			loading_label.text = "Loading... %d%%" % int(progress_bar.value)

		ResourceLoader.THREAD_LOAD_LOADED:
			progress_bar.value = 85
			loading_label.text = "Prewarming assets..."
			set_process(false) # Pause threaded status checks to run prewarm
			
			var packed_scene := ResourceLoader.load_threaded_get(scene_to_load) as PackedScene
			
			# Run prewarming while loading screen is still visible
			await _prewarm_scenes()
			
			progress_bar.value = 90
			loading_label.text = "Starting..."
			await get_tree().process_frame

			get_tree().change_scene_to_packed(packed_scene)
			queue_free()

		ResourceLoader.THREAD_LOAD_FAILED:
			push_error("LoadingScreen: Failed to load scene: %s" % scene_to_load)
			loading_label.text = "Load Failed!"
			set_process(false)

func _prewarm_scenes() -> void:
	var total_scenes = PREWARM_SCENES.size()
	for i in range(total_scenes):
		var path = PREWARM_SCENES[i]
		var scene := load(path) as PackedScene
		if scene != null:
			var instance := scene.instantiate()
			instance.visible = false
			add_child(instance)
			await get_tree().process_frame
			instance.queue_free()
		
		# Smoothly scale the remaining 15% of the progress bar during prewarm
		progress_bar.value = 85.0 + (float(i + 1) / total_scenes) * 15.0
		await get_tree().process_frame
