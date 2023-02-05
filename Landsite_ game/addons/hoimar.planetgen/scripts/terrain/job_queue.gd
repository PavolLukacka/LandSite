tool
class_name JobQueue

# Balancing zátaže, správa vlákien atd...

const Const := preload("../constants.gd")
enum STATE {WORKING, IDLE, CLEANING_UP, CLEANED_UP}

signal all_finished

# Ziskaj informáciu či je dostupné aspon jedno vlákno
var _num_workers: int = max(1, OS.get_processor_count())
var _state: int = STATE.IDLE
var _state_mutex := Mutex.new()
var queued_jobs := []   # Ulohy ktoré boli odoslané na procesing
var queue_mutex := Mutex.new()
var processing_jobs := []   # Ulohy ktoré sa aktuálne spracovávavajú
var _worker_pool := []
var _logger := Logger.get_for(self)
var semaphore:= Semaphore.new()


func _init():
	for i in _num_workers:
		_worker_pool.append(WorkerThread.new(self))


func is_working() -> bool:
	if _state == STATE.WORKING or _state == STATE.CLEANING_UP:
		return true
	else:
		return false


# Vráť totálnu hodnotu (počet) prác ktoré sa teraz vakonávajú
func get_number_of_jobs() -> int:
	return queued_jobs.size() + processing_jobs.size()


func get_jobs_for(var planet: Planet) -> Array:
	var result := []
	queue_mutex.lock()   # Ošetrenie
	for job in queued_jobs:
		if job.get_data().settings.get_planet() == planet:
			result.append(job)
	for job in processing_jobs:
		if job.get_data().settings.get_planet() == planet:
			result.append(job)
	queue_mutex.unlock()
	return result


func update_state():
	if _state == STATE.CLEANING_UP or _state == STATE.CLEANED_UP:
		return
	_state_mutex.lock()
	if queued_jobs.empty() and processing_jobs.empty():
		_state = STATE.IDLE
		call_deferred("emit_signal", "all_finished")   # Thread-safe.
	else:
		_state = STATE.WORKING
	_state_mutex.unlock()


# Add a new job to the queue.
func queue(var job: TerrainJob):
	if _state == STATE.CLEANING_UP:
		return
	queue_mutex.lock()
	queued_jobs.append(job)
	queue_mutex.unlock()
	job.connect("job_finished", self, "on_job_finished")
	semaphore.post()   # Najbližšie vlákno si zoberie danú úlohu.
	update_state()


# Pop a vráť ulohu z queue
func fetch_job() -> TerrainJob:
	if queued_jobs.empty():
		return null   # Ošetrenie možného stavú
	var job: TerrainJob
	queue_mutex.lock()
	job = queued_jobs.pop_front()
	processing_jobs.append(job)
	queue_mutex.unlock()
	update_state()
	return job


func on_job_finished(var job: TerrainJob, var patch: TerrainPatch):
	queue_mutex.lock()
	processing_jobs.erase(job)
	queue_mutex.unlock()
	update_state()


# Ošetrenie prác a upratanie
func clean_up():
	if _state == STATE.CLEANING_UP or _state == STATE.CLEANED_UP:
		return
	_clean_jobs_and_workers()


func _clean_jobs_and_workers():
	# Uprav status 
	_state_mutex.lock()
	_state = STATE.CLEANING_UP
	_state_mutex.unlock()
	queue_mutex.lock()
	queued_jobs.clear()   # Free na všetky práce
	queue_mutex.unlock()
	
	yield(self, "all_finished")
	# Spij všetky vlánka a pridaj do poolu
	for worker in _num_workers:
		semaphore.post()   # Posledný cyklus
	while !_worker_pool.empty():
		var worker: WorkerThread = _worker_pool.pop_front()
		if worker.is_active():
			worker.wait_to_finish()
	
	_state = STATE.CLEANED_UP
