/*
= DSDamNum ====================================================

	The visual damage number.

===============================================================
*/
class DSDamNum : Actor {
	int dur;
	double offset;
	
	const FADE_DUR = 0.2;
	
	property Duration : dur;
	
	Default {
		-SOLID;
		+NOCLIP;
		+NOBLOCKMAP;
		+NOBLOCKMONST;
		+NOTRIGGER;
		+NOINTERACTION;
		+THRUACTORS;
		+BRIGHT;
		+NOTONAUTOMAP;
		+FORCEXYBILLBOARD;
		
		RenderStyle							"Translucent";
		Alpha								1.0;
		Gravity								0.3;
		
		DSDamNum.Duration					15;
	}
	
	States {
		List:
			_NDL A -1; // Doom Large
			_NDS A -1; // Doom Small
			_NHL A -1; // Hexen Large
			_NHS A -1; // Hexen Small
			_NSN A -1; // Strife
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
		// Fade out and destroy after duration
		if (dur > 0) {
			dur--;
		} else {
			A_FadeOut(FADE_DUR);
		}
	}
}

/*
= DSDamTrack ==================================================

	Tracks damage dealt to shootable actors.

===============================================================
*/
class DSDamTrack : Inventory {
	int spawnheight;
	
	int damage;
	string damageType;
	Actor attacker;
	
	override void PostBeginPlay() {
		Super.PostBeginPlay();
		if (owner) {
			// Set spawnheight for damage numbers
			spawnheight = owner.default.height;
		}
	}
	
	override void Tick() {
		Super.Tick();
		// Destroy if there is no owner
		if (!owner) { Destroy(); }
		// If damage is detected, spawn damage numbers
		if (damage > 0) {
			if (dn_enabled && attacker is "PlayerPawn") {
				SpawnDamageNumbers();
			}
			
			// Reset for next processing
			damage = 0;
			damageType = '';
			attacker = null;
		}
	}
	
	void SetTrack(WorldEvent e) {
		damage += e.Damage;
		damageType = e.DamageType;
		attacker = e.DamageSource;
	}
	
	protected void SpawnDamageNumbers() {
		// Get the int ID of the font CVar or return if none exists
		int id = Actor.GetSpriteIndex(dn_font);
		if (id == -1) { return; }
		
		// Convert damage value to string
		String str = String.Format("%i", damage);
		
		// Set color translation based on mode
		name col = "White";
		switch (dn_mode) {
			case 0: // Resistance
				int facDam = 15;
				int fac = owner.ApplyDamageFactor(damageType, facDam);
				col = dn_color_neutral;
				if (fac > facDam) { col = dn_color_strong; }
				if (fac < facDam) { col = dn_color_weak; }
				break;
			case 1: // Types
				DSDamNumEvent ev = DSDamNumEvent(StaticEventHandler.Find("DSDamNumEvent"));
				if (ev) { col = ev.ColorTypes.Get(damageType); }
				break;
			case 2: // Color
				col = dn_color_manual;
				break;
		}
		
		// Spawn damage numbers
		Array<Actor> nArray;
		double nSize;
		double rand = 3.5;
		vector3 nPos = (0, fRandom(-Radius/rand, Radius/rand), (spawnheight * 0.85) + fRandom(-Radius/rand, Radius/rand));
		vector2 nVel = (fRandom(-45, 45), -45);
		for (int i = 0; i < str.CodePointCount(); i++) {
			Actor n = Spawn("DSDamNum", owner.pos + nPos);
			// Face previous attacker
			n.A_Face(attacker);
			// Set number velocity
			n.Vel3DFromAngle(2.5, n.angle + nVel.x, n.pitch + nVel.y);
			// Set sprite id
			n.sprite = id;
			// Set sprite frame
			int num = str.Mid(i, 1).ToInt(0);
			n.frame = num;
			// Set sprite translation
			//n.translation = Translation.GetID("Red");
			n.A_SetTranslation(col);
			// Set sprite scale
			n.A_SetScale(dn_scale, dn_scale);
			// Get the TextureID of the current sprite
			string texStr = String.Format("%s%c0", dn_font, 65 + num);
			TextureID nTex = TexMan.CheckForTexture(texStr);
			// Get size of the sprite
			int sizeX, sizeY; [sizeX, sizeY] = TexMan.GetSize(nTex);
			// Shift sprite offset
			double off = nSize * dn_scale;
			Console.printf("%d", nSize);
			n.A_SpriteOffset(off, 0);
			DSDamNum(n).offset = off;
			// Add width to total size
			nSize += sizeX;
			// Add number to array
			nArray.Push(n);
		}
		
		// Shift sprites back toward center point
		foreach (n : nArray) {
			if (n) {
				n.A_SpriteOffset(DSDamNum(n).offset + -(nSize/2), 0);
			}
		}
	}
	
}

