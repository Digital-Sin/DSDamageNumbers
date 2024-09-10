class DSDamNum : Actor {
	int dur;
	double offset;
	
	property Duration : dur;
	
	Default {
		+NOCLIP;
		+NOBLOCKMAP;
		+NOBLOCKMONST;
		+NOTRIGGER;
		+NOINTERACTION;
		+THRUACTORS;
		+BRIGHT;
		+NOTONAUTOMAP;
		+FORCEXYBILLBOARD;
		
		DSDamNum.Duration					35;
		
		RenderStyle							"Translucent";
		Gravity								0.3;
	}
	
	States {
		List:
			_NDS A -1; // Doom Small
		Spawn:
			#### A -1;
			Stop;
		Death:
			Stop;
	}
	
	override void Tick() {
		Super.Tick();
		// Apply gravity
		vel.z -= Gravity;
		// Destroy after duration
		if (dur > 0) { dur--; } else { Destroy(); }
	}
}