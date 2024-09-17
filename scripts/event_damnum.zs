/*
= DSDamNumEvent ===============================================

	The event to manage the spawning of damage numbers.

===============================================================
*/
class DSDamNumEvent : EventHandler {
	override void WorldThingSpawned(WorldEvent e) {
		// Give an instance of DSDamTrack to all applicable actors
		Actor t = e.Thing;
		if (t.bIsMonster) { t.GiveInventory("DSDamTrack", 1); }
	}
	
	override void WorldThingDamaged(WorldEvent e) {
		// Pass WorldEvent to DSDamTrack
		Actor t = e.Thing;
		DSDamTrack track = DSDamTrack(t.FindInventory("DSDamTrack"));
		if (track) { track.SetTrack(e); }
	}
}

/*
= DSDamNumUtil ================================================

	The static event for accessing color types.

===============================================================
*/
class DSDamNumUtil : StaticEventHandler {
	Map<String, String> ColorTypes;
	override void OnRegister() {
		// ColorTypes.Insert("DamageType", "Color");
	}
}