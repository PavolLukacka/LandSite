tool
class_name WorkerThread
extends Thread
# Reprezentuje kazdeho jedneho pracovnika, zadá mu úlohu, a potom ho spracováva QUEUE

const Const := preload("../constants.gd") # preload konštant

var semaphore: Semaphore
var queue: Reference

#inicializácia
func _init(var job_queue: Reference):
	self.queue = job_queue
	self.semaphore = job_queue.semaphore
	start(self, "work")


# zadanie ulohy pre vlákna 
func work(userdata = null):
	while true:
		semaphore.wait()   # čaká queue
		var job: TerrainJob = queue.fetch_job()
		if job:
			job.run()
		else:
			break   
