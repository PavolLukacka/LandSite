# Koštanty pre stom

# Hlbka stromu
const MAX_TREE_DEPTH := 9
# Na koľko zaspí vlákno v nano sekundách µs.
const THREAD_DELAY := 5000
# vertexový okraj pri jednotlivých čiastkach planety
const BORDER_SIZE := 1
# kolko vrcholov bude ponorených
const BORDER_DIP := 0.8
# minimalna velkosť
const MIN_SIZE := 1.0/pow(2, MAX_TREE_DEPTH)
# Definicia min vzdialenosti
const MIN_DISTANCE := 4.0
# Toto sa násoby z noize hodnotou tak aby sa mohli dobre ovládať vrcholy Simplex noizu
const MIN_MAX_APPROXIMATION := 0.6
# 4 kvadranty
const MAX_LEAVES := 4
# Ofset pre nodes
const LEAF_OFFSETS := [
	Vector2(-1, -1),
	Vector2(-1, 1),
	Vector2(1, -1),
	Vector2(1, 1),
]
# 6 strán kocky v poli tak aby mohli byť normalizované
const DIRECTIONS: Array = [
	Vector3.FORWARD,
	Vector3.BACK,
	Vector3.UP,
	Vector3.DOWN,
	Vector3.LEFT,
	Vector3.RIGHT,
]
