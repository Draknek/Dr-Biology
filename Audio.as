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
		
		public static const MUSIC_VOLUME:Number = 0.8;
		
		public static function startMusic ():void
		{
			music = new Sfx(Sfx_music);
			music.loop(MUSIC_VOLUME);
			
			rewind = new Sfx(Sfx_rewind);
			rewind.loop(0.0);
		}
		
		public static function play (sound:String):void
		{
			var volume:Number = 0.4;
			
			if (sound == "split") volume = 0.1;
			if (sound == "yay2") volume = 1.0;
			if (sound == "button_click") volume = 0.5;
			
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
		private static var rewindTween2:Tween;
		private static var rewindPlaying:Boolean = false;
		
		public static function startRewind ():void
		{
			if (rewindPlaying) return;
			if (rewindTween) rewindTween.cancel();
			if (rewindTween2) rewindTween2.cancel();
			
			rewindTween = FP.tween(rewind, {volume: 1.2}, 6);
			rewindTween2 = FP.tween(music, {volume: 0.0}, 6);
			
			rewindPlaying = true;
		}
		
		public static function stopRewind ():void
		{
			if (! rewindPlaying) return;
			if (rewindTween) rewindTween.cancel();
			if (rewindTween2) rewindTween2.cancel();
			
			rewindTween = FP.tween(rewind, {volume: 0}, 30);
			rewindTween2 = FP.tween(music, {volume: MUSIC_VOLUME}, 90);
			
			rewindPlaying = false;
		}
		
	}
}
