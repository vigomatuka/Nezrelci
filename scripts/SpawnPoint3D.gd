## SpawnPoint3D.gd
## Prikvači na Node3D (ili Marker3D) u svakoj sceni.
## Ime nodea mora se TOČNO podudarati s spawn_id u Teleporter3D skripti.
##
## Primjeri imena:
##   SpawnDefault    ← za inicijalni spawn
##   SpawnFromVeno   ← za dolazak iz veno_mape
##   SpawnFromMario  ← za dolazak iz mario_mape

class_name SpawnPoint3D
extends Node3D
