// Damage Numbers
class DamageNumberEvent : EventHandler {
	override void WorldThingDamaged (WorldEvent e) {
		Actor t = e.Thing;
		Actor s = e.DamageSource;
		
		// Don't spawn if PlayerPawn is damaged
		if (t is "PlayerPawn") { return; }
		// Don't spawn if source is not from a PlayerPawn
		if (!(s is "PlayerPawn")) { return; }
		
		// Check if CVar is enabled for player
		CVar damEnabled = CVar.GetCVar("dn_enabled", s.player);
		
		if (damEnabled.GetBool()) {
			// Get font toggle
			CVar font = CVar.GetCVar("dn_font", s.player);
			// Get font scale
			CVar scale = CVar.GetCVar("dn_scale", s.player);
			// Get font translations
			CVar colN = CVar.GetCVar("dn_color_neutral", s.player);
			CVar colS = CVar.GetCVar("dn_color_strong", s.player);
			CVar colW = CVar.GetCVar("dn_color_weak", s.player);
			
			// Get the int ID of the font CVar or return if none exists
			int id = Actor.GetSpriteIndex(font.GetString());
			if (id == -1) { return; }
			
			// Convert damage value to string
			String str = String.Format("%i", e.Damage);
			
			// Check damage factor for effectiveness
			int facCheck = 15;
			int fac = t.ApplyDamageFactor(e.DamageType, facCheck);
			string col = colN.GetString();
			if (fac > facCheck) { col = colS.GetString(); }
			if (fac < facCheck) { col = colW.GetString(); }
			
			// Spawn damage numbers
			Array<Actor> nArray;
			double nSize;
			double rand = 3.5;
			vector3 nPos = (0, fRandom(-t.Radius/rand, t.Radius/rand), t.height/2 + fRandom(-t.Radius/rand, t.Radius/rand));
			vector2 nVel = (fRandom(-45, 45), -45);
			for (int i = 0; i < str.CodePointCount(); i++) {
				Actor n = Actor.Spawn("DSDamNum", t.pos + nPos);
				// Face toward player
				n.A_Face(s);
				// Set number velocity
				n.Vel3DFromAngle(2, n.angle + nVel.x, n.pitch + nVel.y);
				// Set sprite id
				n.sprite = id;
				// Set sprite frame
				int num = str.Mid(i, 1).ToInt(0);
				n.frame = num;
				// Set sprite translation
				n.translation = Translation.GetID(col);
				// Set sprite scale
				n.A_SetScale(scale.GetFloat(), scale.GetFloat());
				// Get the TextureID of the current sprite
				string texStr = String.Format("%s%c0", font.GetString(), 65 + num);
				TextureID nTex = TexMan.CheckForTexture(texStr);
				// Get size of the sprite
				int sizeX, sizeY; [sizeX, sizeY] = TexMan.GetSize(nTex);
				// Shift sprite offset
				double off = (sizeX * scale.GetFloat()) * i;
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
}