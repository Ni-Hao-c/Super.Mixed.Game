global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	SetupLiveFireMaps()

	// worker drone model
	PrecacheModel( $"models/robots/aerial_unmanned_worker/aerial_unmanned_worker.mdl" )
	
	// note: this map has no marvin spawns, have to spawn them using idle nodes
	// unused
	//AddSpawnCallback_ScriptName( "worker_drone_spawn", DeckSpawnWorkerDrone )
	AddSpawnCallback_ScriptName( "marvin_idle_node", DeckSpawnMarvinForIdleNode )
	// nessie fix
	AddSpawnCallbackEditorClass( "info_target", "info_move_animation", DeckSpawnNPCForMoveAnimation )
}

/* // unused
void function DeckSpawnWorkerDrone( entity spawnpoint )
{
	entity drone = CreateWorkerDrone( TEAM_UNASSIGNED, spawnpoint.GetOrigin() - < 0, 0, 150 >, spawnpoint.GetAngles() )
	drone.ai.killShotSound = false
	DispatchSpawn( drone )

	// this seems weird for drones
	thread AssaultMoveTarget( drone, spawnpoint )
}
*/

void function DeckSpawnMarvinForIdleNode( entity node )
{
	entity marvin = CreateMarvin( TEAM_UNASSIGNED, node.GetOrigin(), node.GetAngles() )
	marvin.ai.killShotSound = false
	DispatchSpawn( marvin )

	thread AssaultMoveTarget( marvin, node )
}

// nessie fix
void function DeckSpawnNPCForMoveAnimation( entity spawnPoint )
{
	TrySpawnWorkerDroneForPoint( spawnPoint )
}

entity function CreateWorkerDroneForDeck( vector pos, vector angs )
{
	entity drone = CreateWorkerDrone( TEAM_UNASSIGNED, pos, angs )
	drone.ai.killShotSound = false
	DispatchSpawn( drone )

	return drone
}

bool function TrySpawnWorkerDroneForPoint( entity spawnPoint )
{
	bool spawnSucceeded = false

	vector pos = spawnPoint.GetOrigin()
	vector angs = spawnPoint.GetAngles()
	entity dummyDrone = CreateWorkerDroneForDeck( pos, angs )
	if ( spawnPoint.HasKey( "leveled_animation" ) )
	{
		string animation = expect string( spawnPoint.kv.leveled_animation )
		if ( dummyDrone.Anim_HasSequence( animation ) )
		{
			entity drone = CreateWorkerDroneForDeck( pos, angs )
			thread AssaultMoveTarget( drone, spawnPoint )
			spawnSucceeded = true
		}
	}

	if ( IsValid( dummyDrone ) )
		dummyDrone.Destroy()

	return spawnSucceeded
}