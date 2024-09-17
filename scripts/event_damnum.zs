/*
= DSDamNumEvent ===============================================

	The event to manage the spawning of damage numbers.

===============================================================
*/
class DSDamNumEvent : StaticEventHandler {
	Map<String, String> ColorTypes;
	override void OnRegister() {
		// ColorTypes.Insert("DamageType", "Color");
	}
	
	override void WorldThingDamaged(WorldEvent e) {
		// Pass WorldEvent to DSDamTrack
		Actor t = e.Thing;
		t.GiveInventory("DSDamTrack", 1);
		DSDamTrack track = DSDamTrack(t.FindInventory("DSDamTrack"));
		if (track) { track.SetTrack(e); }
	}
}