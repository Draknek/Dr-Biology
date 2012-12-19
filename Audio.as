package
{
	import net.flashpunk.*;
	
	public class Audio
	{
		[Embed(source="audio/split.mp3")] public static const Sfx_split:Class;
		[Embed(source="audio/yay.mp3")] public static const Sfx_yay:Class;
		[Embed(source="audio/nope.mp3")] public static const Sfx_nope:Class;
		
		//[Embed(source="audio/split2.mp3")] public static const Sfx_split2:Class;
		[Embed(source="audio/yay2.mp3")] public static const Sfx_yay2:Class;
		
		[Embed(source="audio/music.mp3")] public static const Sfx_music:Class;
		[Embed(source="audio/rewind.mp3")] public static const Sfx_rewind:Class;
		
		[Embed(source="audio/button-click.mp3")] public static const Sfx_button_click:Class;
		//[Embed(source="audio/button-hover.mp3")] public static const Sfx_button_hover:Class;
		
		private static var sounds:Object = {};
		
		public static var music:Sfx;
		public static var rewind:Sfx;
		
		public static function startMusic ():void
		{
			music = new Sfx(Sfx_music);
			music.loop();
			
			rewind = new Sfx(Sfx_rewind);
			rewind.loop(0.0);
		}
		
		public static function play (sound:String):void
		{
			var volume:Number = 0.4;
			
			if (sound == "split") volume = 0.1;
			if (sound == "yay2") volume = 1.0;
			
			if (! sounds[sound]) {
				var embed:Class = Audio["Sfx_" + sound];
				
				if (embed) {
					sounds[sound] = new Sfx(embed);
				} else {
					sounds[sound] = true;
				}
			}
			
			if (sounds[sound] is Sfx) {
				sounds[sound].play(volume);
			}
			
			if (sound == "yay") return;
			
			sound += "2";
			
			if (sound == "yay2") {
				volume = 1.0;
			} else if (sound == "split2") {
				volume = 0.1;
			}
			
			if (! sounds[sound]) {
				embed = Audio["Sfx_" + sound];
				
				if (embed) {
					sounds[sound] = new Sfx(embed);
				} else {
					sounds[sound] = true;
				}
			}
			
			if (sounds[sound] is Sfx) {
				sounds[sound].play(volume);
			}
		}
		
		private static var rewindTween:Tween;
		private static var rewindPlaying:Boolean = false;
		
		public static function startRewind ():void
		{
			if (rewindPlaying) return;
			if (rewindTween) rewindTween.cancel();
			rewindTween = FP.tween(rewind, {volume: 1.0}, 6);
			rewindPlaying = true;
			FP.tween(music, {volume: 0.5}, 6);
		}
		
		public static function stopRewind ():void
		{
			if (! rewindPlaying) return;
			if (rewindTween) rewindTween.cancel();
			rewindPlaying = false;
			rewindTween = FP.tween(rewind, {volume: 0}, 30);
			FP.tween(music, {volume: 1.0}, 10);
		}
		
	}
}
